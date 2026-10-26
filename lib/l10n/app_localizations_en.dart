// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NuroVed';

  @override
  String get appTagline => 'Your Health, Your Control';

  @override
  String get navHome => 'Home';

  @override
  String get navRecords => 'Records';

  @override
  String get navDiet => 'Diet';

  @override
  String get navRoutine => 'Routine';

  @override
  String get navVisits => 'Visits';

  @override
  String get navAccess => 'Access';

  @override
  String get navSettings => 'Settings';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaveMeal => 'Save Meal';

  @override
  String get commonSaveReminder => 'Save Reminder';

  @override
  String get commonSaveVisit => 'Save Visit';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLookup => 'Lookup';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonError => 'Error';

  @override
  String get commonWarning => 'Warning';

  @override
  String get commonInfo => 'Information';

  @override
  String get commonViewAll => 'View All';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonAll => 'All';

  @override
  String get splashTagline => 'Your Health, Your Control';

  @override
  String get splashGettingStarted => 'Getting Started...';

  @override
  String get splashSkip => 'Skip';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Log into your NuroVed account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'Enter your email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginSignInButton => 'Sign In';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUpLink => 'Sign Up';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupSubtitle => 'Sign Up For Free!';

  @override
  String get signupFullNameLabel => 'Full Name';

  @override
  String get signupFullNameHint => 'Enter your full name';

  @override
  String get signupConfirmPasswordLabel => 'Confirm Password';

  @override
  String get signupConfirmPasswordHint => 'Confirm your password';

  @override
  String get signupTermsAgreement => 'I have read all the ';

  @override
  String get signupTermsLink => 'terms of service';

  @override
  String get signupAndWord => ' and ';

  @override
  String get signupPrivacyLink => 'privacy policy';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get signupAlreadyHaveAccount => 'Already have an account?';

  @override
  String get signupSignInLink => 'Sign In';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a password reset link';

  @override
  String get forgotPasswordButton => 'Send Reset Link';

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get forgotPasswordSuccess => 'Email sent successfully';

  @override
  String get authLoadingTitle => 'Loading NuroVed...';

  @override
  String get authVerifyingSession => 'Verifying session...';

  @override
  String get authLogoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get authLogout => 'Log Out';

  @override
  String get validationEnterName => 'Please enter a name';

  @override
  String get validationNameEmpty => 'Name cannot be empty';

  @override
  String get validationEnterEmail => 'Please enter your email';

  @override
  String get validationEnterValidEmail => 'Please enter a valid email address';

  @override
  String get validationEnterPassword => 'Please enter your password';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 6 characters';

  @override
  String get validationPasswordMismatch => 'ERROR: Password do not match!';

  @override
  String get validationAgreeTerms => 'Please agree to the terms of service';

  @override
  String get validationEnterRecordTitle => 'Please enter a record title';

  @override
  String get validationSelectCategory => 'Please select a category';

  @override
  String get validationEnterDoctorName => 'Please enter doctor name';

  @override
  String get validationSelectDate => 'Please select a date';

  @override
  String get validationEnterMedicineName => 'Please enter medicine name';

  @override
  String get validationSelectTiming => 'Please select timing';

  @override
  String get validationSelectProfileAndMedicine =>
      'Please select profile and enter medicine name';

  @override
  String get validationSelectProfile => 'Please select a profile';

  @override
  String get validationEnterIssue =>
      'Please describe the problem you experienced.';

  @override
  String get validationIssueTooShort =>
      'Please provide more detail (minimum 10 characters).';

  @override
  String get validationMealNameEmpty => 'Meal name cannot be empty';

  @override
  String get validationInvalidBarcode =>
      'Please enter a valid 8 to 14-digit barcode';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeFeelingPrompt => 'How are you feeling today?';

  @override
  String get homeSearchPlaceholder =>
      'Search health records, medicines, visits...';

  @override
  String get homeQuickAccess => 'Quick Access';

  @override
  String get homeQuickUploadRecord => 'Upload Record';

  @override
  String get homeQuickDietPlan => 'Diet Plan';

  @override
  String get homeQuickRoutine => 'Routine';

  @override
  String get homeQuickVisits => 'Visits';

  @override
  String get homeQuickCareAccess => 'Care Access';

  @override
  String get homeQuickFoodScanner => 'Food Scanner';

  @override
  String get homeRecentRecords => 'Recent Records';

  @override
  String get homeNoRecentRecords => 'No recent records found';

  @override
  String get homeUpcomingRoutine => 'Upcoming Medications';

  @override
  String get homeNoUpcomingRoutine => 'No medications scheduled for today';

  @override
  String get homeEmergencyCardTitle => 'Emergency Card';

  @override
  String get homeEmergencyBloodGroup => 'Blood Group';

  @override
  String get homeEmergencyAllergies => 'Allergies';

  @override
  String get homeEmergencyContact => 'Emergency Contact';

  @override
  String get recordsTitle => 'Medical Records';

  @override
  String get recordsSubtitle => 'Organize & access clinical files';

  @override
  String get recordsFilterAll => 'All';

  @override
  String get recordsFilterPrescriptions => 'Prescriptions';

  @override
  String get recordsFilterLabReports => 'Lab Reports';

  @override
  String get recordsFilterScans => 'Scans';

  @override
  String get recordsFilterDischarge => 'Discharge';

  @override
  String get recordsFilterInvoices => 'Invoices';

  @override
  String get recordsSearchPlaceholder => 'Search records...';

  @override
  String get recordsNoRecordsFound => 'No records found';

  @override
  String get recordsEmptyUploadPrompt =>
      'Upload your first medical record to track your health.';

  @override
  String get recordsAddRecordButton => 'Add Record';

  @override
  String get recordsAddTitle => 'Add Medical Record';

  @override
  String get recordsAddSubtitle =>
      'Attach lab results, prescriptions, or bills';

  @override
  String get recordsFieldTitle => 'Record Title';

  @override
  String get recordsFieldTitleHint => 'e.g. Blood Test, Prescription';

  @override
  String get recordsFieldDoctor => 'Doctor / Hospital Name';

  @override
  String get recordsFieldDoctorHint => 'e.g. Dr. Sharma, City Clinic';

  @override
  String get recordsFieldDate => 'Record Date';

  @override
  String get recordsFieldCategory => 'Category';

  @override
  String get recordsFieldNotes => 'Clinical Notes / Description';

  @override
  String get recordsFieldNotesHint => 'Add diagnosis details, dosage notes...';

  @override
  String get recordsUploadSectionTitle => 'Attach File';

  @override
  String get recordsUploadFilesButton => 'Upload Files';

  @override
  String get recordsTakePhotoButton => 'Click Photo';

  @override
  String get recordsNoFileSelected => 'No file selected';

  @override
  String get recordsSaveRecordButton => 'Save Record';

  @override
  String get recordsDeleteDialogTitle => 'Delete Medical Record?';

  @override
  String get recordsDeleteDialogMessage =>
      'Are you sure you want to permanently delete this medical record? This action cannot be undone.';

  @override
  String get recordsDeletedSuccess => 'Record deleted successfully';

  @override
  String get recordsAddedSuccess => 'Record added successfully!';

  @override
  String get recordsDetailTitle => 'Record Details';

  @override
  String get recordsDetailCategory => 'Category';

  @override
  String get recordsDetailDate => 'Date';

  @override
  String get recordsDetailDoctor => 'Doctor / Clinic';

  @override
  String get recordsDetailNotes => 'Notes';

  @override
  String get recordsDetailAttachedFile => 'Attached Document';

  @override
  String get recordsDetailDownload => 'View / Download Document';

  @override
  String get familyTitle => 'Family Profiles';

  @override
  String get familySubtitle => 'Manage individual health accounts';

  @override
  String get familyActiveProfile => 'Active Profile';

  @override
  String get familySwitchProfile => 'Switch Profile';

  @override
  String get familyAddMemberButton => 'Add New Profile';

  @override
  String get familyAddMemberTitle => 'Add Family Member';

  @override
  String get familyAddMemberSubtitle => 'Create a dependent clinical profile';

  @override
  String get familyEditMemberTitle => 'Edit Family Member';

  @override
  String get familyFieldName => 'Full Name';

  @override
  String get familyFieldNameHint => 'Enter member\'s name';

  @override
  String get familyFieldRelationship => 'Relationship';

  @override
  String get familyFieldRelationshipHint => 'Select relationship';

  @override
  String get familyFieldDob => 'Date of Birth';

  @override
  String get familyFieldGender => 'Gender';

  @override
  String get familyFieldBloodGroup => 'Blood Group';

  @override
  String get familyRelationSelf => 'Self';

  @override
  String get familyRelationSpouse => 'Spouse';

  @override
  String get familyRelationChild => 'Child';

  @override
  String get familyRelationParent => 'Parent';

  @override
  String get familyRelationOther => 'Other';

  @override
  String get familyAddedSuccess => 'Family member added successfully!';

  @override
  String get familyUpdatedSuccess => 'Family member updated successfully!';

  @override
  String get familyDeleteDialogTitle => 'Remove Profile?';

  @override
  String get familyDeleteDialogMessage =>
      'Are you sure you want to remove this family profile? Their clinical records will remain safely archived.';

  @override
  String familyRemovedSuccess(String name) {
    return 'Removed \"$name\" from family profiles.';
  }

  @override
  String get routineTitle => 'Daily Routine';

  @override
  String get routineSubtitle => 'Medication & health habit tracker';

  @override
  String get routineSectionMorning => 'Morning';

  @override
  String get routineSectionAfternoon => 'Afternoon';

  @override
  String get routineSectionEvening => 'Evening';

  @override
  String get routineSectionNight => 'Night';

  @override
  String get routineStatusTaken => 'Taken';

  @override
  String get routineStatusPending => 'Pending';

  @override
  String get routineStatusSkipped => 'Skipped';

  @override
  String get routineAddMedicine => 'Add Medicine';

  @override
  String get routineAddReminder => 'Add Reminder';

  @override
  String get routineEmptyTitle => 'No reminders for today';

  @override
  String get routineEmptySubtitle =>
      'Add your daily medicines or wellness routines.';

  @override
  String get routineFieldMedicineName => 'Medicine Name';

  @override
  String get routineFieldMedicineNameHint => 'e.g. Metformin 500mg';

  @override
  String get routineFieldDosage => 'Dosage';

  @override
  String get routineFieldDosageHint => 'e.g. 1 Tablet';

  @override
  String get routineFieldTiming => 'Timing';

  @override
  String get routineFieldInstructions => 'Instructions';

  @override
  String get routineInstructionBeforeFood => 'Before Food';

  @override
  String get routineInstructionAfterFood => 'After Food';

  @override
  String get routineInstructionWithFood => 'With Food';

  @override
  String get routineFrequencyDaily => 'Daily';

  @override
  String get routineSaveReminder => 'Save Reminder';

  @override
  String get routineSavedSuccess => 'Medicine reminder saved successfully!';

  @override
  String get routineUpdatedSuccess => 'Meal routine updated successfully!';

  @override
  String get routineConfirmIntakeTitle => 'Confirm Intake';

  @override
  String routineConfirmIntakeMessage(String medicine) {
    return 'Mark $medicine as taken?';
  }

  @override
  String get routineMarkedTakenSuccess => 'Marked as taken';

  @override
  String get visitsTitle => 'Doctor Visits';

  @override
  String get visitsSubtitle => 'Track consultations & follow-ups';

  @override
  String get visitsUpcoming => 'Upcoming';

  @override
  String get visitsPast => 'Past Consultations';

  @override
  String get visitsAddVisit => 'Add Visit';

  @override
  String get visitsEmptyTitle => 'No doctor visits recorded';

  @override
  String get visitsEmptySubtitle =>
      'Keep track of doctor consultations and medical prescriptions.';

  @override
  String get visitsAddTitle => 'Add Doctor Visit';

  @override
  String get visitsAddSubtitle => 'Log a consultation or follow-up';

  @override
  String get visitsFieldDoctor => 'Doctor Name';

  @override
  String get visitsFieldDoctorHint => 'e.g. Dr. Patel';

  @override
  String get visitsFieldSpecialty => 'Specialty';

  @override
  String get visitsFieldSpecialtyHint => 'e.g. Cardiologist, General Physician';

  @override
  String get visitsFieldHospital => 'Hospital / Clinic';

  @override
  String get visitsFieldHospitalHint => 'e.g. Apollo Clinic, Care Hospital';

  @override
  String get visitsFieldDate => 'Visit Date';

  @override
  String get visitsFieldTime => 'Visit Time';

  @override
  String get visitsFieldReason => 'Reason for Consultation';

  @override
  String get visitsFieldReasonHint => 'e.g. Annual health checkup, fever';

  @override
  String get visitsFieldNotes => 'Diagnosis & Advice';

  @override
  String get visitsSaveVisit => 'Save Visit';

  @override
  String get visitsSavedSuccess => 'Doctor visit added successfully!';

  @override
  String get visitsDetailsTitle => 'Visit Details';

  @override
  String get visitsTimelineTitle => 'Consultation Timeline';

  @override
  String get accessTitle => 'Care Access';

  @override
  String get accessSubtitle => 'Share medical data securely';

  @override
  String get accessActiveSessions => 'Active Sessions';

  @override
  String get accessShareAccess => 'Share Access';

  @override
  String get accessPermissions => 'Permissions';

  @override
  String get accessQrCodeTitle => 'Doctor QR Access';

  @override
  String get accessQrCodeSubtitle =>
      'Scan with doctor portal for temporary read-only access';

  @override
  String get accessPinLabel => 'Temporary Access PIN';

  @override
  String get accessDuration24Hours => '24 Hours';

  @override
  String get accessDuration7Days => '7 Days';

  @override
  String get accessDuration30Days => '30 Days';

  @override
  String get accessRevokeButton => 'Revoke Access';

  @override
  String get accessRevokeDialogTitle => 'Revoke Access?';

  @override
  String get accessRevokeDialogMessage =>
      'Are you sure you want to immediately terminate this caregiver\'s access to your medical records?';

  @override
  String get accessRevokedSuccess => 'Access revoked successfully';

  @override
  String get accessNoActiveSessions => 'No active sharing sessions';

  @override
  String get accessHospitalDetailsTitle => 'Hospital Information';

  @override
  String get foodScannerTitle => 'Food Scanner';

  @override
  String get foodScannerSubtitle => 'Scan Retail Food Barcode';

  @override
  String get foodScannerInstructions =>
      'Point camera at a packaged food barcode';

  @override
  String get foodScannerManualButton => 'Enter Barcode Manually';

  @override
  String get foodScannerHistoryButton => 'Scan History';

  @override
  String get foodScannerLookUpProduct => 'Look Up Product';

  @override
  String get foodScannerLookingUpTitle => 'Looking up product...';

  @override
  String get foodScannerLookingUpSubtitle =>
      'Retrieving verified nutritional information';

  @override
  String get foodScannerManualDialogTitle => 'Manual Barcode Entry';

  @override
  String get foodScannerManualDialogHint => 'Enter 8-14 digit barcode';

  @override
  String get foodScannerProductLookup => 'Product Lookup';

  @override
  String get foodScannerScanAgain => 'Scan Again';

  @override
  String get foodScannerEnterManually => 'Enter Manually';

  @override
  String get foodScannerProductNotFoundTitle => 'Product Not Found';

  @override
  String get foodScannerProductNotFoundMessage =>
      'The scanned barcode was not found in the verified database. You can try searching manually or scan another product.';

  @override
  String get foodScannerNetworkError =>
      'Unable to reach nutrition database. Please check your internet connection.';

  @override
  String get foodScannerValidationEmpty => 'Please enter a barcode number.';

  @override
  String get foodScannerValidationMin =>
      'Barcode must contain at least 8 digits (EAN-8).';

  @override
  String get foodScannerResultTitle => 'Nutrition Details';

  @override
  String get foodScannerVerifiedFacts => 'Verified Nutrition Facts';

  @override
  String get foodScannerNutriScore => 'Nutri-Score';

  @override
  String get foodScannerEcoScore => 'Eco-Score';

  @override
  String get foodScannerNovaGroup => 'NOVA Group';

  @override
  String get foodScannerNutritionFacts => 'Nutrition Facts (per 100g/ml)';

  @override
  String get foodScannerCalories => 'Energy';

  @override
  String get foodScannerCarbs => 'Carbohydrates';

  @override
  String get foodScannerFat => 'Fat';

  @override
  String get foodScannerTotalFat => 'Total Fat';

  @override
  String get foodScannerProtein => 'Protein';

  @override
  String get foodScannerProteins => 'Proteins';

  @override
  String get foodScannerFiber => 'Fiber';

  @override
  String get foodScannerSalt => 'Salt';

  @override
  String get foodScannerSodium => 'Sodium';

  @override
  String get foodScannerAllergens => 'Allergens';

  @override
  String get foodScannerSourceAttribution => 'Source & Attribution';

  @override
  String get foodScannerScanAnother => 'Scan Another Item';

  @override
  String get foodScannerBackToDiet => 'Back to Diet Overview';

  @override
  String get foodScannerOpenFoodFactsAttribution =>
      'Nutrition data sourced from Open Food Facts under Open Database License (ODbL).';

  @override
  String get foodScannerHistoryTitle => 'Food Scan History';

  @override
  String get foodScannerHistoryEmpty => 'No scanned foods in history';

  @override
  String get dietPlannerTitle => 'Ai Diet Planner';

  @override
  String get dietPlannerSubtitle => 'Verified nutritional meal planning';

  @override
  String get dietStep1Title => 'Basic Information';

  @override
  String get dietStep1Subtitle => 'Step 1 of 4: Enter body measurements';

  @override
  String get dietFieldAge => 'Age';

  @override
  String get dietFieldGender => 'Gender';

  @override
  String get dietFieldGenderMale => 'Male';

  @override
  String get dietFieldGenderFemale => 'Female';

  @override
  String get dietFieldGenderOther => 'Other';

  @override
  String get dietFieldHeight => 'Height (cm)';

  @override
  String get dietFieldWeight => 'Weight (kg)';

  @override
  String get dietStep2Title => 'Diet Preference';

  @override
  String get dietStep2Subtitle => 'Step 2 of 4: Select dietary pattern';

  @override
  String get dietPatternVegetarian => 'Vegetarian';

  @override
  String get dietPatternNonVegetarian => 'Non-veg';

  @override
  String get dietPatternBoth => 'Both (Veg & Non-Veg)';

  @override
  String get dietNonVegDaysPrompt => 'Pick the days you prefer non-veg meals';

  @override
  String get dietAllergiesPrompt =>
      'Allergies & food exclusions (comma separated):';

  @override
  String get dietStep3Title => 'Health Goals';

  @override
  String get dietStep3Subtitle => 'Step 3 of 4: Activity & metabolic goal';

  @override
  String get dietActivitySedentary => 'Sedentary (Little or no exercise)';

  @override
  String get dietActivityModerate => 'Moderate (Exercise 3-5 days/week)';

  @override
  String get dietActivityAthlete => 'Heavy Athlete (Intense daily exercise)';

  @override
  String get dietGoalLose => 'Lose Weight';

  @override
  String get dietGoalMaintain => 'Maintain Weight';

  @override
  String get dietGoalGain => 'Muscle Gain';

  @override
  String get dietStep4Title => 'Time & Context';

  @override
  String get dietStep4Subtitle =>
      'Step 4 of 4: Meal schedules & cooking budget';

  @override
  String get dietClinicalSupervisionTitle => 'Clinical Supervision Notice';

  @override
  String get dietClinicalSupervisionMessage =>
      'Based on your clinical condition, automated meal planning requires individualized oversight by a qualified dietitian or physician.';

  @override
  String get dietClinicalReferenceNotice => 'Clinical Reference Notice';

  @override
  String get dietVerifiedNutritionalPlanning => 'Verified Nutritional Planning';

  @override
  String get dietOutputTitle => 'Weekly Meal Plan';

  @override
  String get dietOutputDailyCalories => 'Daily Energy Target';

  @override
  String get dietOutputSaveToRoutine => 'Save to My Routine';

  @override
  String get dietOutputRegenerate => 'Regenerate Plan';

  @override
  String get dietMealBreakfast => 'Breakfast';

  @override
  String get dietMealLunch => 'Lunch';

  @override
  String get dietMealSnack => 'Evening Snack';

  @override
  String get dietMealDinner => 'Dinner';

  @override
  String get dietPlanDeletedSuccess => 'Diet plan deleted successfully';

  @override
  String get dietDeleteDialogTitle => 'Delete Diet Plan?';

  @override
  String get dietDeleteDialogMessage =>
      'Are you sure you want to delete your saved meal routine? This will clear all weekly meal schedule data.';

  @override
  String get dietWeeklyMealPlan => 'Weekly Meal Plan';

  @override
  String get dietBtnContinueDietPref => 'Continue to Diet Preference';

  @override
  String get dietBtnContinueHealthGoals => 'Continue to Health Goals';

  @override
  String get dietBtnContinueTimeContext => 'Continue to Time & Context';

  @override
  String get dietBtnGeneratePlan => 'Generate Verified Diet Plan';

  @override
  String get dietReturnToOverview => 'Return to Diet Overview';

  @override
  String get dietBackToOverview => 'Back to Diet Overview';

  @override
  String get dietNoMealRoutineSaved => 'No Meal Routine Saved Yet';

  @override
  String get validationAgeRange => 'Please enter a valid age (1–120).';

  @override
  String get validationSelectNonVegDay =>
      'Please select at least one day for non-vegetarian meals.';

  @override
  String get dietSectionTitle => 'Diet Section';

  @override
  String get dietSectionSubtitle => 'Calculate Your Every Single Bite';

  @override
  String get dietQuickAction => 'Quick Action';

  @override
  String get dietPlannerNav => 'Diet Planner';

  @override
  String get foodScannerNav => 'Food Scanner';

  @override
  String get dietMealRoutineHistoryNav => 'Meal Routine History';

  @override
  String get dietMealRoutineHistorySubtitle =>
      'Check Out Your Meal Routine And Edit';

  @override
  String get dietNoMealRoutineSavedSubtitle =>
      'Your saved weekly meal routine will appear here once configured.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Manage Your App Settings & Preferences';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsLanguageCard => 'Language';

  @override
  String get settingsLanguageSelectTitle => 'Select Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageGujarati => 'ગુજરાતી';

  @override
  String get settingsLanguageHindi => 'हिन्दी';

  @override
  String get settingsAppSettingsCard => 'App Settings';

  @override
  String get settingsAppSettingsSubtitle =>
      'Units, time format, and clinical display';

  @override
  String get settingsDataPrivacyCard => 'Data & Privacy';

  @override
  String get settingsDataPrivacySubtitle =>
      'Row Level Security, permissions & account data';

  @override
  String get settingsSectionSupport => 'Support & Feedback';

  @override
  String get settingsCustomerSupportCard => 'Customer Support';

  @override
  String get settingsCustomerSupportSubtitle =>
      'Direct care coordination and helpdesk';

  @override
  String get settingsReportProblemCard => 'Report a Problem';

  @override
  String get settingsReportProblemSubtitle => 'Report bugs or sync anomalies';

  @override
  String get settingsSectionLegal => 'Legal & Compliance';

  @override
  String get settingsPrivacyPolicyCard => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Zero third-party monetization & RLS sovereignty';

  @override
  String get settingsTermsCard => 'Terms of Service';

  @override
  String get settingsTermsSubtitle =>
      'Continuity of care guidelines and emergency terms';

  @override
  String get settingsTimeFormat => 'Time Format';

  @override
  String get settingsWeightUnit => 'Weight Unit';

  @override
  String get settingsHeightUnit => 'Height Unit';

  @override
  String get reportProblemTitle => 'Report a Problem';

  @override
  String get reportProblemSubtitle =>
      'Describe bugs or anomalies to improve NuroVed';

  @override
  String get reportProblemDescribeLabel => 'Describe your issue';

  @override
  String get reportProblemDescribeSubtitle =>
      'Include what screen you were on and what went wrong';

  @override
  String get reportProblemDescribeHint =>
      'Please explain what happened, steps to reproduce, or feedback...';

  @override
  String get reportProblemSubmitButton => 'Submit Report';

  @override
  String get reportProblemSubmitting => 'Recording Diagnostic...';

  @override
  String get reportProblemSavedSuccess =>
      'Report saved to local device diagnostics.';

  @override
  String get reportProblemHistoryTitle => 'Recent Reports';

  @override
  String get reportProblemPastSection => 'Past Reported Problems';

  @override
  String get reportProblemEmpty => 'No Past Reports';

  @override
  String get reportProblemBadgeSaved => 'Saved on Device';

  @override
  String get reportProblemBadgeSample => 'Sample Reference';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get backendNotConfigured => 'Backend Not Configured';

  @override
  String get backendRunningOffline =>
      'Supabase credentials not provided. Operating in local in-memory mode.';

  @override
  String get routeNotFoundTitle => 'Route Not Found';

  @override
  String get routeNotFoundMessage => 'The requested page could not be located.';

  @override
  String get routeNotFoundReturn => 'Return to Safety';

  @override
  String get semanticsBack => 'Back';

  @override
  String get semanticsClose => 'Close';

  @override
  String get semanticsTogglePassword => 'Toggle password visibility';

  @override
  String get semanticsShowPassword => 'Show password';

  @override
  String get semanticsHidePassword => 'Hide password';

  @override
  String get routineTodaysProgress => 'Today\'s Progress';

  @override
  String get routineMedicineAdherence => 'Medicine Adherence';

  @override
  String get routineMealRoutine => 'Meal Routine';

  @override
  String get routineTime12AM => '12AM';

  @override
  String get routineTime6AM => '6AM';

  @override
  String get routineTime12PM => '12PM';

  @override
  String get routineTime6PM => '6PM';

  @override
  String get routineTabMeals => 'Meals';

  @override
  String get routineTabMedicines => 'Medicines';

  @override
  String get routineMondayMedicines => 'Monday Medicines';

  @override
  String get routineMondayMeals => 'Monday Meals';

  @override
  String get routineDeleteRoutineTitle => 'Delete Routine';

  @override
  String routineDeleteRoutineMessage(Object name) {
    return 'Are you sure you want to remove \"$name\" from your routine?';
  }

  @override
  String routineRemovedSnackbar(Object name) {
    return 'Removed \"$name\" from routine.';
  }

  @override
  String get routineAddMedicinesTitle => 'Add Medicines';

  @override
  String get routineAddMedicinesSubtitle =>
      'Add Your Medicine Reminder So You Dont Forget';

  @override
  String get routineProfiles => 'Profiles';

  @override
  String get routineSelectProfilePrompt => 'Select A Profile';

  @override
  String get routineSelectedProfile => 'Selected Profile';

  @override
  String get routineMedicineDetails => 'Medicine Details';

  @override
  String get routineEnterMedicineDetails => 'Enter Medicine Details';

  @override
  String get routineMedicineNameLabel => 'Medicine Name';

  @override
  String get routineEnterMedicineNameHint => 'Enter Medicine Name';

  @override
  String get routineEnterInstructionsHint =>
      'Enter Instructions (e.g. After food)';

  @override
  String get routineReminderTime => 'Reminder Time';

  @override
  String get routineSelectTimePrompt => 'Select A Time';

  @override
  String get routineSelectProfileAndNameError =>
      'Please select profile and enter medicine name';

  @override
  String routineFailedToScheduleNotification(Object error) {
    return 'Failed to schedule notification: $error';
  }

  @override
  String get routineReminderSavedSuccess =>
      'Medication reminder saved successfully!';

  @override
  String get routinePermissionDenied => 'Permission Denied';

  @override
  String get routinePermissionDeniedMessage =>
      'Notification permissions are required to receive medication reminders. Please enable notifications in your device settings.';

  @override
  String get routineIngredients => 'Ingredients';

  @override
  String routineIntakeMeal(String meal) {
    return 'Intake $meal';
  }

  @override
  String get routineIgnoreAndSkip => 'Ignore & Skip';

  @override
  String routineConfirmMeal(String meal) {
    return 'Confirm $meal';
  }

  @override
  String routineHaveYouFinishedMeal(String meal) {
    return 'Have you finished your $meal meal?';
  }

  @override
  String get routineNotYet => 'Not Yet';

  @override
  String get routineYesDone => 'Yes, Done';

  @override
  String get routineMealNameEmpty => 'Meal name cannot be empty';

  @override
  String get routineMealUpdatedSuccess => 'Meal routine updated successfully!';

  @override
  String get routineAddIngredientHint => 'Add an ingredient';

  @override
  String get routineAddMoreIngredients => 'Add More Ingredients';

  @override
  String get routineSaveMeal => 'Save Meal';

  @override
  String get routineMealTakenSuccess =>
      'Meal has been taken, calorie has been saved';

  @override
  String get routineSeeDietSection => 'See in Diet Section';

  @override
  String get routineMedicineTimeline => 'Medicine Timeline';

  @override
  String routinePercentDone(Object percent) {
    return '$percent% Done';
  }

  @override
  String get routineSourceVerifiedPrescription => 'Verified Prescription';

  @override
  String get routineSourceSelfEntered => 'Self-Entered';

  @override
  String get familyProfilesTitle => 'Family Profiles';

  @override
  String get familyProfilesSubtitle =>
      'Switch or manage health records for your family members';

  @override
  String get familySelectActiveProfile => 'Select as Active Profile';

  @override
  String get familySwitchActiveProfileSubtitle =>
      'Switch health timeline, records and routine to this person';

  @override
  String familySwitchedActiveProfile(Object name) {
    return 'Switched active profile to $name';
  }

  @override
  String get familyEditMemberProfile => 'Edit Member Profile';

  @override
  String get familyRemoveProfileTitle => 'Remove Profile?';

  @override
  String familyRemoveProfileMessage(Object name) {
    return 'Are you sure you want to remove \"$name\" from family profiles? Their local records and visits will remain.';
  }

  @override
  String familyRemovedMemberSnackbar(Object name) {
    return 'Removed \"$name\" from family profiles.';
  }

  @override
  String get familyAddNewProfile => 'Add New Profile';

  @override
  String get familyAddProfileTitle => 'Add Family Profile';

  @override
  String get familyAddProfileSubtitle =>
      'Manage Your And Your Families Personal Information';

  @override
  String get familyEnterNameHint => 'Enter Full Name';

  @override
  String get familyRelationLabel => 'Relationship';

  @override
  String get familyEnterRelationHint => 'Enter Relationship (e.g. Mother, Son)';

  @override
  String get familyEnterNameError => 'Please enter a name';

  @override
  String get familyMemberAddedSuccess => 'Family member added successfully!';

  @override
  String familyMemberAddFailed(Object error) {
    return 'Failed to add family member: $error';
  }

  @override
  String get familyAddNewProfileButton => 'Add New Profile';

  @override
  String get familyActiveBadge => 'ACTIVE';

  @override
  String get familyEditProfileTitle => 'Edit Family Profile';

  @override
  String get familyNameEmptyError => 'Name cannot be empty';

  @override
  String get familyMemberUpdatedSuccess =>
      'Family member updated successfully!';

  @override
  String familyMemberUpdateFailed(Object error) {
    return 'Failed to update family member: $error';
  }

  @override
  String get emergencyCardTitle => 'Emergency Card';

  @override
  String get emergencyCardUnverifiedBadge => 'PATIENT-ENTERED, UNVERIFIED';

  @override
  String get emergencyCardBloodGroup => 'Blood Group';

  @override
  String get emergencyCardAllergies => 'Allergies';

  @override
  String get emergencyCardChronicConditions => 'Chronic Conditions';

  @override
  String get emergencyCardNotProvided => 'Not provided';

  @override
  String get emergencyCardFamilyProfiles => 'Family Profiles';

  @override
  String get emergencyCardViewAllProfiles => 'View all family profiles';

  @override
  String get emergencyCardNotAssigned => 'Not assigned';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get emergencyCardPhoneNotProvided => 'Phone not provided';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle => 'Your Personal Health & Emergency Identity';

  @override
  String get profileTabPersonal => 'Personal';

  @override
  String get profileTabEmergency => 'Emergency';

  @override
  String get profileAgeNotProvided => 'Age not provided';

  @override
  String profileAgeYearsOld(Object age) {
    return '$age years old';
  }

  @override
  String profileUserId(Object id) {
    return 'ID: $id';
  }

  @override
  String get profileMetricBlood => 'Blood';

  @override
  String get profileMetricHeight => 'Height';

  @override
  String get profileMetricWeight => 'Weight';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileKnownAllergies => 'Known Allergies';

  @override
  String get profileChronicCondition => 'Chronic Condition';

  @override
  String get recordsPreviousRecords => 'Previous Records';

  @override
  String get recordsSortNewest => 'Newest First';

  @override
  String get recordsSortOldest => 'Oldest First';

  @override
  String get recordsSortTitle => 'Title (A-Z)';

  @override
  String get recordsFilterMedicalRecords => 'Medical Records';

  @override
  String get recordsFilterVaccinations => 'Vaccinations';

  @override
  String get recordsFilterBills => 'Bills';

  @override
  String get recordsFilterLab => 'Lab';

  @override
  String get recordsSelectProfilePrompt => 'Select a profile';

  @override
  String get recordsEnterTitlePrompt => 'Please enter a record title';

  @override
  String get recordsAttachPrompt => 'Please attach a document or photo';

  @override
  String get recordsAddRecordTitle => 'Add Records';

  @override
  String get recordsAddRecordSubtitle =>
      'A single space for all your medical records';

  @override
  String get recordsSelectProfile => 'Select Profile';

  @override
  String get recordsRecordType => 'Record Type';

  @override
  String get recordsSelectRecordType => 'Select Record Type';

  @override
  String get recordsDateLabel => 'Date';

  @override
  String get recordsSelectDatePrompt => 'Select A Date';

  @override
  String get recordsUploadingSecurely => 'Uploading Securely...';

  @override
  String get recordsSaveButton => 'Save Records';

  @override
  String get recordsTitleAndDescription => 'Record Title & Description';

  @override
  String get recordsEnterTitleAndDescription => 'Enter Title & Description';

  @override
  String get recordsEnterRecordTitleHint =>
      'Enter Record Title (e.g. Blood Test Report)';

  @override
  String get recordsEnterRecordDescriptionHint =>
      'Enter Description / Notes (Optional)';

  @override
  String get recordsRecordFile => 'Record File';

  @override
  String get recordsUploadDocumentPrompt => 'Upload Your Document';

  @override
  String get recordsUploadFilesOption => 'Upload Files';

  @override
  String get recordsClickPhotoOption => 'Click Photo';

  @override
  String get recordsNoStorageFile => 'No storage file attached to this record.';

  @override
  String recordsFailedRetrieveSecureUrl(Object error) {
    return 'Failed to retrieve secure URL: $error';
  }

  @override
  String get recordsSecureRetrievalTitle => 'Secure Retrieval';

  @override
  String get recordsSecureRetrievalSubtitle =>
      'Generated time-bound signed URL directly from Supabase Storage.';

  @override
  String get recordsSecureRetrievalValid => 'Signed URL (valid for 1 hour):';

  @override
  String get recordsEditMetadataTitle => 'Edit Record Metadata';

  @override
  String get recordsEditTitleLabel => 'Title';

  @override
  String get recordsEditDoctorLabel => 'Doctor / Clinician';

  @override
  String get recordsEditHospitalLabel => 'Hospital / Clinic';

  @override
  String get recordsEditNotesLabel => 'Notes / Description';

  @override
  String get recordsDetailsTitle => 'Record Details';

  @override
  String get recordsEditMetadataAction => 'Edit Metadata';

  @override
  String get recordsDeleteRecordAction => 'Delete Record';

  @override
  String recordsDatePrefix(Object date) {
    return 'Date: $date';
  }

  @override
  String recordsDoctorPrefix(Object doctor) {
    return 'Doctor: $doctor';
  }

  @override
  String recordsHospitalPrefix(Object hospital) {
    return 'Hospital: $hospital';
  }

  @override
  String get recordsAttachedDocument => 'Attached Document';

  @override
  String get recordsAuthorizing => 'Authorizing...';

  @override
  String get recordsRequestSecureUrl => 'Request Secure Access URL';

  @override
  String get recordsNoRemoteFile =>
      'No remote storage file associated with this record.';

  @override
  String get recordsClinicalNotesTitle => 'Clinical Notes & Description';

  @override
  String get recordsNoNotesEntered => 'No notes entered for this record.';

  @override
  String get recordsSavedSuccess => 'New Record Saved\nSuccessfully';

  @override
  String get recordsSeeInRecords => 'See in Records';

  @override
  String get recordsNoRecentRecords => 'No Recent Records Found';

  @override
  String get recordsSearchHint => 'Search by title or doctor...';

  @override
  String get recordsDeleteTitle => 'Delete Record';

  @override
  String get recordsDeleteTooltip => 'Delete Record';

  @override
  String get visitsSelectProfileFirst => 'Please select a profile first';

  @override
  String get visitsEnterTitlePrompt => 'Please enter a visit title';

  @override
  String get visitsAddedSuccess => 'Doctor visit added successfully!';

  @override
  String visitsSaveFailed(Object error) {
    return 'Failed to save visit: $error';
  }

  @override
  String get visitsAttachRecords => 'Attach Records';

  @override
  String get visitsSelectRecordRelated => 'Select Record Related To Visit';

  @override
  String get visitsAddNewTitle => 'Add New Visit';

  @override
  String get visitsDetailsCardTitle => 'Visit details';

  @override
  String get visitsEnterDetailsPrompt => 'Enter Doctor\'s Visit details';

  @override
  String get visitsEnterTitleHint =>
      'Enter Title (e.g. Cardiologist Follow-up)';

  @override
  String get visitsEnterDescriptionHint => 'Enter Doctor\'s Diagnosis & Notes';

  @override
  String get visitsSelectDatePrompt => 'Select A Date';

  @override
  String get visitsSaveButton => 'Save Visit';

  @override
  String get visitsDeleteDialogTitle => 'Delete Visit?';

  @override
  String get visitsDeleteDialogMessage =>
      'Are you sure you want to delete this consultation visit? This will remove it from your timeline.';

  @override
  String get visitsDeletedSuccess => 'Visit deleted successfully';

  @override
  String get visitsEditDetailsTitle => 'Edit Visit Details';

  @override
  String get visitsEditTitleLabel => 'Title / Purpose';

  @override
  String get visitsEditDoctorLabel => 'Doctor Name';

  @override
  String get visitsEditHospitalLabel => 'Hospital / Clinic';

  @override
  String get visitsEditNotesLabel => 'Clinical Notes';

  @override
  String get visitsEditDetailsAction => 'Edit Details';

  @override
  String get visitsDeleteVisitAction => 'Delete Visit';

  @override
  String get visitsConsultationNotesTitle => 'Consultation & Clinical Notes';

  @override
  String get visitsNoDetailedNotes =>
      'No detailed clinical notes recorded for this visit.';

  @override
  String get visitsNextFollowUp => 'Next Follow-up';

  @override
  String get visitsNoFollowUpScheduled => 'No follow-up scheduled';

  @override
  String get visitsRelatedRecordsTitle => 'Related Medical Records';

  @override
  String visitsAttachedCount(Object count) {
    return '($count attached)';
  }

  @override
  String get visitsNoRecordsAttached =>
      'No medical records attached to this visit.';

  @override
  String visitsNoRecordsFoundFor(Object name) {
    return 'No Records Found For $name';
  }

  @override
  String get visitsSelectRelatedRecordsSubtitle =>
      'Choose records associated with this consultation';

  @override
  String get visitsSelectRelatedRecordButton => 'Select Related Record';

  @override
  String get visitsViewRelatedRecord => 'View Record';

  @override
  String get dietEditMealTitle => 'Edit Meal';

  @override
  String get dietEditMealSubtitle => 'Edit your meal routine and ingredients';

  @override
  String dietDayNumberName(Object day, Object name) {
    return 'Day $day $name';
  }

  @override
  String get dietIngredientsHeader => 'Ingredients';

  @override
  String get dietAddMore => '+ Add More';

  @override
  String get dietMealTitleEmpty => 'Meal titles cannot be empty.';

  @override
  String get dietPlanUpdatedSuccess => 'Diet meal plan updated successfully.';

  @override
  String get dietSaveRoutineButton => 'Save Routine';

  @override
  String get dietCalorieSavedSuccess => 'Calorie Saved\nSuccessfully';

  @override
  String get dietRoutineSavedSuccess => 'New Meal Routine Saved\nSuccessfully';

  @override
  String get dietSeeMealRoutineHistory => 'See in Meal Routine History';

  @override
  String get foodScannerQueryingOpenFoodFacts =>
      'Querying OpenFoodFacts database...';

  @override
  String get foodScannerAlignPrompt => 'Align barcode inside the frame';

  @override
  String get foodScannerTorchOn => 'Turn flashlight on';

  @override
  String get foodScannerTorchOff => 'Turn flashlight off';

  @override
  String get foodScannerManualCode => 'Enter barcode manually';

  @override
  String get foodScannerFlipLens => 'Switch camera lens';

  @override
  String get foodScannerHistorySubtitle => 'Recent Scanned Food Logs';

  @override
  String get foodScannerHistoryEmptyDesc =>
      'Scanned food nutrition history will appear here once scanning is enabled.';

  @override
  String get dietPlannerVerifiedBanner =>
      'Continuity of care enabled • Patient-centered clinical nutrition';

  @override
  String get dietBasicInfoTitle => 'Basic Profile Information';

  @override
  String dietProfilePrefix(Object name) {
    return 'Profile: $name';
  }

  @override
  String get dietAgeYearsLabel => 'Age (Years)';

  @override
  String get dietWeightKgLabel => 'Weight (kg)';

  @override
  String get dietHeightCmLabel => 'Height (cm)';

  @override
  String get dietContinueToPreferences => 'Continue to Preferences';

  @override
  String get dietValidationAge => 'Please enter a valid age (1-120)';

  @override
  String get dietValidationWeight => 'Please enter a valid weight (10-300 kg)';

  @override
  String get dietValidationHeight => 'Please enter a valid height (50-250 cm)';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietNonVeg => 'Non-Vegetarian';

  @override
  String get dietBothVegNonVeg => 'Both (Veg + Non-Veg)';

  @override
  String get dietPickNonVegDays => 'Pick Non-Veg Days:';

  @override
  String get dietAllergiesOptional => 'Known Allergies (Optional)';

  @override
  String get dietSpecifyIngredientsPrompt =>
      'Specify ingredients to exclude completely';

  @override
  String get dietAllergiesHint => 'e.g., Peanuts, Shellfish, Gluten, Dairy';

  @override
  String get dietContinueToGoals => 'Continue to Health Goals';

  @override
  String get dietValidationNonVegDays =>
      'Please select at least one non-veg day or change your preference';

  @override
  String get dietHealthGoalTitle => 'Activity Level & Primary Goal';

  @override
  String get dietActivityLevelLabel => 'Activity Level';

  @override
  String get dietSelectActivityLevelHint => 'Select your daily activity level';

  @override
  String get dietPrimaryGoalLabel => 'Primary Health Goal';

  @override
  String get dietSelectPrimaryGoalHint => 'Select your primary target';

  @override
  String get dietGoalLoseWeight => 'Lose Weight (Caloric Deficit)';

  @override
  String get dietGoalMuscleGain => 'Build Muscle / Gain Weight';

  @override
  String get dietValidationActivityGoal =>
      'Please select both activity level and health goal';

  @override
  String get dietContinueToTimeContext => 'Continue to Time & Context';

  @override
  String get dietClinicalNoticeTitle => 'Clinical Notice';

  @override
  String dietConditionPrefix(Object conditions) {
    return 'Condition: $conditions';
  }

  @override
  String get dietConstraintsRestrictiveTitle =>
      'Preferences are highly restrictive';

  @override
  String get dietAdjustExclusions =>
      'Adjust your exclusions or dietary preferences to allow healthy menu planning.';

  @override
  String get dietTimeAndContextTitle => 'Meal Timing, Budget & Context';

  @override
  String get dietMealTimingLabel => 'Meal Schedule & Timing';

  @override
  String get dietMealTimingHint =>
      'e.g., Breakfast 8:30 AM, Lunch 1:30 PM, Dinner 8:30 PM';

  @override
  String get dietBudgetLabel => 'Grocery & Meal Budget Preference';

  @override
  String get dietBudgetHint =>
      'e.g., Economical local market, Moderate, Premium organic';

  @override
  String get dietCookingContextLabel => 'Cooking Context & Resources';

  @override
  String get dietCookingContextHint =>
      'e.g., Home-cooked, Hosteller with induction, Working professional';

  @override
  String get dietGeneratePlanButton => 'Generate Tailored Diet Plan';

  @override
  String get dietRegeneratedSuccess => 'Regenerated diet plan successfully.';

  @override
  String get dietSavedToRoutineSuccess =>
      'Diet routine saved to local weekly schedule.';

  @override
  String get dietVerifiedPlanning => 'Verified Clinical Nutritional Planning';

  @override
  String dietEstimatedDailyCaloricTarget(Object calories) {
    return 'Estimated Daily Caloric Target: ~$calories kcal';
  }

  @override
  String get dietInformationalBadge =>
      'INFORMATIONAL NUTRITIONAL ADVISORY • NON-PRESCRIPTIVE';

  @override
  String dietDayNumber(Object day) {
    return 'Day $day';
  }

  @override
  String get dietNutritionOverview => 'Nutrition Overview';

  @override
  String dietTotalCaloriesKcal(Object calories) {
    return 'Total Calories: $calories kcal';
  }

  @override
  String dietProtein(Object grams) {
    return 'Protein: ${grams}g';
  }

  @override
  String dietCarbs(Object grams) {
    return 'Carbs: ${grams}g';
  }

  @override
  String dietFat(Object grams) {
    return 'Fat: ${grams}g';
  }

  @override
  String dietFiber(Object grams) {
    return 'Fiber: ${grams}g';
  }

  @override
  String get dietBreakfast => 'Breakfast';

  @override
  String get dietLunch => 'Lunch';

  @override
  String get dietEveningSnack => 'Evening Snack';

  @override
  String get dietDinner => 'Dinner';

  @override
  String get dietIngredientsAndPortions => 'Ingredients & Portions';

  @override
  String get dietEstimatedNutritionPerServing =>
      'Estimated Nutrition Per Serving';

  @override
  String get dietPreparationNote => 'Preparation Note';

  @override
  String get dietClinicalNoticeHeader => 'Clinical Notice & Safeguards';

  @override
  String get dietSourceDisclaimer =>
      'Source: NuroVed Clinical Heuristics Engine. This nutritional plan provides generalized advisory estimates and is not a substitute for clinical medical therapy or certified renal/metabolic medical nutrition therapy.';

  @override
  String get dietSaveToRoutineButton => 'Save to My Routine';

  @override
  String get dietRegenerateButton => 'Regenerate Plan';

  @override
  String get dietEditInputsButton => 'Edit Inputs';

  @override
  String get dietBackToOverviewButton => 'Back to Overview';

  @override
  String get premiumWelcomeTitle => 'Welcome to NuroVed\nPremium Plus';

  @override
  String get premiumPaymentFailedTitle => 'Payment failed';

  @override
  String get premiumRenewTitle => 'Renew the premium plan';

  @override
  String get premiumStatusActivated => 'Activated';

  @override
  String get premiumStatusFailed => 'Payment Failed';

  @override
  String get premiumStatusExpired => 'Expired';

  @override
  String get premiumJumpToHome => 'Jump to Home';

  @override
  String get premiumRetry => 'Retry';

  @override
  String get premiumRenewNow => 'Renew Now';

  @override
  String get premiumPaymentTotal => 'Payment Total';

  @override
  String get premiumDate => 'Date';

  @override
  String get premiumTime => 'Time';

  @override
  String get premiumBilledTo => 'Billed To';

  @override
  String get premiumBilledAmount => 'Billed Amount';

  @override
  String get premiumSavings => 'Savings';

  @override
  String get premiumGst => 'GST';

  @override
  String get premiumAmountPaid => 'Amount Paid';

  @override
  String get purchaseTitle => 'NuroVed Purchase';

  @override
  String get purchaseCompanySubtitle => 'Promacle private limited';

  @override
  String get purchaseActiveDuration => 'Your account will be active for';

  @override
  String purchaseDaysCount(Object days) {
    return '$days Days';
  }

  @override
  String get purchaseSpecialOffer => 'NuroVed special Offer';

  @override
  String get purchaseOffYearly => '70% Off Yearly';

  @override
  String get purchaseOffMonthly => '65% Off Monthly';

  @override
  String purchaseYouWillSave(Object amount, Object period) {
    return 'you will save ₹$amount on $period';
  }

  @override
  String get purchaseYearly => 'yearly';

  @override
  String get purchaseMonthly => 'monthly';

  @override
  String get purchaseSelectMethod => 'Select Method';

  @override
  String get purchaseSecureBadge => '100% Secure & Safe payments';

  @override
  String get purchaseServiceCharge => 'Service Charge';

  @override
  String get purchaseDiscount => 'Discount';

  @override
  String get purchaseTotalAmountToPay => 'Total Amount To Pay';

  @override
  String get purchaseUnavailableTitle => 'In-App Purchases Unavailable in MVP';

  @override
  String get purchaseUnavailableDesc =>
      'Payment checkout is disabled in this MVP release.\n\nIn accordance with NuroVed safety guidelines, subscription entitlement requires server-side receipt validation with Apple StoreKit and Google Play Billing, which is not yet configured.\n\nAll current core continuity-of-care tools remain accessible in free preview mode.';

  @override
  String get purchaseReturnToApp => 'Return to App';

  @override
  String get customerSupportTitle => 'Customer Support';

  @override
  String get customerSupportAboutUs => 'About Us';

  @override
  String get customerSupportSearchHint => 'Search...';

  @override
  String get customerSupportContactUs => 'Contact Us';

  @override
  String get customerSupportFaq => 'FAQ';

  @override
  String get customerSupportNoContactMatch =>
      'No contact options match your search.';

  @override
  String get customerSupportNoFaqMatch => 'No FAQs match your search.';

  @override
  String get customerSupportService => 'Customer Service';

  @override
  String get customerSupportWebsite => 'Website';

  @override
  String get customerSupportWhatsapp => 'Whatsapp';

  @override
  String get customerSupportFacebook => 'Facebook';

  @override
  String get customerSupportInstagram => 'Instagram';

  @override
  String get customerSupportPhoneNotConfigured =>
      'Direct phone support is currently unconfigured in this release. Please visit our website or report a problem via Settings.';

  @override
  String get customerSupportWebsiteDialog =>
      'Official website: https://nuroved.com\nPlease open this link in your web browser.';

  @override
  String get customerSupportWhatsappNotConfigured =>
      'WhatsApp support is currently unconfigured in this release. Please visit our website or report a problem via Settings.';

  @override
  String customerSupportChannelNotActive(Object channel) {
    return 'The $channel support channel is not yet active in this release. Please visit our website or report a problem via Settings.';
  }

  @override
  String get dataPrivacyTitle => 'Data & Privacy';

  @override
  String get dataPrivacySubtitle => 'Your Data Is Securely Stored & Protected';

  @override
  String get dataPrivacyDeleteTitle => 'Delete Account & Data';

  @override
  String get dataPrivacyDeleteMessage =>
      'Are you sure you want to permanently delete your account? All medical records, visits, and timeline data will be permanently erased. This action cannot be reversed.';

  @override
  String get dataPrivacyConfirmPassword => 'Confirm your password:';

  @override
  String get dataPrivacyEnterPassword => 'Enter password';

  @override
  String get dataPrivacyPasswordRequired =>
      'Password confirmation is required.';

  @override
  String get dataPrivacyDeleteFailed => 'Account deletion failed.';

  @override
  String get dataPrivacyPermanentlyDelete => 'Permanently Delete';

  @override
  String get dataPrivacyNoActiveEmail =>
      'No active email found for current user.';

  @override
  String get dataPrivacySendingReset =>
      'Sending password reset instructions...';

  @override
  String dataPrivacyResetSent(Object email) {
    return 'Reset instructions sent to $email.';
  }

  @override
  String get dataPrivacyPolicyDialogTitle => 'Privacy & Security Policy';

  @override
  String get dataPrivacyChangeEmail => 'Change email address';

  @override
  String get dataPrivacyChangePassword => 'Change password';

  @override
  String get dataPrivacyResetPassword => 'Reset password via email';

  @override
  String get dataPrivacyPolicy => 'Privacy Policy';

  @override
  String get dataPrivacyDeleteMyAccount => 'Delete My Account';

  @override
  String get changeEmailTitle => 'Change Email';

  @override
  String get changeEmailSubtitle => 'Update your registered account email';

  @override
  String get changeEmailEnterNew => 'Enter new email address';

  @override
  String get changeEmailEnterPassword => 'Enter account password';

  @override
  String get changeEmailPasswordRequired =>
      'Password is required to verify identity.';

  @override
  String get changeEmailVerificationSent =>
      'Verification email sent to your new address.';

  @override
  String get changeEmailSaveButton => 'Save New Email';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordSubtitle =>
      'Re-authenticate and set your new password';

  @override
  String get changePasswordEnterCurrent => 'Enter current password';

  @override
  String get changePasswordEnterNew => 'Enter new password (min. 8 characters)';

  @override
  String get changePasswordReEnterNew => 'Re-enter new password';

  @override
  String get changePasswordCurrentRequired => 'Current password is required.';

  @override
  String get changePasswordMinLength =>
      'New password must be at least 8 characters.';

  @override
  String get changePasswordMismatch => 'New passwords do not match.';

  @override
  String get changePasswordSuccess => 'Password changed successfully.';

  @override
  String get changePasswordSaveButton => 'Save New Password';

  @override
  String settingsSelectOption(Object title) {
    return 'Select $title';
  }

  @override
  String get notificationsTitle => 'Notification';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsAllMarkedRead => 'All notifications marked as read';

  @override
  String get notificationsSectionToday => 'Today';

  @override
  String get notificationsSectionThisWeek => 'This week';

  @override
  String get notificationsSampleMedicineTitle => 'Time For Mom\'s Medicine';

  @override
  String get notificationsSampleMedicineSub =>
      'It\'s time to take Mom\'s BP medicine....';

  @override
  String get notificationsSampleBloodTestTitle => 'Blood test Reminder';

  @override
  String get notificationsSampleBloodTestSub =>
      'Remember your upcoming blood test tomorrow...';

  @override
  String get notificationsSampleStreakTitle => '5-day Streak! Great Job!';

  @override
  String get notificationsSampleStreakSub =>
      'You have logged in for 5 days consecutively...';

  @override
  String get notificationsSampleEncryptedTitle => 'Your Data is Encrypted';

  @override
  String get notificationsSampleEncryptedSub =>
      'Your health records are securely encrypted & protected';

  @override
  String get notificationsSampleRecordTitle => 'First record has been added';

  @override
  String get notificationsSampleRecordSub =>
      'Your first health records has been added successfully.....';

  @override
  String get notificationsSampleWelcomeTitle => 'Thank you for joining us';

  @override
  String get notificationsSampleWelcomeSub =>
      'Welcome to new revolutionary step towards your health....';

  @override
  String get accessManageTab => 'Manage Access';

  @override
  String get accessRequestTab => 'Access Request';

  @override
  String get accessGrantNewTitle => 'Grant New Access';

  @override
  String get accessGrantNewSubtitle =>
      'Give Hospitals Access To Your Health Profile';

  @override
  String get accessSelectHospital => 'Select Hospital';

  @override
  String get accessChooseHospitalSubtitle =>
      'Choose A Hospital Or Healthcare Provider';

  @override
  String get accessDurationTitle => 'Access Duration';

  @override
  String get accessPermanent => 'Permanent Access';

  @override
  String get accessUntilDay => 'Select Access Until Day';

  @override
  String get accessDataToShare => 'Data To Share';

  @override
  String get accessFullProfile => 'Full Profile Access';

  @override
  String get accessHealthTimelineOnly => 'Only Health Timeline';

  @override
  String get accessMedicalRecordsOnly => 'Only Medical Records';

  @override
  String get accessProfilePageOnly => 'Only Profile Page';

  @override
  String get accessTypeTitle => 'Access Type';

  @override
  String get accessViewOnly => 'View Only';

  @override
  String get accessEditAndView => 'Edit & View';

  @override
  String get accessGrantedSuccess => 'Access Granted Successfully!';

  @override
  String get accessReviewAndGrant => 'Review & Grant Access';

  @override
  String get accessActiveHospitals => 'Active Hospital Access';

  @override
  String get accessActiveHospitalsSubtitle =>
      'Hospitals That Currently Have Access To Your Profile';

  @override
  String get accessNoActive => 'No active access';

  @override
  String get accessRevokeAction => 'Revoke Access';

  @override
  String get accessRevokeTitle => 'Revoke Access?';

  @override
  String accessRevokeConfirmMessage(Object hospital) {
    return 'Are you sure you want to revoke access for $hospital? They will immediately lose access to your data.';
  }

  @override
  String accessRevokedSnackbar(Object hospital) {
    return 'Access revoked for $hospital';
  }

  @override
  String get accessHospitalRequestTitle => 'Hospital Access Request';

  @override
  String get accessHospitalRequestSubtitle =>
      'Hospitals Requesting Access To Your Profile';

  @override
  String get accessClinicianComingSoon =>
      'Clinician Direct Sharing Coming Soon';

  @override
  String get accessClinicianNotice =>
      'Direct institutional hospital and clinician sharing is disabled in the MVP.\n\nIn accordance with healthcare safety standards, clinical access requires server-side identity verification through accredited provider directories. A clinician\'s identity is never proven by an unverified name or typed email.\n\nDelegated caregiver access is available in the \'Manage Access\' tab, protected by authenticated Row Level Security.';

  @override
  String get accessEnforcedSecurity =>
      'Enforced via Care Access Grants & RLS policies';

  @override
  String get accessGoToManage => 'Go to Manage Access';

  @override
  String get hospitalDetailsExpiringIn => 'Expiring In';

  @override
  String get hospitalDetailsActivityLog => 'Activity Log';

  @override
  String get hospitalDetailsRecentActions => 'Recent Actions By Hospitals';

  @override
  String get hospitalDetailsViewedRecord => 'Viewed Medical Record';

  @override
  String get hospitalDetailsAddedRecord => 'Added New Record';

  @override
  String get hospitalDetailsAddedVisits => 'Added New Visits';

  @override
  String hospitalDetailsActionSubtitle(Object name, Object time) {
    return 'By $name - $time';
  }

  @override
  String get loginPhoneLabel => 'Phone Number';

  @override
  String get commonUnderstood => 'Understood';

  @override
  String get routineEditMeal => 'Edit Routine';

  @override
  String get homeHealthHeadline =>
      'Let\'s take the next step\nfor your health!';

  @override
  String get recordsUpdatedSuccess => 'Record updated successfully';

  @override
  String recordsFailedDelete(String error) {
    return 'Failed to delete record: $error';
  }

  @override
  String get recordsUnknownSize => 'Unknown size';

  @override
  String get commonView => 'View';

  @override
  String get commonTime => 'Time';

  @override
  String get visitsUpdatedSuccess => 'Visit updated successfully';

  @override
  String get dietDisclaimerBanner =>
      'Diet suggestions are for nutritional tracking only and do not constitute medical diagnosis or treatment.';

  @override
  String get dietPreviewMetricsNotice =>
      'Sample preview metrics - not clinical measurements';

  @override
  String get dietKcalIntake => 'kcal intake';

  @override
  String get dietSleep => 'Sleep';

  @override
  String get dietSeeInDietSection => 'See in Diet Section';

  @override
  String get dietVerifiedNutritionalPlanningNotice =>
      'Verified Nutritional Planning: Calculations are based on clinical dietary guidelines (ICMR-NIN & Mifflin-St Jeor). General reference only.';

  @override
  String get dietGuidelinesAttribution =>
      'Source: ICMR-NIN & USDA Food Data Central Dietary Guidelines.';

  @override
  String foodScannerQueryingBarcode(String barcode) {
    return 'Querying Open Food Facts for barcode $barcode';
  }

  @override
  String get foodScannerManualSubtitle =>
      'Type the 8, 12, 13, or 14-digit retail barcode found on the product packaging (EAN / UPC).';

  @override
  String get foodScannerBarcodeLabel => 'Barcode Digits';

  @override
  String get foodScannerBarcodeHint => 'e.g. 3017620422003';

  @override
  String get foodScannerCameraUnavailable => 'Camera Unavailable';

  @override
  String get foodScannerCameraUnavailableDesc =>
      'Camera access is denied or no camera hardware is available on this device/simulator.\n\nYou can still look up any food product by entering its barcode number manually.';

  @override
  String get foodScannerBackToHome => 'Back to Home';

  @override
  String get foodScannerNutritionDataSubtitle =>
      'Open Food Facts Nutrition Data';

  @override
  String get foodScannerProductNameNotSpecified => 'Product Name Not Specified';

  @override
  String get foodScannerBrandNotSpecified => 'Brand not specified';

  @override
  String foodScannerServingPrefix(String serving) {
    return 'Serving: $serving';
  }

  @override
  String foodScannerBasisPrefix(String basis) {
    return 'Basis: $basis';
  }

  @override
  String get foodScannerSugars => '  • of which Sugars';

  @override
  String get foodScannerSaturates => '  • of which Saturates';

  @override
  String get foodScannerUnreportedNotice =>
      'Unreported nutrients are shown as \'—\'. NuroVed does not simulate or estimate missing nutritional facts.';

  @override
  String get foodScannerMedicalDisclaimer =>
      'Medical Disclaimer: Nutritional information is provided for informational reference only. Always verify product packaging directly for allergens and medical dietary restrictions.';

  @override
  String get premiumExploreTitle => 'Explore Premium';

  @override
  String get premiumExploreSubtitle =>
      'Unlock The Full Potential Of Your Health';

  @override
  String get premiumUpgradeCardTitle => 'Upgrade to premium';

  @override
  String get premiumUpgradeCardSubtitle =>
      'Unlock the full power of NuroVed and take control of your health.';

  @override
  String get premiumSectionEverythingFreePlus => 'Everything is Free, plus';

  @override
  String get premiumFeatureShareTitle => 'Share with Doctors';

  @override
  String get premiumFeatureShareSub =>
      'Share your complete health profile with doctors in one tap.';

  @override
  String get premiumFeatureAiInsightsTitle => 'AI Health Insights';

  @override
  String get premiumFeatureAiInsightsSub =>
      'Get intelligent insights and risk alerts from your health data.';

  @override
  String get premiumFeatureTimelineTitle => 'Advanced Timeline';

  @override
  String get premiumFeatureTimelineSub =>
      'Track trends and patterns with advanced health timeline.';

  @override
  String get premiumFeatureFamilyTitle => 'Family Profiles';

  @override
  String get premiumFeatureFamilySub =>
      'Add and manage your family\'s health in one secure place.';

  @override
  String get premiumFeatureScannerTitle => 'Unlimited Scanner';

  @override
  String get premiumFeatureScannerSub =>
      'Scan and store unlimited reports with smart auto-tagging.';

  @override
  String get premiumFeatureDietTitle => 'Context Aware Diet Plans';

  @override
  String get premiumFeatureDietSub =>
      'Personalized diet recommendations based on your goals.';

  @override
  String get premiumLimitedOffer => 'Limited Time Offer';

  @override
  String get premiumYearlyDiscount => '70% OFF On Yearly Plan';

  @override
  String get premiumTakeControlToday => 'Take control of your health today';

  @override
  String get premiumSaveAmount => 'Save ₹2100';

  @override
  String get premiumSelectYourPlan => 'Select your plan';

  @override
  String get premiumMonthlyPlan => 'Monthly Premium';

  @override
  String get premiumMonthlyOffer => '65% Off Offer';

  @override
  String get premiumYearlyPlan => 'Yearly Premium';

  @override
  String get premiumYearlyPricePerYear => '₹804/Year';

  @override
  String get premiumMostPopular => 'Most Popular';

  @override
  String get premiumContinueButton => 'Continue to Premium';

  @override
  String get premiumPreviewNotice =>
      'Subscriptions are currently in preview mode. In-app checkout is disabled until store release.';

  @override
  String get premiumPerMonth => '/Month';

  @override
  String get reportProblemEmptyDesc =>
      'Any problems you report on this device will be recorded here for local diagnostic tracking.';

  @override
  String get reportProblemDeviceRecorded =>
      'Recorded on this device for diagnostic analysis.';

  @override
  String get customerSupportFaqQ1 => 'What is NuroVed and how does it work?';

  @override
  String get customerSupportFaqA1 =>
      'NuroVed is an AI-powered health companion that understands your lifestyle, preferences, and medical context to provide personalized diet plans, insights, and health guidance—all in one place.';

  @override
  String get customerSupportFaqQ2 =>
      'How is NuroVed different from other health apps?';

  @override
  String get customerSupportFaqA2 =>
      'Unlike generic trackers, NuroVed adapts to you. It combines AI, real-time analysis, and behavior-focused design to deliver recommendations that actually fit your daily life.';

  @override
  String get customerSupportFaqQ3 => 'Is my health data safe with NuroVed?';

  @override
  String get customerSupportFaqA3 =>
      'Yes. Your data is securely stored and handled with strict privacy measures. NuroVed is built with a strong focus on protecting your personal and medical information.';

  @override
  String get customerSupportFaqQ4 =>
      'Can NuroVed handle specific needs like allergies or medical conditions?';

  @override
  String get customerSupportFaqA4 =>
      'Absolutely. NuroVed considers your allergies, dietary restrictions, and health conditions to provide safe and personalized recommendations.';

  @override
  String get commonOk => 'OK';

  @override
  String get homeHealthTimeline => 'Health Timeline';

  @override
  String get accessRevokeConfirm => 'Revoke';

  @override
  String get accessExpiryNever => 'Never';

  @override
  String get notificationsTimeJustNow => 'Just now';

  @override
  String get notificationsTimeOneHourAgo => '1 hr ago';

  @override
  String get notificationsTimeTwoHoursAgo => '2 hr ago';

  @override
  String get notificationsTimeTuesday => 'Tuesday';

  @override
  String get notificationsTimeMonday => 'Monday';

  @override
  String get homeTooltipNotifications => 'Notifications';

  @override
  String get homeTooltipUpgradePremium => 'Upgrade to Premium';

  @override
  String get recordsBackToRecords => 'Back to records';

  @override
  String get dietSuccessBackSemantics => 'Back to diet overview';
}
