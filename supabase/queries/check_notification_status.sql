-- Bildirim durumunu kontrol et
SELECT 
    n.*,
    ft.token as fcm_token,
    u.email
FROM notifications n
LEFT JOIN fcm_tokens ft ON ft.user_id = n.user_id
LEFT JOIN users u ON u.id = n.user_id
WHERE n.id = 'eb52587b-616c-45b9-8424-6b2f0cef0406'; 