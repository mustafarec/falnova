import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

serve(async (req) => {
  try {
    const { fortune_id } = await req.json()
    
    // Durumu processing'e çek
    await supabase
      .from('fortune_readings')
      .update({ status: 'processing' })
      .eq('uuid', fortune_id)
    
    // Rastgele bekleme süresi (1-10 dakika)
    const waitTime = Math.floor(Math.random() * 9 + 1) * 60000
    await new Promise(resolve => setTimeout(resolve, waitTime))
    
    // Fal sonucunu completed yap
    await supabase
      .from('fortune_readings')
      .update({ 
        status: 'completed',
        completed_at: new Date().toISOString()
      })
      .eq('uuid', fortune_id)
    
    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    // Hata durumunda failed'a çek
    if (req.json().fortune_id) {
      await supabase
        .from('fortune_readings')
        .update({ status: 'failed' })
        .eq('uuid', req.json().fortune_id)
    }
    
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})