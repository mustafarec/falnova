-- Önce tüm eski fonksiyonları ve extension'ı temizle
DROP EXTENSION IF EXISTS http CASCADE;
DROP SCHEMA IF EXISTS extensions CASCADE;

-- Eski fonksiyonları temizle
DROP FUNCTION IF EXISTS public.http_request(text, text, text[], text) CASCADE;
DROP FUNCTION IF EXISTS public.http_post(text, text, http_header[]) CASCADE;
DROP FUNCTION IF EXISTS public.http_post(character varying, character varying, character varying) CASCADE;
DROP FUNCTION IF EXISTS public.http_post(character varying, jsonb) CASCADE;
DROP FUNCTION IF EXISTS public.http_get(character varying) CASCADE;
DROP FUNCTION IF EXISTS public.http_get(character varying, jsonb) CASCADE;
DROP FUNCTION IF EXISTS public.http_delete(character varying) CASCADE;
DROP FUNCTION IF EXISTS public.http_delete(character varying, character varying, character varying) CASCADE;
DROP FUNCTION IF EXISTS public.http_put(character varying, character varying, character varying) CASCADE;
DROP FUNCTION IF EXISTS public.http_patch(character varying, character varying, character varying) CASCADE;
DROP FUNCTION IF EXISTS public.http_head(character varying) CASCADE;
DROP FUNCTION IF EXISTS public.test_http_request(uuid, boolean) CASCADE;
DROP TYPE IF EXISTS public.http_header CASCADE;
DROP TYPE IF EXISTS public.http_request CASCADE;
DROP TYPE IF EXISTS public.http_response CASCADE;

-- Yeni şema ve extension'ı kur
CREATE SCHEMA extensions;
CREATE EXTENSION http WITH SCHEMA extensions;

-- HTTP yanıt tipini tanımla
DROP TYPE IF EXISTS public.http_response_row CASCADE;
CREATE TYPE public.http_response_row AS (
    status integer,
    content text,
    headers text[]
);

-- HTTP POST isteği gönderen temel fonksiyon
CREATE OR REPLACE FUNCTION public.do_http_post(
    p_url text,
    p_body text DEFAULT '',
    p_headers text[] DEFAULT '{}'
)
RETURNS public.http_response_row AS $$
DECLARE
    v_response public.http_response_row;
BEGIN
    SELECT status, content, headers 
    INTO v_response
    FROM extensions.http_post(p_url, p_body, p_headers)
    LIMIT 1;
    
    RETURN v_response;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Test fonksiyonu
CREATE OR REPLACE FUNCTION public.test_notification_request(
    notification_id uuid,
    is_test boolean DEFAULT true
)
RETURNS SETOF public.http_response_row AS $$
DECLARE
    v_response public.http_response_row;
BEGIN
    SELECT * INTO v_response
    FROM public.do_http_post(
        'https://mrnrusxbpvazlpuifhjp.functions.supabase.co/send-notifications',
        jsonb_build_object(
            'notification_id', notification_id,
            'test', is_test
        )::text,
        ARRAY[
            'Content-Type: application/json',
            'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ybnJ1c3hicHZhemxwdWlmaGpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDU1MDI3OSwiZXhwIjoyMDIxMDc4Nzl9.CRXPiA7WOeoJeXXjNpi43kdwxkFt4qPkf6RxIsr0Vc'
        ]
    );
    
    RETURN NEXT v_response;
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 