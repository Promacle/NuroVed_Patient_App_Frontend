import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/medicine_routine.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_visits_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
    0x31, 0x2E, 0x34, 0x0A,
  ]);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Critical Journeys Integration Tests', () {
    late FakeAuthRepository fakeAuth;
    late FakeProfileRepository fakeProfile;
    late FakeRecordsRepository fakeRecords;
    late FakeVisitsRepository fakeVisits;

    late AuthController authCtrl;
    late ProfileController profileCtrl;
    late RecordsController recordsCtrl;
    late VisitsController visitsCtrl;
    late RoutineController routineCtrl;

    setUp(() {
      fakeAuth = FakeAuthRepository();
      fakeProfile = FakeProfileRepository();
      fakeRecords = FakeRecordsRepository();
      fakeVisits = FakeVisitsRepository(recordsRepository: fakeRecords);

      authCtrl = AuthController(authRepository: fakeAuth);
      AppRouter.authRepository = fakeAuth;

      ProfileController.resetForTesting(repository: fakeProfile);
      profileCtrl = ProfileController.instance;

      RecordsController.resetForTesting(repository: fakeRecords);
      recordsCtrl = RecordsController.instance;

      VisitsController.resetForTesting(repository: fakeVisits, empty: true);
      visitsCtrl = VisitsController.instance;

      RoutineController.resetForTesting();
      routineCtrl = RoutineController();
    });

    tearDown(() {
      authCtrl.dispose();
      fakeAuth.dispose();
    });

    test(
      'End-to-End Critical Journey: Signup -> Login -> Add Profile -> Switch -> Upload Record -> Create Visit -> Routine -> Timeline -> Logout',
      () async {
        // -------------------------------------------------------------
        // JOURNEY 1: SIGNUP
        // -------------------------------------------------------------
        // Step 1: Attempt signup without agreeing to terms -> fails
        authCtrl.emailController.text = 'patient.one@example.com';
        authCtrl.passwordController.text = 'ValidPassword123!';
        authCtrl.confirmPasswordController.text = 'ValidPassword123!';
        expect(authCtrl.validateStepOne(), isTrue);

        authCtrl.nameController.text = 'Patient One';
        authCtrl.phoneController.text = '+91 91234 56789';
        authCtrl.dobController.text = '15/06/1985';
        authCtrl.setSelectedGender('Male');
        authCtrl.setAcknowledgedTerms(false);

        final termsFail = await authCtrl.completeSignUp();
        expect(termsFail, isFalse);
        expect(authCtrl.errorMessage, contains('terms and conditions'));

        // Step 2: Valid signup with terms acknowledged
        authCtrl.setAcknowledgedTerms(true);
        final signupSuccess = await authCtrl.completeSignUp();
        expect(signupSuccess, isTrue);
        expect(authCtrl.isAuthenticated, isTrue);
        expect(authCtrl.currentUser?.email, equals('patient.one@example.com'));

        // -------------------------------------------------------------
        // JOURNEY 2: LOGOUT & LOGIN
        // -------------------------------------------------------------
        await authCtrl.logout();
        expect(authCtrl.isAuthenticated, isFalse);
        expect(authCtrl.currentUser, isNull);

        // Attempt login with invalid password
        authCtrl.emailController.text = 'patient.one@example.com';
        authCtrl.passwordController.text = 'wrongPassword';
        final badLogin = await authCtrl.signIn();
        expect(badLogin, isFalse);
        expect(authCtrl.isAuthenticated, isFalse);
        expect(authCtrl.errorMessage, contains('Invalid email or password'));

        // Login with correct credentials
        authCtrl.passwordController.text = 'ValidPassword123!';
        final goodLogin = await authCtrl.signIn();
        expect(goodLogin, isTrue);
        expect(authCtrl.isAuthenticated, isTrue);
        expect(authCtrl.currentUser?.name, equals('Patient One'));

        // Sync active profile with authenticated user
        await profileCtrl.updateProfile(
          profileCtrl.profile.copyWith(
            id: authCtrl.currentUser!.id,
            name: authCtrl.currentUser!.name,
            email: authCtrl.currentUser!.email,
          ),
        );
        profileCtrl.switchSubjectToSelf();
        expect(profileCtrl.profile.id, equals(authCtrl.currentUser!.id));

        // -------------------------------------------------------------
        // JOURNEY 3: ADD FAMILY PROFILE & SWITCH ACTIVE SUBJECT
        // -------------------------------------------------------------
        expect(profileCtrl.isMainPatientActive, isTrue);
        final initialSubjectId = profileCtrl.activeSubjectId;

        // Add family member (Father) with stable UUID
        final addFamilySuccess = await profileCtrl.addFamilyMember(
          const FamilyMember(
            id: '',
            name: 'Father Test',
            relation: 'Father',
            phone: '+91 98888 77777',
          ),
        );
        expect(addFamilySuccess.isSuccess, isTrue);
        expect(profileCtrl.familyMembersList.length, equals(1));
        final dadMember = profileCtrl.familyMembersList.first;
        expect(dadMember.id.isNotEmpty, isTrue);
        expect(dadMember.name, equals('Father Test'));

        // Switch active subject to Father
        profileCtrl.switchSubject(dadMember.id);
        expect(profileCtrl.isMainPatientActive, isFalse);
        expect(profileCtrl.activeSubjectId, equals(dadMember.id));
        expect(profileCtrl.activeProfileName, equals('Father Test'));

        // -------------------------------------------------------------
        // JOURNEY 4: UPLOAD RECORD (SUBJECT ISOLATION)
        // -------------------------------------------------------------
        // Upload record for Dad
        final uploadSuccess = await recordsCtrl.uploadAndSaveRecord(
          title: 'Dad HbA1c Lab Report',
          recordType: 'Lab Report',
          date: '2026-03-01T08:30:00Z',
          file: AppPlatformFile(
            name: 'dad_hba1c.pdf',
            size: pdfBytes.length,
            bytes: pdfBytes,
          ),
          doctorName: 'Dr. Mehta',
          hospitalName: 'Apollo Clinic',
        );
        expect(uploadSuccess.isSuccess, isTrue);
        expect(recordsCtrl.records.length, equals(1));
        final dadRecord = recordsCtrl.records.first;
        expect(dadRecord.subjectId, equals(dadMember.id));
        expect(dadRecord.title, equals('Dad HbA1c Lab Report'));

        // Verify signed URL retrieval
        final signedUrl = await recordsCtrl.getSignedUrl(dadRecord.id);
        expect(signedUrl.isSuccess, isTrue);
        expect(signedUrl.dataOrNull, contains('fake_signed'));

        // Switch back to Main Patient: Records for Main Patient must be empty
        profileCtrl.switchSubject(initialSubjectId);
        await recordsCtrl.loadRecords();
        expect(
          recordsCtrl.records,
          isEmpty,
          reason: 'Records must be isolated per subject',
        );

        // Switch back to Dad: Record reloads cleanly
        profileCtrl.switchSubject(dadMember.id);
        await recordsCtrl.loadRecords();
        expect(recordsCtrl.records.length, equals(1));

        // -------------------------------------------------------------
        // JOURNEY 5: CREATE VISIT & CANONICAL RECORD LINKING
        // -------------------------------------------------------------
        final visitSuccess = await visitsCtrl.addVisit({
          'title': 'Endocrinology Consultation',
          'subtitle': 'Quarterly Diabetes Review',
          'doctorName': 'Dr. Mehta',
          'specialty': 'Endocrinologist',
          'hospitalName': 'Apollo Clinic',
          'date': '2026-03-01T10:00:00Z',
          'notes': 'HbA1c stable at 6.8%. Continue current regimen.',
          'relatedRecordIds': [
            dadRecord.id,
            dadRecord.id,
          ], // duplicate intentional to test deduplication
        });
        expect(visitSuccess.isSuccess, isTrue);
        expect(visitsCtrl.visits.length, equals(1));
        final dadVisit = visitsCtrl.visits.first;
        expect(dadVisit.subjectId, equals(dadMember.id));
        // Canonical record IDs deduplicated
        expect(dadVisit.relatedRecordIds, equals([dadRecord.id]));

        // -------------------------------------------------------------
        // JOURNEY 6: MEDICINE ROUTINE & ADHERENCE PROGRESS
        // -------------------------------------------------------------
        // For Dad, routines start clean
        expect(routineCtrl.medicines, isEmpty);
        expect(routineCtrl.progress, equals(0.0));

        // Add self-entered medication routine
        routineCtrl.addMedicine({
          'name': 'Metformin 500mg',
          'dosage': '1 tablet twice daily',
          'time': '08:00 AM',
          'instruction': 'Take after meals',
          'source': RoutineSource.selfEntered.name,
        });
        expect(routineCtrl.medicines.length, equals(1));
        final routine = routineCtrl.medicines.first;
        expect(routine['source'], equals(RoutineSource.selfEntered.name));
        expect(routine['source_display'], equals('Self-Entered'));
        expect(
          routine['dosage'],
          equals('1 tablet twice daily'),
        ); // Exact dosage preserved
        expect(routineCtrl.progress, equals(0.0));
        expect(routineCtrl.progressText, equals('0/1 Completed'));

        // Toggle routine completion
        routineCtrl.toggleMedicine(0);
        expect(routineCtrl.medicines.first['isCompleted'], isTrue);
        expect(routineCtrl.progress, equals(1.0));
        expect(routineCtrl.progressText, equals('1/1 Completed'));

        // -------------------------------------------------------------
        // JOURNEY 7: VIEW TIMELINE (CHRONOLOGICAL MERGING & ISOLATION)
        // -------------------------------------------------------------
        final timeline = visitsCtrl.getTimelineItems(
          recordsController: recordsCtrl,
        );
        expect(timeline.length, equals(2));
        // Visit at 10:00 is newer than Record at 08:30 -> Visit first, then Record
        expect(timeline[0].type, equals(TimelineItemType.visit));
        expect(timeline[0].title, equals('Endocrinology Consultation'));
        expect(timeline[1].type, equals(TimelineItemType.record));
        expect(timeline[1].title, equals('Dad HbA1c Lab Report'));

        // Switch to main patient -> Dad's timeline events do not leak
        profileCtrl.switchSubject(initialSubjectId);
        await visitsCtrl.loadVisits();
        await recordsCtrl.loadRecords();
        final mainTimeline = visitsCtrl.getTimelineItems(
          recordsController: recordsCtrl,
        );
        expect(mainTimeline, isEmpty);

        // Switch back to Dad -> timeline events intact
        profileCtrl.switchSubject(dadMember.id);
        await visitsCtrl.loadVisits();
        await recordsCtrl.loadRecords();
        final dadTimeline = visitsCtrl.getTimelineItems(
          recordsController: recordsCtrl,
        );
        expect(dadTimeline.length, equals(2));

        // -------------------------------------------------------------
        // JOURNEY 8: LOGOUT & ROUTE GUARD PROTECTION
        // -------------------------------------------------------------
        await authCtrl.logout();
        expect(authCtrl.isAuthenticated, isFalse);
        expect(authCtrl.currentUser, isNull);

        // Route Guard redirects unauthenticated access away from protected routes to login
        final homeRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.home),
        );
        expect(homeRoute.settings.name, equals(AppRouter.login));

        final recordsRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.records),
        );
        expect(recordsRoute.settings.name, equals(AppRouter.login));

        final visitsRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.visits),
        );
        expect(visitsRoute.settings.name, equals(AppRouter.login));

        // Public routes remain accessible
        final loginRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.login),
        );
        expect(loginRoute.settings.name, equals(AppRouter.login));

        final signupRoute = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.signup),
        );
        expect(signupRoute.settings.name, equals(AppRouter.signup));
      },
    );
  });
}
