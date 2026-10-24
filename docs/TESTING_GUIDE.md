# NuroVed Patient App - Manual QA & Clinical Testing Guide

This guide provides test procedures for validating the authentication, session security, and patient data lifecycle of the NuroVed Patient App.

---

## Test Suite 1: Account Registration (Sign Up)

### TC-1.1: Input Validation & Error Handling (Step 1)
1. Launch the app and proceed to the **Sign Up** screen (`/signup`).
2. Leave the **Email Address** field blank and enter `Password123!` in password fields. Click **Continue**.
   - **Expected Result**: An inline error appears stating email is required or invalid. Progression to Step 2 is blocked.
3. Enter `invalid-email-format` and click **Continue**.
   - **Expected Result**: Inline error rejects the email format.
4. Enter password `short` (<8 characters) and click **Continue**.
   - **Expected Result**: Error states password must be at least 8 characters.
5. Enter mismatched passwords (`Password123!` and `OtherPass456!`).
   - **Expected Result**: Password confirmation border highlights red and an error displays `Passwords do not match!`.

### TC-1.2: Profile Details & Terms Acknowledgement (Step 2)
1. Enter valid email and matching passwords in Step 1 and click **Continue**.
2. Verify smooth slide transition to Step 2.
3. Leave **Full Name** empty, check the terms checkbox, and click **Sign Up**.
   - **Expected Result**: Error states full name is required.
4. Enter a future date of birth (e.g., year 2099) or invalid date (`31/02/1995`).
   - **Expected Result**: Error rejects the invalid calendar date.
5. Fill in valid Name and DOB, but leave the **Terms & Conditions** checkbox UNCHECKED. Click **Sign Up**.
   - **Expected Result**: Progression is blocked. Warning states terms and conditions must be acknowledged.
6. Check the **Terms of Service & Privacy Policy** checkbox and click **Sign Up**.
   - **Expected Result**: Sign Up button shows loading spinner. Account is registered, session is saved, and user is taken to `/home`.

---

## Test Suite 2: Credential Verification & Sign In (Login)

### TC-2.1: Login Validation & Error Propagation
1. Open the **Login** screen (`/login`).
2. Attempt login with an unregistered email (`nobody@nuroved.com`) and any password.
   - **Expected Result**: Error notification indicates invalid credentials or unregistered account. No bypass occurs.
3. Enter registered email with an incorrect password.
   - **Expected Result**: Error states incorrect password. User remains on Login screen.
4. Enter registered email and correct password. Tap **Sign In**.
   - **Expected Result**: Loading spinner displays, genuine credential check succeeds, and user is routed to `/home`.

---

## Test Suite 3: Session Persistence & App Restart

### TC-3.1: Session Restoration on Startup
1. Log into a patient account.
2. Force quit / terminate the app.
3. Relaunch the app.
   - **Expected Result**: The entry `LoadingScreen` displays brand animation while asynchronously restoring the cached session from secure preferences. Once complete, app navigates directly to `/home`, bypassing splash and login.

### TC-3.2: Expired / Revoked Session Cleanup
1. If session token expires or is revoked on the backend:
   - **Expected Result**: `restoreSession()` cleans up stored tokens and navigates to the `/login` screen with a message stating session has expired.

---

## Test Suite 4: Route Guards & Deep Link Protection

### TC-4.1: Unauthenticated Navigation Interception
1. Ensure the user is logged out.
2. Attempt to navigate directly to `/home`, `/records`, `/visits`, or `/profile`.
   - **Expected Result**: Route guard intercepts the transition and redirects the user directly to `/login`.

### TC-4.2: Authenticated Redirection
1. Ensure the user is logged in.
2. Attempt to navigate to `/login`, `/signup`, or `/splash`.
   - **Expected Result**: Route guard detects active authentication and redirects the user directly to `/home`.

---

## Test Suite 5: Password Reset Flow

### TC-5.1: Forgot Password Submission
1. On `/login`, tap **Forget password?**.
2. Enter an invalid email and tap **Send Reset Instructions**.
   - **Expected Result**: Form validation displays error.
3. Enter valid registered email and tap **Send Reset Instructions**.
   - **Expected Result**: Request is dispatched to auth provider. Upon genuine success, `SuccessEmailSheet` modal appears with confirmation.

---

## Test Suite 6: Security Settings (Change Password & Email)

### TC-6.1: Change Password with Re-authentication
1. Navigate to **Settings > Data & Privacy > Change password** (`/change-password`).
2. Attempt saving without current password -> blocked.
3. Enter incorrect current password -> error indicates re-authentication failure.
4. Enter correct current password and new password (min. 8 chars) -> password is updated; user can log in with new password.

### TC-6.2: Change Email with Verification
1. Navigate to **Settings > Data & Privacy > Change email address** (`/change-email`).
2. Enter new email and account password -> verification email dispatched to new address.

---

