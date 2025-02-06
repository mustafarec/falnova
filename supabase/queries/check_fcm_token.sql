-- En son FCM token'ı kontrol et
SELECT 
    ft.*,
    u.email
FROM fcm_tokens ft
JOIN users u ON u.id = ft.user_id
ORDER BY ft.created_at DESC
LIMIT 1; 