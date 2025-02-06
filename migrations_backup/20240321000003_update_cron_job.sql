-- Önce eski cron job'ı sil
SELECT cron.unschedule('check-scheduled-notifications');

-- Yeni cron job'ı oluştur
SELECT cron.schedule(
  'check-scheduled-notifications',
  '* * * * *',
  $$
  BEGIN
    PERFORM net.http_post(
      url:='https://mrnrusxbpvazlpuifhjp.functions.supabase.co/check-scheduled-notifications',
      headers:=format(
        '{"Content-Type": "application/json", "Authorization": "Bearer %s"}',
        (SELECT secret_value FROM vault.secrets WHERE name = 'service_role_key' LIMIT 1)
      )::jsonb
    );
  END;
  $$
); 