-- Önce tabloyu sil
DROP TABLE IF EXISTS public.users CASCADE;

-- Tabloyu yeniden oluştur
CREATE TABLE public.users (
    id UUID NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- Kullanıcıyı ekle
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
);

-- Foreign key'i ekle
ALTER TABLE public.users
ADD CONSTRAINT users_id_fkey 
FOREIGN KEY (id) 
REFERENCES auth.users(id)
ON DELETE CASCADE; 