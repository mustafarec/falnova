-- Edge Function'ı test et
SELECT 
    status,
    content::json as response,
    headers
FROM public.test_http_request('eb52587b-616c-45b9-8424-6b2f0cef0406'::uuid, true); 