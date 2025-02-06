// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { SignJWT } from "https://deno.land/x/jose@v4.9.1/jwt/sign.ts";
import { importPKCS8 } from "https://deno.land/x/jose@v4.9.1/key/import.ts";
import { encode as base64url } from "https://deno.land/std@0.82.0/encoding/base64url.ts";

const FIREBASE_PROJECT_ID = 'falnova' // Firebase projenizin ID'si

// HTTP v1 endpoint'i için
const FCM_ENDPOINT = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`

async function getAccessToken() {
  try {
    const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
    console.log('Service Account String:', serviceAccountStr);

    if (!serviceAccountStr) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT environment variable is not set');
    }

    const serviceAccount = JSON.parse(serviceAccountStr);
    console.log('Service Account parsed:', {
      type: serviceAccount.type,
      project_id: serviceAccount.project_id,
      client_email: serviceAccount.client_email
    });
    
    const now = Math.floor(Date.now() / 1000);
    const privateKey = await importPKCS8(serviceAccount.private_key, 'RS256');
    
    const jwt = await new SignJWT({
      scope: 'https://www.googleapis.com/auth/firebase.messaging'
    })
      .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
      .setIssuer(serviceAccount.client_email)
      .setSubject(serviceAccount.client_email)
      .setAudience('https://oauth2.googleapis.com/token')
      .setIssuedAt(now)
      .setExpirationTime(now + 3600)
      .sign(privateKey);

    console.log('Generated JWT:', jwt);

    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    });

    if (!tokenResponse.ok) {
      const errorText = await tokenResponse.text();
      console.error('Token response error:', errorText);
      throw new Error(`Failed to get access token: ${errorText}`);
    }

    const { access_token } = await tokenResponse.json();
    return access_token;
  } catch (error) {
    console.error('Error getting access token:', error);
    console.error('Error stack:', error.stack);
    throw error;
  }
}

serve(async (req) => {
  try {
    const { token, title, body, data } = await req.json()
    
    if (!token) {
      return new Response(
        JSON.stringify({ error: 'FCM token is required' }),
        { 
          status: 400,
          headers: { 'Content-Type': 'application/json' }
        }
      )
    }

    const accessToken = await getAccessToken()
    
    const message = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body
        },
        android: {
          notification: {
            title: title,
            body: body,
            channel_id: "high_importance_channel"
          }
        },
        data: data || {}
      }
    }

    console.log('Sending FCM message:', JSON.stringify(message, null, 2))

    const fcmResponse = await fetch(FCM_ENDPOINT, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message)
    })

    if (!fcmResponse.ok) {
      const errorText = await fcmResponse.text()
      console.error('FCM response error:', errorText)
      throw new Error(`Failed to send FCM message: ${errorText}`)
    }

    const responseData = await fcmResponse.json()
    console.log('FCM response:', JSON.stringify(responseData, null, 2))

    return new Response(
      JSON.stringify(responseData),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error sending FCM notification:', error)
    console.error('Error stack:', error.stack)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/send-fcm' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"token":"your_fcm_token","title":"Hello","body":"World","data":{"key":"value"}}'

*/
