-- En son giriş yapan kullanıcıları listele
SELECT 
    id,
    email,
    last_sign_in_at,
    created_at
FROM auth.users
WHERE last_sign_in_at IS NOT NULL
ORDER BY last_sign_in_at DESC
LIMIT 5; 