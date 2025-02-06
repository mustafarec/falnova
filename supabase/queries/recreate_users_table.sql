-- Users tablosunu yeniden oluştur
DROP TABLE IF EXISTS public.users CASCADE;

CREATE TABLE public.users (
    id UUID PRIMARY KEY,
    email TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Foreign key constraint ekle
ALTER TABLE public.users
ADD CONSTRAINT users_id_fkey
FOREIGN KEY (id)
REFERENCES auth.users(id)
ON DELETE CASCADE;

-- Kullanıcıyı ekle
INSERT INTO public.users (id, email, created_at, updated_at)
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at as updated_at
FROM auth.users
WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b'
RETURNING *; 