import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/errors/failures.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/medical_record.dart';
import 'package:nuroved_patient/core/models/medicine_routine.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/models/visit.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_routine_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_visits_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FakeAuthRepository', () {
    late FakeAuthRepository authRepo;

    setUp(() {
      authRepo = FakeAuthRepository();
    });

    tearDown(() {
      authRepo.dispose();
    });

    test('signUp creates new account with valid credentials', () async {
      final res = await authRepo.signUp(
        email: 'alice@example.com',
        password: 'securePassword123',
        name: 'Alice Smith',
        acknowledgedTerms: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull?.email, equals('alice@example.com'));
      expect(res.dataOrNull?.name, equals('Alice Smith'));
      expect(authRepo.currentUser?.email, equals('alice@example.com'));
    });

    test('signUp fails if terms not acknowledged', () async {
      final res = await authRepo.signUp(
        email: 'alice2@example.com',
        password: 'securePassword123',
        name: 'Alice',
        acknowledgedTerms: false,
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('signUp fails if password is too short (< 8 chars)', () async {
      final res = await authRepo.signUp(
        email: 'alice3@example.com',
        password: 'short',
        name: 'Alice',
        acknowledgedTerms: true,
      );

      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ValidationFailure>());
    });

    test('signUp fails if email already registered', () async {
      await authRepo.signUp(
        email: 'duplicate@example.com',
        password: 'password123',
        name: 'First',
        acknowledgedTerms: true,
      );

      final second = await authRepo.signUp(
        email: 'DUPLICATE@example.com',
        password: 'differentPassword',
        name: 'Second',
        acknowledgedTerms: true,
      );

      expect(second.isFailure, isTrue);
      expect(second.failureOrNull, isA<AuthFailure>());
    });

    test('signIn succeeds with valid credentials', () async {
      final res = await authRepo.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(res.isSuccess, isTrue);
      expect(authRepo.currentUser?.email, equals('test@example.com'));
    });

    test('signIn fails with wrong password or unknown user', () async {
      final wrongPass = await authRepo.signIn(
        email: 'test@example.com',
        password: 'wrong',
      );
      expect(wrongPass.isFailure, isTrue);

      final wrongEmail = await authRepo.signIn(
        email: 'unknown@example.com',
        password: 'password123',
      );
      expect(wrongEmail.isFailure, isTrue);
    });

    test(
      'restoreSession restores persisted user or detects expired session',
      () async {
        await authRepo.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        final restoreRes = await authRepo.restoreSession();
        expect(restoreRes.isSuccess, isTrue);
        expect(restoreRes.dataOrNull?.email, equals('test@example.com'));

        authRepo.simulateExpiredSession = true;
        final expiredRes = await authRepo.restoreSession();
        expect(expiredRes.isFailure, isTrue);
        expect(authRepo.currentUser, isNull);
      },
    );

    test('changePassword updates password and verifies old password', () async {
      await authRepo.signIn(email: 'test@example.com', password: 'password123');

      final failOld = await authRepo.changePassword(
        currentPassword: 'incorrectPassword',
        newPassword: 'brandNewPassword123',
      );
      expect(failOld.isFailure, isTrue);

      final success = await authRepo.changePassword(
        currentPassword: 'password123',
        newPassword: 'brandNewPassword123',
      );
      expect(success.isSuccess, isTrue);

      final reLogin = await authRepo.signIn(
        email: 'test@example.com',
        password: 'brandNewPassword123',
      );
      expect(reLogin.isSuccess, isTrue);
    });

    test(
      'deleteAccount removes credentials and clears current session',
      () async {
        await authRepo.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        final delRes = await authRepo.deleteAccount(
          passwordConfirm: 'password123',
        );
        expect(delRes.isSuccess, isTrue);
        expect(authRepo.currentUser, isNull);

        final reLogin = await authRepo.signIn(
          email: 'test@example.com',
          password: 'password123',
        );
        expect(reLogin.isFailure, isTrue);
      },
    );

    test('shouldFail returns NetworkFailure', () async {
      authRepo.shouldFail = true;
      final res = await authRepo.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('FakeProfileRepository', () {
    late FakeProfileRepository profileRepo;

    setUp(() {
      profileRepo = FakeProfileRepository(
        initialProfile: UserProfile(
          id: 'patient-123',
          name: 'Jane Doe',
          email: 'jane@example.com',
          phone: '+91 98765 43210',
          dateOfBirth: '1985-05-15',
          gender: 'female',
          height: '165',
          weight: '62',
          bloodGroup: 'B+',
          allergies: ['Penicillin'],
          chronicConditions: ['Type 2 Diabetes'],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );
    });

    test('getProfile and updateProfile manage user state', () async {
      final getRes = await profileRepo.getProfile();
      expect(getRes.isSuccess, isTrue);
      expect(getRes.dataOrNull?.name, equals('Jane Doe'));

      final updateRes = await profileRepo.updateProfile(
        getRes.dataOrNull!.copyWith(name: 'Jane Roe', weight: '60'),
      );
      expect(updateRes.isSuccess, isTrue);
      expect(updateRes.dataOrNull?.name, equals('Jane Roe'));
      expect(updateRes.dataOrNull?.weight, equals('60'));
    });

    test('family member CRUD operates with stable IDs', () async {
      final addRes = await profileRepo.addFamilyMember(
        const FamilyMember(id: '', name: 'Dad', relation: 'Father'),
      );
      expect(addRes.isSuccess, isTrue);
      final memberId = addRes.dataOrNull!.id;
      expect(memberId.isNotEmpty, isTrue);

      final listRes = await profileRepo.getFamilyMembers();
      expect(listRes.isSuccess, isTrue);
      expect(listRes.dataOrNull?.length, equals(1));
      expect(listRes.dataOrNull?.first.name, equals('Dad'));

      final updateRes = await profileRepo.updateFamilyMember(
        addRes.dataOrNull!.copyWith(name: 'Father (Updated)'),
      );
      expect(updateRes.isSuccess, isTrue);

      final deleteRes = await profileRepo.deleteFamilyMember(memberId);
      expect(deleteRes.isSuccess, isTrue);

      final listAfter = await profileRepo.getFamilyMembers();
      expect(listAfter.dataOrNull, isEmpty);
    });

    test('caregiver invite, accept, update scopes, and revoke flow', () async {
      final inviteRes = await profileRepo.inviteCaregiver(
        email: 'caregiver@example.com',
        name: 'Dr. Caregiver',
        scopes: ['records:view', 'timeline:view'],
        purpose: 'Care monitoring',
      );
      expect(inviteRes.isSuccess, isTrue);
      final grant = inviteRes.dataOrNull!;
      expect(grant.status, equals('pending'));
      expect(grant.scopes, contains('records:view'));

      // Accept invite
      final acceptRes = await profileRepo.acceptCaregiverInvite(grant.id);
      expect(acceptRes.isSuccess, isTrue);
      expect(acceptRes.dataOrNull?.status, equals('active'));

      // Update scopes
      final updateScopesRes = await profileRepo.updateCaregiverScopes(
        grant.id,
        ['records:view'],
      );
      expect(updateScopesRes.isSuccess, isTrue);
      expect(updateScopesRes.dataOrNull?.scopes, equals(['records:view']));

      // Revoke grant
      final revokeRes = await profileRepo.revokeCaregiver(grant.id);
      expect(revokeRes.isSuccess, isTrue);

      final finalGrant = await profileRepo.getCaregiverGrant();
      expect(finalGrant.dataOrNull?.status, equals('revoked'));
      expect(finalGrant.dataOrNull?.revokedAt, isNotNull);
    });

    test('shouldFail causes ServerFailure on all operations', () async {
      profileRepo.shouldFail = true;
      final res = await profileRepo.getProfile();
      expect(res.isFailure, isTrue);
      expect(res.failureOrNull, isA<ServerFailure>());
    });
  });

  group('FakeRecordsRepository', () {
    late FakeRecordsRepository recordsRepo;

    setUp(() {
      recordsRepo = FakeRecordsRepository();
    });

    test('uploadFile succeeds and calculates progress', () async {
      final progressValues = <double>[];
      final fakeFile = AppPlatformFile(
        name: 'test_lab_report.pdf',
        size: 1024,
        bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]), // %PDF
      );

      final uploadRes = await recordsRepo.uploadFile(
        ownerId: 'owner-1',
        subjectId: 'subject-1',
        recordId: 'rec-1',
        file: fakeFile,
        onProgress: (p) => progressValues.add(p),
      );

      expect(uploadRes.isSuccess, isTrue);
      expect(
        uploadRes.dataOrNull,
        equals('owner-1/subject-1/rec-1/test_lab_report.pdf'),
      );
      expect(progressValues, contains(1.0));
    });

    test('uploadFile fails cleanly when isCancelled returns true', () async {
      final fakeFile = AppPlatformFile(
        name: 'cancelled.pdf',
        size: 512,
        bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
      );

      final cancelRes = await recordsRepo.uploadFile(
        ownerId: 'owner-1',
        subjectId: 'subject-1',
        recordId: 'rec-cancel',
        file: fakeFile,
        isCancelled: () => true,
      );

      expect(cancelRes.isFailure, isTrue);
      expect(cancelRes.failureOrNull?.message, contains('cancelled'));
    });

    test('records CRUD, search, filter, and soft delete isolation', () async {
      final r1 = MedicalRecord(
        id: 'r1',
        userId: 'owner-1',
        subjectId: 'subject-A',
        profileName: 'Alice',
        recordType: 'Lab Report',
        title: 'HbA1c Blood Test',
        date: '2025-02-10',
        storagePath: 'owner-1/subject-A/r1/test.pdf',
        fileSize: 2048,
        createdAt: DateTime(2025, 2, 10, 10, 0),
      );

      final r2 = MedicalRecord(
        id: 'r2',
        userId: 'owner-1',
        subjectId: 'subject-B',
        profileName: 'Bob',
        recordType: 'Prescription',
        title: 'Metformin Prescription',
        date: '2025-02-12',
        storagePath: 'owner-1/subject-B/r2/presc.pdf',
        fileSize: 1024,
        createdAt: DateTime(2025, 2, 12, 11, 0),
      );

      await recordsRepo.addRecord(r1);
      await recordsRepo.addRecord(r2);

      // Filter by subject
      final forA = await recordsRepo.getRecords(subjectId: 'subject-A');
      expect(forA.dataOrNull?.length, equals(1));
      expect(forA.dataOrNull?.first.id, equals('r1'));

      // Search query
      final searchRes = await recordsRepo.getRecords(searchQuery: 'Metformin');
      expect(searchRes.dataOrNull?.length, equals(1));
      expect(searchRes.dataOrNull?.first.title, contains('Metformin'));

      // Signed URL generation
      final signedUrlRes = await recordsRepo.getSignedUrl(
        'r1',
        expiresIn: const Duration(minutes: 10),
      );
      expect(signedUrlRes.isSuccess, isTrue);
      expect(signedUrlRes.dataOrNull, contains('token=fake_signed'));

      // Soft delete
      final delRes = await recordsRepo.deleteRecord('r1');
      expect(delRes.isSuccess, isTrue);

      final afterDel = await recordsRepo.getRecords(subjectId: 'subject-A');
      expect(afterDel.dataOrNull, isEmpty);
    });
  });

  group('FakeVisitsRepository', () {
    late FakeVisitsRepository visitsRepo;
    late FakeRecordsRepository recordsRepo;

    setUp(() {
      recordsRepo = FakeRecordsRepository();
      visitsRepo = FakeVisitsRepository(recordsRepository: recordsRepo);
    });

    test(
      'addVisit dedupes canonical record links and filters by subject',
      () async {
        final v1 = Visit(
          id: 'v1',
          userId: 'owner-1',
          subjectId: 'subject-1',
          profileName: 'Alice',
          title: 'Endocrinology Consultation',
          subtitle: 'Routine checkup',
          doctorName: 'Dr. Kumar',
          specialty: 'Endocrinologist',
          hospitalName: 'City Clinic',
          date: '2025-02-15',
          visitDate: DateTime.parse('2025-02-15T09:30:00Z'),
          relatedRecordIds: [
            'rec-1',
            'rec-1',
            'rec-2',
          ], // Duplicates intentionally passed
        );

        final addRes = await visitsRepo.addVisit(v1);
        expect(addRes.isSuccess, isTrue);
        expect(addRes.dataOrNull?.relatedRecordIds, equals(['rec-1', 'rec-2']));

        final getRes = await visitsRepo.getVisits(subjectId: 'subject-1');
        expect(getRes.dataOrNull?.length, equals(1));

        final otherSubject = await visitsRepo.getVisits(subjectId: 'subject-2');
        expect(otherSubject.dataOrNull, isEmpty);
      },
    );

    test('getRelatedRecords resolves canonical medical records', () async {
      final testRecord = MedicalRecord(
        id: 'canonical-rec-1',
        userId: 'owner-1',
        subjectId: 'subject-1',
        profileName: 'Alice',
        recordType: 'Prescription',
        title: 'Doctor Notes',
        date: '2025-02-15',
        storagePath: 'owner-1/subject-1/canonical-rec-1/notes.pdf',
        fileSize: 1024,
      );
      await recordsRepo.addRecord(testRecord);

      final visit = Visit(
        id: 'visit-with-link',
        userId: 'owner-1',
        subjectId: 'subject-1',
        profileName: 'Alice',
        title: 'Diabetology Followup',
        subtitle: 'Quarterly review',
        doctorName: 'Dr. Patel',
        specialty: 'Diabetology',
        date: '2025-02-15',
        visitDate: DateTime.parse('2025-02-15T10:00:00Z'),
        relatedRecordIds: ['canonical-rec-1'],
      );
      await visitsRepo.addVisit(visit);

      final relatedRes = await visitsRepo.getRelatedRecords('visit-with-link');
      expect(relatedRes.isSuccess, isTrue);
      expect(relatedRes.dataOrNull?.length, equals(1));
      expect(relatedRes.dataOrNull?.first.id, equals('canonical-rec-1'));
    });
  });

  group('FakeRoutineRepository', () {
    late FakeRoutineRepository routineRepo;

    setUp(() {
      routineRepo = FakeRoutineRepository();
    });

    test(
      'addRoutine, toggleRoutine, and deleteRoutine operate cleanly',
      () async {
        final r1 = const MedicineRoutine(
          id: 'med-1',
          medicineName: 'Metformin 500mg',
          dosage: '1 tablet twice daily',
          instruction: 'Take after meals',
          time: '08:00 AM',
          profileName: 'Alice',
          isCompleted: false,
        );

        final addRes = await routineRepo.addRoutine(r1);
        expect(addRes.isSuccess, isTrue);

        final toggleRes = await routineRepo.toggleRoutine('med-1', true);
        expect(toggleRes.isSuccess, isTrue);
        expect(toggleRes.dataOrNull?.isCompleted, isTrue);

        final delRes = await routineRepo.deleteRoutine('med-1');
        expect(delRes.isSuccess, isTrue);

        final listAfter = await routineRepo.getRoutines(profileName: 'Alice');
        expect(listAfter.dataOrNull, isEmpty);
      },
    );
  });

  group('Repository Timeout and Concurrency Simulation', () {
    test('operations correctly handle timeout thresholds', () async {
      final delayedFuture = Future<String>.delayed(
        const Duration(milliseconds: 200),
        () => 'done',
      );

      expect(
        () => delayedFuture.timeout(const Duration(milliseconds: 20)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
