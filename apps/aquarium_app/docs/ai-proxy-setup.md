# Danio AI Proxy — Supabase Edge Function

## Status: ✅ DEPLOYED & VERIFIED

**Project:** Danio (`fqmzaeutdvmqssdwduhu`)
**Region:** Central Europe (Zurich)
**Function URL:** `https://fqmzaeutdvmqssdwduhu.supabase.co/functions/v1/ai-proxy`
**Auth redirect:** `io.supabase.aquariumapp://login-callback/`

## What it does

Routes OpenAI API requests through a server-side proxy so the API key never
touches the client. The client sends requests with the Supabase anon key
(safe to embed), and the Edge Function injects the real OpenAI key server-side.

## Build command (production)

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://fqmzaeutdvmqssdwduhu.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxbXphZXV0ZHZtcXNzZHdkdWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4MjQ5ODcsImV4cCI6MjA4NzQwMDk4N30.b9DlagB9lVan2gUrgWmePqAquKff6opEYsK_VWCMGFw \
  --dart-define=SUPABASE_AI_PROXY_URL=https://fqmzaeutdvmqssdwduhu.supabase.co/functions/v1/ai-proxy
```

## Architecture

```
Client (Flutter app)
  ↓ POST /functions/v1/ai-proxy
  ↓ Header: Authorization: Bearer <anon-key>
Supabase Edge Function
  ↓ Injects OPENAI_API_KEY from secrets
  ↓ POST api.openai.com/v1/chat/completions
OpenAI API
  ↓ Response
Edge Function → Client
```

## Secrets

- `OPENAI_API_KEY` — set via `npx supabase secrets set`
- To rotate: `npx supabase secrets set OPENAI_API_KEY=sk-new-key`

## Redeployment

```bash
cd /mnt/c/Users/larki/Documents/Danio\ Aquarium\ App\ Project/repo/apps/aquarium_app
export SUPABASE_ACCESS_TOKEN="<token>"
npx supabase functions deploy ai-proxy --no-verify-jwt
```

## Fallback

When `SUPABASE_AI_PROXY_URL` is NOT set in the build, the app falls back to:
1. User-supplied key (entered in Settings, AES-256 encrypted at rest)
2. Build-time `OPENAI_API_KEY` define (dev only)

This means the app works without the proxy — AI features just require the user
to enter their own key.
