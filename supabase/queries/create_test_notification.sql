INSERT INTO notifications (
  user_id,
  title,
  body,
  type,
  scheduled_time,
  is_sent
) VALUES (
  '1f3341d1-3f50-41c5-9d18-5508d050b74b',
  'Yeni Test',
  'Yeni cron job testi - ' || to_char(now(), 'HH24:MI:SS'),
  'scheduled',
  now() + interval '30 seconds',
  false
) RETURNING *;