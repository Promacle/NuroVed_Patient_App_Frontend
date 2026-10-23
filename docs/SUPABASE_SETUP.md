# Supabase Authentication & Backend Setup Guide

This document describes the backend configuration, rate limiting, and server-side RPC functions required to support NuroVed Patient App authentication, session security, and patient data privacy.

---

## 1. Security Architecture & Threat Model

### 1.1 Zero Privileged Key in Mobile Client
- **Rule**: The mobile client (`lib/core/repositories/supabase/supabase_auth_repository.dart`) MUST NEVER embed, receive, or use the Supabase `service_role` key.
- **Client Configuration**: Only the public `SUPABASE_URL` and `SUPABASE_ANON_KEY` are passed to the app via `--dart-define` or local untracked `.env`.
- **Identity Enforcement**: All operations are authenticated via standard JWT Bearer tokens issued by Supabase Auth (`/auth/v1/token?grant_type=password`).

---

## 2. Server-Backed Account Deletion RPC

Per medical privacy regulations (GDPR/HIPAA/DPDP Act 2023) and app store privacy policies, a patient must be able to permanently delete their account and associated data directly within the app.

Since deleting an entry from `auth.users` requires administrative privilege, client apps cannot call `DELETE` on `auth.users` directly with an anon key. A PostgreSQL function with `SECURITY DEFINER` is used.

### 2.1 SQL Function: `delete_user_account()`

Execute the following SQL in the Supabase SQL Editor:

```sql
-- Step 1: Function to delete current user and cascade data
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Obtain authenticated caller's user id from JWT context
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated request: cannot delete account without active session';
  END IF;

  -- 1. Delete associated patient medical timeline data
  DELETE FROM public.medical_records WHERE user_id = v_user_id;
  DELETE FROM public.visits WHERE user_id = v_user_id;
  DELETE FROM public.profiles WHERE id = v_user_id;

  -- 2. Delete the user from auth.users (cascades sessions, identities, MFA)
  DELETE FROM auth.users WHERE id = v_user_id;

  RETURN json_build_object(
    'success', true,
    'message', 'Account and associated records successfully erased'
  );
END;
$$;

-- Step 2: Grant execution permission only to authenticated users
REVOKE EXECUTE ON FUNCTION public.delete_user_account() FROM public, anon;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;
```

### 2.2 Client Invocations
The Flutter client calls this endpoint using:
`POST /rest/v1/rpc/delete_user_account`
Headers:
```http
Authorization: Bearer <user_jwt_access_token>
apikey: <supabase_anon_key>
Content-Type: application/json
```

---

## 3. Brute-Force & Rate Limiting Configuration

To protect patients against credential stuffing and brute-force attacks, configure the following in the Supabase Dashboard under **Project Settings > Authentication > Rate Limits**:

| Setting | Recommended Value | Purpose |
|---|---|---|
| **Max Sign In Attempts** | 5 attempts per 15 minutes | Mitigates dictionary attacks on passwords |
| **Max Password Reset Emails** | 3 emails per hour per IP | Prevents email bombing / inbox exhaustion |
| **Email Verification Rate** | 5 emails per hour | Prevents verification flooding |
| **Token Refresh Rate** | 100 requests per 5 minutes | Protects against token harvesting |

### 3.1 Web Application Firewall (WAF) & Cloudflare Protection
When deploying a custom Supabase domain:
1. Enable Cloudflare Turnstile or Managed Challenge for repeated 401 Unauthorized responses.
2. Block IPs exceeding 20 failed `/auth/v1/token` requests in a 5-minute window.

---

## 4. Environment Configuration in Flutter

To configure the mobile app for Supabase in staging or production:

1. Create a local untracked `.env` file (copied from `.env.example`):
   ```bash
   SUPABASE_URL=https://<your-project-id>.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOi...
   ```
2. Or compile the release build with `--dart-define`:
   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=https://<project-id>.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=<anon-key>
   ```
