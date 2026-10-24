# NuroVed Security & Data Protection Review

This document specifies the security architecture, authorization matrix, Row Level Security (RLS) enforcement, and storage isolation policies for the NuroVed Patient App (Diabetes Care Timeline).

---

## 1. Security Architecture Principles

1. **Zero Privileged Keys in Client**:
   - The Flutter mobile client never holds or embeds the Supabase `service_role` key.
   - All client queries use the anonymous key (`SUPABASE_ANON_KEY`) paired with an authenticated user JWT Bearer token issued by Supabase Auth.
2. **Database-Enforced Authorization**:
   - Authorization is enforced by the PostgreSQL kernel via Row Level Security (RLS) on every table and storage object. No reliance on client-side filtering.
3. **Delegated Access Control**:
   - Sharing with caregivers and clinicians is explicitly governed by `care_access_grants` with temporal expirations (`expires_at`), revocation tracking (`revoked_at`), and fine-grained resource scopes (`full_profile`, `medical_records`, `health_timeline`, `medications`).
4. **Private Storage & Short-Lived Signed URLs**:
   - Medical files reside in a strictly private bucket (`medical-records`). No public URLs exist.
   - Access to raw files requires server authorization via `authorize_medical_file_access()`, which issues short-lived (60-second) signed URLs after verifying active ownership or grant status.
5. **Immutable Audit Trail**:
   - The `audit_events` table is append-only. Table triggers block all `UPDATE` and `DELETE` queries.

---

## 2. Resource Access Control Matrix

