import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app_binding.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/config/app_config.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/models/visit.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_visits_repository.dart';
import 'package:nuroved_patient/core/repositories/supabase/supabase_auth_repository.dart';
import 'package:nuroved_patient/core/utils/app_logger.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/core/utils/validators.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';
import 'package:nuroved_patient/features/auth/screens/login_screen.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SEC-1: Session Termination & Cross-Account Isolation', () {
    late FakeAuthRepository fakeAuth;
    late AuthController authController;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'cached_profile_id': 'user-123',
        'cached_profile_name': 'Sensitive Patient',
        'cached_profile_email': 'patient@example.com',
        'cached_profile_phone': '9876543210',
        'last_active_subject_id': 'user-123',
      });
      fakeAuth = FakeAuthRepository();
      authController = AuthController(authRepository: fakeAuth);

      // Seed authenticated session
      await fakeAuth.signUp(
        email: 'patient@example.com',
        password: 'Password123!',
        name: 'Sensitive Patient',
        acknowledgedTerms: true,
      );

      // 1. Populate profile
      await ProfileController.instance.updateProfile(
        const UserProfile(
          id: 'user-123',
          name: 'Sensitive Patient',
          email: 'patient@example.com',
          phone: '9876543210',
          dateOfBirth: '01/01/1990',
          gender: 'Female',
          height: '165',
          weight: '60',
          bloodGroup: 'B+',
          allergies: ['Penicillin'],
          chronicConditions: ['Type 2 Diabetes'],
        ),
      );
      ProfileController.instance.switchSubjectToSelf();

      // 2. Populate records
      final recordsRepo = FakeRecordsRepository();
      RecordsController.resetForTesting(repository: recordsRepo);
      await RecordsController.instance.uploadAndSaveRecord(
        title: 'Sensitive Blood Report',
        recordType: 'Lab',
        date: '2026-01-10T10:00:00Z',
        file: AppPlatformFile(
          name: 'report.pdf',
          size: 4,
          bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
        ),
      );

      // 3. Populate visits
      final visitsRepo = FakeVisitsRepository();
      await visitsRepo.addVisit(
        Visit(
          id: 'vis-1',
          userId: 'user-123',
          subjectId: 'user-123',
          profileName: 'Sensitive Patient',
          title: 'Psychiatry Consultation',
          subtitle: 'Clinical review',
          specialty: 'Psychiatry',
          doctorName: 'Dr. Jane',
          hospitalName: 'Mental Health Clinic',
          visitDate: DateTime(2026, 1, 2),
          date: '02/01/2026',
        ),
      );
      VisitsController.resetForTesting(repository: visitsRepo);
      await VisitsController.instance.loadVisits();

      // 4. Populate diet and routine
      DietController().saveDietPlan({'planName': 'Diabetic Regimen'});
      RoutineController().addMedicine({
        'medicineName': 'Metformin',
        'time': '08:00 AM',
      });
    });

    tearDown(() {
      authController.dispose();
      fakeAuth.dispose();
    });

    test(
      'logout() purges memory and persistent cache across all clinical controllers',
      () async {
        // Pre-condition: clinical data is loaded
        expect(RecordsController.instance.records.isNotEmpty, isTrue);
        expect(VisitsController.instance.visits.isNotEmpty, isTrue);
        expect(DietController().hasSavedPlan, isTrue);
        expect(RoutineController().medicines.isNotEmpty, isTrue);

        // Execute logout
        await authController.logout();

        // 1. Auth state is purged
        expect(authController.isAuthenticated, isFalse);
        expect(authController.currentUser, isNull);

        // 2. Profile state and SharedPreferences cache are purged
        expect(ProfileController.instance.profile.name, equals('Not provided'));
        expect(
          ProfileController.instance.profile.email,
          equals('Not provided'),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('cached_profile_id'), isNull);
        expect(prefs.getString('cached_profile_name'), isNull);
        expect(prefs.getString('cached_profile_email'), isNull);
        expect(prefs.getString('last_active_subject_id'), isNull);

        // 3. RecordsController in-memory records are purged
        expect(RecordsController.instance.records, isEmpty);
        expect(RecordsController.instance.filteredRecords, isEmpty);

        // 4. VisitsController in-memory visits are purged
        expect(VisitsController.instance.visits, isEmpty);

        // 5. RoutineController and DietController are purged
        expect(RoutineController().medicines, isEmpty);
        expect(DietController().hasSavedPlan, isFalse);
      },
    );

    test(
      'deleteAccount() purges memory and persistent cache across all clinical controllers',
      () async {
        final result = await authController.deleteAccount(
          passwordConfirm: 'Password123!',
        );
        expect(result.isSuccess, isTrue);

        // All clinical state must be empty
        expect(authController.isAuthenticated, isFalse);
        expect(ProfileController.instance.profile.name, equals('Not provided'));
        expect(
          ProfileController.instance.profile.email,
          equals('Not provided'),
        );
        expect(RecordsController.instance.records, isEmpty);
        expect(VisitsController.instance.visits, isEmpty);
        expect(RoutineController().medicines, isEmpty);
        expect(DietController().hasSavedPlan, isFalse);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('cached_profile_id'), isNull);
      },
    );
  });

  group('SEC-2: File Upload & Path Traversal Prevention', () {
    test(
      'AppValidators.validateMedicalDocument rejects directory traversal in filename',
      () {
        final validBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]); // %PDF

        // Traversal attempts
        final errDotDot = AppValidators.validateMedicalDocument(
          fileName: '../../etc/passwd.pdf',
          byteLength: validBytes.length,
          bytes: validBytes,
        );
        expect(errDotDot, contains('invalid path traversal characters'));

        final errBackslash = AppValidators.validateMedicalDocument(
          fileName: r'..\..\windows\system32.pdf',
          byteLength: validBytes.length,
          bytes: validBytes,
        );
        expect(errBackslash, contains('invalid path traversal characters'));

        final errSlash = AppValidators.validateMedicalDocument(
          fileName: 'subfolder/record.pdf',
          byteLength: validBytes.length,
          bytes: validBytes,
        );
        expect(errSlash, contains('invalid path traversal characters'));
      },
    );

    test(
      'AppValidators.validateMedicalDocument rejects null bytes in filename',
      () {
        final validBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);
        final errNullByte = AppValidators.validateMedicalDocument(
          fileName: 'report.pdf\x00.exe',
          byteLength: validBytes.length,
          bytes: validBytes,
        );
        expect(errNullByte, contains('invalid path traversal characters'));
      },
    );

    test(
      'AppValidators rejects content signature mismatch (file spoofing)',
      () {
        // Disguised executable pretending to be PDF
        final exeBytes = Uint8List.fromList([
          0x4D,
          0x5A,
          0x90,
          0x00,
        ]); // MZ header
        final err = AppValidators.validateMedicalDocument(
          fileName: 'malicious.pdf',
          byteLength: exeBytes.length,
          bytes: exeBytes,
        );
        expect(err, contains('content signature does not match PDF format'));
      },
    );

    test('AppValidators rejects files exceeding 10MB limit', () {
      final validPdfHeader = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);
      final err = AppValidators.validateMedicalDocument(
        fileName: 'huge.pdf',
        byteLength: 10485761, // 10MB + 1 byte
        bytes: validPdfHeader,
      );
      expect(err, contains('exceeds maximum allowed limit of 10.0MB'));
    });

    test(
      'AppPlatformFile.sanitizedName neutralizes path traversal characters',
      () {
        const file = AppPlatformFile(name: '../../sub/evil.pdf', size: 100);
        expect(file.sanitizedName, isNot(contains('/')));
        expect(file.sanitizedName, isNot(contains(r'\')));
        expect(file.sanitizedName, isNot(contains('..')));
        expect(file.sanitizedName, equals('evil.pdf'));
      },
    );

    test(
      'FakeRecordsRepository rejects path traversal in path segments',
      () async {
        final repo = FakeRecordsRepository();
        final file = AppPlatformFile(
          name: 'clean.pdf',
          size: 4,
          bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
        );

        final result = await repo.uploadFile(
          file: file,
          ownerId: '../escape_owner',
          subjectId: 'subject-1',
          recordId: 'rec-1',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.message,
          contains('path traversal detected'),
        );
      },
    );
  });

  group('SEC-3: Safe Logging & Sensitive Data Scrubbing', () {
    test(
      'AppLogger scrubs bearer tokens, secrets, emails, and phone numbers',
      () {
        const sensitiveInput =
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.sig '
            'password: secretPassword123! '
            'token=secretToken_xyz '
            'email: patient.confidential@example.org '
            'phone: +91 9876543210';

        final sanitized = AppLogger.sanitize(sensitiveInput);

        expect(sanitized, isNot(contains('secretPassword123!')));
        expect(sanitized, isNot(contains('secretToken_xyz')));
        expect(sanitized, isNot(contains('patient.confidential@example.org')));
        expect(sanitized, isNot(contains('9876543210')));
        expect(sanitized, contains('[REDACTED_TOKEN]'));
        expect(sanitized, contains('[REDACTED]'));
        expect(sanitized, contains('[REDACTED_EMAIL]'));
        expect(sanitized, contains('[REDACTED_PHONE]'));
      },
    );
  });

  group('SEC-4: Route Guards & Access Control', () {
    testWidgets(
      'Unauthenticated user accessing protected route is redirected to login',
      (tester) async {
        final fakeAuth = FakeAuthRepository();
        AppRouter.authRepository = fakeAuth;

        expect(AppRouter.isAuthenticated, isFalse);

        // Attempt to generate route for protected /home
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.home),
        );

        expect(route.settings.name, equals(AppRouter.login));

        await tester.pumpWidget(
          AppBinding(
            authRepository: fakeAuth,
            child: MaterialApp(
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouter.home,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        fakeAuth.dispose();
      },
    );
  });

  group('SEC-5: Backend Configuration & Fail-Safe Credential Absence', () {
    test(
      'AppConfig.isBackendConfigured is false in local test environment',
      () {
        expect(AppConfig.supabaseUrl, isEmpty);
        expect(AppConfig.supabaseAnonKey, isEmpty);
        expect(AppConfig.isBackendConfigured, isFalse);
      },
    );

    test(
      'SupabaseAuthRepository safely aborts network calls when backend is unconfigured',
      () async {
        final repo = SupabaseAuthRepository();
        final result = await repo.signIn(
          email: 'test@example.com',
          password: 'Password123!',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.failureOrNull?.message,
          contains('Backend is not configured'),
        );
        repo.dispose();
      },
    );
  });
}
