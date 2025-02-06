create table if not exists fcm_tokens (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  token text not null,
  device_type text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique (user_id, token)
);

-- RLS Politikaları
alter table fcm_tokens enable row level security;

-- Drop existing policy if exists
DROP POLICY IF EXISTS "Kullanıcılar kendi FCM token'larını görebilir" ON fcm_tokens;
DROP POLICY IF EXISTS "Kullanıcılar kendi FCM token'larını ekleyebilir" ON fcm_tokens;
DROP POLICY IF EXISTS "Kullanıcılar kendi FCM token'larını güncelleyebilir" ON fcm_tokens;
DROP POLICY IF EXISTS "Kullanıcılar kendi FCM token'larını silebilir" ON fcm_tokens;

-- Create policy
CREATE POLICY "Kullanıcılar kendi FCM token'larını görebilir"
ON fcm_tokens
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi FCM token'larını ekleyebilir"
ON fcm_tokens
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi FCM token'larını güncelleyebilir"
ON fcm_tokens
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi FCM token'larını silebilir"
ON fcm_tokens
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS update_fcm_tokens_updated_at ON fcm_tokens;

-- Create trigger for updating updated_at
CREATE TRIGGER update_fcm_tokens_updated_at
    BEFORE UPDATE ON fcm_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 