## Test Suite 7: Permanent Account Deletion

### TC-7.1: Confirmed Deletion Flow
1. Navigate to **Settings > Data & Privacy** (`/data-privacy`).
2. Tap **Delete My Account**.
   - **Expected Result**: Warning dialog appears detailing permanent erasure of patient records.
3. Submit without password -> blocked with validation error.
4. Enter incorrect password -> blocked with error.
5. Enter correct account password and tap **Permanently Delete**.
   - **Expected Result**: Server-backed RPC (`delete_user_account()`) deletes user and records, local session tokens are purged, and app navigates to `/login`. Subsequent login attempts with deleted credentials fail.

---

## Test Suite 8: Logout Cleanup

### TC-8.1: Full Logout State Purge
1. Open **Profile** screen (`/profile`) and tap **Logout**.
   - **Expected Result**: Session tokens, in-memory controllers, and cached profile data are completely purged. App navigates to `/login` and clears the navigation stack so the Back button cannot return to protected screens.

---

## Test Suite 9: Patient Profile Management & Optimistic UI

### TC-9.1: Edit Profile, Input Validation, and Rollback on Failure
1. On the **Profile** screen, tap the edit pen icon on the avatar or navigate to `/edit-profile`.
2. Modify name, date of birth, blood group, height, weight, allergies, and chronic conditions.
3. Tap **Save Changes**.
   - **Expected Result**: Changes take effect immediately in optimistic UI. If repository operation fails (e.g. simulated network error), UI displays an error snackbar and immediately rolls back fields to their previous state.
4. Attempt to save an invalid date of birth (e.g., `31/02/1990` or future year) or invalid metric number.
   - **Expected Result**: Inline validator rejects the input and blocks submission.

### TC-9.2: Profile Photo Validation (Size & Extension)
1. In `/edit-profile`, tap the camera icon on the avatar.
2. Select a valid PNG or JPEG image under 10MB.
   - **Expected Result**: Image previews correctly and passes client-side validation.
3. Attempt to upload a file exceeding 10MB (or an unpermitted format like `.pdf` or `.exe`).
   - **Expected Result**: Validation fails immediately with a descriptive snackbar: "Image size exceeds maximum allowed limit of 10.0MB" or "File format is not allowed".

---

## Test Suite 10: Family Profiles & Stable UUIDs

### TC-10.1: Add, Edit, and Delete Family Member with Confirmation
1. On **Profile**, toggle to **Emergency Card**, then tap **View all family profiles** (or navigate to `/family-profiles`).
2. Tap **+ Add New Profile**.
3. Fill in family member name, relation (e.g. "Father"), DOB, blood group, and emergency contact toggle. Tap **Add New Profile**.
   - **Expected Result**: Member is assigned an immutable, stable UUID and appears in the list.
4. Tap the family member card and select **Edit Member** from the bottom sheet. Update details and tap **Save**.
   - **Expected Result**: Updates persist under the existing stable UUID.
5. In `/family-profiles`, tap the delete icon on a family member.
   - **Expected Result**: A confirmation dialog appears ("Delete Family Member? Are you sure you want to remove...?").
6. Tap **Cancel** -> Member remains intact.
7. Tap **Delete** -> Member is removed by stable UUID. If the deleted member was currently the active health subject, active subject immediately falls back to the primary patient UUID.

---

## Test Suite 11: Single Source of Truth & Subject Switching Isolation

### TC-11.1: Multi-profile Subject Switching and Cache Purging
1. In the app bar on **Records** (`/records`), tap the profile switch dropdown.
2. Add a record titled "Primary Patient Lab Report" for the primary patient.
3. Switch active profile to "Father".
   - **Expected Result**: Active subject UUID updates app-wide. The records screen immediately purges John's records and displays an empty or Father-specific state. No stale data from the previous subject is visible.
4. Add a record titled "Father ECG Test" under Father's profile.
5. Navigate to **Visits** (`/visits`) and add a visit "Father Cardiology Checkup".
6. Navigate to **Routines** (`/routine`) -> Only Father's routine is visible (Metformin from primary user is NOT displayed).
7. Switch back to "Self" (Primary Patient).
   - **Expected Result**: Records immediately reload only primary user's "Primary Patient Lab Report". Father's ECG and cardiology visits disappear from the view.

---

## Test Suite 12: Emergency Card & Unverified Badge

### TC-12.1: Missing Field Fallback ("Not provided") and Unverified Badge
1. Toggle to **Emergency Card** on the Profile screen (`/profile`).
2. Verify top banner displays a prominent **"PATIENT-ENTERED, UNVERIFIED"** badge.
3. For a profile with unpopulated allergies, chronic conditions, or blood group:
   - **Expected Result**: Missing fields explicitly display **"Not provided"** (no hard-coded "B+" or "None").

