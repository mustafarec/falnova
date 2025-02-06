-- Önce mevcut foreign key'i kaldır (eğer varsa)
ALTER TABLE notifications 
DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;

-- Yeni foreign key'i ekle
ALTER TABLE notifications
ADD CONSTRAINT notifications_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES auth.users(id)
ON DELETE CASCADE; 