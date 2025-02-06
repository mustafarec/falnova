-- Oturum açmış kullanıcıların listesi
SELECT 
  id,
  email,
  last_sign_in_at
FROM auth.users
ORDER BY last_sign_in_at DESC
LIMIT 5; 