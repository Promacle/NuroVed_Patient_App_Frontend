# NuroVed Patient App — Frontend Audit (Phase 0)

> **Document Status**: AUDIT COMPLETE (READ-ONLY)  
> **Date**: October 23, 2026  
> **Repository**: `https://github.com/Promacle/NuroVed_Patient_App_Frontend.git`  
> **Branch**: `nuroved/repair`  
> **Environment**: macOS darwin-arm64, Flutter 3.38.5 (Channel stable), Dart 3.10.4

---

## 1. Executive Summary & Baseline Results

### Baseline Execution Evidence

1. **Git Repository Status**:
   - Initial run:
     ```bash
     $ git status ; git log --oneline -20 ; git branch -a
     fatal: not a git repository (or any of the parent directories): .git
     ```
   - *Action Taken*: Workspace was unzipped/downloaded without a `.git` folder. Initialized clean Git repo, configured remote origin `https://github.com/Promacle/NuroVed_Patient_App_Frontend.git`, created initial baseline commit, and switched to working branch `nuroved/repair`.

2. **Flutter Environment (`flutter --version ; flutter doctor -v`)**:
   - **Flutter**: 3.38.5, channel stable, revision `f6ff1529fd`
   - **Dart**: 3.10.4 (DevTools 2.51.1)
   - **Android SDK**: 36.1.0 (build-tools 36.1.0), JDK 21.0.8 bundled with Android Studio
   - **Xcode**: 27.0 (Build 27A266a), CocoaPods 1.16.2
   - **Connected Devices**: macOS (desktop darwin-arm64), Chrome (web-javascript)
   - *Doctor Warnings*: Android licenses unaccepted (`flutter doctor --android-licenses`), iOS 27.0 Simulator not installed, PATH warnings for Flutter and Dart binaries.

3. **Dependencies & Packages (`flutter pub get ; flutter pub outdated`)**:
   - `flutter pub get`: Succeeded with code 0 (`Changed 2 dependencies! 44 packages have newer versions`).
   - `flutter pub outdated`: Direct dependencies with outdated constraints: `cupertino_icons`, `file_picker`, `fl_chart`, `font_awesome_flutter`, `image_picker`, `intl`, `mobile_scanner`, `shared_preferences`, `shimmer`, `url_launcher`.
   - **CRITICAL BACKEND OMISSION**: No backend client package exists in `pubspec.yaml`. Neither `supabase_flutter`, `http`, `dio`, nor `firebase_core` is present.

4. **Static Analysis (`flutter analyze`)**:
   - Exit code: **1**
   - Total issues: **141 issues found**
   - Categories:
     - 1 Error/Warning in `pubspec.yaml:75:7`: `The asset directory 'assets/fonts/' doesn't exist`
     - 1 Warning in `lib/features/routine/screens/routine_screen.dart:468:11`: Unused local variable `dashedPaint`
     - 139 Infos: Deprecated `.withOpacity()` usage (should use `.withValues()`), flow control missing curly braces (`curly_braces_in_flow_control_structures`), unnecessary casts.

5. **Test Suite (`flutter test`)**:
   - Exit code: **1**
   - Results: **1 test run, 1 failed (0 passed)**
   - Failure: `test/widget_test.dart:18:5` — Default Flutter sample counter test asserting `'0'` and `'1'`, failing against `MyApp()`. No domain unit or widget tests exist.

6. **Build Verifications**:
   - **Android Debug APK (`flutter build apk --debug`)**: Succeeded (`✓ Built build/app/outputs/flutter-apk/app-debug.apk` in 333.4s).
     - Warnings: Obsolete Java source/target 8 from legacy plugins, missing `assets/fonts/` directory entry.
   - **Web Build (`flutter build web`)**: Succeeded (`✓ Built build/web` in 24.3s).
     - Note: While the static compiler passes, runtime usage of `dart:io` in 10 reachable files will trigger fatal crashes on Web when opened in a browser.

---

## 2. Inventories (A through H)

### A. Screens and Routes Inventory

