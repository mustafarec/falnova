-- Önce mevcut foreign key'i kaldır
ALTER TABLE notifications 
DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;

-- Yeni foreign key'i ekle (public.users tablosuna)
ALTER TABLE notifications
ADD CONSTRAINT notifications_user_id_fkey 
FOREIGN KEY (user_id) 
REFERENCES public.users(id)
ON DELETE CASCADE; 