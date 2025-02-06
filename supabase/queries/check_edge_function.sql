-- Edge function'ı manuel olarak tetikle
SELECT
    cron.schedule(
        'manual_test_notification',
        NOW() + interval '10 seconds',
        $$
        SELECT net.http_post(
            'https://falnova.vercel.app/api/functions/v1/send-notifications',
            '{"test": true}',
            ARRAY[net.http_header('Content-Type', 'application/json')]
        ) AS request_id;
        $$
    );

-- Bekleyen bildirimleri kontrol et
SELECT 
    n.*,
    u.email,
    ft.token as fcm_token
FROM notifications n
JOIN public.users u ON u.id = n.user_id
JOIN fcm_tokens ft ON ft.user_id = n.user_id
WHERE n.is_sent = false 
AND n.scheduled_time <= NOW()
ORDER BY n.scheduled_time DESC; 