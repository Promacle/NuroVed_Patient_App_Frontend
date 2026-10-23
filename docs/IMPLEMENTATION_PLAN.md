# NuroVed Patient App — Implementation Plan

> **Document Status**: AUDIT & PLAN (PHASE 0 REVISED)  
> **Order**: Security and data-integrity first, followed by auth, backend, features, tests, and polish.  
> **Target Branch**: `nuroved/repair` (sharing ancestry with `origin/main`)  
> **Readiness Baseline Score**: **1.5 / 10**  
> **Score Justification**: Visually complete UI with passing static builds (Android debug APK, Web), but fundamentally lacks backend connectivity, authentication, and data persistence. Zero medical records survive restart. Authentication is completely bypassed/simulated. 15 empty (0-byte) files exist in `lib/`, 10 files contain direct `dart:io` imports causing Web runtime crashes, release builds sign with the debug key, and real personal data (PII) is committed in the remote history.

---

## Stage 1: Safety, Platform Fixes & Data Integrity Foundation

### Goals
1. **Remove Hardcoded Personal Data (PII)**:
   - Strip all hardcoded personal data from `lib/` (full name [REDACTED] in `profile_controller.dart:23`, `routine_controller.dart:18`, `visits_controller.dart:14,21`; email [REDACTED] in `profile_controller.dart:24`, `auth_form.dart:73`, `forgot_password_screen.dart:45`; phone [REDACTED] in `profile_controller.dart:25`; DOB [REDACTED] in `profile_controller.dart:26`, `edit_profile_screen.dart:34`; blood group & allergies [REDACTED] in `profile_controller.dart:28-30`; family members [REDACTED] in `profile_controller.dart:8-9`, `emergency_card_screen.dart:73`; user ID [REDACTED] in `profile_screen.dart:104`).
   - Initialize models to empty/unauthenticated state.

2. **Android Release Signing Fix**:
   - Eliminate release signing with the debug key in `android/app/build.gradle.kts`.
   - Implement keystore configuration loading from untracked `android/key.properties`.
   - Provide and commit `android/key.properties.example` with clear documentation.
   - Add `android/key.properties` and signing keystores (`*.jks`, `*.keystore`) to `.gitignore`.

3. **Platform & Permissions**:
   - Add `android.permission.INTERNET`, `android.permission.CAMERA`, and media permissions to `android/app/src/main/AndroidManifest.xml`.
   - Eliminate all direct `dart:io` imports reachable from web builds; replace with platform-safe abstractions (`Uint8List` bytes / `cross_file`).
   - Fix asset declaration in `pubspec.yaml` (remove non-existent `assets/fonts/`).

4. **Shared Validators & Unit Tests**:
   - Implement robust input validation in `lib/core/utils/validators.dart` (which is currently an empty 0-byte file): email validation, password strength, phone format (E.164 / Indian mobile format), date format (DD/MM/YYYY), and age calculation.
   - Create thorough unit tests covering all validators with 100% test pass rate.

5. **Central Safe Logger**:
   - Create a central logging utility (`lib/core/utils/app_logger.dart`) replacing all `debugPrint` / `print` calls.
   - Enforce security rules: strip or redact passwords, tokens, auth headers, and medical data from logs; restrict verbose logs to debug builds only.

6. **"Backend Not Configured" State**:
   - Implement a safe, graceful "Backend Not Configured" state and banner across the app when Supabase URL/keys are absent, preventing false claims of security, fake auth, or silent failures.

7. **Food Scanner & AI Meal Generation Disablement (Scope Control)**:
   - Disable the food scanner and AI meal generation features with an explicit, user-friendly "Feature Unavailable in MVP" state.
   - **Strict Rule**: Do NOT integrate any external food API in the MVP. Eliminate hardcoded Lay's chips nutritional claims and fake weekly meal outputs.

8. **Typed Domain Models**:
   - Create immutable, null-safe domain models in `lib/core/models/` with immutable `final String id` (UUIDs): `UserProfile`, `FamilyMember`, `MedicalRecord`, `Visit`, `RoutineMedicine`, `RoutineMeal`, `AccessGrant`.
   - Eliminate raw `Map<String, dynamic>` across business logic.