| Screen Name | File Path | Route Constant | Navigation Method | Required Arguments | Destination & Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `LoadingScreen` | `lib/features/auth/screens/loading_screen.dart` | `/` (`AppRouter.loading`) | Initial route | None | Timer/Animation navigates to `/splash`. WORKS (missing mounted check). |
| `SplashScreen` | `lib/features/auth/screens/splash_screen.dart` | `/splash` | Named route | None | Navigates to `/login` or `/signup`. External links to google.com terms/privacy. |
| `LoginScreen` | `lib/features/auth/screens/login_screen.dart` | `/login` | Named route | None | Sign In navigates to `/home` with NO auth check. Google login empty. |
| `SignUpScreen` | `lib/features/auth/screens/signup_screen.dart` | `/signup` | Named route | None | Multi-step sign-up. Discards inputs and navigates to `/home`. |
| `ForgotPasswordScreen` | `lib/features/auth/screens/forgot_password_screen.dart` | `/forgot-password` | Named route | None | Shows modal with hardcoded email `elem*******221b@gmail.com`. FAKE-SUCCESS. |
| `MainLayout` | `lib/features/home/screens/main_layout.dart` | `/home` | Named route | `initialIndex` (optional int) | Hosts `IndexedStack` with 5 tab navigators. WORKS. |
| `HomeScreen` | `lib/features/home/screens/home_screen.dart` | Nested Tab 0 | Tab index | None | Header, static chart, quick access, hardcoded record cards. |
| `RecordsScreen` | `lib/features/records/screens/records_screen.dart` | `/records` (Tab 1) | Tab index / Named | None | Record grid, filter chips, profile selector, FAB to add. |
| `AddRecordScreen` | `lib/features/records/screens/add_record_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | None | File picker, metadata. In-memory save to `ProfileController`. |
| `RecordSuccessScreen` | `lib/features/records/screens/record_success_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | `profileName`, `date` | Success acknowledgment. Navigates back to Records tab. |
| `FoodScannerScreen` | `lib/features/diet/screens/food_scanner_screen.dart` | Nested Tab 2 | Tab index | None | Camera QR/barcode scan. Shows hardcoded Lay's chips for ANY code. |
| `FoodScannerHistoryScreen` | `lib/features/diet/screens/food_scanner_history_screen.dart` | `/food-scanner-history` | Named route | None | Static hardcoded list (Lay's, CocaCola). |
| `CalorieSuccessScreen` | `lib/features/diet/screens/calorie_success_screen.dart` | `/calorie-success` | Named route | `DateTime timestamp` | Static intake success acknowledgment. |
| `DietScreen` | `lib/features/diet/screens/diet_screen.dart` | `/diet` | Named route | None | Hardcoded charts and quick action links. |
| `AiDietPlannerScreen` | `lib/features/diet/screens/ai_diet_planner_screen.dart` | `/ai-diet-planner` | Named route | None | Form inputs for age, weight, height. Navigates to preferences. |
| `DietPreferenceScreen` | `lib/features/diet/screens/diet_preference_screen.dart` | `/diet-preference` | Named route | None | Vegetarian, non-veg, allergies preferences. |
| `HealthGoalScreen` | `lib/features/diet/screens/health_goal_screen.dart` | `/health-goal` | Named route | None | Goal selection (Weight loss, diabetes maintenance). |
| `TimeAndContextScreen` | `lib/features/diet/screens/time_and_context_screen.dart` | `/time-and-context` | Named route | None | Meal timings and context. Navigates to output. |
| `DietOutputScreen` | `lib/features/diet/screens/diet_output_screen.dart` | `/diet-output` | Named route | None | Generates static hardcoded weekly meal plan. |
| `EditMealScreen` | `lib/features/diet/screens/edit_meal_screen.dart` | `/edit-meal` | Named route | None | Edits in-memory meal plan. |
| `DietSuccessScreen` | `lib/features/diet/screens/diet_success_screen.dart` | `/diet-success` | Named route | `DateTime timestamp` | Diet routine saved acknowledgment. |
| `MealRoutineHistoryScreen` | `lib/features/diet/screens/meal_routine_history_screen.dart` | `/meal-routine-history` | Named route | None | Static meal history timeline. |
| `VisitsScreen` | `lib/features/visits/screens/visits_screen.dart` | `/visits` (Tab 3) | Tab index / Named | None | Shows dummy timeline visits. Filtered by active profile. |
| `AddVisitScreen` | `lib/features/visits/screens/add_visit_screen.dart` | `/add-visit` | Named route | None | Form to add visit. Saves only to in-memory singleton. |
| `VisitDetailsScreen` | `lib/features/visits/screens/visit_details_screen.dart` | None | Direct Push (Never called) | None | **EMPTY FILE (0 bytes)**. |
| `SelectRelatedRecords` | `lib/features/visits/screens/select_related_records.dart` | None (Direct Push) | Direct `MaterialPageRoute` | `selectedProfile` | Selects record to attach to visit. |
| `ProfileScreen` | `lib/features/profile/screens/profile_screen.dart` | `/profile` (Tab 4) | Tab index / Named | None | Shows hardcoded profile data and metrics. |
| `EditProfileScreen` | `lib/features/profile/screens/edit_profile_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | `initialData` (Map) | Edits profile data and photo. Updates in-memory map. |
| `EmergencyCardView` | `lib/features/profile/screens/emergency_card_screen.dart` | None | Embedded in Profile | `data` (Map) | QR code and medical emergency summary. |
| `FamilyProfilesScreen` | `lib/features/family/screens/family_profile_screen.dart` | `/family-profiles` | Named route | None | Lists family members. Add and edit actions. |
| `AddFamilyMemberScreen` | `lib/features/family/screens/add_family_member_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | None | Form to add family member. Saves to in-memory list. |
| `EditFamilyMemberScreen` | `lib/features/family/screens/edit_family_member_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | `memberData`, `index` | Form to edit member. Updates in-memory list by index. |
| `AccessScreen` | `lib/features/access/screens/access_screen.dart` | `/access` | Named route | None | Manage hospital access. In-memory grant access list. |
| `HospitalDetailsScreen` | `lib/features/access/screens/hospital_details_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | Hospital parameters | Details and fake activity log. No revoke capability. |
| `RoutineScreen` | `lib/features/routine/screens/routine_screen.dart` | `/routine` | Named route | None | Medications & routine tracking. FAB is empty callback. |
| `AddMedicineScreen` | `lib/features/routine/screens/add_medicine_screen.dart` | None | Unreachable | None | Form to add medicine. Unreachable from UI. |
| `RoutineDetailScreen` | `lib/features/routine/screens/routine_detail_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | None | Details of routine. |
| `EditRoutineScreen` | `lib/features/routine/screens/edit_routine_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | Routine parameters | Edit routine parameters. |
| `RoutineSuccessScreen` | `lib/features/routine/screens/routine_success_screen.dart` | None (Direct Push) | Direct `MaterialPageRoute` | None | Routine update acknowledgment. |
| `NotificationsScreen` | `lib/features/notifications/screens/notification_screen.dart` | `/notifications` | Named route | None | Hardcoded notification cards. |
| `PremiumScreen` | `lib/features/premium/screens/premium_screen.dart` | `/premium` | Named route | None | Plan selection (Monthly/Yearly). Navigates to `/purchase`. |
| `PurchaseScreen` | `lib/features/premium/screens/purchase_screen.dart` | `/purchase` | Named route | `Map<String, dynamic>` args | Payment methods. Contains "Demo: Failed" / "Demo: Renew". |
| `PremiumStatusScreen` | `lib/features/premium/screens/premium_status_screen.dart` | `/premium-status` | Named route | `Map<String, dynamic>` args | Receipt / failure card. Simulated transaction. |
| `SettingsScreen` | `lib/features/settings/screens/settings_screen.dart` | `/settings` | Named route | None | Settings list. Privacy and Terms have empty `onTap: () {}`. |
| `AppSettingsScreen` | `lib/features/settings/screens/app_settings_screen.dart` | `/app-settings` | Named route | None | Time format, weight, height units. Persists to SharedPreferences. |
| `DataPrivacyScreen` | `lib/features/settings/screens/data_privacy_screen.dart` | `/data-privacy` | Named route | None | Privacy settings. Privacy policy has empty `onTap: () {}`. |
| `CustomerSupportScreen` | `lib/features/settings/screens/customer_support_screen.dart` | `/customer-support` | Named route | None | FAQ (works) + Contact Us tiles (non-interactive). |
| `ChangeEmailScreen` | `lib/features/settings/screens/change_email_screen.dart` | `/change-email` | Named route | None | "Save New Email" actually navigates to `/change-password`! |
| `ChangePasswordScreen` | `lib/features/settings/screens/change_password_screen.dart` | `/change-password` | Named route | None | "Save New Password" just calls `Navigator.pop(context)`. |
| `ReportProblemScreen` | `lib/features/settings/screens/report_problem_screen.dart` | `/report-problem` | Named route | None | "Submit" shows SnackBar with no transmission. |
| `ShareAccessScreen` | `lib/features/doctor_share/screens/share_access_screen.dart` | None | Unreachable | None | **EMPTY FILE (0 bytes)**. |
| `ActiveSessionsScreen` | `lib/features/doctor_share/screens/active_sessions_screen.dart` | None | Unreachable | None | **EMPTY FILE (0 bytes)**. |
| `PermissionSettingsScreen` | `lib/features/doctor_share/screens/permission_settings_screen.dart` | None | Unreachable | None | **EMPTY FILE (0 bytes)**. |

---

### B. Interactive Elements Inventory

| File & Line | Control | Current Behavior | Expected Behavior | Status |
| :--- | :--- | :--- | :--- | :--- |
| `login_screen.dart:74` | "Log in with Google" Button | Empty closure `onPressed: () {}` | Trigger OAuth sign-in flow | **EMPTY** |
| `login_screen.dart:119` | "Sign In" Button | Ignores input, debugPrint, navigates to `/home` | Authenticate with backend, validate credentials | **FAKE-SUCCESS** |
| `signup_screen.dart:274` | "Sign Up" Button | Ignores input, navigates to `/home` | Register user account in auth system | **FAKE-SUCCESS** |
| `forgot_password_screen.dart:36` | "Send via Email" Card | Immediately shows bottom sheet for hardcoded email | Input email field and trigger reset email API | **FAKE-SUCCESS** |
| `home_header.dart:29` | Profile avatar & name | Switches to Tab 4 (Profile) | Switches to Profile tab | **WORKS** |
| `home_header.dart:99` | Notification bell | Navigates to `/notifications` | Opens notification center | **WORKS** |
| `home_header.dart:109` | Crown icon | Navigates to `/premium` | Opens premium subscription view | **WORKS** |
| `home_screen.dart:59` | RecordCard "View" button | Empty closure `onPressed: () {}` | Open record viewer / detail dialog | **EMPTY** |
| `records_screen.dart:164` | Record item tap | `debugPrint("Tapped on ${record['title']}")` | Open record detail / PDF preview | **EMPTY** |
| `records_screen.dart:168` | Record delete icon | Removes from in-memory list matching title/date | API deletion with confirmation prompt & ID | **NOT-PERSISTED** |
| `records_screen.dart:181` | FAB Add Record | Opens `AddRecordScreen` | Opens record upload screen | **WORKS** |
| `add_record_screen.dart:85` | Pick File Button | Picks local file using `FilePicker` | Selects file and checks size/mime | **WORKS** |
| `add_record_screen.dart:47` | Save Record Button | Stores in `ProfileController` in-memory list | Uploads to private storage & saves DB row | **NOT-PERSISTED** |
| `records_widgets.dart:79` | Filter button | Empty closure `onPressed: () {}` | Open advanced filter options | **EMPTY** |
| `visits_screen.dart:83` | FAB Add Visit | Navigates to `/add-visit` | Opens add visit screen | **WORKS** |
| `add_visit_screen.dart:31` | Save Visit Button | Inserts into in-memory list `VisitsController` | Persists visit to database | **NOT-PERSISTED** |
| `visit_timeline_item.dart:135` | "View Related Record" Button | Empty closure `onPressed: () {}` | Opens linked medical record | **EMPTY** |
| `select_related_records.dart:122` | "View" button | Empty closure `onPressed: () {}` | Previews record content | **EMPTY** |
| `profile_screen.dart:82` | Edit profile icon | Pushes `EditProfileScreen` | Opens profile edit form | **WORKS** |
| `profile_screen.dart:131` | "Log Out" Button | Prints log, navigates to `/login` without clearing session | Revokes session token and clears cache | **FAKE-SUCCESS** |
| `edit_profile_screen.dart:30` | Image picker | Picks image from gallery | Updates profile image state | **WORKS** |
| `edit_profile_screen.dart:74` | Save Profile Button | Returns updated Map to caller | Persists profile to database | **NOT-PERSISTED** |
| `access_screen.dart:305` | "Review & Grant Access" Button | Appends to local list, shows SnackBar | Submits scoped grant to backend | **NOT-PERSISTED** |
| `routine_screen.dart:73` | FAB Add Medicine | Empty closure `onPressed: () { /* ... */ }` | Navigates to `AddMedicineScreen` | **EMPTY** |
| `routine_screen.dart:90` | Toggle Medicine Checkbox | Toggles in-memory boolean | Persists adherence log | **NOT-PERSISTED** |
| `routine_screen.dart:103` | Intake Meal Button | Sets in-memory boolean `isCompleted: true` | Persists meal log | **NOT-PERSISTED** |
| `food_scanner_screen.dart:58` | Barcode detector | Triggers hardcoded Lay's chips result | Queries food/UPC database | **FAKE-SUCCESS** |
| `food_scanner_screen.dart:266` | "Intake" Button | Navigates to `/calorie-success` | Logs food calories to diary | **NOT-PERSISTED** |
| `purchase_screen.dart:434` | "Demo: Failed" Button | Routes to failure receipt | Real checkout webhook handling | **FAKE-SUCCESS** |
| `purchase_screen.dart:452` | "Demo: Renew" Button | Routes to renewal receipt | Real checkout webhook handling | **FAKE-SUCCESS** |
| `settings_screen.dart:47` | "Privacy Policy" ListTile | Empty closure `onTap: () {}` | Opens privacy policy webpage/dialog | **EMPTY** |
| `settings_screen.dart:55` | "Terms of Service" ListTile | Empty closure `onTap: () {}` | Opens terms of service webpage/dialog | **EMPTY** |
| `data_privacy_screen.dart:58` | "Privacy Policy" Tile | Empty closure `onTap: () {}` | Opens privacy policy webpage/dialog | **EMPTY** |
| `data_privacy_screen.dart:60` | "Delete Account" Button | Shows confirmation, does no deletion | Authenticated account deletion & erasure | **BROKEN** |
| `customer_support_screen.dart:222` | Contact Us Tiles | Arrow down icon, but no `onTap` listener | Launches WhatsApp, website, phone call | **EMPTY** |
| `change_email_screen.dart:165` | "Save New Email" Button | Routes to `/change-password`! | Submits email change verification | **BROKEN** |
| `change_password_screen.dart:176` | "Save New Password" Button | Calls `Navigator.pop(context)` | Updates password in auth provider | **FAKE-SUCCESS** |
| `report_problem_screen.dart:136` | "Submit" Button | Shows SnackBar, does not transmit report | Submits ticket to backend support | **FAKE-SUCCESS** |

---

### C. State Management Inventory

| Controller / Provider | Extends | Creation Scope | Lifecycle & Disposal | Hidden Singleton? | State Owned |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `AuthController` | `ChangeNotifier` | `LoginScreen`, `SignUpScreen` via `ChangeNotifierProvider` | `dispose()` cleans up text controllers, but **LEAKS** `PageController` and `headerPageController`. | No | Login/Signup step index, password visibility, mismatch error. |
| `SplashController` | `ChangeNotifier` | Unused in `SplashScreen` | Never instantiated or disposed. | No | Checkbox boolean. |
| `HomeController` | `ChangeNotifier` | Accessed across app via factory constructor | Singleton created once, **NEVER disposed**. | **YES** (`_instance`) | `_currentIndex` (active bottom navigation tab). |
| `ProfileController` | `ChangeNotifier` | Accessed across app via factory constructor | Singleton created once, **NEVER disposed**. | **YES** (`_instance`) | Raw user data Map, active profile name, in-memory family list, embedded records. |
| `FamilyController` | *None* | Accessed via factory constructor | Singleton wrapper, does not extend `ChangeNotifier`. | **YES** (`_instance`) | Delegates directly to `ProfileController`. |
| `RecordsController` | `ChangeNotifier` | Created in `_RecordsScreenState` | Never disposed. Subscribes to `ProfileController`. | No | `filteredRecords` list, `selectedFilter` string. |
| `VisitsController` | `ChangeNotifier` | Accessed via factory constructor | Singleton created once, **NEVER disposed**. | **YES** (`_instance`) | `_allVisits` list, `filteredVisits` list. |
| `RoutineController` | `ChangeNotifier` | Accessed via factory constructor | Singleton created once, **NEVER disposed**. | **YES** (`_instance`) | `_medicinesPerProfile`, `_mealsPerProfile`, progress calculation. |
| `DietController` | `ChangeNotifier` | Accessed via factory constructor | Singleton created once, **NEVER disposed**. | **YES** (`_instance`) | `_savedDietPlan` Map. |
| `AppSettingsController`| `ChangeNotifier` | Accessed via factory constructor | Singleton created once, **NEVER disposed**. | **YES** (`_instance`) | `timeFormat`, `weightUnit`, `heightUnit`. |
| `DoctorShareController`| *None* | Empty file (0 bytes) | Not implemented. | No | None. |

---

### D. Data Storage & Persistence Inventory

| Feature Data | Storage Medium | Survives App Restart? | Synchronization / Remote |
| :--- | :--- | :--- | :--- |
| **Authentication Session** | Memory | **NO** (App always boots to loading screen, any click bypasses auth) | None |
| **User Profile Data** | Memory (`ProfileController.userData`) | **NO** (Resets to hardcoded "Fazilkhan Malek" on launch) | None |
| **Family Members** | Memory (`ProfileController._familyList`) | **NO** (Resets to default Umar, Sara) | None |
| **Medical Records** | Memory (`ProfileController._familyList[index]['records']`) | **NO** (All uploaded files & metadata vanish on restart) | None |
| **Doctor / Hospital Access** | Memory (`_AccessScreenState._activeHospitals`) | **NO** (Resets on screen pop) | None |
| **Visits Timeline** | Memory (`VisitsController._allVisits`) | **NO** (Resets to 2 dummy visits) | None |
| **Medication Routine** | Memory (`RoutineController._medicinesPerProfile`) | **NO** (Resets to default Atorvastatin/Aspirin) | None |
| **Meals & Diet Plan** | Memory (`DietController._savedDietPlan`, `RoutineController._mealsPerProfile`) | **NO** (Resets to default Oatmeal/Wrap) | None |
| **Food Scanner History** | Hardcoded static widget tree | **NO** (No storage) | None |
| **Notifications** | Hardcoded static widget tree | **NO** (No storage) | None |
| **App Settings** | `SharedPreferences` (`timeFormat`, `weightUnit`, `heightUnit`) | **YES** (Properly loaded and saved via async methods) | Local only |

---

### E. Hardcoded Sample & Demo Data Inventory

1. **User Identity & Personal Details** (`lib/features/profile/controllers/profile_controller.dart:22-34`):
   - Name: `"Fazilkhan Malek"`
   - Email: `"malekfazilkhan@gmail.com"`
   - Phone: `"+91 98765 43210"`
   - Date of Birth: `"02/05/2007"`
   - Height: `"175"`, Weight: `"95"`, Gender: `"male"`, Blood: `"B+"`
   - Allergies: `["Penicillin"]`, Chronic Conditions: `["Mild Asthma"]`
   - Family Members: `"Umar chk"` (Friend), `"Sara Malek"` (Wife)
   - Hardcoded User ID: `"User id: 23802839490"` (`profile_screen.dart:104`)

2. **Visits & Doctors** (`lib/features/visits/controllers/visits_controller.dart:13-27`):
   - `"Visited Dr. Priya Mehta"`, `"Routine diabetes checkup. HbA1c levels discussed."`
   - `"Blood sugar test"`, `"Blood test report for sugar level"`

3. **Medications & Prescriptions** (`lib/features/routine/controllers/routine_controller.dart:30-45`):
   - `"Atorvastatin 10mg"`, `"1 tablet * 09:00 * Take Before bed"`
   - `"Aspirin 75mg"`, `"1 tablet * 09:00 * Take after lunch"`
   - `"Atorvastatin 10mg"`, `"2 tablet * 09:00 * Take before breakfast"`

4. **Diet & Nutrition Data** (`lib/features/routine/controllers/routine_controller.dart:50-79`, `food_scanner_screen.dart:205-260`):
   - Oatmeal with Banana and Almond Milk (350 kCal)
   - Vegetable Wrap and Curd (400 kCal)
   - Quinoa and Vegetable Stir-Fry (500 kCal)
   - Hardcoded Barcode Scan: `"Lay's Sour Cream & Onion - 160 kcal, 10g fat, 170mg sodium, 1g sugar"`

5. **Hospitals & Access Logs** (`lib/features/access/screens/access_screen.dart:20-31`, `hospital_details_screen.dart:194-210`):
   - Apollo Hospitals (Navrangpura, Ahmedabad), Zydus Hospital (Sola Road, Ahmedabad)
   - Hardcoded activity logs: `"Viewed Medical Record By Apollo Hospitals"`, `"Added New Record"`, `"Added New Visits"`

6. **Notifications** (`lib/features/notifications/screens/notification_screen.dart:37-81`):
   - Hardcoded reminder tiles: `"Time For Mom's Medicine"`, `"Blood test Reminder"`, `"5-day Streak!"`, `"Your Data is Encrypted"`.

---

### F. Privacy-Sensitive Operations & Required Authorization

| Operation | Current Implementation | Risk / Vulnerability | Required Backend Authorization |
| :--- | :--- | :--- | :--- |
| **Medical Record Viewing** | Unauthenticated in-memory reading of local file paths | Anyone holding the device views records without session or PIN check | Row-Level Security (RLS) on `records` table, scoped to `patient_id = auth.uid()` |
| **Medical Document Storage** | `FilePicker` paths stored in dynamic maps in RAM | No encryption at rest, no cloud storage | Private storage bucket with short-lived signed URLs generated on-demand |
| **Hospital Access Granting** | Local state toggle with mock expiry | Fake security: access is not enforced, verifiable or auditable | `access_grants` table with strict RLS, valid doctor public keys or scoped auth tokens |
| **Hospital Access Revocation** | Missing from UI completely | Patient cannot revoke shared data | Instant deletion or expiration update on grant token, backend-enforced rejection |
| **Family Member Record Access** | Filtered purely by display name string in UI (`m['name'] == activeProfile`) | Changing a display name breaks or cross-leaks record isolation | Multi-user tenant or scoped family member IDs with explicit role assignments |
| **Emergency Profile Access** | Unauthenticated screen inside app | Available only when already logged in | Public or locked-screen access restricted to emergency-only data (allergies, blood group) |
| **Account Deletion** | Dialog with no backend endpoint | Non-compliant with GDPR / App Store / Play Store deletion requirements | Authenticated cascade deletion of user records, files, and auth account |

---

### G. Platform Issues

1. **`dart:io` Web Compatibility Violations**:
   - `import 'dart:io';` is directly present in 10 files reachable from web routing:
     - `lib/features/home/widgets/home_header.dart:1`
     - `lib/features/records/screens/add_record_screen.dart:1`
     - `lib/features/records/widgets/profile_selector.dart:1`
     - `lib/features/visits/screens/add_visit_screen.dart:1`
     - `lib/features/routine/screens/add_medicine_screen.dart:1`
     - `lib/features/family/screens/add_family_member_screen.dart:1`
     - `lib/features/family/screens/edit_family_member_screen.dart:1`
     - `lib/features/family/widgets/family_member_tile.dart:1`
     - `lib/features/diet/screens/ai_diet_planner_screen.dart:1`
     - `lib/features/profile/screens/edit_profile_screen.dart:1`
   - *Impact*: In Flutter Web runtime, any instantiation of `File` or `FileImage(imageFile as File)` throws `Unsupported operation: Platform._operatingSystem` or `UnsupportedError`. Must use platform-safe abstractions (e.g. `Uint8List` bytes or `cross_file`).

2. **Android Configuration & Permissions (`android/app/src/main/AndroidManifest.xml`)**:
   - **Missing Permissions**:
     - `android.permission.CAMERA` missing (required by `mobile_scanner` and `image_picker`).
     - `android.permission.INTERNET` missing (required for URL launching, web builds, and backend APIs).
     - Storage permissions (`READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`) missing for document selection.
   - **Application ID**: Still default placeholder `applicationId = "com.example.nuroved_patient"`.
   - **Signing Config**: `buildTypes.release` is signed with `debug` key (`signingConfig = signingConfigs.getByName("debug")`).

3. **iOS Configuration (`ios/Runner/Info.plist`)**:
   - Usage descriptions present: `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription`.
   - String describes only profile picture ("We need access to your camera to update your profile picture"), which does not disclose medical document scanning or barcode reading (risk of App Store rejection).
   - No Entitlements or Associated Domains configured.

4. **Asset Declarations (`pubspec.yaml`)**:
   - Line 75 lists `- assets/fonts/`, but the directory does not exist, triggering analyzer and build errors.

---

### H. Backend Reality Check

- **Current Configured Backend**: **NONE**.
- **Backend SDKs**: No backend client package exists in `pubspec.yaml`.
- **Environment Variables**: No `.env`, `.env.example`, or `--dart-define` configurations exist in the workspace.
- **API Endpoints**: Zero backend endpoints are defined in code.
- **Database Schemas & Migrations**: Zero SQL migrations, schema files, or Supabase configurations exist in the repository.
- **Storage Buckets**: No storage bucket configuration or client integration exists.
- *What Cannot Be Seen*: No external Supabase project credentials or remote backend endpoints are present in this repository. All data operations currently simulate persistence inside ephemeral memory models.

---

## 3. Comprehensive Defect Table

| ID | Severity | File:Line | Defect Description | User Impact | Proposed Fix | Test Needed |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DEF-001** | **Critical** | `pubspec.yaml` | No backend integration client installed. | No data is persisted or backed up; data vanishes on restart. | Add `supabase_flutter` (or chosen backend SDK) and repository interfaces. | Unit test for backend repository connection. |
| **DEF-002** | **Critical** | `lib/features/auth/controllers/auth_controller.dart:59-68` | Authentication is simulated; any click logs in without verification. | Any unauthorized party bypasses login; zero data security. | Implement real auth service with token storage and validation. | AuthController sign-in / sign-up unit tests. |
| **DEF-003** | **Critical** | `lib/features/profile/controllers/profile_controller.dart:22-34` | Real personal data hardcoded in source repository. | Privacy breach, personal data exposed in code and git. | Replace hardcoded identity with dynamic profile model initialized to null/empty until fetched. | Profile initialization unit test. |
| **DEF-004** | **Critical** | Multiple (10 files) | Direct `dart:io` imports and `FileImage` casts on web-reachable paths. | Instant crash on web platforms when accessing profiles, records, or visits. | Abstract files using `Uint8List` or `cross_file` `XFile`. | Web smoke test & cross-platform image rendering test. |
| **DEF-005** | **Critical** | `android/app/src/main/AndroidManifest.xml` | Missing camera, storage, and internet permissions. | App crashes or fails to open camera in scanner / file picker. | Declare `CAMERA`, `INTERNET`, `READ_MEDIA_IMAGES` in manifest. | Android camera & network permission verification test. |
| **DEF-006** | **High** | `android/app/build.gradle.kts:38` | Release build is signed with debug keystore. | Insecure APK; cannot be published to Play Store safely. | Configure release signing via Gradle properties or environment variables. | Gradle build release verification. |
| **DEF-007** | **High** | `lib/features/records/controllers/records_controller.dart:50-67` | Record deletion and profile switching identified by display name string instead of UUID. | Name collision deletes incorrect patient records; renaming breaks records. | Refactor models to use immutable `id: String` (UUID). | RecordsController delete by ID unit test. |
| **DEF-008** | **High** | `lib/features/settings/screens/change_email_screen.dart:166` | "Save New Email" button navigates to change password screen instead of saving email. | User cannot update email address; confusing erratic navigation. | Wire email change to auth repository and show confirmation dialog. | ChangeEmailScreen form submit test. |
| **DEF-009** | **High** | `lib/features/settings/screens/change_password_screen.dart:180` | "Save New Password" button pops navigation without executing update. | Password is never changed. | Call auth password update API and handle errors. | Password update integration test. |
| **DEF-010** | **High** | `lib/features/routine/screens/routine_screen.dart:73-75` | Add Medicine FAB has empty `onPressed: () { /* ... */ }`. | `AddMedicineScreen` is completely unreachable; user cannot add medicine. | Wire FAB to navigate to `AddMedicineScreen`. | RoutineScreen FAB widget test. |
| **DEF-011** | **High** | Multiple (15 files) | 15 files in `lib/` are completely empty (0 bytes). | Unused dead files cluttering codebase and broken imports if referenced. | Implement required components or remove orphaned files safely. | Compilation and static analysis pass. |
| **DEF-012** | **High** | `lib/features/settings/screens/data_privacy_screen.dart:60` | Delete account button shows dialog with no backend action. | Privacy violation; fails Apple and Google account deletion rules. | Implement account deletion endpoint and session cleanup. | Account deletion unit test. |
| **DEF-013** | **Medium** | `pubspec.yaml:75` | Asset declaration `assets/fonts/` points to non-existent folder. | Analyzer warning and build warnings. | Create folder or remove line from `pubspec.yaml`. | `flutter analyze` clean check. |
| **DEF-014** | **Medium** | `lib/features/auth/controllers/auth_controller.dart:6-7` | `PageController` and `headerPageController` are never disposed. | Memory leak upon leaving login/signup screens. | Add controller disposal in `dispose()`. | Lifecycle test for AuthController. |
| **DEF-015** | **Medium** | `lib/features/diet/screens/food_scanner_screen.dart:205` | Barcode scanner displays hardcoded Lay's chips for all barcodes. | Misleading clinical and nutritional information shown to diabetic patient. | Connect scanner to real food database API or disable simulated display. | Barcode parsing test. |
| **DEF-016** | **Medium** | `lib/features/premium/screens/purchase_screen.dart:434-465` | Payment screen contains "Demo: Failed" and "Demo: Renew" buttons. | Unprofessional test code in UI; no real payment gateway. | Hide demo controls or document out-of-scope in MVP. | Purchase screen widget test. |
| **DEF-017** | **Medium** | `lib/features/settings/screens/customer_support_screen.dart:306-350` | Contact Us tiles have dropdown arrow but zero interaction. | User unable to contact support, email, or WhatsApp. | Implement `url_launcher` handlers for phone, email, WhatsApp. | Launcher URL test. |
| **DEF-018** | **Medium** | Multiple files (7 instances) | Empty callbacks `onPressed: () {}` and `onTap: () {}`. | Dead buttons across settings, records, and visits screens. | Wire callbacks to active controllers or disable buttons with tooltips. | Dead-control sweep script. |
| **DEF-019** | **Medium** | `lib/app/app_router.dart:201-219` | Raw `Map<String, dynamic>` passed across router arguments. | Runtime type casts crash on missing keys; violates code standards. | Create typed route argument classes (`PurchaseArgs`, `PremiumStatusArgs`). | AppRouter navigation test. |
| **DEF-020** | **Low** | `lib/features/diet/screens/diet_output_screen.dart:264` | Lunch time displays "12:00 AM" instead of "12:00 PM". | Formatting error on meal timeline. | Fix time formatting string. | Date/time format unit test. |
| **DEF-021** | **Low** | `test/widget_test.dart` | Default Flutter template counter smoke test fails. | `flutter test` always fails baseline test run. | Replace counter smoke test with valid `MyApp` smoke test. | `flutter test` pass. |
| **DEF-022** | **Low** | Multiple files (139 instances) | Deprecated `.withOpacity()` usage across themes and widgets. | Precision loss warnings in Flutter analysis. | Migrate to `.withValues(alpha: ...)`. | `flutter analyze` clean check. |

---
