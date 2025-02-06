-- Kullanıcıyı doğrudan ekle
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
    updated_at = EXCLUDED.updated_at
RETURNING *; 