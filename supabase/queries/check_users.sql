-- public.users tablosundaki kullanıcıyı kontrol et
SELECT * FROM public.users WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b';

-- Tablonun şemasını kontrol et
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'users'
ORDER BY ordinal_position; 