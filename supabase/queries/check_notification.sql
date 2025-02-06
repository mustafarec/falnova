-- Bildirim durumunu kontrol et
SELECT 
    n.*,
    u.email,
    ft.token as fcm_token,
    ft.created_at as token_created_at,
    ft.updated_at as token_updated_at
FROM notifications n
JOIN public.users u ON u.id = n.user_id
JOIN fcm_tokens ft ON ft.user_id = n.user_id
WHERE n.id = 'eb52587b-616c-45b9-8424-6b2f0cef0406'; 