### Files Likely to Change
- `pubspec.yaml`
- `.gitignore`
- `android/app/build.gradle.kts`
- `android/key.properties.example` (NEW)
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `lib/core/models/user_profile.dart` (NEW)
- `lib/core/models/family_member.dart` (NEW)
- `lib/core/models/medical_record.dart` (NEW)
- `lib/core/models/visit.dart` (NEW)
- `lib/core/models/routine_item.dart` (NEW)
- `lib/core/models/access_grant.dart` (NEW)
- `lib/core/utils/platform_file.dart` (NEW cross-platform file wrapper)
- `lib/core/utils/validators.dart` (Implement previously 0-byte file)
- `lib/core/utils/app_logger.dart` (NEW safe logger)
- `test/unit/validators_test.dart` (NEW)
- `lib/features/home/widgets/home_header.dart`
- `lib/features/records/screens/add_record_screen.dart`
- `lib/features/records/widgets/profile_selector.dart`
- `lib/features/visits/screens/add_visit_screen.dart`
- `lib/features/routine/screens/add_medicine_screen.dart`
- `lib/features/family/screens/add_family_member_screen.dart`
- `lib/features/family/screens/edit_family_member_screen.dart`
- `lib/features/family/widgets/family_member_tile.dart`
- `lib/features/diet/screens/ai_diet_planner_screen.dart`
- `lib/features/diet/screens/food_scanner_screen.dart` (Set to Unavailable)
- `lib/features/diet/screens/diet_output_screen.dart` (Set to Unavailable)
- `lib/features/profile/screens/edit_profile_screen.dart`
- `lib/features/profile/screens/emergency_card_screen.dart`
- `lib/features/profile/screens/profile_screen.dart`
- `lib/features/profile/controllers/profile_controller.dart`

### Risks & Mitigations
- *Risk*: Switching from dynamic maps to typed models could break existing widgets expecting specific map keys.
- *Mitigation*: Implement bidirectional JSON/Map serializers (`fromMap` / `toMap`) on all domain models during the transition period.

### Dependencies on Backend Access
- None (All Stage 1 safety, platform, model, validator, and scope fixes are local code refactors).

### Exit Gate [STATUS: COMPLETED & VERIFIED]
- `dart format --set-exit-if-changed .`: **VERIFIED** (Passed, 138 files formatted, 0 changed).
- `flutter analyze --no-fatal-infos`: **VERIFIED** (Passed with 0 errors, 0 warnings; pubspec font asset warning resolved).
- `flutter test`: **VERIFIED** (Passed 36/36 unit and widget tests covering validators, logger PII scrubbing, domain models, Result type, and MyApp smoke test).
- `flutter build apk --debug`: **VERIFIED** (Built `build/app/outputs/flutter-apk/app-debug.apk` in 20.9s).
- `flutter build web`: **VERIFIED** (Built `build/web` in 23.0s with zero `dart:io` references or web compilation crashes).
- Zero personal data remains hardcoded in `lib/`: **VERIFIED** (Replaced with dynamic values and "Not provided" empty states).
- Food scanner and meal generation explicitly show "Unavailable": **VERIFIED** (DEC-005 implemented with clean "Feature Unavailable" UI and clinical honesty badge).

---

## Stage 2: Architecture & Provider State Management Refactoring

### Goals
1. Eradicate hidden singletons (`static final _instance = ..._internal()`) across all controllers (`HomeController`, `ProfileController`, `VisitsController`, `RoutineController`, `DietController`, `AppSettingsController`).
2. Implement top-level `MultiProvider` in `AppBinding` (`lib/app/app_binding.dart`) wrapped around `MaterialApp` in `lib/app/app.dart`.
3. Provide clean dependency injection: controllers depend on abstract repository interfaces (`AuthRepository`, `ProfileRepository`, `RecordsRepository`, `VisitsRepository`, `RoutineRepository`).
4. Implement in-memory fake repositories for unit and widget testing without network dependency.
5. Fix controller lifecycle leaks: ensure `dispose()` is executed properly and `PageController`s are cleaned up.

### Files Likely to Change
- `lib/app/app.dart`
- `lib/app/app_binding.dart`
- `lib/core/repositories/auth_repository.dart` (NEW interface)
- `lib/core/repositories/profile_repository.dart` (NEW interface)
- `lib/core/repositories/records_repository.dart` (NEW interface)
- `lib/core/repositories/visits_repository.dart` (NEW interface)
- `lib/core/repositories/routine_repository.dart` (NEW interface)
- `lib/core/repositories/fakes/fake_auth_repository.dart` (NEW)
- `lib/core/repositories/fakes/fake_records_repository.dart` (NEW)
- `lib/features/auth/controllers/auth_controller.dart`
- `lib/features/home/controllers/home_controller.dart`
- `lib/features/profile/controllers/profile_controller.dart`
- `lib/features/family/controllers/family_controller.dart`
- `lib/features/records/controllers/records_controller.dart`
- `lib/features/visits/controllers/visits_controller.dart`
- `lib/features/routine/controllers/routine_controller.dart`
- `lib/features/diet/controllers/diet_controller.dart`
- `lib/features/settings/controllers/app_settings_controller.dart`

