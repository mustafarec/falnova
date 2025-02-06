-- auth.users tablosundaki kullanıcıyı kontrol et
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at,
    raw_user_meta_data
FROM auth.users
WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b';

-- Tüm auth.users kullanıcılarını listele
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5; 