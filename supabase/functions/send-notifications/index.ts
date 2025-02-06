// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Firebase Admin SDK yapılandırması
const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')
if (!serviceAccountStr) {
  throw new Error('FIREBASE_SERVICE_ACCOUNT ortam değişkeni bulunamadı')
}

let serviceAccount
try {
  serviceAccount = JSON.parse(serviceAccountStr)
  console.log('Service account yüklendi:', {
    project_id: serviceAccount.project_id,
    client_email: serviceAccount.client_email
  })
} catch (error) {
  console.error('Service account parse hatası:', error)
  throw new Error('FIREBASE_SERVICE_ACCOUNT geçerli bir JSON değil')
}

async function getAccessToken() {
  if (!serviceAccount.private_key) {
    throw new Error('private_key bulunamadı')
  }

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
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { token, title, body, scheduled_time } = await req.json()

    if (!token || !title || !body || !scheduled_time) {
      throw new Error('Eksik parametreler')
    }

    // Planlanan zamanı kontrol et
    const scheduledTime = new Date(scheduled_time)
    const now = new Date()

    // Access token al
    const accessToken = await getAccessToken()

    // FCM API'ye istek gönder
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

    const result = await response.json()

    return new Response(
      JSON.stringify({ success: true, result }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Hata:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/send-notifications' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
