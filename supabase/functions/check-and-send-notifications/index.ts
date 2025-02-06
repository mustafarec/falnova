// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

console.log('Bildirim kontrol servisi başlatıldı...')

// Firebase Admin SDK yapılandırması
const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
if (!serviceAccountStr) {
  throw new Error('FIREBASE_SERVICE_ACCOUNT ortam değişkeni bulunamadı')
}

const serviceAccount = JSON.parse(serviceAccountStr)

// Supabase istemcisini oluştur
const supabaseUrl = Deno.env.get('SUPABASE_URL')
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error('Supabase yapılandırması eksik')
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function getAccessToken() {
  try {
    const jwtHeader = {
      alg: 'RS256',
      typ: 'JWT',
      kid: serviceAccount.private_key_id
    }

    const now = Math.floor(Date.now() / 1000)
    const jwtClaimSet = {
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600,
      iat: now
    }

    // PEM formatındaki özel anahtarı temizle
    const privateKey = serviceAccount.private_key
      .replace(/\\n/g, '\n')
      .replace('-----BEGIN PRIVATE KEY-----\n', '')
      .replace('\n-----END PRIVATE KEY-----', '')

    // Base64'ten binary'ye çevir
    const binaryKey = Uint8Array.from(atob(privateKey), c => c.charCodeAt(0))

    const encoder = new TextEncoder()
    const headerString = JSON.stringify(jwtHeader)
    const payloadString = JSON.stringify(jwtClaimSet)
    const headerBase64 = btoa(headerString)
    const payloadBase64 = btoa(payloadString)
    const signatureInput = `${headerBase64}.${payloadBase64}`

    // RSA-SHA256 imzalama
    const key = await crypto.subtle.importKey(
      'pkcs8',
      binaryKey,
      {
        name: 'RSASSA-PKCS1-v1_5',
        hash: 'SHA-256',
      },
      false,
      ['sign']
    )

    const signature = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      key,
      encoder.encode(signatureInput)
    )

    const signatureBase64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    const jwt = `${headerBase64}.${payloadBase64}.${signatureBase64}`

    // Token al
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    })

    const tokenData = await tokenResponse.json()
    return tokenData.access_token
  } catch (error) {
    console.error('Access token alınırken hata:', error)
    throw error
  }
}

async function sendFCMNotification(token: string, title: string, body: string) {
  try {
    const accessToken = await getAccessToken()

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: token,
            notification: {
              title: title,
              body: body,
            },
            android: {
              priority: 'high',
              notification: {
                sound: 'default',
                priority: 'high',
                channelId: 'high_importance_channel',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          },
        }),
      }
    )

    if (!response.ok) {
      const errorData = await response.text()
      throw new Error(`FCM isteği başarısız: ${response.status} - ${errorData}`)
    }

    return await response.json()
  } catch (error) {
    console.error('FCM bildirimi gönderilirken hata:', error)
    throw error
  }
}

serve(async (req) => {
  // CORS için OPTIONS isteğini işle
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Supabase istemcisini oluştur
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Gönderilmemiş ve zamanı gelmiş bildirimleri al
    const { data: notifications, error: notificationsError } = await supabaseClient
      .from('notifications')
      .select(`
        id,
        user_id,
        type,
        title,
        body,
        scheduled_time
      `)
      .eq('is_sent', false)
      .lte('scheduled_time', new Date().toISOString())

    if (notificationsError) {
      throw notificationsError
    }

    if (!notifications || notifications.length === 0) {
      return new Response(
        JSON.stringify({ message: 'Gönderilecek bildirim bulunamadı' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // FCM token'larını al
    const { data: fcmTokens, error: fcmTokensError } = await supabaseClient
      .from('fcm_tokens')
      .select('user_id, token')
      .in(
        'user_id',
        notifications.map((n) => n.user_id)
      )

    if (fcmTokensError) {
      throw fcmTokensError
    }

    // Token'ları kullanıcı ID'sine göre grupla
    const tokensByUserId = fcmTokens.reduce((acc, curr) => {
      acc[curr.user_id] = curr.token
      return acc
    }, {})

    // Firebase Admin SDK'yı başlat
    const firebaseConfig = {
      projectId: Deno.env.get('FIREBASE_PROJECT_ID'),
      privateKey: Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
      clientEmail: Deno.env.get('FIREBASE_CLIENT_EMAIL'),
    }

    // Her bildirim için FCM isteği gönder
    const sendPromises = notifications.map(async (notification) => {
      const token = tokensByUserId[notification.user_id]
      if (!token) {
        console.log(`Token bulunamadı: ${notification.user_id}`)
        return
      }

      try {
        // FCM isteği gönder
        const fcmResponse = await fetch(
          'https://fcm.googleapis.com/v1/projects/' +
            firebaseConfig.projectId +
            '/messages:send',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${await getAccessToken(firebaseConfig)}`,
            },
            body: JSON.stringify({
              message: {
                token: token,
                notification: {
                  title: notification.title,
                  body: notification.body,
                },
                data: {
                  type: notification.type,
                  notificationId: notification.id,
                },
              },
            }),
          }
        )

        if (!fcmResponse.ok) {
          throw new Error(
            `FCM isteği başarısız: ${fcmResponse.status} ${fcmResponse.statusText}`
          )
        }

        // Bildirimi gönderildi olarak işaretle
        const { error: updateError } = await supabaseClient
          .from('notifications')
          .update({ is_sent: true })
          .eq('id', notification.id)

        if (updateError) {
          throw updateError
        }

        console.log(`Bildirim gönderildi: ${notification.id}`)
      } catch (error) {
        console.error(
          `Bildirim gönderme hatası (${notification.id}):`,
          error.message
        )
      }
    })

    await Promise.all(sendPromises)

    return new Response(
      JSON.stringify({ message: 'Bildirimler başarıyla işlendi' }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Hata:', error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

// Firebase access token'ı al
async function getAccessToken(config: {
  clientEmail: string
  privateKey: string
}) {
  const jwt = await new jose.SignJWT({
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  })
    .setExpirationTime('1h')
    .setIssuedAt()
    .setIssuer(config.clientEmail)
    .setAudience('https://oauth2.googleapis.com/token')
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .sign(await importPKCS8(config.privateKey, 'RS256'))

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })

  const data = await response.json()
  return data.access_token
} 