| Table / Bucket | Operation | Patient (Owner) | Active Grantee (In-Scope) | Active Grantee (Out-of-Scope) | Expired / Revoked Grantee | Unrelated Patient | Anonymous / Unauthenticated |
|---|---|---|---|---|---|---|---|
| **`profiles`** | **Read** | ALLOW | ALLOW (if `full_profile`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW (`auth.uid() = id`) | DENY | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW (`auth.uid() = id`) | DENY | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW (`auth.uid() = id`) | DENY | DENY | DENY | DENY | DENY |
| **`family_members`** | **Read** | ALLOW | ALLOW (`full_profile`/`medical_records`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| **`care_access_grants`** | **Read** | ALLOW (as patient) | ALLOW (as grantee) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW (as patient) | DENY | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW (as patient) | ALLOW (status = `revoked` only) | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW (as patient) | DENY | DENY | DENY | DENY | DENY |
| **`medical_records`** | **Read** | ALLOW (non-deleted) | ALLOW (`medical_records`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW | ALLOW (if `view_and_edit`) | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW | ALLOW (if `view_and_edit`) | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| **`visits`** | **Read** | ALLOW (non-deleted) | ALLOW (`health_timeline`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW | ALLOW (if `view_and_edit`) | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW | ALLOW (if `view_and_edit`) | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| **`visit_record_links`** | **Read** | ALLOW | ALLOW (`health_timeline`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW | ALLOW (if `view_and_edit`) | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| **`medication_routines`**| **Read** | ALLOW | ALLOW (`medications`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| **`medication_completions`**| **Read** | ALLOW | ALLOW (`medications`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW | DENY | DENY | DENY | DENY | DENY |
| **`patient_timeline`** *(View)* | **Read** | ALLOW (security invoker)| ALLOW (security invoker) | DENY | DENY | DENY | DENY |
| **`audit_events`** | **Read** | ALLOW (`auth.uid() = user_id`)| DENY | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW (system triggers)| DENY | DENY | DENY | DENY | DENY |
| | **Update** | DENY (Blocked by trigger)| DENY (Blocked by trigger) | DENY | DENY | DENY | DENY |
| | **Delete** | DENY (Blocked by trigger)| DENY (Blocked by trigger) | DENY | DENY | DENY | DENY |
| **`storage: medical-records`**| **Read** | ALLOW (owner prefix) | ALLOW (`medical_records`) | DENY | DENY | DENY | DENY |
| | **Create** | ALLOW (owner prefix) | ALLOW (if `view_and_edit`) | DENY | DENY | DENY | DENY |
| | **Update** | ALLOW (owner prefix) | DENY | DENY | DENY | DENY | DENY |
| | **Delete** | ALLOW (owner prefix) | DENY | DENY | DENY | DENY | DENY |

---

## 3. Storage Security & Path Conventions

### 3.1 Path Hierarchy
Medical files uploaded to the `medical-records` bucket must adhere to the following path format:
```
{owner_uid}/{subject_id}/{record_id}/{filename}
```
- `{owner_uid}`: UUID of the account owner (validated against `auth.uid()`).
- `{subject_id}`: UUID of the patient or dependent family member (`family_members.id`).
- `{record_id}`: UUID of the diagnostic metadata entry (`medical_records.id`).
- `{filename}`: Sanitized file name with approved extension (`.pdf`, `.jpg`, `.jpeg`, `.png`).

### 3.2 Server-Side Upload Validation
1. **Allowed MIME Types**: `application/pdf`, `image/jpeg`, `image/png`.
2. **Maximum File Size**: 10,485,760 bytes (10MB).
3. **Path Validation**: Storage RLS check `array_length(storage.foldername(name), 1) >= 3` ensures files cannot be placed at the bucket root or outside the owner's hierarchy.

### 3.3 Secure Retrieval Flow (Signed URLs)
Direct URL downloads are blocked by `public = false`.
To view a document:
1. Client calls RPC `public.authorize_medical_file_access(p_record_id uuid)`.
2. Function verifies caller is either the record owner or has an active `care_access_grants` entry with `medical_records` scope.
3. Access event is recorded in `public.audit_events`.
4. Client requests a 60-second signed URL via Supabase Storage API (`POST /storage/v1/object/sign/medical-records/...`).

---

## 4. Execution & Verification Guide

Since the local testing environment lacks Docker and the Supabase CLI, migrations and tests are committed as **IMPLEMENTED-UNVERIFIED**.

### How to Apply Migrations to a Supabase Project:
1. **Via Supabase CLI** (in an environment with Docker installed):
   ```bash
   # Initialize and link project
   supabase link --project-ref <your-project-ref>
   
   # Push all pending migrations
   supabase db push
   ```
2. **Via Supabase Management Dashboard**:
   - Open the **SQL Editor** in the Supabase Dashboard.
   - Run in sequential order:
     1. `supabase/migrations/20261023000001_core_schema.sql`
     2. `supabase/migrations/20261023000002_row_level_security.sql`
     3. `supabase/migrations/20261023000003_storage_security.sql`

### How to Run the Automated RLS Policy Verification Suite:
Open the SQL Editor in Supabase (or connect via `psql`) and execute:
```sql
\i supabase/tests/rls_policies_test.sql
```
The test suite executes inside a `BEGIN ... ROLLBACK` transaction block, leaving the target database completely clean. It raises `NOTICE` logs on passing each test suite:
- `Test Suite 1 Passed: Anonymous user gets nothing (0 rows).`
- `Test Suite 2 Passed: Full isolation between unrelated patients verified.`
- `Test Suite 3 Passed: Scope and revocation enforcement verified.`
- `Test Suite 4 Passed: Storage authorization check verified.`
- `Test Suite 5 Passed: Audit events immutability verified.`

---

## 5. Privacy Review & Local Data Safeguards (Phase 7)

A comprehensive privacy review was conducted covering logs, file caches, background snapshots, clipboard access, and local persistence of sensitive data.

### 5.1 Telemetry & Logging Sanitization
- **Issue**: Standard debug statements or naive logging can leak personal health information (PHI) such as patient names, email addresses, phone numbers, auth tokens, or diagnostic measurements into device logs (`adb logcat`, Console.app).
- **Control**: All logging is routed through `AppLogger` (`lib/core/utils/app_logger.dart`).
- **Mitigation**:
  - `_sanitizeMessage` regex redacts emails (`[REDACTED_EMAIL]`), international phone numbers (`[REDACTED_PHONE]`), JWT bearer tokens (`[REDACTED_TOKEN]`), and passwords.
  - Zero raw `print(` statements remain in `lib/` (verified via `git grep -n "print(" lib/`).
  - Release builds suppress verbose debug logging via Flutter's `kReleaseMode`.

### 5.2 File Caches & Temporary Artifacts
- **Issue**: Picked PDF reports or captured camera images can linger in temporary cache directories (`/data/user/0/.../cache`), exposing sensitive diagnostic documents.
- **Control**: In `lib/core/utils/platform_file.dart` and `RecordsController`, temporary picked files are deleted after upload completes or fails. On session termination (`signOut()`), local cached thumbnails and image references are purged.

### 5.3 App Switcher Screenshots & Background Previews
- **Issue**: When an app is placed in the background on Android or iOS, the operating system takes a snapshot of the screen to display in the recent apps switcher, potentially exposing the Emergency Medical Card, glucose levels, or medication lists.
- **Production Hardening Recommendation**:
  - On Android: Enable `FLAG_SECURE` in `MainActivity.kt` (`window.setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE)`) on sensitive clinical screens to blank the task preview.
  - On iOS: Render a blur/privacy overlay in `AppDelegate.swift` when `applicationWillResignActive` fires.

### 5.4 Clipboard Protection
- **Control**: The app avoids copying passwords or session tokens to the system clipboard.
- **Caregiver Codes**: Sharing tokens (Caregiver invite code or link) are only copied upon explicit user confirmation with a transient SnackBar notification, and clipboard entries contain short-lived random tokens rather than credentials.

### 5.5 Local Storage of Sensitive Data
- **Control**: `SharedPreferences` is restricted to non-sensitive session states and user preferences.
- **Tokens**: In production with live Supabase, session tokens are stored using platform-encrypted keystores (`flutter_secure_storage` / Keychain).
- **Medical Binaries**: Raw medical records are NEVER persisted in SharedPreferences or external public storage; they are streamed from private bucket signed URLs directly into memory.
