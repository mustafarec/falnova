import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'
import * as jose from 'https://deno.land/x/jose@v4.14.4/index.ts'

console.log('Zamanlanmış bildirim servisi başlatıldı...')

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    console.log('Zamanlanmış bildirimleri kontrol ediyorum...')
    console.log('Supabase URL:', Deno.env.get('SUPABASE_URL'))
    console.log('Firebase Project ID:', Deno.env.get('FIREBASE_PROJECT_ID'))

    const now = new Date()
    const currentTime = now.toISOString()
    const startOfMinute = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), 0, 0).toISOString()
    
    console.log('İstek alındı. Şu anki zaman:', currentTime)
    console.log('Dakika başlangıcı:', startOfMinute)

    // Son bir dakika içinde gönderilmiş bildirimleri kontrol et
    const { data: recentNotifications, error: recentError } = await supabaseClient
      .from('notifications')
      .select('user_id, type')
      .gte('created_at', startOfMinute)
      .eq('is_sent', true)

    if (recentError) {
      console.error('Son bildirimler kontrol edilirken hata:', recentError)
      throw recentError
    }

    // Kullanıcı ve bildirim tipi bazında son gönderimler
    const recentSent = new Set(
      recentNotifications?.map(n => `${n.user_id}-${n.type}`) || []
    )

    // Kullanıcıların bildirim ayarlarını al
    const { data: notificationSettings, error: settingsError } = await supabaseClient
      .from('notification_settings')
      .select('user_id, coffee_reminder_time, horoscope_reminder_time')

    if (settingsError) {
      console.error('Bildirim ayarları alınırken hata:', settingsError)
      throw settingsError
    }

    // Şu anki saat ve dakikayı al (yerel saat)
    const currentHour = now.getHours().toString().padStart(2, '0')
    const currentMinute = now.getMinutes().toString().padStart(2, '0')
    const currentTimeString = `${currentHour}:${currentMinute}`

    console.log('Şu anki saat:', currentTimeString)

    // Zamanı gelen bildirimleri oluştur
    const notifications = []
    for (const settings of notificationSettings) {
      // Kahve falı hatırlatması
      if (settings.coffee_reminder_time && 
          settings.coffee_reminder_time.includes(currentTimeString) &&
          !recentSent.has(`${settings.user_id}-coffee_reminder`)) {
        notifications.push({
          user_id: settings.user_id,
          title: 'Kahve Falı Zamanı',
          body: 'Kahve falınıza baktırmak ister misiniz?',
          type: 'coffee_reminder',
          is_sent: false,
          scheduled_time: currentTime,
          data: { type: 'coffee_reminder' }
        })
      }

      // Burç yorumu hatırlatması
      if (settings.horoscope_reminder_time && 
          settings.horoscope_reminder_time.includes(currentTimeString) &&
          !recentSent.has(`${settings.user_id}-horoscope_reminder`)) {
        notifications.push({
          user_id: settings.user_id,
          title: 'Günlük Burç Yorumunuz',
          body: 'Bugün yıldızlar sizin için ne diyor?',
          type: 'horoscope_reminder',
          is_sent: false,
          scheduled_time: currentTime,
          data: { type: 'horoscope_reminder' }
        })
      }
    }

    console.log('Oluşturulan bildirimler:', notifications)

    if (notifications.length === 0) {
      console.log('Gönderilecek bildirim bulunamadı')
      return new Response(
        JSON.stringify({ message: 'Gönderilecek bildirim bulunamadı' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // Bildirimleri veritabanına kaydet ve ID'leri al
    const { data: insertedNotifications, error: insertError } = await supabaseClient
      .from('notifications')
      .insert(notifications)
      .select()

    if (insertError) {
      console.error('Bildirimler kaydedilirken hata:', insertError)
      throw insertError
    }

    if (!insertedNotifications) {
      console.error('Bildirimler kaydedildi ama ID\'ler alınamadı')
      throw new Error('Bildirimler kaydedildi ama ID\'ler alınamadı')
    }

    console.log('Kaydedilen bildirimler:', insertedNotifications)

    // FCM token'larını al
    const { data: fcmTokens, error: fcmTokensError } = await supabaseClient
      .from('fcm_tokens')
      .select('user_id, token')
      .in(
        'user_id',
        insertedNotifications.map((n) => n.user_id)
      )

    if (fcmTokensError) {
      console.error('FCM token\'ları alınırken hata:', fcmTokensError)
      throw fcmTokensError
    }

    // Token'ları kullanıcı ID'sine göre grupla
    const tokensByUserId = fcmTokens.reduce((acc, curr) => {
      acc[curr.user_id] = curr.token
      return acc
    }, {})

    // Firebase yapılandırması
    const firebaseConfig = {
      projectId: Deno.env.get('FIREBASE_PROJECT_ID'),
      clientEmail: Deno.env.get('FIREBASE_CLIENT_EMAIL'),
      privateKey: Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
    }

    if (!firebaseConfig.projectId || !firebaseConfig.privateKey || !firebaseConfig.clientEmail) {
      console.error('Firebase yapılandırması eksik:', {
        projectId: !!firebaseConfig.projectId,
        privateKey: !!firebaseConfig.privateKey,
        clientEmail: !!firebaseConfig.clientEmail,
      })
      throw new Error('Firebase yapılandırması eksik')
    }

    // Her bildirim için FCM isteği gönder
    const sendPromises = insertedNotifications.map(async (notification) => {
      const token = tokensByUserId[notification.user_id]
      if (!token) {
        console.log(`Token bulunamadı: ${notification.user_id}`)
        return
      }

      try {
        console.log(`Bildirim gönderiliyor. ID: ${notification.id}`)
        console.log('Bildirim detayları:', {
          id: notification.id,
          token,
          title: notification.title,
          body: notification.body,
        })

        // Access token al
        const accessToken = await getAccessToken(firebaseConfig)
        console.log('Access token alındı')

        // FCM isteği gönder
        const fcmResponse = await fetch(
          `https://fcm.googleapis.com/v1/projects/${firebaseConfig.projectId}/messages:send`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              message: {
                token,
                notification: {
                  title: notification.title,
                  body: notification.body,
                },
                data: {
                  type: notification.data.type,
                  notificationId: notification.id,
                },
                android: {
                  priority: 'high',
                  notification: {
                    sound: 'default',
                    channel_id: 'default',
                    notification_priority: 'PRIORITY_HIGH'
                  }
                },
                apns: {
                  headers: {
                    'apns-priority': '10',
                  },
                  payload: {
                    aps: {
                      alert: {
                        title: notification.title,
                        body: notification.body,
                      },
                      sound: 'default',
                      badge: 1,
                      content_available: true,
                      priority: 10,
                    }
                  }
                }
              }
            })
          }
        )

        const fcmResponseText = await fcmResponse.text()
        console.log('FCM yanıtı:', fcmResponseText)

        if (!fcmResponse.ok) {
          console.error(`FCM isteği başarısız: ${fcmResponseText}`)
          throw new Error(`FCM isteği başarısız: ${fcmResponseText}`)
        }

        console.log(`FCM isteği başarılı: ${notification.id}`)

        // Bildirimi gönderildi olarak işaretle
        const { error: updateError } = await supabaseClient
          .from('notifications')
          .update({ is_sent: true })
          .eq('id', notification.id)

        if (updateError) {
          console.error(`Bildirim durumu güncellenirken hata: ${notification.id}`, updateError)
          throw updateError
        }

        console.log(`Bildirim başarıyla gönderildi ve güncellendi: ${notification.id}`)
      } catch (error) {
        console.error(`Bildirim gönderilirken hata: ${notification.id}`, error)
      }
    })

    await Promise.all(sendPromises)

    return new Response(
      JSON.stringify({ 
        message: 'Bildirimler başarıyla işlendi',
        count: notifications.length
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Genel hata:', error)
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
  try {
    const now = Math.floor(Date.now() / 1000)
    const hour = 60 * 60

    const payload = {
      iss: config.clientEmail,
      sub: config.clientEmail,
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + hour,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
    }

    console.log('JWT payload hazırlandı')

    const privateKey = config.privateKey
    const alg = 'RS256'

    const jwt = await new jose.SignJWT(payload)
      .setProtectedHeader({ alg })
      .sign(await jose.importPKCS8(privateKey, alg))

    console.log('JWT token oluşturuldu')

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

    const { access_token } = await tokenResponse.json()
    console.log('Access token alındı')

    return access_token
  } catch (error) {
    console.error('Access token alınırken hata:', error)
    throw error
  }
}