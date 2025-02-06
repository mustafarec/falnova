-- Tüm bildirimleri kontrol et
SELECT 
  n.*,
  ft.token as fcm_token,
  u.email
FROM notifications n
LEFT JOIN fcm_tokens ft ON ft.user_id = n.user_id
LEFT JOIN auth.users u ON u.id = n.user_id
WHERE n.scheduled_time <= NOW()
ORDER BY n.scheduled_time DESC
LIMIT 10; 