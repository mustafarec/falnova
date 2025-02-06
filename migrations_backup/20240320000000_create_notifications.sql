-- Notifications tablosunu oluştur
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    scheduled_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS politikalarını ayarla
DO $$
BEGIN
    -- RLS'i etkinleştir
    ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

    -- Politikaları kontrol et ve ekle
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'notifications' 
        AND policyname = 'Users can view their own notifications'
    ) THEN
        CREATE POLICY "Users can view their own notifications"
            ON notifications FOR SELECT
            USING (auth.uid() = user_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'notifications' 
        AND policyname = 'Users can update their own notifications'
    ) THEN
        CREATE POLICY "Users can update their own notifications"
            ON notifications FOR UPDATE
            USING (auth.uid() = user_id);
    END IF;
END
$$;

-- İndexleri kontrol et ve ekle
DO $$
BEGIN
    -- user_id index
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'notifications' 
        AND indexname = 'notifications_user_id_idx'
    ) THEN
        CREATE INDEX notifications_user_id_idx ON notifications(user_id);
    END IF;

    -- scheduled_time index
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'notifications' 
        AND indexname = 'notifications_scheduled_time_idx'
    ) THEN
        CREATE INDEX notifications_scheduled_time_idx ON notifications(scheduled_time);
    END IF;

    -- is_sent index
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'notifications' 
        AND indexname = 'notifications_is_sent_idx'
    ) THEN
        CREATE INDEX notifications_is_sent_idx ON notifications(is_sent);
    END IF;
END
$$;

-- Trigger fonksiyonu
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger'ı kontrol et ve ekle
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'update_notifications_updated_at'
    ) THEN
        CREATE TRIGGER update_notifications_updated_at
            BEFORE UPDATE ON notifications
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END
$$; 