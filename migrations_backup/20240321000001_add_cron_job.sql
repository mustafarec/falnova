-- Create cron job for checking scheduled notifications
SELECT cron.schedule(
  'check-scheduled-notifications', -- job name
  '* * * * *',                    -- every minute
  $$
  SELECT net.http_post(
    url:='https://mrnrusxbpvazlpuifhjp.functions.supabase.co/check-scheduled-notifications',
    headers:='{"Content-Type": "application/json", "Authorization": "Bearer ' || current_setting('app.settings.service_role_key', true) || '"}'
  ) AS request_id;
  $$
); 