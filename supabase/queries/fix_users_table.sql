-- 1. Tüm foreign key'leri kaldır
ALTER TABLE public.users
DROP CONSTRAINT IF EXISTS users_id_fkey;

-- 2. Kullanıcıyı ekle
INSERT INTO public.users (
    id,
    email,
    created_at,
    updated_at
) VALUES (
    '1f3341d1-3f50-41c5-9d18-5568d050b74b'::uuid,
    'deneme5@gmail.com',
    '2025-01-12 21:33:36.575533+00'::timestamptz,
    '2025-01-15 19:01:39.229301+00'::timestamptz
) ON CONFLICT (id) DO UPDATE 
SET 
    email = EXCLUDED.email,
    updated_at = EXCLUDED.updated_at;

-- 3. Foreign key'i tekrar ekle
ALTER TABLE public.users
ADD CONSTRAINT users_id_fkey 
FOREIGN KEY (id) 
REFERENCES auth.users(id)
ON DELETE CASCADE;

-- 4. Eklenen kullanıcıyı kontrol et
SELECT * FROM public.users WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b'; 