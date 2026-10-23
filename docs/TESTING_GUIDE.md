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
