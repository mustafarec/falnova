-- Test bildirimi oluştur
INSERT INTO notifications (
  user_id,
  type,
  title,
  body,
  scheduled_time,
  is_sent
) VALUES (
  '1f3341d1-3f50-41c5-9d18-5568d050b74b',
  'test',
  'Test Bildirimi 2',
  'Bu bir test bildirimidir - ' || NOW()::text,
  NOW() + interval '1 minute',
  false
); 