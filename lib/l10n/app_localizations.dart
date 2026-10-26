import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NuroVed'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Health, Your Control'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get navDiet;

  /// No description provided for @navRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get navRoutine;

  /// No description provided for @navVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get navVisits;

  /// No description provided for @navAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get navAccess;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get commonSaveMeal;

  /// No description provided for @commonSaveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get commonSaveReminder;

  /// No description provided for @commonSaveVisit.
  ///
  /// In en, this message translates to:
  /// **'Save Visit'**
  String get commonSaveVisit;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLookup.
  ///
  /// In en, this message translates to:
  /// **'Lookup'**
  String get commonLookup;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarning;

  /// No description provided for @commonInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get commonInfo;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get commonPrevious;

  /// No description provided for @commonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get commonFinish;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Health, Your Control'**
  String get splashTagline;

  /// No description provided for @splashGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started...'**
  String get splashGettingStarted;

  /// No description provided for @splashSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get splashSkip;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log into your NuroVed account'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignInButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUpLink;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up For Free!'**
  String get signupSubtitle;

  /// No description provided for @signupFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signupFullNameLabel;

  /// No description provided for @signupFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get signupFullNameHint;

  /// No description provided for @signupConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signupConfirmPasswordLabel;

  /// No description provided for @signupConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get signupConfirmPasswordHint;

  /// No description provided for @signupTermsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I have read all the '**
  String get signupTermsAgreement;

  /// No description provided for @signupTermsLink.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get signupTermsLink;

  /// No description provided for @signupAndWord.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get signupAndWord;

  /// No description provided for @signupPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get signupPrivacyLink;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @signupAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupAlreadyHaveAccount;

  /// No description provided for @signupSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signupSignInLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email sent successfully'**
  String get forgotPasswordSuccess;

  /// No description provided for @authLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading NuroVed...'**
  String get authLoadingTitle;

  /// No description provided for @authVerifyingSession.
  ///
  /// In en, this message translates to:
  /// **'Verifying session...'**
  String get authVerifyingSession;

  /// No description provided for @authLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get authLogoutConfirmation;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get authLogout;

  /// No description provided for @validationEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get validationEnterName;

  /// No description provided for @validationNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get validationNameEmpty;

  /// No description provided for @validationEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get validationEnterEmail;

  /// No description provided for @validationEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEnterValidEmail;

  /// No description provided for @validationEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validationEnterPassword;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordMinLength;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'ERROR: Password do not match!'**
  String get validationPasswordMismatch;

  /// No description provided for @validationAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms of service'**
  String get validationAgreeTerms;

  /// No description provided for @validationEnterRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a record title'**
  String get validationEnterRecordTitle;

  /// No description provided for @validationSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get validationSelectCategory;

  /// No description provided for @validationEnterDoctorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter doctor name'**
  String get validationEnterDoctorName;

  /// No description provided for @validationSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get validationSelectDate;

  /// No description provided for @validationEnterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get validationEnterMedicineName;

  /// No description provided for @validationSelectTiming.
  ///
  /// In en, this message translates to:
  /// **'Please select timing'**
  String get validationSelectTiming;

  /// No description provided for @validationSelectProfileAndMedicine.
  ///
  /// In en, this message translates to:
  /// **'Please select profile and enter medicine name'**
  String get validationSelectProfileAndMedicine;

  /// No description provided for @validationSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile'**
  String get validationSelectProfile;

  /// No description provided for @validationEnterIssue.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem you experienced.'**
  String get validationEnterIssue;

  /// No description provided for @validationIssueTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please provide more detail (minimum 10 characters).'**
  String get validationIssueTooShort;

  /// No description provided for @validationMealNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Meal name cannot be empty'**
  String get validationMealNameEmpty;

  /// No description provided for @validationInvalidBarcode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 8 to 14-digit barcode'**
  String get validationInvalidBarcode;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeFeelingPrompt.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get homeFeelingPrompt;

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search health records, medicines, visits...'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get homeQuickAccess;

  /// No description provided for @homeQuickUploadRecord.
  ///
  /// In en, this message translates to:
  /// **'Upload Record'**
  String get homeQuickUploadRecord;

  /// No description provided for @homeQuickDietPlan.
  ///
  /// In en, this message translates to:
  /// **'Diet Plan'**
  String get homeQuickDietPlan;

  /// No description provided for @homeQuickRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get homeQuickRoutine;

  /// No description provided for @homeQuickVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get homeQuickVisits;

  /// No description provided for @homeQuickCareAccess.
  ///
  /// In en, this message translates to:
  /// **'Care Access'**
  String get homeQuickCareAccess;

  /// No description provided for @homeQuickFoodScanner.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner'**
  String get homeQuickFoodScanner;

  /// No description provided for @homeRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent Records'**
  String get homeRecentRecords;

  /// No description provided for @homeNoRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'No recent records found'**
  String get homeNoRecentRecords;

  /// No description provided for @homeUpcomingRoutine.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Medications'**
  String get homeUpcomingRoutine;

  /// No description provided for @homeNoUpcomingRoutine.
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled for today'**
  String get homeNoUpcomingRoutine;

  /// No description provided for @homeEmergencyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Card'**
  String get homeEmergencyCardTitle;

  /// No description provided for @homeEmergencyBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get homeEmergencyBloodGroup;

  /// No description provided for @homeEmergencyAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get homeEmergencyAllergies;

  /// No description provided for @homeEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get homeEmergencyContact;

  /// No description provided for @recordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get recordsTitle;

  /// No description provided for @recordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize & access clinical files'**
  String get recordsSubtitle;

  /// No description provided for @recordsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recordsFilterAll;

  /// No description provided for @recordsFilterPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get recordsFilterPrescriptions;

  /// No description provided for @recordsFilterLabReports.
  ///
  /// In en, this message translates to:
  /// **'Lab Reports'**
  String get recordsFilterLabReports;

  /// No description provided for @recordsFilterScans.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get recordsFilterScans;

  /// No description provided for @recordsFilterDischarge.
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get recordsFilterDischarge;

  /// No description provided for @recordsFilterInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get recordsFilterInvoices;

  /// No description provided for @recordsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search records...'**
  String get recordsSearchPlaceholder;

  /// No description provided for @recordsNoRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get recordsNoRecordsFound;

  /// No description provided for @recordsEmptyUploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload your first medical record to track your health.'**
  String get recordsEmptyUploadPrompt;

  /// No description provided for @recordsAddRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get recordsAddRecordButton;

  /// No description provided for @recordsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Record'**
  String get recordsAddTitle;

  /// No description provided for @recordsAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attach lab results, prescriptions, or bills'**
  String get recordsAddSubtitle;

  /// No description provided for @recordsFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Title'**
  String get recordsFieldTitle;

  /// No description provided for @recordsFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Blood Test, Prescription'**
  String get recordsFieldTitleHint;

  /// No description provided for @recordsFieldDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Hospital Name'**
  String get recordsFieldDoctor;

  /// No description provided for @recordsFieldDoctorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Sharma, City Clinic'**
  String get recordsFieldDoctorHint;

  /// No description provided for @recordsFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Record Date'**
  String get recordsFieldDate;

  /// No description provided for @recordsFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get recordsFieldCategory;

  /// No description provided for @recordsFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes / Description'**
  String get recordsFieldNotes;

  /// No description provided for @recordsFieldNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add diagnosis details, dosage notes...'**
  String get recordsFieldNotesHint;

  /// No description provided for @recordsUploadSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Attach File'**
  String get recordsUploadSectionTitle;

  /// No description provided for @recordsUploadFilesButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get recordsUploadFilesButton;

  /// No description provided for @recordsTakePhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Click Photo'**
  String get recordsTakePhotoButton;

  /// No description provided for @recordsNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get recordsNoFileSelected;

  /// No description provided for @recordsSaveRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get recordsSaveRecordButton;

  /// No description provided for @recordsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Medical Record?'**
  String get recordsDeleteDialogTitle;

  /// No description provided for @recordsDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this medical record? This action cannot be undone.'**
  String get recordsDeleteDialogMessage;

  /// No description provided for @recordsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record deleted successfully'**
  String get recordsDeletedSuccess;

  /// No description provided for @recordsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record added successfully!'**
  String get recordsAddedSuccess;

  /// No description provided for @recordsDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Details'**
  String get recordsDetailTitle;

  /// No description provided for @recordsDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get recordsDetailCategory;

  /// No description provided for @recordsDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get recordsDetailDate;

  /// No description provided for @recordsDetailDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Clinic'**
  String get recordsDetailDoctor;

  /// No description provided for @recordsDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recordsDetailNotes;

  /// No description provided for @recordsDetailAttachedFile.
  ///
  /// In en, this message translates to:
  /// **'Attached Document'**
  String get recordsDetailAttachedFile;

  /// No description provided for @recordsDetailDownload.
  ///
  /// In en, this message translates to:
  /// **'View / Download Document'**
  String get recordsDetailDownload;

  /// No description provided for @familyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Profiles'**
  String get familyTitle;

  /// No description provided for @familySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage individual health accounts'**
  String get familySubtitle;

  /// No description provided for @familyActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Active Profile'**
  String get familyActiveProfile;

  /// No description provided for @familySwitchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch Profile'**
  String get familySwitchProfile;

  /// No description provided for @familyAddMemberButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Profile'**
  String get familyAddMemberButton;

  /// No description provided for @familyAddMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get familyAddMemberTitle;

  /// No description provided for @familyAddMemberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a dependent clinical profile'**
  String get familyAddMemberSubtitle;

  /// No description provided for @familyEditMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Family Member'**
  String get familyEditMemberTitle;

  /// No description provided for @familyFieldName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get familyFieldName;

  /// No description provided for @familyFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter member\'s name'**
  String get familyFieldNameHint;

  /// No description provided for @familyFieldRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get familyFieldRelationship;

  /// No description provided for @familyFieldRelationshipHint.
  ///
  /// In en, this message translates to:
  /// **'Select relationship'**
  String get familyFieldRelationshipHint;

  /// No description provided for @familyFieldDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get familyFieldDob;

  /// No description provided for @familyFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get familyFieldGender;

  /// No description provided for @familyFieldBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get familyFieldBloodGroup;

  /// No description provided for @familyRelationSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get familyRelationSelf;

  /// No description provided for @familyRelationSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get familyRelationSpouse;

  /// No description provided for @familyRelationChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get familyRelationChild;

  /// No description provided for @familyRelationParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get familyRelationParent;

  /// No description provided for @familyRelationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get familyRelationOther;

  /// No description provided for @familyAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Family member added successfully!'**
  String get familyAddedSuccess;

  /// No description provided for @familyUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Family member updated successfully!'**
  String get familyUpdatedSuccess;

  /// No description provided for @familyDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Profile?'**
  String get familyDeleteDialogTitle;

  /// No description provided for @familyDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this family profile? Their clinical records will remain safely archived.'**
  String get familyDeleteDialogMessage;

  /// No description provided for @familyRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{name}\" from family profiles.'**
  String familyRemovedSuccess(String name);

  /// No description provided for @routineTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get routineTitle;

  /// No description provided for @routineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Medication & health habit tracker'**
  String get routineSubtitle;

  /// No description provided for @routineSectionMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get routineSectionMorning;

  /// No description provided for @routineSectionAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get routineSectionAfternoon;

  /// No description provided for @routineSectionEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get routineSectionEvening;

  /// No description provided for @routineSectionNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get routineSectionNight;

  /// No description provided for @routineStatusTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get routineStatusTaken;

  /// No description provided for @routineStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get routineStatusPending;

  /// No description provided for @routineStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get routineStatusSkipped;

  /// No description provided for @routineAddMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get routineAddMedicine;

  /// No description provided for @routineAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get routineAddReminder;

  /// No description provided for @routineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders for today'**
  String get routineEmptyTitle;

  /// No description provided for @routineEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your daily medicines or wellness routines.'**
  String get routineEmptySubtitle;

  /// No description provided for @routineFieldMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get routineFieldMedicineName;

  /// No description provided for @routineFieldMedicineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Metformin 500mg'**
  String get routineFieldMedicineNameHint;

  /// No description provided for @routineFieldDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get routineFieldDosage;

  /// No description provided for @routineFieldDosageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 Tablet'**
  String get routineFieldDosageHint;

  /// No description provided for @routineFieldTiming.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get routineFieldTiming;

  /// No description provided for @routineFieldInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get routineFieldInstructions;

  /// No description provided for @routineInstructionBeforeFood.
  ///
  /// In en, this message translates to:
  /// **'Before Food'**
  String get routineInstructionBeforeFood;

  /// No description provided for @routineInstructionAfterFood.
  ///
  /// In en, this message translates to:
  /// **'After Food'**
  String get routineInstructionAfterFood;

  /// No description provided for @routineInstructionWithFood.
  ///
  /// In en, this message translates to:
  /// **'With Food'**
  String get routineInstructionWithFood;

  /// No description provided for @routineFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get routineFrequencyDaily;

  /// No description provided for @routineSaveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get routineSaveReminder;

  /// No description provided for @routineSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medicine reminder saved successfully!'**
  String get routineSavedSuccess;

  /// No description provided for @routineUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal routine updated successfully!'**
  String get routineUpdatedSuccess;

  /// No description provided for @routineConfirmIntakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Intake'**
  String get routineConfirmIntakeTitle;

  /// No description provided for @routineConfirmIntakeMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark {medicine} as taken?'**
  String routineConfirmIntakeMessage(String medicine);

  /// No description provided for @routineMarkedTakenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Marked as taken'**
  String get routineMarkedTakenSuccess;

  /// No description provided for @visitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visits'**
  String get visitsTitle;

  /// No description provided for @visitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track consultations & follow-ups'**
  String get visitsSubtitle;

  /// No description provided for @visitsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get visitsUpcoming;

  /// No description provided for @visitsPast.
  ///
  /// In en, this message translates to:
  /// **'Past Consultations'**
  String get visitsPast;

  /// No description provided for @visitsAddVisit.
  ///
  /// In en, this message translates to:
  /// **'Add Visit'**
  String get visitsAddVisit;

  /// No description provided for @visitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No doctor visits recorded'**
  String get visitsEmptyTitle;

  /// No description provided for @visitsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep track of doctor consultations and medical prescriptions.'**
  String get visitsEmptySubtitle;

  /// No description provided for @visitsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Doctor Visit'**
  String get visitsAddTitle;

  /// No description provided for @visitsAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log a consultation or follow-up'**
  String get visitsAddSubtitle;

  /// No description provided for @visitsFieldDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor Name'**
  String get visitsFieldDoctor;

  /// No description provided for @visitsFieldDoctorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Patel'**
  String get visitsFieldDoctorHint;

  /// No description provided for @visitsFieldSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get visitsFieldSpecialty;

  /// No description provided for @visitsFieldSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cardiologist, General Physician'**
  String get visitsFieldSpecialtyHint;

  /// No description provided for @visitsFieldHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Clinic'**
  String get visitsFieldHospital;

  /// No description provided for @visitsFieldHospitalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Apollo Clinic, Care Hospital'**
  String get visitsFieldHospitalHint;

  /// No description provided for @visitsFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get visitsFieldDate;

  /// No description provided for @visitsFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Visit Time'**
  String get visitsFieldTime;

  /// No description provided for @visitsFieldReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for Consultation'**
  String get visitsFieldReason;

  /// No description provided for @visitsFieldReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Annual health checkup, fever'**
  String get visitsFieldReasonHint;

  /// No description provided for @visitsFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis & Advice'**
  String get visitsFieldNotes;

  /// No description provided for @visitsSaveVisit.
  ///
  /// In en, this message translates to:
  /// **'Save Visit'**
  String get visitsSaveVisit;

  /// No description provided for @visitsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit added successfully!'**
  String get visitsSavedSuccess;

  /// No description provided for @visitsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit Details'**
  String get visitsDetailsTitle;

  /// No description provided for @visitsTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Consultation Timeline'**
  String get visitsTimelineTitle;

  /// No description provided for @accessTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Access'**
  String get accessTitle;

  /// No description provided for @accessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share medical data securely'**
  String get accessSubtitle;

  /// No description provided for @accessActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get accessActiveSessions;

  /// No description provided for @accessShareAccess.
  ///
  /// In en, this message translates to:
  /// **'Share Access'**
  String get accessShareAccess;

  /// No description provided for @accessPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get accessPermissions;

  /// No description provided for @accessQrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor QR Access'**
  String get accessQrCodeTitle;

  /// No description provided for @accessQrCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan with doctor portal for temporary read-only access'**
  String get accessQrCodeSubtitle;

  /// No description provided for @accessPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Temporary Access PIN'**
  String get accessPinLabel;

  /// No description provided for @accessDuration24Hours.
  ///
  /// In en, this message translates to:
  /// **'24 Hours'**
  String get accessDuration24Hours;

  /// No description provided for @accessDuration7Days.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get accessDuration7Days;

  /// No description provided for @accessDuration30Days.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get accessDuration30Days;

  /// No description provided for @accessRevokeButton.
  ///
  /// In en, this message translates to:
  /// **'Revoke Access'**
  String get accessRevokeButton;

  /// No description provided for @accessRevokeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke Access?'**
  String get accessRevokeDialogTitle;

  /// No description provided for @accessRevokeDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to immediately terminate this caregiver\'s access to your medical records?'**
  String get accessRevokeDialogMessage;

  /// No description provided for @accessRevokedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Access revoked successfully'**
  String get accessRevokedSuccess;

  /// No description provided for @accessNoActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'No active sharing sessions'**
  String get accessNoActiveSessions;

  /// No description provided for @accessHospitalDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hospital Information'**
  String get accessHospitalDetailsTitle;

  /// No description provided for @foodScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner'**
  String get foodScannerTitle;

  /// No description provided for @foodScannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Retail Food Barcode'**
  String get foodScannerSubtitle;

  /// No description provided for @foodScannerInstructions.
  ///
  /// In en, this message translates to:
  /// **'Point camera at a packaged food barcode'**
  String get foodScannerInstructions;

  /// No description provided for @foodScannerManualButton.
  ///
  /// In en, this message translates to:
  /// **'Enter Barcode Manually'**
  String get foodScannerManualButton;

  /// No description provided for @foodScannerHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get foodScannerHistoryButton;

  /// No description provided for @foodScannerLookUpProduct.
  ///
  /// In en, this message translates to:
  /// **'Look Up Product'**
  String get foodScannerLookUpProduct;

  /// No description provided for @foodScannerLookingUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking up product...'**
  String get foodScannerLookingUpTitle;

  /// No description provided for @foodScannerLookingUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Retrieving verified nutritional information'**
  String get foodScannerLookingUpSubtitle;

  /// No description provided for @foodScannerManualDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Barcode Entry'**
  String get foodScannerManualDialogTitle;

  /// No description provided for @foodScannerManualDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 8-14 digit barcode'**
  String get foodScannerManualDialogHint;

  /// No description provided for @foodScannerProductLookup.
  ///
  /// In en, this message translates to:
  /// **'Product Lookup'**
  String get foodScannerProductLookup;

  /// No description provided for @foodScannerScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get foodScannerScanAgain;

  /// No description provided for @foodScannerEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get foodScannerEnterManually;

  /// No description provided for @foodScannerProductNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get foodScannerProductNotFoundTitle;

  /// No description provided for @foodScannerProductNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The scanned barcode was not found in the verified database. You can try searching manually or scan another product.'**
  String get foodScannerProductNotFoundMessage;

  /// No description provided for @foodScannerNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach nutrition database. Please check your internet connection.'**
  String get foodScannerNetworkError;

  /// No description provided for @foodScannerValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a barcode number.'**
  String get foodScannerValidationEmpty;

  /// No description provided for @foodScannerValidationMin.
  ///
  /// In en, this message translates to:
  /// **'Barcode must contain at least 8 digits (EAN-8).'**
  String get foodScannerValidationMin;

  /// No description provided for @foodScannerResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Details'**
  String get foodScannerResultTitle;

  /// No description provided for @foodScannerVerifiedFacts.
  ///
  /// In en, this message translates to:
  /// **'Verified Nutrition Facts'**
  String get foodScannerVerifiedFacts;

  /// No description provided for @foodScannerNutriScore.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score'**
  String get foodScannerNutriScore;

  /// No description provided for @foodScannerEcoScore.
  ///
  /// In en, this message translates to:
  /// **'Eco-Score'**
  String get foodScannerEcoScore;

  /// No description provided for @foodScannerNovaGroup.
  ///
  /// In en, this message translates to:
  /// **'NOVA Group'**
  String get foodScannerNovaGroup;

  /// No description provided for @foodScannerNutritionFacts.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts (per 100g/ml)'**
  String get foodScannerNutritionFacts;

  /// No description provided for @foodScannerCalories.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get foodScannerCalories;

  /// No description provided for @foodScannerCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get foodScannerCarbs;

  /// No description provided for @foodScannerFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get foodScannerFat;

  /// No description provided for @foodScannerTotalFat.
  ///
  /// In en, this message translates to:
  /// **'Total Fat'**
  String get foodScannerTotalFat;

  /// No description provided for @foodScannerProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get foodScannerProtein;

  /// No description provided for @foodScannerProteins.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get foodScannerProteins;

  /// No description provided for @foodScannerFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get foodScannerFiber;

  /// No description provided for @foodScannerSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get foodScannerSalt;

  /// No description provided for @foodScannerSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get foodScannerSodium;

  /// No description provided for @foodScannerAllergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get foodScannerAllergens;

  /// No description provided for @foodScannerSourceAttribution.
  ///
  /// In en, this message translates to:
  /// **'Source & Attribution'**
  String get foodScannerSourceAttribution;

  /// No description provided for @foodScannerScanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Item'**
  String get foodScannerScanAnother;

  /// No description provided for @foodScannerBackToDiet.
  ///
  /// In en, this message translates to:
  /// **'Back to Diet Overview'**
  String get foodScannerBackToDiet;

  /// No description provided for @foodScannerOpenFoodFactsAttribution.
  ///
  /// In en, this message translates to:
  /// **'Nutrition data sourced from Open Food Facts under Open Database License (ODbL).'**
  String get foodScannerOpenFoodFactsAttribution;

  /// No description provided for @foodScannerHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Scan History'**
  String get foodScannerHistoryTitle;

  /// No description provided for @foodScannerHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scanned foods in history'**
  String get foodScannerHistoryEmpty;

  /// No description provided for @dietPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Ai Diet Planner'**
  String get dietPlannerTitle;

  /// No description provided for @dietPlannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verified nutritional meal planning'**
  String get dietPlannerSubtitle;

  /// No description provided for @dietStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get dietStep1Title;

  /// No description provided for @dietStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 4: Enter body measurements'**
  String get dietStep1Subtitle;

  /// No description provided for @dietFieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get dietFieldAge;

  /// No description provided for @dietFieldGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get dietFieldGender;

  /// No description provided for @dietFieldGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get dietFieldGenderMale;

  /// No description provided for @dietFieldGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get dietFieldGenderFemale;

  /// No description provided for @dietFieldGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dietFieldGenderOther;

  /// No description provided for @dietFieldHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get dietFieldHeight;

  /// No description provided for @dietFieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get dietFieldWeight;

  /// No description provided for @dietStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Diet Preference'**
  String get dietStep2Title;

  /// No description provided for @dietStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 4: Select dietary pattern'**
  String get dietStep2Subtitle;

  /// No description provided for @dietPatternVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietPatternVegetarian;

  /// No description provided for @dietPatternNonVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Non-veg'**
  String get dietPatternNonVegetarian;

  /// No description provided for @dietPatternBoth.
  ///
  /// In en, this message translates to:
  /// **'Both (Veg & Non-Veg)'**
  String get dietPatternBoth;

  /// No description provided for @dietNonVegDaysPrompt.
  ///
  /// In en, this message translates to:
  /// **'Pick the days you prefer non-veg meals'**
  String get dietNonVegDaysPrompt;

  /// No description provided for @dietAllergiesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Allergies & food exclusions (comma separated):'**
  String get dietAllergiesPrompt;

  /// No description provided for @dietStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Health Goals'**
  String get dietStep3Title;

  /// No description provided for @dietStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 4: Activity & metabolic goal'**
  String get dietStep3Subtitle;

  /// No description provided for @dietActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary (Little or no exercise)'**
  String get dietActivitySedentary;

  /// No description provided for @dietActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (Exercise 3-5 days/week)'**
  String get dietActivityModerate;

  /// No description provided for @dietActivityAthlete.
  ///
  /// In en, this message translates to:
  /// **'Heavy Athlete (Intense daily exercise)'**
  String get dietActivityAthlete;

  /// No description provided for @dietGoalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get dietGoalLose;

  /// No description provided for @dietGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get dietGoalMaintain;

  /// No description provided for @dietGoalGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get dietGoalGain;

  /// No description provided for @dietStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Time & Context'**
  String get dietStep4Title;

  /// No description provided for @dietStep4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 4 of 4: Meal schedules & cooking budget'**
  String get dietStep4Subtitle;

  /// No description provided for @dietClinicalSupervisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Supervision Notice'**
  String get dietClinicalSupervisionTitle;

  /// No description provided for @dietClinicalSupervisionMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your clinical condition, automated meal planning requires individualized oversight by a qualified dietitian or physician.'**
  String get dietClinicalSupervisionMessage;

  /// No description provided for @dietClinicalReferenceNotice.
  ///
  /// In en, this message translates to:
  /// **'Clinical Reference Notice'**
  String get dietClinicalReferenceNotice;

  /// No description provided for @dietVerifiedNutritionalPlanning.
  ///
  /// In en, this message translates to:
  /// **'Verified Nutritional Planning'**
  String get dietVerifiedNutritionalPlanning;

  /// No description provided for @dietOutputTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Meal Plan'**
  String get dietOutputTitle;

  /// No description provided for @dietOutputDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily Energy Target'**
  String get dietOutputDailyCalories;

  /// No description provided for @dietOutputSaveToRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save to My Routine'**
  String get dietOutputSaveToRoutine;

  /// No description provided for @dietOutputRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Plan'**
  String get dietOutputRegenerate;

  /// No description provided for @dietMealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get dietMealBreakfast;

  /// No description provided for @dietMealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get dietMealLunch;

  /// No description provided for @dietMealSnack.
  ///
  /// In en, this message translates to:
  /// **'Evening Snack'**
  String get dietMealSnack;

  /// No description provided for @dietMealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dietMealDinner;

  /// No description provided for @dietPlanDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Diet plan deleted successfully'**
  String get dietPlanDeletedSuccess;

  /// No description provided for @dietDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Diet Plan?'**
  String get dietDeleteDialogTitle;

  /// No description provided for @dietDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your saved meal routine? This will clear all weekly meal schedule data.'**
  String get dietDeleteDialogMessage;

  /// No description provided for @dietWeeklyMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly Meal Plan'**
  String get dietWeeklyMealPlan;

  /// No description provided for @dietBtnContinueDietPref.
  ///
  /// In en, this message translates to:
  /// **'Continue to Diet Preference'**
  String get dietBtnContinueDietPref;

  /// No description provided for @dietBtnContinueHealthGoals.
  ///
  /// In en, this message translates to:
  /// **'Continue to Health Goals'**
  String get dietBtnContinueHealthGoals;

  /// No description provided for @dietBtnContinueTimeContext.
  ///
  /// In en, this message translates to:
  /// **'Continue to Time & Context'**
  String get dietBtnContinueTimeContext;

  /// No description provided for @dietBtnGeneratePlan.
  ///
  /// In en, this message translates to:
  /// **'Generate Verified Diet Plan'**
  String get dietBtnGeneratePlan;

  /// No description provided for @dietReturnToOverview.
  ///
  /// In en, this message translates to:
  /// **'Return to Diet Overview'**
  String get dietReturnToOverview;

  /// No description provided for @dietBackToOverview.
  ///
  /// In en, this message translates to:
  /// **'Back to Diet Overview'**
  String get dietBackToOverview;

  /// No description provided for @dietNoMealRoutineSaved.
  ///
  /// In en, this message translates to:
  /// **'No Meal Routine Saved Yet'**
  String get dietNoMealRoutineSaved;

  /// No description provided for @validationAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age (1–120).'**
  String get validationAgeRange;

  /// No description provided for @validationSelectNonVegDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day for non-vegetarian meals.'**
  String get validationSelectNonVegDay;

  /// No description provided for @dietSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Section'**
  String get dietSectionTitle;

  /// No description provided for @dietSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate Your Every Single Bite'**
  String get dietSectionSubtitle;

  /// No description provided for @dietQuickAction.
  ///
  /// In en, this message translates to:
  /// **'Quick Action'**
  String get dietQuickAction;

  /// No description provided for @dietPlannerNav.
  ///
  /// In en, this message translates to:
  /// **'Diet Planner'**
  String get dietPlannerNav;

  /// No description provided for @foodScannerNav.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner'**
  String get foodScannerNav;

  /// No description provided for @dietMealRoutineHistoryNav.
  ///
  /// In en, this message translates to:
  /// **'Meal Routine History'**
  String get dietMealRoutineHistoryNav;

  /// No description provided for @dietMealRoutineHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check Out Your Meal Routine And Edit'**
  String get dietMealRoutineHistorySubtitle;

  /// No description provided for @dietNoMealRoutineSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved weekly meal routine will appear here once configured.'**
  String get dietNoMealRoutineSavedSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Your App Settings & Preferences'**
  String get settingsSubtitle;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsLanguageCard.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageCard;

  /// No description provided for @settingsLanguageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsLanguageSelectTitle;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageGujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get settingsLanguageGujarati;

  /// No description provided for @settingsLanguageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get settingsLanguageHindi;

  /// No description provided for @settingsAppSettingsCard.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsAppSettingsCard;

  /// No description provided for @settingsAppSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Units, time format, and clinical display'**
  String get settingsAppSettingsSubtitle;

  /// No description provided for @settingsDataPrivacyCard.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get settingsDataPrivacyCard;

  /// No description provided for @settingsDataPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Row Level Security, permissions & account data'**
  String get settingsDataPrivacySubtitle;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get settingsSectionSupport;

  /// No description provided for @settingsCustomerSupportCard.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get settingsCustomerSupportCard;

  /// No description provided for @settingsCustomerSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct care coordination and helpdesk'**
  String get settingsCustomerSupportSubtitle;

  /// No description provided for @settingsReportProblemCard.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get settingsReportProblemCard;

  /// No description provided for @settingsReportProblemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or sync anomalies'**
  String get settingsReportProblemSubtitle;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal & Compliance'**
  String get settingsSectionLegal;

  /// No description provided for @settingsPrivacyPolicyCard.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicyCard;

  /// No description provided for @settingsPrivacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Zero third-party monetization & RLS sovereignty'**
  String get settingsPrivacyPolicySubtitle;

  /// No description provided for @settingsTermsCard.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsCard;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continuity of care guidelines and emergency terms'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get settingsTimeFormat;

  /// No description provided for @settingsWeightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight Unit'**
  String get settingsWeightUnit;

  /// No description provided for @settingsHeightUnit.
  ///
  /// In en, this message translates to:
  /// **'Height Unit'**
  String get settingsHeightUnit;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblemTitle;

  /// No description provided for @reportProblemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe bugs or anomalies to improve NuroVed'**
  String get reportProblemSubtitle;

  /// No description provided for @reportProblemDescribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue'**
  String get reportProblemDescribeLabel;

  /// No description provided for @reportProblemDescribeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include what screen you were on and what went wrong'**
  String get reportProblemDescribeSubtitle;

  /// No description provided for @reportProblemDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'Please explain what happened, steps to reproduce, or feedback...'**
  String get reportProblemDescribeHint;

  /// No description provided for @reportProblemSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get reportProblemSubmitButton;

  /// No description provided for @reportProblemSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Recording Diagnostic...'**
  String get reportProblemSubmitting;

  /// No description provided for @reportProblemSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report saved to local device diagnostics.'**
  String get reportProblemSavedSuccess;

  /// No description provided for @reportProblemHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get reportProblemHistoryTitle;

  /// No description provided for @reportProblemPastSection.
  ///
  /// In en, this message translates to:
  /// **'Past Reported Problems'**
  String get reportProblemPastSection;

  /// No description provided for @reportProblemEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Past Reports'**
  String get reportProblemEmpty;

  /// No description provided for @reportProblemBadgeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on Device'**
  String get reportProblemBadgeSaved;

  /// No description provided for @reportProblemBadgeSample.
  ///
  /// In en, this message translates to:
  /// **'Sample Reference'**
  String get reportProblemBadgeSample;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @backendNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Backend Not Configured'**
  String get backendNotConfigured;

  /// No description provided for @backendRunningOffline.
  ///
  /// In en, this message translates to:
  /// **'Supabase credentials not provided. Operating in local in-memory mode.'**
  String get backendRunningOffline;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Not Found'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The requested page could not be located.'**
  String get routeNotFoundMessage;

  /// No description provided for @routeNotFoundReturn.
  ///
  /// In en, this message translates to:
  /// **'Return to Safety'**
  String get routeNotFoundReturn;

  /// No description provided for @semanticsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get semanticsBack;

  /// No description provided for @semanticsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get semanticsClose;

  /// No description provided for @semanticsTogglePassword.
  ///
  /// In en, this message translates to:
  /// **'Toggle password visibility'**
  String get semanticsTogglePassword;

  /// No description provided for @semanticsShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get semanticsShowPassword;

  /// No description provided for @semanticsHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get semanticsHidePassword;

  /// No description provided for @routineTodaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get routineTodaysProgress;

  /// No description provided for @routineMedicineAdherence.
  ///
  /// In en, this message translates to:
  /// **'Medicine Adherence'**
  String get routineMedicineAdherence;

  /// No description provided for @routineMealRoutine.
  ///
  /// In en, this message translates to:
  /// **'Meal Routine'**
  String get routineMealRoutine;

  /// No description provided for @routineTime12AM.
  ///
  /// In en, this message translates to:
  /// **'12AM'**
  String get routineTime12AM;

  /// No description provided for @routineTime6AM.
  ///
  /// In en, this message translates to:
  /// **'6AM'**
  String get routineTime6AM;

  /// No description provided for @routineTime12PM.
  ///
  /// In en, this message translates to:
  /// **'12PM'**
  String get routineTime12PM;

  /// No description provided for @routineTime6PM.
  ///
  /// In en, this message translates to:
  /// **'6PM'**
  String get routineTime6PM;

  /// No description provided for @routineTabMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get routineTabMeals;

  /// No description provided for @routineTabMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get routineTabMedicines;

  /// No description provided for @routineMondayMedicines.
  ///
  /// In en, this message translates to:
  /// **'Monday Medicines'**
  String get routineMondayMedicines;

  /// No description provided for @routineMondayMeals.
  ///
  /// In en, this message translates to:
  /// **'Monday Meals'**
  String get routineMondayMeals;

  /// No description provided for @routineDeleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get routineDeleteRoutineTitle;

  /// No description provided for @routineDeleteRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{name}\" from your routine?'**
  String routineDeleteRoutineMessage(Object name);

  /// No description provided for @routineRemovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{name}\" from routine.'**
  String routineRemovedSnackbar(Object name);

  /// No description provided for @routineAddMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medicines'**
  String get routineAddMedicinesTitle;

  /// No description provided for @routineAddMedicinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Medicine Reminder So You Dont Forget'**
  String get routineAddMedicinesSubtitle;

  /// No description provided for @routineProfiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get routineProfiles;

  /// No description provided for @routineSelectProfilePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select A Profile'**
  String get routineSelectProfilePrompt;

  /// No description provided for @routineSelectedProfile.
  ///
  /// In en, this message translates to:
  /// **'Selected Profile'**
  String get routineSelectedProfile;

  /// No description provided for @routineMedicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine Details'**
  String get routineMedicineDetails;

  /// No description provided for @routineEnterMedicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Medicine Details'**
  String get routineEnterMedicineDetails;

  /// No description provided for @routineMedicineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get routineMedicineNameLabel;

  /// No description provided for @routineEnterMedicineNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Medicine Name'**
  String get routineEnterMedicineNameHint;

  /// No description provided for @routineEnterInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Instructions (e.g. After food)'**
  String get routineEnterInstructionsHint;

  /// No description provided for @routineReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get routineReminderTime;

  /// No description provided for @routineSelectTimePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select A Time'**
  String get routineSelectTimePrompt;

  /// No description provided for @routineSelectProfileAndNameError.
  ///
  /// In en, this message translates to:
  /// **'Please select profile and enter medicine name'**
  String get routineSelectProfileAndNameError;

  /// No description provided for @routineFailedToScheduleNotification.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule notification: {error}'**
  String routineFailedToScheduleNotification(Object error);

  /// No description provided for @routineReminderSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medication reminder saved successfully!'**
  String get routineReminderSavedSuccess;

  /// No description provided for @routinePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get routinePermissionDenied;

  /// No description provided for @routinePermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification permissions are required to receive medication reminders. Please enable notifications in your device settings.'**
  String get routinePermissionDeniedMessage;

  /// No description provided for @routineIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get routineIngredients;

  /// Intake meal button text
  ///
  /// In en, this message translates to:
  /// **'Intake {meal}'**
  String routineIntakeMeal(String meal);

  /// No description provided for @routineIgnoreAndSkip.
  ///
  /// In en, this message translates to:
  /// **'Ignore & Skip'**
  String get routineIgnoreAndSkip;

  /// Confirm meal dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm {meal}'**
  String routineConfirmMeal(String meal);

  /// Confirm meal dialog message
  ///
  /// In en, this message translates to:
  /// **'Have you finished your {meal} meal?'**
  String routineHaveYouFinishedMeal(String meal);

  /// No description provided for @routineNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not Yet'**
  String get routineNotYet;

  /// No description provided for @routineYesDone.
  ///
  /// In en, this message translates to:
  /// **'Yes, Done'**
  String get routineYesDone;

  /// No description provided for @routineMealNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Meal name cannot be empty'**
  String get routineMealNameEmpty;

  /// No description provided for @routineMealUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal routine updated successfully!'**
  String get routineMealUpdatedSuccess;

  /// No description provided for @routineAddIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'Add an ingredient'**
  String get routineAddIngredientHint;

  /// No description provided for @routineAddMoreIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add More Ingredients'**
  String get routineAddMoreIngredients;

  /// No description provided for @routineSaveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get routineSaveMeal;

  /// No description provided for @routineMealTakenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Meal has been taken, calorie has been saved'**
  String get routineMealTakenSuccess;

  /// No description provided for @routineSeeDietSection.
  ///
  /// In en, this message translates to:
  /// **'See in Diet Section'**
  String get routineSeeDietSection;

  /// No description provided for @routineMedicineTimeline.
  ///
  /// In en, this message translates to:
  /// **'Medicine Timeline'**
  String get routineMedicineTimeline;

  /// No description provided for @routinePercentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Done'**
  String routinePercentDone(Object percent);

  /// No description provided for @routineSourceVerifiedPrescription.
  ///
  /// In en, this message translates to:
  /// **'Verified Prescription'**
  String get routineSourceVerifiedPrescription;

  /// No description provided for @routineSourceSelfEntered.
  ///
  /// In en, this message translates to:
  /// **'Self-Entered'**
  String get routineSourceSelfEntered;

  /// No description provided for @familyProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Profiles'**
  String get familyProfilesTitle;

  /// No description provided for @familyProfilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch or manage health records for your family members'**
  String get familyProfilesSubtitle;

  /// No description provided for @familySelectActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Select as Active Profile'**
  String get familySelectActiveProfile;

  /// No description provided for @familySwitchActiveProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch health timeline, records and routine to this person'**
  String get familySwitchActiveProfileSubtitle;

  /// No description provided for @familySwitchedActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Switched active profile to {name}'**
  String familySwitchedActiveProfile(Object name);

  /// No description provided for @familyEditMemberProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Member Profile'**
  String get familyEditMemberProfile;

  /// No description provided for @familyRemoveProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Profile?'**
  String get familyRemoveProfileTitle;

  /// No description provided for @familyRemoveProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{name}\" from family profiles? Their local records and visits will remain.'**
  String familyRemoveProfileMessage(Object name);

  /// No description provided for @familyRemovedMemberSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{name}\" from family profiles.'**
  String familyRemovedMemberSnackbar(Object name);

  /// No description provided for @familyAddNewProfile.
  ///
  /// In en, this message translates to:
  /// **'Add New Profile'**
  String get familyAddNewProfile;

  /// No description provided for @familyAddProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Family Profile'**
  String get familyAddProfileTitle;

  /// No description provided for @familyAddProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Your And Your Families Personal Information'**
  String get familyAddProfileSubtitle;

  /// No description provided for @familyEnterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name'**
  String get familyEnterNameHint;

  /// No description provided for @familyRelationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get familyRelationLabel;

  /// No description provided for @familyEnterRelationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Relationship (e.g. Mother, Son)'**
  String get familyEnterRelationHint;

  /// No description provided for @familyEnterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get familyEnterNameError;

  /// No description provided for @familyMemberAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Family member added successfully!'**
  String get familyMemberAddedSuccess;

  /// No description provided for @familyMemberAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add family member: {error}'**
  String familyMemberAddFailed(Object error);

  /// No description provided for @familyAddNewProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Profile'**
  String get familyAddNewProfileButton;

  /// No description provided for @familyActiveBadge.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get familyActiveBadge;

  /// No description provided for @familyEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Family Profile'**
  String get familyEditProfileTitle;

  /// No description provided for @familyNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get familyNameEmptyError;

  /// No description provided for @familyMemberUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Family member updated successfully!'**
  String get familyMemberUpdatedSuccess;

  /// No description provided for @familyMemberUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update family member: {error}'**
  String familyMemberUpdateFailed(Object error);

  /// No description provided for @emergencyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Card'**
  String get emergencyCardTitle;

  /// No description provided for @emergencyCardUnverifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'PATIENT-ENTERED, UNVERIFIED'**
  String get emergencyCardUnverifiedBadge;

  /// No description provided for @emergencyCardBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get emergencyCardBloodGroup;

  /// No description provided for @emergencyCardAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get emergencyCardAllergies;

  /// No description provided for @emergencyCardChronicConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get emergencyCardChronicConditions;

  /// No description provided for @emergencyCardNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get emergencyCardNotProvided;

  /// No description provided for @emergencyCardFamilyProfiles.
  ///
  /// In en, this message translates to:
  /// **'Family Profiles'**
  String get emergencyCardFamilyProfiles;

  /// No description provided for @emergencyCardViewAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'View all family profiles'**
  String get emergencyCardViewAllProfiles;

  /// No description provided for @emergencyCardNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get emergencyCardNotAssigned;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @emergencyCardPhoneNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Phone not provided'**
  String get emergencyCardPhoneNotProvided;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Health & Emergency Identity'**
  String get profileSubtitle;

  /// No description provided for @profileTabPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get profileTabPersonal;

  /// No description provided for @profileTabEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get profileTabEmergency;

  /// No description provided for @profileAgeNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Age not provided'**
  String get profileAgeNotProvided;

  /// No description provided for @profileAgeYearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String profileAgeYearsOld(Object age);

  /// No description provided for @profileUserId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String profileUserId(Object id);

  /// No description provided for @profileMetricBlood.
  ///
  /// In en, this message translates to:
  /// **'Blood'**
  String get profileMetricBlood;

  /// No description provided for @profileMetricHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileMetricHeight;

  /// No description provided for @profileMetricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profileMetricWeight;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// No description provided for @profileKnownAllergies.
  ///
  /// In en, this message translates to:
  /// **'Known Allergies'**
  String get profileKnownAllergies;

  /// No description provided for @profileChronicCondition.
  ///
  /// In en, this message translates to:
  /// **'Chronic Condition'**
  String get profileChronicCondition;

  /// No description provided for @recordsPreviousRecords.
  ///
  /// In en, this message translates to:
  /// **'Previous Records'**
  String get recordsPreviousRecords;

  /// No description provided for @recordsSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get recordsSortNewest;

  /// No description provided for @recordsSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get recordsSortOldest;

  /// No description provided for @recordsSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get recordsSortTitle;

  /// No description provided for @recordsFilterMedicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get recordsFilterMedicalRecords;

  /// No description provided for @recordsFilterVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get recordsFilterVaccinations;

  /// No description provided for @recordsFilterBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get recordsFilterBills;

  /// No description provided for @recordsFilterLab.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get recordsFilterLab;

  /// No description provided for @recordsSelectProfilePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a profile'**
  String get recordsSelectProfilePrompt;

  /// No description provided for @recordsEnterTitlePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a record title'**
  String get recordsEnterTitlePrompt;

  /// No description provided for @recordsAttachPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please attach a document or photo'**
  String get recordsAttachPrompt;

  /// No description provided for @recordsAddRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Records'**
  String get recordsAddRecordTitle;

  /// No description provided for @recordsAddRecordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A single space for all your medical records'**
  String get recordsAddRecordSubtitle;

  /// No description provided for @recordsSelectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select Profile'**
  String get recordsSelectProfile;

  /// No description provided for @recordsRecordType.
  ///
  /// In en, this message translates to:
  /// **'Record Type'**
  String get recordsRecordType;

  /// No description provided for @recordsSelectRecordType.
  ///
  /// In en, this message translates to:
  /// **'Select Record Type'**
  String get recordsSelectRecordType;

  /// No description provided for @recordsDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get recordsDateLabel;

  /// No description provided for @recordsSelectDatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select A Date'**
  String get recordsSelectDatePrompt;

  /// No description provided for @recordsUploadingSecurely.
  ///
  /// In en, this message translates to:
  /// **'Uploading Securely...'**
  String get recordsUploadingSecurely;

  /// No description provided for @recordsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Records'**
  String get recordsSaveButton;

  /// No description provided for @recordsTitleAndDescription.
  ///
  /// In en, this message translates to:
  /// **'Record Title & Description'**
  String get recordsTitleAndDescription;

  /// No description provided for @recordsEnterTitleAndDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter Title & Description'**
  String get recordsEnterTitleAndDescription;

  /// No description provided for @recordsEnterRecordTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Record Title (e.g. Blood Test Report)'**
  String get recordsEnterRecordTitleHint;

  /// No description provided for @recordsEnterRecordDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Description / Notes (Optional)'**
  String get recordsEnterRecordDescriptionHint;

  /// No description provided for @recordsRecordFile.
  ///
  /// In en, this message translates to:
  /// **'Record File'**
  String get recordsRecordFile;

  /// No description provided for @recordsUploadDocumentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Document'**
  String get recordsUploadDocumentPrompt;

  /// No description provided for @recordsUploadFilesOption.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get recordsUploadFilesOption;

  /// No description provided for @recordsClickPhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Click Photo'**
  String get recordsClickPhotoOption;

  /// No description provided for @recordsNoStorageFile.
  ///
  /// In en, this message translates to:
  /// **'No storage file attached to this record.'**
  String get recordsNoStorageFile;

  /// No description provided for @recordsFailedRetrieveSecureUrl.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve secure URL: {error}'**
  String recordsFailedRetrieveSecureUrl(Object error);

  /// No description provided for @recordsSecureRetrievalTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Retrieval'**
  String get recordsSecureRetrievalTitle;

  /// No description provided for @recordsSecureRetrievalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generated time-bound signed URL directly from Supabase Storage.'**
  String get recordsSecureRetrievalSubtitle;

  /// No description provided for @recordsSecureRetrievalValid.
  ///
  /// In en, this message translates to:
  /// **'Signed URL (valid for 1 hour):'**
  String get recordsSecureRetrievalValid;

  /// No description provided for @recordsEditMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Record Metadata'**
  String get recordsEditMetadataTitle;

  /// No description provided for @recordsEditTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get recordsEditTitleLabel;

  /// No description provided for @recordsEditDoctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Clinician'**
  String get recordsEditDoctorLabel;

  /// No description provided for @recordsEditHospitalLabel.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Clinic'**
  String get recordsEditHospitalLabel;

  /// No description provided for @recordsEditNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes / Description'**
  String get recordsEditNotesLabel;

  /// No description provided for @recordsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Details'**
  String get recordsDetailsTitle;

  /// No description provided for @recordsEditMetadataAction.
  ///
  /// In en, this message translates to:
  /// **'Edit Metadata'**
  String get recordsEditMetadataAction;

  /// No description provided for @recordsDeleteRecordAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get recordsDeleteRecordAction;

  /// No description provided for @recordsDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String recordsDatePrefix(Object date);

  /// No description provided for @recordsDoctorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Doctor: {doctor}'**
  String recordsDoctorPrefix(Object doctor);

  /// No description provided for @recordsHospitalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Hospital: {hospital}'**
  String recordsHospitalPrefix(Object hospital);

  /// No description provided for @recordsAttachedDocument.
  ///
  /// In en, this message translates to:
  /// **'Attached Document'**
  String get recordsAttachedDocument;

  /// No description provided for @recordsAuthorizing.
  ///
  /// In en, this message translates to:
  /// **'Authorizing...'**
  String get recordsAuthorizing;

  /// No description provided for @recordsRequestSecureUrl.
  ///
  /// In en, this message translates to:
  /// **'Request Secure Access URL'**
  String get recordsRequestSecureUrl;

  /// No description provided for @recordsNoRemoteFile.
  ///
  /// In en, this message translates to:
  /// **'No remote storage file associated with this record.'**
  String get recordsNoRemoteFile;

  /// No description provided for @recordsClinicalNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes & Description'**
  String get recordsClinicalNotesTitle;

  /// No description provided for @recordsNoNotesEntered.
  ///
  /// In en, this message translates to:
  /// **'No notes entered for this record.'**
  String get recordsNoNotesEntered;

  /// No description provided for @recordsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'New Record Saved\nSuccessfully'**
  String get recordsSavedSuccess;

  /// No description provided for @recordsSeeInRecords.
  ///
  /// In en, this message translates to:
  /// **'See in Records'**
  String get recordsSeeInRecords;

  /// No description provided for @recordsNoRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'No Recent Records Found'**
  String get recordsNoRecentRecords;

  /// No description provided for @recordsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or doctor...'**
  String get recordsSearchHint;

  /// No description provided for @recordsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get recordsDeleteTitle;

  /// No description provided for @recordsDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get recordsDeleteTooltip;

  /// No description provided for @visitsSelectProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile first'**
  String get visitsSelectProfileFirst;

  /// No description provided for @visitsEnterTitlePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a visit title'**
  String get visitsEnterTitlePrompt;

  /// No description provided for @visitsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit added successfully!'**
  String get visitsAddedSuccess;

  /// No description provided for @visitsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save visit: {error}'**
  String visitsSaveFailed(Object error);

  /// No description provided for @visitsAttachRecords.
  ///
  /// In en, this message translates to:
  /// **'Attach Records'**
  String get visitsAttachRecords;

  /// No description provided for @visitsSelectRecordRelated.
  ///
  /// In en, this message translates to:
  /// **'Select Record Related To Visit'**
  String get visitsSelectRecordRelated;

  /// No description provided for @visitsAddNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Visit'**
  String get visitsAddNewTitle;

  /// No description provided for @visitsDetailsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit details'**
  String get visitsDetailsCardTitle;

  /// No description provided for @visitsEnterDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter Doctor\'s Visit details'**
  String get visitsEnterDetailsPrompt;

  /// No description provided for @visitsEnterTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Title (e.g. Cardiologist Follow-up)'**
  String get visitsEnterTitleHint;

  /// No description provided for @visitsEnterDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Doctor\'s Diagnosis & Notes'**
  String get visitsEnterDescriptionHint;

  /// No description provided for @visitsSelectDatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Select A Date'**
  String get visitsSelectDatePrompt;

  /// No description provided for @visitsSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Visit'**
  String get visitsSaveButton;

  /// No description provided for @visitsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Visit?'**
  String get visitsDeleteDialogTitle;

  /// No description provided for @visitsDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this consultation visit? This will remove it from your timeline.'**
  String get visitsDeleteDialogMessage;

  /// No description provided for @visitsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Visit deleted successfully'**
  String get visitsDeletedSuccess;

  /// No description provided for @visitsEditDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Visit Details'**
  String get visitsEditDetailsTitle;

  /// No description provided for @visitsEditTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title / Purpose'**
  String get visitsEditTitleLabel;

  /// No description provided for @visitsEditDoctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor Name'**
  String get visitsEditDoctorLabel;

  /// No description provided for @visitsEditHospitalLabel.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Clinic'**
  String get visitsEditHospitalLabel;

  /// No description provided for @visitsEditNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notes'**
  String get visitsEditNotesLabel;

  /// No description provided for @visitsEditDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get visitsEditDetailsAction;

  /// No description provided for @visitsDeleteVisitAction.
  ///
  /// In en, this message translates to:
  /// **'Delete Visit'**
  String get visitsDeleteVisitAction;

  /// No description provided for @visitsConsultationNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Consultation & Clinical Notes'**
  String get visitsConsultationNotesTitle;

  /// No description provided for @visitsNoDetailedNotes.
  ///
  /// In en, this message translates to:
  /// **'No detailed clinical notes recorded for this visit.'**
  String get visitsNoDetailedNotes;

  /// No description provided for @visitsNextFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Next Follow-up'**
  String get visitsNextFollowUp;

  /// No description provided for @visitsNoFollowUpScheduled.
  ///
  /// In en, this message translates to:
  /// **'No follow-up scheduled'**
  String get visitsNoFollowUpScheduled;

  /// No description provided for @visitsRelatedRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Related Medical Records'**
  String get visitsRelatedRecordsTitle;

  /// No description provided for @visitsAttachedCount.
  ///
  /// In en, this message translates to:
  /// **'({count} attached)'**
  String visitsAttachedCount(Object count);

  /// No description provided for @visitsNoRecordsAttached.
  ///
  /// In en, this message translates to:
  /// **'No medical records attached to this visit.'**
  String get visitsNoRecordsAttached;

  /// No description provided for @visitsNoRecordsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No Records Found For {name}'**
  String visitsNoRecordsFoundFor(Object name);

  /// No description provided for @visitsSelectRelatedRecordsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose records associated with this consultation'**
  String get visitsSelectRelatedRecordsSubtitle;

  /// No description provided for @visitsSelectRelatedRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Select Related Record'**
  String get visitsSelectRelatedRecordButton;

  /// No description provided for @visitsViewRelatedRecord.
  ///
  /// In en, this message translates to:
  /// **'View Record'**
  String get visitsViewRelatedRecord;

  /// No description provided for @dietEditMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get dietEditMealTitle;

  /// No description provided for @dietEditMealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your meal routine and ingredients'**
  String get dietEditMealSubtitle;

  /// No description provided for @dietDayNumberName.
  ///
  /// In en, this message translates to:
  /// **'Day {day} {name}'**
  String dietDayNumberName(Object day, Object name);

  /// No description provided for @dietIngredientsHeader.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get dietIngredientsHeader;

  /// No description provided for @dietAddMore.
  ///
  /// In en, this message translates to:
  /// **'+ Add More'**
  String get dietAddMore;

  /// No description provided for @dietMealTitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Meal titles cannot be empty.'**
  String get dietMealTitleEmpty;

  /// No description provided for @dietPlanUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Diet meal plan updated successfully.'**
  String get dietPlanUpdatedSuccess;

  /// No description provided for @dietSaveRoutineButton.
  ///
  /// In en, this message translates to:
  /// **'Save Routine'**
  String get dietSaveRoutineButton;

  /// No description provided for @dietCalorieSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Calorie Saved\nSuccessfully'**
  String get dietCalorieSavedSuccess;

  /// No description provided for @dietRoutineSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'New Meal Routine Saved\nSuccessfully'**
  String get dietRoutineSavedSuccess;

  /// No description provided for @dietSeeMealRoutineHistory.
  ///
  /// In en, this message translates to:
  /// **'See in Meal Routine History'**
  String get dietSeeMealRoutineHistory;

  /// No description provided for @foodScannerQueryingOpenFoodFacts.
  ///
  /// In en, this message translates to:
  /// **'Querying OpenFoodFacts database...'**
  String get foodScannerQueryingOpenFoodFacts;

  /// No description provided for @foodScannerAlignPrompt.
  ///
  /// In en, this message translates to:
  /// **'Align barcode inside the frame'**
  String get foodScannerAlignPrompt;

  /// No description provided for @foodScannerTorchOn.
  ///
  /// In en, this message translates to:
  /// **'Turn flashlight on'**
  String get foodScannerTorchOn;

  /// No description provided for @foodScannerTorchOff.
  ///
  /// In en, this message translates to:
  /// **'Turn flashlight off'**
  String get foodScannerTorchOff;

  /// No description provided for @foodScannerManualCode.
  ///
  /// In en, this message translates to:
  /// **'Enter barcode manually'**
  String get foodScannerManualCode;

  /// No description provided for @foodScannerFlipLens.
  ///
  /// In en, this message translates to:
  /// **'Switch camera lens'**
  String get foodScannerFlipLens;

  /// No description provided for @foodScannerHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Scanned Food Logs'**
  String get foodScannerHistorySubtitle;

  /// No description provided for @foodScannerHistoryEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Scanned food nutrition history will appear here once scanning is enabled.'**
  String get foodScannerHistoryEmptyDesc;

  /// No description provided for @dietPlannerVerifiedBanner.
  ///
  /// In en, this message translates to:
  /// **'Continuity of care enabled • Patient-centered clinical nutrition'**
  String get dietPlannerVerifiedBanner;

  /// No description provided for @dietBasicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Profile Information'**
  String get dietBasicInfoTitle;

  /// No description provided for @dietProfilePrefix.
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}'**
  String dietProfilePrefix(Object name);

  /// No description provided for @dietAgeYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Age (Years)'**
  String get dietAgeYearsLabel;

  /// No description provided for @dietWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get dietWeightKgLabel;

  /// No description provided for @dietHeightCmLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get dietHeightCmLabel;

  /// No description provided for @dietContinueToPreferences.
  ///
  /// In en, this message translates to:
  /// **'Continue to Preferences'**
  String get dietContinueToPreferences;

  /// No description provided for @dietValidationAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age (1-120)'**
  String get dietValidationAge;

  /// No description provided for @dietValidationWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight (10-300 kg)'**
  String get dietValidationWeight;

  /// No description provided for @dietValidationHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height (50-250 cm)'**
  String get dietValidationHeight;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietNonVeg.
  ///
  /// In en, this message translates to:
  /// **'Non-Vegetarian'**
  String get dietNonVeg;

  /// No description provided for @dietBothVegNonVeg.
  ///
  /// In en, this message translates to:
  /// **'Both (Veg + Non-Veg)'**
  String get dietBothVegNonVeg;

  /// No description provided for @dietPickNonVegDays.
  ///
  /// In en, this message translates to:
  /// **'Pick Non-Veg Days:'**
  String get dietPickNonVegDays;

  /// No description provided for @dietAllergiesOptional.
  ///
  /// In en, this message translates to:
  /// **'Known Allergies (Optional)'**
  String get dietAllergiesOptional;

  /// No description provided for @dietSpecifyIngredientsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Specify ingredients to exclude completely'**
  String get dietSpecifyIngredientsPrompt;

  /// No description provided for @dietAllergiesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Peanuts, Shellfish, Gluten, Dairy'**
  String get dietAllergiesHint;

  /// No description provided for @dietContinueToGoals.
  ///
  /// In en, this message translates to:
  /// **'Continue to Health Goals'**
  String get dietContinueToGoals;

  /// No description provided for @dietValidationNonVegDays.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one non-veg day or change your preference'**
  String get dietValidationNonVegDays;

  /// No description provided for @dietHealthGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Level & Primary Goal'**
  String get dietHealthGoalTitle;

  /// No description provided for @dietActivityLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get dietActivityLevelLabel;

  /// No description provided for @dietSelectActivityLevelHint.
  ///
  /// In en, this message translates to:
  /// **'Select your daily activity level'**
  String get dietSelectActivityLevelHint;

  /// No description provided for @dietPrimaryGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary Health Goal'**
  String get dietPrimaryGoalLabel;

  /// No description provided for @dietSelectPrimaryGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Select your primary target'**
  String get dietSelectPrimaryGoalHint;

  /// No description provided for @dietGoalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight (Caloric Deficit)'**
  String get dietGoalLoseWeight;

  /// No description provided for @dietGoalMuscleGain.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle / Gain Weight'**
  String get dietGoalMuscleGain;

  /// No description provided for @dietValidationActivityGoal.
  ///
  /// In en, this message translates to:
  /// **'Please select both activity level and health goal'**
  String get dietValidationActivityGoal;

  /// No description provided for @dietContinueToTimeContext.
  ///
  /// In en, this message translates to:
  /// **'Continue to Time & Context'**
  String get dietContinueToTimeContext;

  /// No description provided for @dietClinicalNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notice'**
  String get dietClinicalNoticeTitle;

  /// No description provided for @dietConditionPrefix.
  ///
  /// In en, this message translates to:
  /// **'Condition: {conditions}'**
  String dietConditionPrefix(Object conditions);

  /// No description provided for @dietConstraintsRestrictiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences are highly restrictive'**
  String get dietConstraintsRestrictiveTitle;

  /// No description provided for @dietAdjustExclusions.
  ///
  /// In en, this message translates to:
  /// **'Adjust your exclusions or dietary preferences to allow healthy menu planning.'**
  String get dietAdjustExclusions;

  /// No description provided for @dietTimeAndContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Timing, Budget & Context'**
  String get dietTimeAndContextTitle;

  /// No description provided for @dietMealTimingLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Schedule & Timing'**
  String get dietMealTimingLabel;

  /// No description provided for @dietMealTimingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Breakfast 8:30 AM, Lunch 1:30 PM, Dinner 8:30 PM'**
  String get dietMealTimingHint;

  /// No description provided for @dietBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Grocery & Meal Budget Preference'**
  String get dietBudgetLabel;

  /// No description provided for @dietBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Economical local market, Moderate, Premium organic'**
  String get dietBudgetHint;

  /// No description provided for @dietCookingContextLabel.
  ///
  /// In en, this message translates to:
  /// **'Cooking Context & Resources'**
  String get dietCookingContextLabel;

  /// No description provided for @dietCookingContextHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Home-cooked, Hosteller with induction, Working professional'**
  String get dietCookingContextHint;

  /// No description provided for @dietGeneratePlanButton.
  ///
  /// In en, this message translates to:
  /// **'Generate Tailored Diet Plan'**
  String get dietGeneratePlanButton;

  /// No description provided for @dietRegeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Regenerated diet plan successfully.'**
  String get dietRegeneratedSuccess;

  /// No description provided for @dietSavedToRoutineSuccess.
  ///
  /// In en, this message translates to:
  /// **'Diet routine saved to local weekly schedule.'**
  String get dietSavedToRoutineSuccess;

  /// No description provided for @dietVerifiedPlanning.
  ///
  /// In en, this message translates to:
  /// **'Verified Clinical Nutritional Planning'**
  String get dietVerifiedPlanning;

  /// No description provided for @dietEstimatedDailyCaloricTarget.
  ///
  /// In en, this message translates to:
  /// **'Estimated Daily Caloric Target: ~{calories} kcal'**
  String dietEstimatedDailyCaloricTarget(Object calories);

  /// No description provided for @dietInformationalBadge.
  ///
  /// In en, this message translates to:
  /// **'INFORMATIONAL NUTRITIONAL ADVISORY • NON-PRESCRIPTIVE'**
  String get dietInformationalBadge;

  /// No description provided for @dietDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dietDayNumber(Object day);

  /// No description provided for @dietNutritionOverview.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Overview'**
  String get dietNutritionOverview;

  /// No description provided for @dietTotalCaloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Total Calories: {calories} kcal'**
  String dietTotalCaloriesKcal(Object calories);

  /// No description provided for @dietProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein: {grams}g'**
  String dietProtein(Object grams);

  /// No description provided for @dietCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs: {grams}g'**
  String dietCarbs(Object grams);

  /// No description provided for @dietFat.
  ///
  /// In en, this message translates to:
  /// **'Fat: {grams}g'**
  String dietFat(Object grams);

  /// No description provided for @dietFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber: {grams}g'**
  String dietFiber(Object grams);

  /// No description provided for @dietBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get dietBreakfast;

  /// No description provided for @dietLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get dietLunch;

  /// No description provided for @dietEveningSnack.
  ///
  /// In en, this message translates to:
  /// **'Evening Snack'**
  String get dietEveningSnack;

  /// No description provided for @dietDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dietDinner;

  /// No description provided for @dietIngredientsAndPortions.
  ///
  /// In en, this message translates to:
  /// **'Ingredients & Portions'**
  String get dietIngredientsAndPortions;

  /// No description provided for @dietEstimatedNutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Estimated Nutrition Per Serving'**
  String get dietEstimatedNutritionPerServing;

  /// No description provided for @dietPreparationNote.
  ///
  /// In en, this message translates to:
  /// **'Preparation Note'**
  String get dietPreparationNote;

  /// No description provided for @dietClinicalNoticeHeader.
  ///
  /// In en, this message translates to:
  /// **'Clinical Notice & Safeguards'**
  String get dietClinicalNoticeHeader;

  /// No description provided for @dietSourceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Source: NuroVed Clinical Heuristics Engine. This nutritional plan provides generalized advisory estimates and is not a substitute for clinical medical therapy or certified renal/metabolic medical nutrition therapy.'**
  String get dietSourceDisclaimer;

  /// No description provided for @dietSaveToRoutineButton.
  ///
  /// In en, this message translates to:
  /// **'Save to My Routine'**
  String get dietSaveToRoutineButton;

  /// No description provided for @dietRegenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Plan'**
  String get dietRegenerateButton;

  /// No description provided for @dietEditInputsButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Inputs'**
  String get dietEditInputsButton;

  /// No description provided for @dietBackToOverviewButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Overview'**
  String get dietBackToOverviewButton;

  /// No description provided for @premiumWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NuroVed\nPremium Plus'**
  String get premiumWelcomeTitle;

  /// No description provided for @premiumPaymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get premiumPaymentFailedTitle;

  /// No description provided for @premiumRenewTitle.
  ///
  /// In en, this message translates to:
  /// **'Renew the premium plan'**
  String get premiumRenewTitle;

  /// No description provided for @premiumStatusActivated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get premiumStatusActivated;

  /// No description provided for @premiumStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get premiumStatusFailed;

  /// No description provided for @premiumStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get premiumStatusExpired;

  /// No description provided for @premiumJumpToHome.
  ///
  /// In en, this message translates to:
  /// **'Jump to Home'**
  String get premiumJumpToHome;

  /// No description provided for @premiumRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get premiumRetry;

  /// No description provided for @premiumRenewNow.
  ///
  /// In en, this message translates to:
  /// **'Renew Now'**
  String get premiumRenewNow;

  /// No description provided for @premiumPaymentTotal.
  ///
  /// In en, this message translates to:
  /// **'Payment Total'**
  String get premiumPaymentTotal;

  /// No description provided for @premiumDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get premiumDate;

  /// No description provided for @premiumTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get premiumTime;

  /// No description provided for @premiumBilledTo.
  ///
  /// In en, this message translates to:
  /// **'Billed To'**
  String get premiumBilledTo;

  /// No description provided for @premiumBilledAmount.
  ///
  /// In en, this message translates to:
  /// **'Billed Amount'**
  String get premiumBilledAmount;

  /// No description provided for @premiumSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get premiumSavings;

  /// No description provided for @premiumGst.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get premiumGst;

  /// No description provided for @premiumAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get premiumAmountPaid;

  /// No description provided for @purchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'NuroVed Purchase'**
  String get purchaseTitle;

  /// No description provided for @purchaseCompanySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Promacle private limited'**
  String get purchaseCompanySubtitle;

  /// No description provided for @purchaseActiveDuration.
  ///
  /// In en, this message translates to:
  /// **'Your account will be active for'**
  String get purchaseActiveDuration;

  /// No description provided for @purchaseDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String purchaseDaysCount(Object days);

  /// No description provided for @purchaseSpecialOffer.
  ///
  /// In en, this message translates to:
  /// **'NuroVed special Offer'**
  String get purchaseSpecialOffer;

  /// No description provided for @purchaseOffYearly.
  ///
  /// In en, this message translates to:
  /// **'70% Off Yearly'**
  String get purchaseOffYearly;

  /// No description provided for @purchaseOffMonthly.
  ///
  /// In en, this message translates to:
  /// **'65% Off Monthly'**
  String get purchaseOffMonthly;

  /// No description provided for @purchaseYouWillSave.
  ///
  /// In en, this message translates to:
  /// **'you will save ₹{amount} on {period}'**
  String purchaseYouWillSave(Object amount, Object period);

  /// No description provided for @purchaseYearly.
  ///
  /// In en, this message translates to:
  /// **'yearly'**
  String get purchaseYearly;

  /// No description provided for @purchaseMonthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get purchaseMonthly;

  /// No description provided for @purchaseSelectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get purchaseSelectMethod;

  /// No description provided for @purchaseSecureBadge.
  ///
  /// In en, this message translates to:
  /// **'100% Secure & Safe payments'**
  String get purchaseSecureBadge;

  /// No description provided for @purchaseServiceCharge.
  ///
  /// In en, this message translates to:
  /// **'Service Charge'**
  String get purchaseServiceCharge;

  /// No description provided for @purchaseDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get purchaseDiscount;

  /// No description provided for @purchaseTotalAmountToPay.
  ///
  /// In en, this message translates to:
  /// **'Total Amount To Pay'**
  String get purchaseTotalAmountToPay;

  /// No description provided for @purchaseUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'In-App Purchases Unavailable in MVP'**
  String get purchaseUnavailableTitle;

  /// No description provided for @purchaseUnavailableDesc.
  ///
  /// In en, this message translates to:
  /// **'Payment checkout is disabled in this MVP release.\n\nIn accordance with NuroVed safety guidelines, subscription entitlement requires server-side receipt validation with Apple StoreKit and Google Play Billing, which is not yet configured.\n\nAll current core continuity-of-care tools remain accessible in free preview mode.'**
  String get purchaseUnavailableDesc;

  /// No description provided for @purchaseReturnToApp.
  ///
  /// In en, this message translates to:
  /// **'Return to App'**
  String get purchaseReturnToApp;

  /// No description provided for @customerSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customerSupportTitle;

  /// No description provided for @customerSupportAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get customerSupportAboutUs;

  /// No description provided for @customerSupportSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get customerSupportSearchHint;

  /// No description provided for @customerSupportContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get customerSupportContactUs;

  /// No description provided for @customerSupportFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get customerSupportFaq;

  /// No description provided for @customerSupportNoContactMatch.
  ///
  /// In en, this message translates to:
  /// **'No contact options match your search.'**
  String get customerSupportNoContactMatch;

  /// No description provided for @customerSupportNoFaqMatch.
  ///
  /// In en, this message translates to:
  /// **'No FAQs match your search.'**
  String get customerSupportNoFaqMatch;

  /// No description provided for @customerSupportService.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customerSupportService;

  /// No description provided for @customerSupportWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get customerSupportWebsite;

  /// No description provided for @customerSupportWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Whatsapp'**
  String get customerSupportWhatsapp;

  /// No description provided for @customerSupportFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get customerSupportFacebook;

  /// No description provided for @customerSupportInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get customerSupportInstagram;

  /// No description provided for @customerSupportPhoneNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Direct phone support is currently unconfigured in this release. Please visit our website or report a problem via Settings.'**
  String get customerSupportPhoneNotConfigured;

  /// No description provided for @customerSupportWebsiteDialog.
  ///
  /// In en, this message translates to:
  /// **'Official website: https://nuroved.com\nPlease open this link in your web browser.'**
  String get customerSupportWebsiteDialog;

  /// No description provided for @customerSupportWhatsappNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp support is currently unconfigured in this release. Please visit our website or report a problem via Settings.'**
  String get customerSupportWhatsappNotConfigured;

  /// No description provided for @customerSupportChannelNotActive.
  ///
  /// In en, this message translates to:
  /// **'The {channel} support channel is not yet active in this release. Please visit our website or report a problem via Settings.'**
  String customerSupportChannelNotActive(Object channel);

  /// No description provided for @dataPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacyTitle;

  /// No description provided for @dataPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Data Is Securely Stored & Protected'**
  String get dataPrivacySubtitle;

  /// No description provided for @dataPrivacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account & Data'**
  String get dataPrivacyDeleteTitle;

  /// No description provided for @dataPrivacyDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? All medical records, visits, and timeline data will be permanently erased. This action cannot be reversed.'**
  String get dataPrivacyDeleteMessage;

  /// No description provided for @dataPrivacyConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password:'**
  String get dataPrivacyConfirmPassword;

  /// No description provided for @dataPrivacyEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get dataPrivacyEnterPassword;

  /// No description provided for @dataPrivacyPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required.'**
  String get dataPrivacyPasswordRequired;

  /// No description provided for @dataPrivacyDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed.'**
  String get dataPrivacyDeleteFailed;

  /// No description provided for @dataPrivacyPermanentlyDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently Delete'**
  String get dataPrivacyPermanentlyDelete;

  /// No description provided for @dataPrivacyNoActiveEmail.
  ///
  /// In en, this message translates to:
  /// **'No active email found for current user.'**
  String get dataPrivacyNoActiveEmail;

  /// No description provided for @dataPrivacySendingReset.
  ///
  /// In en, this message translates to:
  /// **'Sending password reset instructions...'**
  String get dataPrivacySendingReset;

  /// No description provided for @dataPrivacyResetSent.
  ///
  /// In en, this message translates to:
  /// **'Reset instructions sent to {email}.'**
  String dataPrivacyResetSent(Object email);

  /// No description provided for @dataPrivacyPolicyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security Policy'**
  String get dataPrivacyPolicyDialogTitle;

  /// No description provided for @dataPrivacyChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email address'**
  String get dataPrivacyChangeEmail;

  /// No description provided for @dataPrivacyChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get dataPrivacyChangePassword;

  /// No description provided for @dataPrivacyResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password via email'**
  String get dataPrivacyResetPassword;

  /// No description provided for @dataPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get dataPrivacyPolicy;

  /// No description provided for @dataPrivacyDeleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get dataPrivacyDeleteMyAccount;

  /// No description provided for @changeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmailTitle;

  /// No description provided for @changeEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your registered account email'**
  String get changeEmailSubtitle;

  /// No description provided for @changeEmailEnterNew.
  ///
  /// In en, this message translates to:
  /// **'Enter new email address'**
  String get changeEmailEnterNew;

  /// No description provided for @changeEmailEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter account password'**
  String get changeEmailEnterPassword;

  /// No description provided for @changeEmailPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required to verify identity.'**
  String get changeEmailPasswordRequired;

  /// No description provided for @changeEmailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to your new address.'**
  String get changeEmailVerificationSent;

  /// No description provided for @changeEmailSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save New Email'**
  String get changeEmailSaveButton;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-authenticate and set your new password'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordEnterCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get changePasswordEnterCurrent;

  /// No description provided for @changePasswordEnterNew.
  ///
  /// In en, this message translates to:
  /// **'Enter new password (min. 8 characters)'**
  String get changePasswordEnterNew;

  /// No description provided for @changePasswordReEnterNew.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get changePasswordReEnterNew;

  /// No description provided for @changePasswordCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required.'**
  String get changePasswordCurrentRequired;

  /// No description provided for @changePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters.'**
  String get changePasswordMinLength;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save New Password'**
  String get changePasswordSaveButton;

  /// No description provided for @settingsSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Select {title}'**
  String settingsSelectOption(Object title);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsAllMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get notificationsAllMarkedRead;

  /// No description provided for @notificationsSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsSectionToday;

  /// No description provided for @notificationsSectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get notificationsSectionThisWeek;

  /// No description provided for @notificationsSampleMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Time For Mom\'s Medicine'**
  String get notificationsSampleMedicineTitle;

  /// No description provided for @notificationsSampleMedicineSub.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to take Mom\'s BP medicine....'**
  String get notificationsSampleMedicineSub;

  /// No description provided for @notificationsSampleBloodTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Blood test Reminder'**
  String get notificationsSampleBloodTestTitle;

  /// No description provided for @notificationsSampleBloodTestSub.
  ///
  /// In en, this message translates to:
  /// **'Remember your upcoming blood test tomorrow...'**
  String get notificationsSampleBloodTestSub;

  /// No description provided for @notificationsSampleStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'5-day Streak! Great Job!'**
  String get notificationsSampleStreakTitle;

  /// No description provided for @notificationsSampleStreakSub.
  ///
  /// In en, this message translates to:
  /// **'You have logged in for 5 days consecutively...'**
  String get notificationsSampleStreakSub;

  /// No description provided for @notificationsSampleEncryptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Data is Encrypted'**
  String get notificationsSampleEncryptedTitle;

  /// No description provided for @notificationsSampleEncryptedSub.
  ///
  /// In en, this message translates to:
  /// **'Your health records are securely encrypted & protected'**
  String get notificationsSampleEncryptedSub;

  /// No description provided for @notificationsSampleRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'First record has been added'**
  String get notificationsSampleRecordTitle;

  /// No description provided for @notificationsSampleRecordSub.
  ///
  /// In en, this message translates to:
  /// **'Your first health records has been added successfully.....'**
  String get notificationsSampleRecordSub;

  /// No description provided for @notificationsSampleWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for joining us'**
  String get notificationsSampleWelcomeTitle;

  /// No description provided for @notificationsSampleWelcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Welcome to new revolutionary step towards your health....'**
  String get notificationsSampleWelcomeSub;

  /// No description provided for @accessManageTab.
  ///
  /// In en, this message translates to:
  /// **'Manage Access'**
  String get accessManageTab;

  /// No description provided for @accessRequestTab.
  ///
  /// In en, this message translates to:
  /// **'Access Request'**
  String get accessRequestTab;

  /// No description provided for @accessGrantNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Grant New Access'**
  String get accessGrantNewTitle;

  /// No description provided for @accessGrantNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give Hospitals Access To Your Health Profile'**
  String get accessGrantNewSubtitle;

  /// No description provided for @accessSelectHospital.
  ///
  /// In en, this message translates to:
  /// **'Select Hospital'**
  String get accessSelectHospital;

  /// No description provided for @accessChooseHospitalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose A Hospital Or Healthcare Provider'**
  String get accessChooseHospitalSubtitle;

  /// No description provided for @accessDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Duration'**
  String get accessDurationTitle;

  /// No description provided for @accessPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent Access'**
  String get accessPermanent;

  /// No description provided for @accessUntilDay.
  ///
  /// In en, this message translates to:
  /// **'Select Access Until Day'**
  String get accessUntilDay;

  /// No description provided for @accessDataToShare.
  ///
  /// In en, this message translates to:
  /// **'Data To Share'**
  String get accessDataToShare;

  /// No description provided for @accessFullProfile.
  ///
  /// In en, this message translates to:
  /// **'Full Profile Access'**
  String get accessFullProfile;

  /// No description provided for @accessHealthTimelineOnly.
  ///
  /// In en, this message translates to:
  /// **'Only Health Timeline'**
  String get accessHealthTimelineOnly;

  /// No description provided for @accessMedicalRecordsOnly.
  ///
  /// In en, this message translates to:
  /// **'Only Medical Records'**
  String get accessMedicalRecordsOnly;

  /// No description provided for @accessProfilePageOnly.
  ///
  /// In en, this message translates to:
  /// **'Only Profile Page'**
  String get accessProfilePageOnly;

  /// No description provided for @accessTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Type'**
  String get accessTypeTitle;

  /// No description provided for @accessViewOnly.
  ///
  /// In en, this message translates to:
  /// **'View Only'**
  String get accessViewOnly;

  /// No description provided for @accessEditAndView.
  ///
  /// In en, this message translates to:
  /// **'Edit & View'**
  String get accessEditAndView;

  /// No description provided for @accessGrantedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Access Granted Successfully!'**
  String get accessGrantedSuccess;

  /// No description provided for @accessReviewAndGrant.
  ///
  /// In en, this message translates to:
  /// **'Review & Grant Access'**
  String get accessReviewAndGrant;

  /// No description provided for @accessActiveHospitals.
  ///
  /// In en, this message translates to:
  /// **'Active Hospital Access'**
  String get accessActiveHospitals;

  /// No description provided for @accessActiveHospitalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hospitals That Currently Have Access To Your Profile'**
  String get accessActiveHospitalsSubtitle;

  /// No description provided for @accessNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active access'**
  String get accessNoActive;

  /// No description provided for @accessRevokeAction.
  ///
  /// In en, this message translates to:
  /// **'Revoke Access'**
  String get accessRevokeAction;

  /// No description provided for @accessRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke Access?'**
  String get accessRevokeTitle;

  /// No description provided for @accessRevokeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke access for {hospital}? They will immediately lose access to your data.'**
  String accessRevokeConfirmMessage(Object hospital);

  /// No description provided for @accessRevokedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Access revoked for {hospital}'**
  String accessRevokedSnackbar(Object hospital);

  /// No description provided for @accessHospitalRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Hospital Access Request'**
  String get accessHospitalRequestTitle;

  /// No description provided for @accessHospitalRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hospitals Requesting Access To Your Profile'**
  String get accessHospitalRequestSubtitle;

  /// No description provided for @accessClinicianComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Clinician Direct Sharing Coming Soon'**
  String get accessClinicianComingSoon;

  /// No description provided for @accessClinicianNotice.
  ///
  /// In en, this message translates to:
  /// **'Direct institutional hospital and clinician sharing is disabled in the MVP.\n\nIn accordance with healthcare safety standards, clinical access requires server-side identity verification through accredited provider directories. A clinician\'s identity is never proven by an unverified name or typed email.\n\nDelegated caregiver access is available in the \'Manage Access\' tab, protected by authenticated Row Level Security.'**
  String get accessClinicianNotice;

  /// No description provided for @accessEnforcedSecurity.
  ///
  /// In en, this message translates to:
  /// **'Enforced via Care Access Grants & RLS policies'**
  String get accessEnforcedSecurity;

  /// No description provided for @accessGoToManage.
  ///
  /// In en, this message translates to:
  /// **'Go to Manage Access'**
  String get accessGoToManage;

  /// No description provided for @hospitalDetailsExpiringIn.
  ///
  /// In en, this message translates to:
  /// **'Expiring In'**
  String get hospitalDetailsExpiringIn;

  /// No description provided for @hospitalDetailsActivityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get hospitalDetailsActivityLog;

  /// No description provided for @hospitalDetailsRecentActions.
  ///
  /// In en, this message translates to:
  /// **'Recent Actions By Hospitals'**
  String get hospitalDetailsRecentActions;

  /// No description provided for @hospitalDetailsViewedRecord.
  ///
  /// In en, this message translates to:
  /// **'Viewed Medical Record'**
  String get hospitalDetailsViewedRecord;

  /// No description provided for @hospitalDetailsAddedRecord.
  ///
  /// In en, this message translates to:
  /// **'Added New Record'**
  String get hospitalDetailsAddedRecord;

  /// No description provided for @hospitalDetailsAddedVisits.
  ///
  /// In en, this message translates to:
  /// **'Added New Visits'**
  String get hospitalDetailsAddedVisits;

  /// No description provided for @hospitalDetailsActionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By {name} - {time}'**
  String hospitalDetailsActionSubtitle(Object name, Object time);

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhoneLabel;

  /// No description provided for @commonUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get commonUnderstood;

  /// No description provided for @routineEditMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get routineEditMeal;

  /// No description provided for @homeHealthHeadline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s take the next step\nfor your health!'**
  String get homeHealthHeadline;

  /// No description provided for @recordsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Record updated successfully'**
  String get recordsUpdatedSuccess;

  /// Error message when record deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete record: {error}'**
  String recordsFailedDelete(String error);

  /// No description provided for @recordsUnknownSize.
  ///
  /// In en, this message translates to:
  /// **'Unknown size'**
  String get recordsUnknownSize;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get commonTime;

  /// No description provided for @visitsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Visit updated successfully'**
  String get visitsUpdatedSuccess;

  /// No description provided for @dietDisclaimerBanner.
  ///
  /// In en, this message translates to:
  /// **'Diet suggestions are for nutritional tracking only and do not constitute medical diagnosis or treatment.'**
  String get dietDisclaimerBanner;

  /// No description provided for @dietPreviewMetricsNotice.
  ///
  /// In en, this message translates to:
  /// **'Sample preview metrics - not clinical measurements'**
  String get dietPreviewMetricsNotice;

  /// No description provided for @dietKcalIntake.
  ///
  /// In en, this message translates to:
  /// **'kcal intake'**
  String get dietKcalIntake;

  /// No description provided for @dietSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get dietSleep;

  /// No description provided for @dietSeeInDietSection.
  ///
  /// In en, this message translates to:
  /// **'See in Diet Section'**
  String get dietSeeInDietSection;

  /// No description provided for @dietVerifiedNutritionalPlanningNotice.
  ///
  /// In en, this message translates to:
  /// **'Verified Nutritional Planning: Calculations are based on clinical dietary guidelines (ICMR-NIN & Mifflin-St Jeor). General reference only.'**
  String get dietVerifiedNutritionalPlanningNotice;

  /// No description provided for @dietGuidelinesAttribution.
  ///
  /// In en, this message translates to:
  /// **'Source: ICMR-NIN & USDA Food Data Central Dietary Guidelines.'**
  String get dietGuidelinesAttribution;

  /// Lookup loading status with barcode
  ///
  /// In en, this message translates to:
  /// **'Querying Open Food Facts for barcode {barcode}'**
  String foodScannerQueryingBarcode(String barcode);

  /// No description provided for @foodScannerManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type the 8, 12, 13, or 14-digit retail barcode found on the product packaging (EAN / UPC).'**
  String get foodScannerManualSubtitle;

  /// No description provided for @foodScannerBarcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode Digits'**
  String get foodScannerBarcodeLabel;

  /// No description provided for @foodScannerBarcodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3017620422003'**
  String get foodScannerBarcodeHint;

  /// No description provided for @foodScannerCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera Unavailable'**
  String get foodScannerCameraUnavailable;

  /// No description provided for @foodScannerCameraUnavailableDesc.
  ///
  /// In en, this message translates to:
  /// **'Camera access is denied or no camera hardware is available on this device/simulator.\n\nYou can still look up any food product by entering its barcode number manually.'**
  String get foodScannerCameraUnavailableDesc;

  /// No description provided for @foodScannerBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get foodScannerBackToHome;

  /// No description provided for @foodScannerNutritionDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts Nutrition Data'**
  String get foodScannerNutritionDataSubtitle;

  /// No description provided for @foodScannerProductNameNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Product Name Not Specified'**
  String get foodScannerProductNameNotSpecified;

  /// No description provided for @foodScannerBrandNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Brand not specified'**
  String get foodScannerBrandNotSpecified;

  /// Serving size label
  ///
  /// In en, this message translates to:
  /// **'Serving: {serving}'**
  String foodScannerServingPrefix(String serving);

  /// Serving basis label
  ///
  /// In en, this message translates to:
  /// **'Basis: {basis}'**
  String foodScannerBasisPrefix(String basis);

  /// No description provided for @foodScannerSugars.
  ///
  /// In en, this message translates to:
  /// **'  • of which Sugars'**
  String get foodScannerSugars;

  /// No description provided for @foodScannerSaturates.
  ///
  /// In en, this message translates to:
  /// **'  • of which Saturates'**
  String get foodScannerSaturates;

  /// No description provided for @foodScannerUnreportedNotice.
  ///
  /// In en, this message translates to:
  /// **'Unreported nutrients are shown as \'—\'. NuroVed does not simulate or estimate missing nutritional facts.'**
  String get foodScannerUnreportedNotice;

  /// No description provided for @foodScannerMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer: Nutritional information is provided for informational reference only. Always verify product packaging directly for allergens and medical dietary restrictions.'**
  String get foodScannerMedicalDisclaimer;

  /// No description provided for @premiumExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Premium'**
  String get premiumExploreTitle;

  /// No description provided for @premiumExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock The Full Potential Of Your Health'**
  String get premiumExploreSubtitle;

  /// No description provided for @premiumUpgradeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium'**
  String get premiumUpgradeCardTitle;

  /// No description provided for @premiumUpgradeCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full power of NuroVed and take control of your health.'**
  String get premiumUpgradeCardSubtitle;

  /// No description provided for @premiumSectionEverythingFreePlus.
  ///
  /// In en, this message translates to:
  /// **'Everything is Free, plus'**
  String get premiumSectionEverythingFreePlus;

  /// No description provided for @premiumFeatureShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share with Doctors'**
  String get premiumFeatureShareTitle;

  /// No description provided for @premiumFeatureShareSub.
  ///
  /// In en, this message translates to:
  /// **'Share your complete health profile with doctors in one tap.'**
  String get premiumFeatureShareSub;

  /// No description provided for @premiumFeatureAiInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Health Insights'**
  String get premiumFeatureAiInsightsTitle;

  /// No description provided for @premiumFeatureAiInsightsSub.
  ///
  /// In en, this message translates to:
  /// **'Get intelligent insights and risk alerts from your health data.'**
  String get premiumFeatureAiInsightsSub;

  /// No description provided for @premiumFeatureTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Timeline'**
  String get premiumFeatureTimelineTitle;

  /// No description provided for @premiumFeatureTimelineSub.
  ///
  /// In en, this message translates to:
  /// **'Track trends and patterns with advanced health timeline.'**
  String get premiumFeatureTimelineSub;

  /// No description provided for @premiumFeatureFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Profiles'**
  String get premiumFeatureFamilyTitle;

  /// No description provided for @premiumFeatureFamilySub.
  ///
  /// In en, this message translates to:
  /// **'Add and manage your family\'s health in one secure place.'**
  String get premiumFeatureFamilySub;

  /// No description provided for @premiumFeatureScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Scanner'**
  String get premiumFeatureScannerTitle;

  /// No description provided for @premiumFeatureScannerSub.
  ///
  /// In en, this message translates to:
  /// **'Scan and store unlimited reports with smart auto-tagging.'**
  String get premiumFeatureScannerSub;

  /// No description provided for @premiumFeatureDietTitle.
  ///
  /// In en, this message translates to:
  /// **'Context Aware Diet Plans'**
  String get premiumFeatureDietTitle;

  /// No description provided for @premiumFeatureDietSub.
  ///
  /// In en, this message translates to:
  /// **'Personalized diet recommendations based on your goals.'**
  String get premiumFeatureDietSub;

  /// No description provided for @premiumLimitedOffer.
  ///
  /// In en, this message translates to:
  /// **'Limited Time Offer'**
  String get premiumLimitedOffer;

  /// No description provided for @premiumYearlyDiscount.
  ///
  /// In en, this message translates to:
  /// **'70% OFF On Yearly Plan'**
  String get premiumYearlyDiscount;

  /// No description provided for @premiumTakeControlToday.
  ///
  /// In en, this message translates to:
  /// **'Take control of your health today'**
  String get premiumTakeControlToday;

  /// No description provided for @premiumSaveAmount.
  ///
  /// In en, this message translates to:
  /// **'Save ₹2100'**
  String get premiumSaveAmount;

  /// No description provided for @premiumSelectYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Select your plan'**
  String get premiumSelectYourPlan;

  /// No description provided for @premiumMonthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Premium'**
  String get premiumMonthlyPlan;

  /// No description provided for @premiumMonthlyOffer.
  ///
  /// In en, this message translates to:
  /// **'65% Off Offer'**
  String get premiumMonthlyOffer;

  /// No description provided for @premiumYearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Premium'**
  String get premiumYearlyPlan;

  /// No description provided for @premiumYearlyPricePerYear.
  ///
  /// In en, this message translates to:
  /// **'₹804/Year'**
  String get premiumYearlyPricePerYear;

  /// No description provided for @premiumMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get premiumMostPopular;

  /// No description provided for @premiumContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Premium'**
  String get premiumContinueButton;

  /// No description provided for @premiumPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are currently in preview mode. In-app checkout is disabled until store release.'**
  String get premiumPreviewNotice;

  /// No description provided for @premiumPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/Month'**
  String get premiumPerMonth;

  /// No description provided for @reportProblemEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Any problems you report on this device will be recorded here for local diagnostic tracking.'**
  String get reportProblemEmptyDesc;

  /// No description provided for @reportProblemDeviceRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded on this device for diagnostic analysis.'**
  String get reportProblemDeviceRecorded;

  /// No description provided for @customerSupportFaqQ1.
  ///
  /// In en, this message translates to:
  /// **'What is NuroVed and how does it work?'**
  String get customerSupportFaqQ1;

  /// No description provided for @customerSupportFaqA1.
  ///
  /// In en, this message translates to:
  /// **'NuroVed is an AI-powered health companion that understands your lifestyle, preferences, and medical context to provide personalized diet plans, insights, and health guidance—all in one place.'**
  String get customerSupportFaqA1;

  /// No description provided for @customerSupportFaqQ2.
  ///
  /// In en, this message translates to:
  /// **'How is NuroVed different from other health apps?'**
  String get customerSupportFaqQ2;

  /// No description provided for @customerSupportFaqA2.
  ///
  /// In en, this message translates to:
  /// **'Unlike generic trackers, NuroVed adapts to you. It combines AI, real-time analysis, and behavior-focused design to deliver recommendations that actually fit your daily life.'**
  String get customerSupportFaqA2;

  /// No description provided for @customerSupportFaqQ3.
  ///
  /// In en, this message translates to:
  /// **'Is my health data safe with NuroVed?'**
  String get customerSupportFaqQ3;

  /// No description provided for @customerSupportFaqA3.
  ///
  /// In en, this message translates to:
  /// **'Yes. Your data is securely stored and handled with strict privacy measures. NuroVed is built with a strong focus on protecting your personal and medical information.'**
  String get customerSupportFaqA3;

  /// No description provided for @customerSupportFaqQ4.
  ///
  /// In en, this message translates to:
  /// **'Can NuroVed handle specific needs like allergies or medical conditions?'**
  String get customerSupportFaqQ4;

  /// No description provided for @customerSupportFaqA4.
  ///
  /// In en, this message translates to:
  /// **'Absolutely. NuroVed considers your allergies, dietary restrictions, and health conditions to provide safe and personalized recommendations.'**
  String get customerSupportFaqA4;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @homeHealthTimeline.
  ///
  /// In en, this message translates to:
  /// **'Health Timeline'**
  String get homeHealthTimeline;

  /// No description provided for @accessRevokeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get accessRevokeConfirm;

  /// No description provided for @accessExpiryNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get accessExpiryNever;

  /// No description provided for @notificationsTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsTimeJustNow;

  /// No description provided for @notificationsTimeOneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hr ago'**
  String get notificationsTimeOneHourAgo;

  /// No description provided for @notificationsTimeTwoHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'2 hr ago'**
  String get notificationsTimeTwoHoursAgo;

  /// No description provided for @notificationsTimeTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get notificationsTimeTuesday;

  /// No description provided for @notificationsTimeMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get notificationsTimeMonday;

  /// No description provided for @homeTooltipNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeTooltipNotifications;

  /// No description provided for @homeTooltipUpgradePremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get homeTooltipUpgradePremium;

  /// No description provided for @recordsBackToRecords.
  ///
  /// In en, this message translates to:
  /// **'Back to records'**
  String get recordsBackToRecords;

  /// No description provided for @dietSuccessBackSemantics.
  ///
  /// In en, this message translates to:
  /// **'Back to diet overview'**
  String get dietSuccessBackSemantics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
