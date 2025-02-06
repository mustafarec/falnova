-- HTTP extension'ı yükle
CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA public;

-- Mevcut tipleri temizle
DROP TYPE IF EXISTS public.http_response CASCADE;
DROP TYPE IF EXISTS public.http_header CASCADE;
DROP TYPE IF EXISTS public.http_request CASCADE;

-- HTTP yanıt tipi
CREATE TYPE public.http_response AS (
    status integer,
    content text,
    headers text[]
);

-- HTTP header tipi
CREATE TYPE public.http_header AS (
    name text,
    value text
);

-- HTTP istek tipi
CREATE TYPE public.http_request AS (
    method text,
    url text,
    headers public.http_header[],
    content text
);

-- Header'ları formatlayan yardımcı fonksiyon
CREATE OR REPLACE FUNCTION public.format_headers(headers public.http_header[])
RETURNS text[] AS $$
BEGIN
    RETURN COALESCE(
        array_agg(h.name || ': ' || h.value)
        FROM unnest(headers) h,
        '{}'::text[]
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Ana HTTP istek fonksiyonu
CREATE OR REPLACE FUNCTION public.http_request(req public.http_request)
RETURNS public.http_response AS $$
DECLARE
    response public.http_response;
BEGIN
    SELECT 
        h.status,
        h.content,
        h.headers
    INTO response
    FROM http(
        req.method,
        req.url,
        public.format_headers(req.headers),
        req.content
    ) h;
    
    RETURN response;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Kolaylık sağlayan HTTP POST fonksiyonu
CREATE OR REPLACE FUNCTION public.http_post(
    url text,
    content text DEFAULT NULL,
    headers public.http_header[] DEFAULT NULL
)
RETURNS public.http_response AS $$
BEGIN
    RETURN public.http_request(
        ROW(
            'POST',
            url,
            COALESCE(headers, ARRAY[]::public.http_header[]),
            content
        )::public.http_request
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test fonksiyonu
CREATE OR REPLACE FUNCTION public.test_http_request(
    notification_id uuid,
    is_test boolean DEFAULT true
)
RETURNS public.http_response AS $$
BEGIN
    RETURN public.http_post(
        'https://mrnrusxbpvazlpuifhjp.functions.supabase.co/send-notifications',
        jsonb_build_object(
            'notification_id', notification_id,
            'test', is_test
        )::text,
        ARRAY[
            ROW('Content-Type', 'application/json')::public.http_header,
            ROW('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybnJ1c3hicHZhemxwdWlmaGpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDU1MDI3OSwiZXhwIjoyMDIxMDc4Nzl9.CRXPiA7WOeoJeXXjNpi43kdwxkFt4qPkf6RxIsr0Vc')::public.http_header
        ]
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 