import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Supabase yapılandırması eksik')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Zamanı gelmiş bildirimleri al
    const { data: notifications, error: notificationsError } = await supabase
      .from('notifications')
      .select(`
        *,
        fcm_tokens!inner(token)
      `)
      .eq('is_sent', false)
      .lte('scheduled_time', new Date().toISOString())

    if (notificationsError) {
      throw notificationsError
    }

    if (!notifications || notifications.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'Gönderilecek bildirim yok' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // Her bildirim için FCM'e istek gönder
    const sendPromises = notifications.map(async (notification) => {
      const token = notification.fcm_tokens.token

      // send-notifications fonksiyonunu çağır
      const response = await fetch(
        `${supabaseUrl}/functions/v1/send-notifications`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${supabaseServiceKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            token,
            title: notification.title,
            body: notification.body,
            scheduled_time: notification.scheduled_time,
          }),
        }
      )

      const result = await response.json()

      if (result.success) {
        // Bildirimi gönderildi olarak işaretle
        await supabase
          .from('notifications')
          .update({ is_sent: true })
          .eq('id', notification.id)
      }

      return result
    })

    const results = await Promise.all(sendPromises)

    return new Response(
      JSON.stringify({ success: true, results }),
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