### TC-12.2: Designated Emergency Contact Dynamic Display
1. In Family Profiles, designate a family member with a valid phone number as the Emergency Contact (`isEmergencyContact: true`).
2. Return to Emergency Card.
   - **Expected Result**: The Family Profiles emergency contact section renders that member's name, relation badge `(Emergency Contact)`, and phone number.
3. If no member is designated:
   - **Expected Result**: Displays "Not assigned" and "Phone not provided" with a button to view and assign family profiles.

---

## Test Suite 13: Caregiver Delegated Access & Scopes

### TC-13.1: Caregiver Invitation, Accept, Scopes, and Revocation
1. Navigate to **Hospital Access** (`/access`).
2. Select hospital or caregiver name, choose scopes (`Only Medical Records`, `Only Health Timeline`, or `Full Profile`), access type (`View Only` vs `Edit & View`), and duration.
3. Tap **Review & Grant Access**.
   - **Expected Result**: A `care_access_grants` record is created with `status: 'pending'` and specified scopes.
4. When accepted, grant status transitions to `active`.
5. Tap the hospital tile to inspect details on `/hospital-details` or tap the red cancel icon on `/access`.
6. Confirm revocation dialog.
   - **Expected Result**: Grant status updates immediately to `revoked` with timestamp `revoked_at`. All resource checks for this caregiver fail immediately.

---

## Test Suite 14: Health Records Management & Secure Upload Pipeline

### TC-14.1: Multi-Platform Document Picking & Magic Byte Validation
1. Navigate to **Records** (`/records`) and tap the floating **+** button (`/add-record`).
2. Attempt picking or capturing a file with invalid magic bytes (e.g. an `.exe` renamed to `.pdf` or corrupted file header).
   - **Expected Result**: Validation fails with `File content does not match a valid PDF, JPEG, or PNG signature`. Upload is blocked.
3. Pick a file exceeding 10MB limit.
   - **Expected Result**: Validation fails with `File size exceeds the 10MB limit`.
4. Pick a valid PDF, JPG, or PNG under 10MB.
   - **Expected Result**: File is accepted. Details card displays filename, MIME type, and formatted size.

### TC-14.2: Upload Progress, In-Flight Cancellation, and Duplicate Submission Guard
1. Fill in record title, category chip ("Medical Records", "Lab", "Bills", "Vaccination's"), and valid date.
2. Tap **Upload Record**.
   - **Expected Result**: Progress bar appears displaying live percentage. Button disables to prevent duplicate submissions.
3. Tap **Cancel** during upload.
   - **Expected Result**: In-flight upload is aborted via cancellation token. Any partial storage object is purged. Controller state returns to idle.
4. Re-upload and allow completion.
   - **Expected Result**: Private bucket upload succeeds (`medical-records/{owner_id}/{subject_id}/{record_id}/{filename}`). Metadata is persisted only after upload completes. Record is added to active subject list.

### TC-14.3: Short-Lived Signed URLs & Soft-Delete with Confirmation
1. On `/records`, tap any record card or tap **View** (`/record-details`).
2. Tap **Request Secure Access Link** / preview document.
   - **Expected Result**: Generates a temporary signed URL with a 10-minute expiry notice. Never exposes a public or unauthenticated URL.
3. Tap the delete icon.
   - **Expected Result**: Confirmation dialog appears ("Are you sure you want to delete this record?").
4. Confirm deletion.
   - **Expected Result**: Record is soft-deleted (`deleted_at` timestamp set) and removed from the active subject view.

---

## Test Suite 15: Clinical Visits & Canonical Record Linking

### TC-15.1: Timezone-Safe Date Parsing & Edge Dates
1. Navigate to **Visits** (`/visits`) and tap **Add Visit** (`/add-visit`).
2. Enter consultation on leap day `2024-02-29` or month boundary `2026-03-31`.
   - **Expected Result**: `DateParser` correctly parses the calendar date without timezone shift or off-by-one errors.

### TC-15.2: Canonical Record Linking (Deduplicated)
1. On `/add-visit`, tap **Select Related Records** (`/select-related-records`).
   - **Expected Result**: Loads canonical records for the active subject only.
2. Select a record and save visit.
   - **Expected Result**: `related_record_ids` contains unique IDs without duplication.
3. Open visit details (`/visit-details`).
   - **Expected Result**: Attached canonical record card appears with a working **View** button that navigates to `/record-details`.

---

## Test Suite 16: Unified Chronological Timeline

### TC-16.1: Merged Chronological Ordering (Newest First)
1. View the Timeline on the home/visits screen for the active patient.
   - **Expected Result**: Clinical visits and diagnostic records are merged into a single chronological stream sorted newest first.
2. Verify that visits with timezone offsets (e.g., UTC morning vs IST afternoon) sort according to absolute UTC timestamp.
3. Switch health subject to another family member.
   - **Expected Result**: Entire timeline updates immediately to display only the newly selected subject's visits and records.
