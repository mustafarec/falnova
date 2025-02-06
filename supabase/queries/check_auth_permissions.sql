-- 1. auth.users tablosundaki kullanıcıyı kontrol et
SELECT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b'
) as user_exists;

-- 2. Mevcut rolü kontrol et
SELECT current_user, current_setting('role');

-- 3. auth.users tablosuna erişim yetkilerini kontrol et
SELECT 
    grantee, 
    table_schema, 
    table_name, 
    privilege_type
FROM information_schema.table_privileges 
WHERE table_schema = 'auth' 
AND table_name = 'users';

-- 4. auth.users tablosundaki kullanıcı sayısını kontrol et
SELECT COUNT(*) as total_users FROM auth.users;

-- 5. En son eklenen kullanıcıları listele
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5; 