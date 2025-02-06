-- HTTP isteği gönder
SELECT extensions.http_post(
    'https://mrnrusxbpvazlpuifhjp.functions.supabase.co/send-notifications',
    json_build_object(
        'notification_id', 'eb52587b-616c-45b9-8424-6b2f0cef0406',
        'test', true
    )::text,
    ARRAY[extensions.http_header('Content-Type', 'application/json')]
) AS request_id;

-- Bekleyen bildirimleri kontrol et
SELECT 
    n.*,
    u.email,
    ft.token as fcm_token
FROM notifications n
JOIN public.users u ON u.id = n.user_id
JOIN fcm_tokens ft ON ft.user_id = n.user_id
WHERE n.id = 'eb52587b-616c-45b9-8424-6b2f0cef0406'; 