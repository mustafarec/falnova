-- 1. Notifications tablosunun foreign key'ini düzelt
ALTER TABLE notifications 
DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;

ALTER TABLE notifications
ADD CONSTRAINT notifications_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES public.users(id)
ON DELETE CASCADE;

-- 2. Test bildirimi oluştur
INSERT INTO notifications (
    user_id,
    type,
    title,
    body,
    scheduled_time,
    is_sent
) VALUES (
    '1f3341d1-3f50-41c5-9d18-5508d050b74b',
    'test',
    'Test Bildirimi 3',
    'Bu bir test bildirimidir - ' || NOW()::text,
    NOW() + interval '1 minute',
    false
) RETURNING *;

-- 3. Oluşturulan bildirimi kontrol et
SELECT 
    n.*,
    u.email
FROM notifications n
JOIN public.users u ON u.id = n.user_id
WHERE n.user_id = '1f3341d1-3f50-41c5-9d18-5508d050b74b'
ORDER BY n.created_at DESC
LIMIT 1; 