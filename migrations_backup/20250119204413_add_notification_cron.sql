-- migrate:up
SELECT cron.schedule(
  'check-notifications',
  '* * * * *',
  --include-all
    SELECT check_scheduled_notifications(user_id, false)
    FROM (
      SELECT DISTINCT user_id 
      FROM notifications 
      WHERE NOT is_sent 
      AND scheduled_time <= now()
    ) users;
  --include-all
);

-- migrate:down
SELECT cron.unschedule('check-notifications');
