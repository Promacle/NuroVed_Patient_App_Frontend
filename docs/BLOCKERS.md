# NuroVed Patient App — Blockers & Required Credentials

> **Document Status**: ACTIVE (PENDING USER INPUT)  
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
| **Android Release Signing Keystore** | Keystore file (`.jks`), key alias, keystore password, and key password (passed securely via environment or untracked file). | Required to produce valid production release APK/AAB; currently release build uses debug keystore. | **BLOCKED**: Debug key configured in `build.gradle.kts`. |
| **Firebase / APNs Push Notification Configuration** | `google-services.json` (Android) and `GoogleService-Info.plist` (iOS). | Required to configure real medication reminders and doctor-share alerts. | **BLOCKED**: Notifications are currently hardcoded static widgets. |

---

## 4. Product Scope Decisions

| Item | Context / Choice | Decision Needed | Impact on Implementation |
| :--- | :--- | :--- | :--- |
| **Payment & Subscription Integration** | Premium screen currently simulates subscription purchases with "Demo: Failed" and "Demo: Renew" buttons. | Should in-app purchases (RevenueCat / Razorpay / Stripe) be integrated now, or should Premium be disabled/marked as "Coming Soon" for MVP? | If MVP: Hide demo buttons, disable checkout, and document in `docs/MVP_SCOPE.md`. If required: payment gateway credentials needed. |
| **Food & Barcode Scanner Database** | Food scanner currently displays hardcoded "Lay's Sour Cream & Onion" for any scanned barcode. | Should a third-party food API (e.g. Open Food Facts API) be integrated, or should scanner be scoped out or set to show "Barcode not recognized"? | Prevents misleading diabetic patients with false nutritional information. |
| **Doctor Share Module Scope** | All 4 files under `lib/features/doctor_share/` are 0-byte empty files. | Is doctor sharing distinct from the Hospital Access screen (`lib/features/access/`), or should they be unified under one Access Management feature? | Unifying prevents duplicated/orphaned code paths and clarifies patient consent. |
