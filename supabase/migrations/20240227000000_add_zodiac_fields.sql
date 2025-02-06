-- Burç alanlarını profiles tablosuna ekle
ALTER TABLE profiles
ADD COLUMN sun_sign text,
ADD COLUMN ascendant_sign text,
ADD COLUMN moon_sign text;

-- RLS politikalarını güncelle
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar kendi profillerini güncelleyebilir"
ON profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "Kullanıcılar kendi profillerini görebilir"
ON profiles FOR SELECT
USING (auth.uid() = id); 