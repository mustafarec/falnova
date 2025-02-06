-- 1. auth.users tablosundaki kullanıcıyı kontrol et
SELECT EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b'
) as user_exists_in_auth;

-- 2. auth.users tablosunun yetkilerini kontrol et
SELECT grantee, privilege_type 
FROM information_schema.table_privileges 
WHERE table_schema = 'auth' 
AND table_name = 'users';

-- 3. public.users tablosunun yetkilerini kontrol et
SELECT grantee, privilege_type 
FROM information_schema.table_privileges 
WHERE table_schema = 'public' 
AND table_name = 'users';

-- 4. auth.users tablosunun şema bilgilerini kontrol et
SELECT 
    c.column_name, 
    c.data_type,
    c.is_nullable,
    c.column_default,
    tc.constraint_type,
    tc.constraint_name
FROM information_schema.columns c
LEFT JOIN information_schema.constraint_column_usage ccu 
    ON c.column_name = ccu.column_name 
    AND c.table_name = ccu.table_name
LEFT JOIN information_schema.table_constraints tc
    ON tc.constraint_name = ccu.constraint_name
WHERE c.table_schema = 'auth' 
AND c.table_name = 'users'; 