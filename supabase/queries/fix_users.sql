-- Insert test user directly
INSERT INTO users (id, email, created_at, updated_at)
SELECT 
    id,
    email,
    created_at,
    last_sign_in_at as updated_at
FROM auth.users
WHERE id = '1f3341d1-3f50-41c5-9d18-5568d050b74b'
ON CONFLICT (id) DO UPDATE 
SET 
    email = EXCLUDED.email,
    updated_at = EXCLUDED.updated_at; 