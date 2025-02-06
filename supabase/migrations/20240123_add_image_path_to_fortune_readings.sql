-- Kahve falı resimlerinin yolunu tutacak sütunu ekle
ALTER TABLE fortune_readings
ADD COLUMN IF NOT EXISTS image_path TEXT;

-- RLS politikalarını güncelle
ALTER TABLE fortune_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Kullanıcılar kendi kahve fallarını görebilir"
ON fortune_readings FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi kahve fallarını ekleyebilir"
ON fortune_readings FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi kahve fallarını güncelleyebilir"
ON fortune_readings FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id); 