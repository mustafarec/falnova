-- Cron job'ları listele
SELECT * FROM cron.job;

-- Son çalışan cron job'ları kontrol et
SELECT * FROM cron.job_run_details 
WHERE jobid = (
  SELECT jobid 
  FROM cron.job 
  WHERE jobname = 'check-scheduled-notifications'
)
ORDER BY start_time DESC
LIMIT 5; 