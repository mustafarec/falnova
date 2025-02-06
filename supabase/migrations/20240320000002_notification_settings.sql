-- Notification ayarları için tablo oluştur
CREATE TABLE IF NOT EXISTS notification_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS politikalarını ayarla
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

-- Kullanıcıların kendi ayarlarını görmesi için politika
CREATE POLICY "Users can view their own notification settings"
    ON notification_settings FOR SELECT
    USING (auth.uid() = user_id);

-- Kullanıcıların kendi ayarlarını güncellemesi için politika
CREATE POLICY "Users can update their own notification settings"
    ON notification_settings FOR UPDATE
    USING (auth.uid() = user_id);

-- Trigger fonksiyonu
CREATE OR REPLACE FUNCTION update_notification_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger'ı ekle
CREATE TRIGGER update_notification_settings_updated_at
    BEFORE UPDATE ON notification_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_notification_settings_updated_at(); 