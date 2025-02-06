-- pg_cron extension'ı için yetkileri düzenle
DO $$
BEGIN
    -- Eğer extension zaten kurulu değilse kur
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        CREATE EXTENSION pg_cron WITH SCHEMA public;
    END IF;
    
    -- Gerekli yetkileri ver
    GRANT USAGE ON SCHEMA cron TO postgres;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA cron TO postgres;
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA cron TO postgres;
END
$$;

-- Eski cron job'ı varsa kaldır
DO $$
BEGIN
    PERFORM cron.unschedule('check-notifications');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END
$$;

-- Her dakika çalışacak yeni cron job'ı oluştur
SELECT cron.schedule(
    'check-notifications',
    '* * * * *',
    $$
    SELECT net.http_post(
        'https://YOUR_PROJECT_REF.functions.supabase.co/check-and-send-notifications',
        '{}',
        '{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'
    );
    $$
); 