### Exit Gate
- Zero hidden singletons remain in `lib/`.
- All controllers instantiate cleanly via Provider tree.
- `flutter analyze` passes without broken provider references.

---

## Stage 3: Authentication & Session Security

### Goals
1. Integrate real authentication provider (e.g. Supabase Auth) via `AuthRepository`.
2. Bind input fields in `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen` to real controller fields.
3. Implement authentic session lifecycle: secure token storage, splash route auth state checking, auto-login for active sessions, and true logout that invalidates sessions.
4. Add `context.mounted` verification after every asynchronous operation before navigation or context usage.
5. Ensure double-submission protection and loading spinners during auth requests.

### Files Likely to Change
- `pubspec.yaml` (Add `supabase_flutter` or approved auth client)
- `lib/core/services/supabase_service.dart` (NEW)
- `lib/features/auth/controllers/auth_controller.dart`
- `lib/features/auth/screens/loading_screen.dart`
- `lib/features/auth/screens/login_screen.dart`
- `lib/features/auth/screens/signup_screen.dart`
- `lib/features/auth/screens/forgot_password_screen.dart`
- `lib/features/auth/widgets/auth_form.dart`
- `lib/features/profile/screens/profile_screen.dart` (Logout logic)

### Dependencies on Backend Access
- Backend URL and Anonymous Key (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).

### Exit Gate
- Full sign-in, sign-up, session check, and sign-out flows execute with state preservation.
- Every `await` is guarded with `if (!context.mounted) return;`.

### Phase 2 Verification Results
- `flutter analyze --no-fatal-infos`: **VERIFIED** (Passed with 0 errors, 0 warnings).
- `flutter test`: **VERIFIED** (Passed 74/74 tests covering AuthController, session restoration, route guards, logout cleanup, validators, logger, models, and smoke tests).
- `flutter build apk --debug`: **VERIFIED** (Built `build/app/outputs/flutter-apk/app-debug.apk` in 25.9s).
- `flutter build web`: **VERIFIED** (Built `build/web` in 33.3s with zero web compilation errors).
- `SupabaseAuthRepository`: **IMPLEMENTED-UNVERIFIED** (Production repository implemented using Supabase Auth REST and `delete_user_account` RPC; live credentials unconfigured in local test environment).
- `FakeAuthRepository`: **VERIFIED** (Full in-memory implementation supporting credential verification, session token storage, password change, email update, and permanent account deletion).
- Route Guards: **VERIFIED** (Unauthenticated users attempting to access `/home`, `/records`, `/visits` redirected to `/login`; authenticated users redirected to `/home`).
- Dead-Control Sweep: **VERIFIED** (Eliminated all simulated snackbars, wired email and password controllers, added terms checkbox, wired password visibility toggles, provided unconfigured notification for Google button).
- Documentation: **VERIFIED** (`docs/TESTING_GUIDE.md` and `docs/SUPABASE_SETUP.md` created and committed).

---

## Stage 4: Backend Schema, Row Level Security & Private Storage (Phase 3)

### Goals
1. Create version-controlled, non-destructive, idempotent PostgreSQL migrations in `supabase/migrations/` for core MVP tables: `profiles`, `family_members`, `care_access_grants`, `medical_records`, `visits`, `visit_record_links`, `medication_routines`, `medication_completions`, `audit_events`, and unified view `patient_timeline` (`WITH (security_invoker = true)`).
2. Enforce primary keys (UUIDs), foreign key constraints with cascade/set null rules, validation checks (`CHECK` constraints for email, phone, blood group, grant status, mime type), auto-updating `updated_at` triggers, and covering indexes.
3. Enable Row Level Security (RLS) on all 9 tables with granular, explicit policies for `SELECT`, `INSERT`, `UPDATE`, and `DELETE` enforcing patient ownership and scoped caregiver/clinician access via `public.has_active_grant()`.
4. Configure private storage bucket `medical-records` with strict path hierarchy `{owner_uid}/{subject_id}/{record_id}/{filename}`, max 10MB limit, allowed MIME types (`application/pdf`, `image/jpeg`, `image/png`), and signed-URL authorization RPC `public.authorize_medical_file_access()`.
5. Enforce append-only immutable audit trail via database trigger on `audit_events` preventing any `UPDATE` or `DELETE`.
6. Zero privileged `service_role` keys in client code; enforce least-privilege authenticated user JWTs.
7. Provide comprehensive RLS policy test suite (`supabase/tests/rls_policies_test.sql`) executing inside a rollback transaction.
8. Document full security matrix in `docs/SECURITY_REVIEW.md`.

