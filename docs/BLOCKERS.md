# NuroVed Patient App — Blockers & Required Credentials

> **Document Status**: ACTIVE (PHASE 0 REVISED)  
> **Date**: October 23, 2026

The following items are required to transition from local/mock repair into live end-to-end verification and production readiness.

---

## 1. Backend Project & API Credentials

| Item | Description | Why It Is Needed | Current State |
| :--- | :--- | :--- | :--- |
| **Backend URL & Anon Key** | Supabase project URL (`https://xyz.supabase.co`) and public anonymous API key (`anon-key`). | Required to connect Flutter client to live authentication, database tables, and storage buckets. | **BLOCKED**: No backend package or credentials configured in repo. |
| **Supabase Project Access / Schema Migrations** | Access to database dashboard or SQL migration scripts for tables: `profiles`, `family_members`, `medical_records`, `visits`, `access_grants`, `medication_routines`. | Required to verify Row Level Security (RLS) policies and ensure database columns match frontend model schemas. | **BLOCKED**: No SQL schema or backend migrations present in frontend repository. |
| **Private Storage Bucket Setup** | Bucket named `medical-records` configured with private ACL and authenticated RLS policies. | Medical records (PDFs/images) must be stored securely and served only via short-lived signed URLs. | **BLOCKED**: Storage bucket does not exist. |

---

## 2. Test Accounts & Personas

| Item | Description | Why It Is Needed | Current State |
| :--- | :--- | :--- | :--- |
| **Primary Patient Test Account** | Valid credentials (email + password or phone OTP) for testing. | To verify sign-in, profile updates, and session expiration without using personal credentials. | **BLOCKED**: Hardcoded to personal account `malekfazilkhan@gmail.com`. |
| **Clinician / Hospital Test Persona** | Test account representing an authorized hospital/clinician. | To verify doctor access sharing, audit trails, and access revocation. | **BLOCKED**: Doctor sharing module is currently 0 bytes. |

---

## 3. Platform & Release Configurations

| Item | Description | Why It Is Needed | Current State |
| :--- | :--- | :--- | :--- |
| **Android Release Signing Keystore** | Keystore file (`.jks`), key alias, keystore password, and key password (passed securely via untracked `android/key.properties`). | Required to produce valid production release APK/AAB; currently release build uses debug keystore. | **BLOCKED**: Debug key configured in `build.gradle.kts`. `android/key.properties.example` to be committed in Stage 1. |
| **Firebase / APNs Push Notification Configuration** | `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). | Required to configure real medication reminders and doctor-share alerts. | **BLOCKED**: Notifications are currently hardcoded static widgets. |

---

## 4. Product Scope Decisions (Resolved & Pending)

| Item | Context / Choice | Status / Decision | Impact on Implementation |
| :--- | :--- | :--- | :--- |
| **Food & Barcode Scanner** | Scanner displays hardcoded Lay's chips for all barcodes; meal planner outputs static meals. | **RESOLVED**: Scanner and meal-generation features will be disabled with a clear "Unavailable" state in Stage 1. **No external food API will be integrated in MVP.** | Prevents false medical/nutritional claims; zero external API dependencies. |
| **Payment & Subscription Integration** | Premium screen currently simulates subscription purchases with "Demo: Failed" and "Demo: Renew" buttons. | **PENDING USER DECISION**: Confirm disabling subscription checkout and marking as "Coming Soon" in MVP. | Hides demo buttons, disables simulated purchases, and documents in `docs/MVP_SCOPE.md`. |
| **Doctor Share Module Scope** | All 4 files under `lib/features/doctor_share/` are 0-byte empty files. | **PENDING USER DECISION**: Confirm unifying Doctor Share with Hospital Access (`lib/features/access/`) under single Access Management feature. | Eliminates 4 dead 0-byte files; unifies consent and audit logs. |
