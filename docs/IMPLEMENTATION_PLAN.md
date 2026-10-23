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
   - Strip all hardcoded personal data from `lib/` (name `"Fazilkhan Malek"`, email `"malekfazilkhan@gmail.com"`, phone `"+91 98765 43210"`, DOB `"02/05/2007"`, family members `"Umar chk"`, `"Sara Malek"`, user ID `"23802839490"`).
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

### Exit Gate
- `dart format .` passes.
- `flutter analyze` reports zero errors, asset warning resolved.
- `flutter test` passes all validator unit tests.
- `flutter build web` succeeds with zero `dart:io` compiler warnings or runtime web crashes.
- Zero personal data remains hardcoded in `lib/`.
- Food scanner and meal generation explicitly show "Unavailable".

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

---

## Stage 4: Backend Persistence & Private Storage

### Goals
1. Persist medical records, patient profiles, family members, doctor access grants, and clinical visits to remote database tables.
2. Secure file uploads: upload medical document PDFs and images to a private storage bucket (`medical-records`); generate short-lived signed URLs for viewing.
3. Replace display-name based deletion and profile filtering with immutable UUID foreign keys.
4. Add Row Level Security (RLS) enforcement verification: ensure records can only be queried by the authenticated user or an active granted hospital/doctor session.
5. Provide offline caching via local SQLite/Hive or cached responses so data survives offline restarts.

### Files Likely to Change
- `lib/core/repositories/supabase/supabase_records_repository.dart` (NEW)
- `lib/core/repositories/supabase/supabase_profile_repository.dart` (NEW)
- `lib/core/repositories/supabase/supabase_visits_repository.dart` (NEW)
- `lib/core/repositories/supabase/supabase_access_repository.dart` (NEW)
- `lib/features/records/screens/records_screen.dart`
- `lib/features/records/screens/add_record_screen.dart`
- `lib/features/records/controllers/records_controller.dart`
- `lib/features/visits/screens/visits_screen.dart`
- `lib/features/visits/screens/add_visit_screen.dart`
- `lib/features/visits/controllers/visits_controller.dart`
- `lib/features/access/screens/access_screen.dart`
- `lib/features/access/screens/hospital_details_screen.dart`

### Dependencies on Backend Access
- Supabase Project schema migration: `profiles`, `family_members`, `medical_records`, `visits`, `access_grants`.
- Private Storage Bucket: `medical_records`.

### Exit Gate
- Uploaded medical record persists to database and storage, and survives application restart and device reinstall.
- Revoked doctor access immediately denies access to records.

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