### Files Created
- `supabase/migrations/20261023000001_core_schema.sql` (Core schema, constraints, indexes, triggers, timeline view, audit trigger)
- `supabase/migrations/20261023000002_row_level_security.sql` (RLS policies, `has_active_grant()` helper)
- `supabase/migrations/20261023000003_storage_security.sql` (Private storage bucket, storage RLS, `authorize_medical_file_access()` RPC)
- `supabase/tests/rls_policies_test.sql` (Automated transactional policy verification suite)
- `docs/SECURITY_REVIEW.md` (Security matrix, storage path conventions, execution guide)

### Dependencies on Backend Access
- Supabase CLI or project SQL Editor access to execute migrations on remote project.

### Exit Gate
- Migrations and policy tests authored, non-destructive, idempotent, and documented.
- Security matrix and execution guide complete in `docs/SECURITY_REVIEW.md`.
- Status labeled as `IMPLEMENTED-UNVERIFIED` due to absent local Supabase CLI/Docker environment.

### Phase 3 Verification Results
- `flutter test`: **VERIFIED** (74/74 tests passing; regression suite clean).
- `flutter analyze --no-fatal-infos`: **VERIFIED** (0 errors, 0 warnings).
- Zero `service_role` keys in repository: **VERIFIED** (`git grep` clean; only public anon key and authenticated JWTs used).
- Schema Migrations: **IMPLEMENTED-UNVERIFIED** (Authored in `supabase/migrations/` with idempotent `CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS`, and drop-create triggers; requires live Supabase instance or Docker CLI to execute).
- Storage Configuration & RLS: **IMPLEMENTED-UNVERIFIED** (Bucket definition and object-level RLS policies in `20261023000003_storage_security.sql`; requires live Supabase instance to execute).
- RLS Policy Test Suite: **IMPLEMENTED-UNVERIFIED** (Authored in `supabase/tests/rls_policies_test.sql` with self-contained `BEGIN ... ROLLBACK` testing matrix; requires live PostgreSQL/Supabase instance to execute).
- Security Architecture Matrix: **VERIFIED** (Documented in `docs/SECURITY_REVIEW.md`).

---

## Stage 4.5: Profile, Family Profiles, Active Subject Isolation & Emergency Card (Phase 4)

### Goals
1. Strongly typed profile and family models with immutable UUIDs matching backend schema.
2. Patient profile editing with input validation, photo validation (size <= 10MB, extension jpg/jpeg/png), and optimistic UI with rollback on repository failure.
3. Family profiles CRUD: add, edit, select, and remove with confirmation. Members managed with stable UUIDs.
4. Delegated access model: explicit `care_access_grants` relation (invite, accept, scope check, revocation). Existence of family member does NOT automatically grant access.
5. Profile switching with strict data isolation: `activeSubjectId` acts as single source of truth; records, routines, visits, and timeline immediately purge previous subject data and reload for active subject.
6. Emergency card: displays only patient-entered data, missing fields fallback to "Not provided" (hard-coded defaults removed), renders prominent "PATIENT-ENTERED, UNVERIFIED" badge, dynamically displays designated emergency contact.
7. Local cache persistence across app restarts with retry on network failure.

