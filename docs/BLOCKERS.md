# NuroVed Patient App — Blockers & Resolution Status

> **Document Status**: FINAL AUDIT (PHASE 7 COMPLETED)  
> **Date**: October 24, 2026  
> **Branch**: `nuroved/repair`

---

## 1. Cross-Account Backend Authorization Tests (Current Status: BLOCKED)

| Item | Status | Impact | How to Unblock |
| :--- | :--- | :--- | :--- |
| **Cross-Account Authorization Tests (Live Database)** | **BLOCKED** | Cannot verify multi-tenant isolation against live PostgreSQL without live database access. In-memory isolation is VERIFIED (100% test pass rate across 168 unit/integration tests). | Deploy the authored idempotent migration and SQL test suite to Supabase staging using the steps below. |

### How to Unblock & Run Live Backend Tests
1. **Prerequisites**:
   - Install Supabase CLI:
     ```bash
     brew install supabase/tap/supabase
     ```
   - Docker running locally (for local test instance) OR a linked remote staging project.

2. **Run Local Database & Migrations**:
   ```bash
   # Initialize local test database container
   supabase start

   # Apply all migrations idempotently
   supabase db reset
   ```

3. **Execute SQL Row-Level Security (RLS) Test Suite**:
   ```bash
   supabase test db
   ```
   This executes `supabase/tests/rls_policy_test.sql`, testing:
   - Tenant A cannot read Tenant B's profile
   - Tenant A cannot view Tenant B's medical records
   - Grantee access is strictly governed by `care_access_grants`
   - Expired or revoked grants immediately deny access
   - Storage object path policies enforce owner/grantee boundaries

4. **Run Live Flutter Cross-Account Client Tests**:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL="https://your-staging-project.supabase.co" \
     --dart-define=SUPABASE_ANON_KEY="your-staging-anon-key"
   ```

---

## 2. Resolved Blockers (Phases 1–6)

| Original Blocker | Resolution Phase | Solution Implemented |
| :--- | :--- | :--- |
| **Zero Backend Configuration & Hardcoded Personal Creds** | Phase 1 & 2 | Clean architectural decoupling via `AppConfig.isBackendConfigured`. When backend keys are omitted, the app safely defaults to in-memory mode with an honest `BackendStatusBanner`. Hardcoded developer email removed. |
| **Missing Database Migrations & RLS** | Phase 3 | Authored `supabase/migrations/20260216000000_mvp_backend_schema.sql` covering `profiles`, `family_members`, `care_access_grants`, `medical_records`, `visits`, `medicine_routines`, and private storage bucket `medical-records` with zero public access. |
| **Profile Bleed & Unstable Family IDs** | Phase 4 | Implemented single source of truth for active health subject with stable UUIDs across `ProfileController`, `RecordsController`, `VisitsController`, and `RoutineController`. Strict per-subject data isolation. |
| **Fabricated Clinical Data (Lay's Chips Scanner)** | Phase 6 | Disabled fake barcode recognition and mock meal plan generation with honest clinical disclaimers. Displayed "Service Unavailable" banner instead of fabricating diagnostic data. |
| **Fake In-App Purchases (Demo Buttons)** | Phase 6 | Replaced fake purchase simulation with honest "Coming Soon — In-App Purchases Disabled in MVP" state. No misleading payment claims. |
| **Insecure Release Signing (Debug Keystore Fallback)** | Phase 7 | `android/app/build.gradle.kts` updated so release builds NEVER fall back to debug key. `android/key.properties.example` provided. Cleartext HTTP disabled (`usesCleartextTraffic="false"`). Explicit `minSdk = 21`. |
| **Empty 0-Byte Doctor Share Files** | Phase 6 | Removed 0-byte placeholders and unified clinical sharing under `lib/features/access/` with explicit consent scopes, expiry dates, and revocation controls. |

---

## 3. Deployment Readiness Prerequisites

Before releasing to Google Play Store and Apple App Store:
1. **Provide Production Supabase Credentials**:
   - Provide `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define` at build time or CI secrets.
2. **Configure Android Keystore**:
   - Copy `android/key.properties.example` to `android/key.properties` and provide production release keystore credentials.
3. **Configure Apple Developer Team**:
   - Set valid Development Team ID in Xcode project for iOS code signing.