### Files Created / Modified
- `lib/core/models/care_access_grant.dart` (NEW domain model for access grants)
- `lib/core/models/family_member.dart` (Verified stable UUIDs and emergency contact attributes)
- `lib/core/repositories/profile_repository.dart` (Contract with family CRUD and caregiver grant operations)
- `lib/core/repositories/fake/fake_profile_repository.dart` (In-memory implementation with simulated failure toggle)
- `lib/features/profile/controllers/profile_controller.dart` (Refactored for optimistic UI, active subject isolation, avatar validation, offline cache)
- `lib/features/family/controllers/family_controller.dart` (Delegates to ProfileController with stable UUIDs)
- `lib/features/records/controllers/records_controller.dart` (Strict subject isolation and cache purge on switch)
- `lib/features/visits/controllers/visits_controller.dart` (Strict subject isolation and cache purge on switch)
- `lib/features/routine/controllers/routine_controller.dart` (Strict subject isolation for medications and meals)
- `lib/features/profile/screens/emergency_card_screen.dart` (Removed hardcoded defaults, added unverified badge, dynamic contact)
- `lib/features/profile/screens/edit_profile_screen.dart` (Avatar validation, input validation, optimistic save)
- `lib/features/family/screens/family_profile_screen.dart` (Active indicator badge, bottom sheet for switching/editing, delete confirmation)
- `lib/features/family/screens/edit_family_member_screen.dart` (Stable UUID update support)
- `lib/features/access/screens/access_screen.dart` (Caregiver invite with scopes and revocation dialog)
- `lib/features/access/screens/hospital_details_screen.dart` (Revoke access button with confirmation)
- `lib/app/app_binding.dart` (Registered ProfileRepository and ProfileController in MultiProvider)
- `test/features/profile/profile_controller_test.dart` (12 unit tests for profile CRUD, optimistic rollback, avatar validation, age calculation)
- `test/features/family/family_isolation_test.dart` (5 integration tests for family CRUD and strict multi-profile data isolation)
- `test/features/profile/emergency_card_test.dart` (4 widget tests for empty/partial/full emergency card states and unverified badge)
- `test/features/access/caregiver_scope_test.dart` (5 tests for caregiver invite, accept, scope evaluation, and revocation)

### Phase 4 Verification Results
- `flutter test`: **VERIFIED** (99/99 tests passing; 26 new tests added for Phase 4).
- `flutter analyze --no-fatal-infos`: **VERIFIED** (0 errors, 0 warnings).
- Dead-Control Sweep: **VERIFIED** (Profile edit, avatar pickers, family add/edit/delete, switch subject, caregiver invite and revocation all cleanly wired).
- Documentation: **VERIFIED** (`docs/TESTING_GUIDE.md` updated with Suites 9-13).

---

## Stage 5: Feature Repair & Dead-Control Elimination

### Goals
1. Fix all broken navigation routes (e.g. `ChangeEmailScreen` navigating to `ChangePasswordScreen`).
2. Eliminate all 7 empty callback closures identified in the Dead-Control Sweep:
   - `lib/features/home/widgets/record_card.dart:59` ("View" record)
   - `lib/features/records/widgets/records_widgets.dart:79` (Filter button)
   - `lib/features/visits/screens/select_related_records.dart:122` ("View" related record)
   - `lib/features/visits/widgets/visit_timeline_item.dart:135` ("View Related Record")
   - `lib/features/settings/screens/settings_screen.dart:47, 55` (Privacy policy, Terms of service)
   - `lib/features/settings/screens/data_privacy_screen.dart:58` (Privacy policy)
3. Connect `RoutineScreen` FAB to navigate to `AddMedicineScreen`.
4. Fix non-interactive contact tiles in `CustomerSupportScreen` to launch WhatsApp (`whatsapp://send`), website (`https://`), and dialer (`tel:`).
5. Address out-of-scope / simulated features:
   - Disable or clearly mark simulated "Demo: Failed" / "Demo: Renew" buttons in `PurchaseScreen` and document in `docs/MVP_SCOPE.md`.

### Files Likely to Change
- `lib/features/settings/screens/change_email_screen.dart`
- `lib/features/settings/screens/change_password_screen.dart`
- `lib/features/settings/screens/settings_screen.dart`
- `lib/features/settings/screens/data_privacy_screen.dart`
- `lib/features/settings/screens/customer_support_screen.dart`
- `lib/features/routine/screens/routine_screen.dart`
- `lib/features/routine/screens/add_medicine_screen.dart`
- `lib/features/home/widgets/record_card.dart`
- `lib/features/visits/widgets/visit_timeline_item.dart`
- `lib/features/premium/screens/purchase_screen.dart`
- `docs/MVP_SCOPE.md` (NEW)

### Exit Gate
- Dead-control grep sweep returns 0 hits in `lib/`.

---

## Stage 6: Test Suite, Verification & Final Polish

### Goals
1. Replace broken counter template test in `test/widget_test.dart` with valid root widget tests.
2. Implement unit tests for domain models, auth controller, records controller, visits controller, and routine adherence calculator.
3. Migrate all 139 deprecated `.withOpacity()` occurrences to `.withValues(alpha: ...)`.
4. Fix formatting across codebase: `dart format .`.
5. Execute end-to-end Dead-Control Sweep and verify clean Android and Web builds.

### Exit Gate
- `flutter test` runs and passes 100% of tests.
- `flutter analyze` reports **0 issues**.
- `flutter build apk --debug` and `flutter build web` complete with 0 errors.
- `docs/FIX_IMPLEMENTATION_REPORT.md` updated with evidence.
