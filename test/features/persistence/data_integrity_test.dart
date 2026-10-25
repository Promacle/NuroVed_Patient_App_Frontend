import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/errors/failures.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/medical_record.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/models/visit.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_visits_repository.dart';
import 'package:nuroved_patient/core/repositories/records_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/core/utils/result.dart';
import 'package:nuroved_patient/features/family/controllers/family_controller.dart';
import 'package:nuroved_patient/features/family/screens/add_family_member_screen.dart';
import 'package:nuroved_patient/features/family/screens/edit_family_member_screen.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';
import 'package:nuroved_patient/features/visits/screens/add_visit_screen.dart';

/// Test repository that can simulate asynchronous delays and exceptions
class DelayableVisitsRepository extends FakeVisitsRepository {
  Completer<Result<Visit>>? saveCompleter;

  DelayableVisitsRepository({super.recordsRepository});

  @override
  Future<Result<Visit>> addVisit(Visit visit) async {
    if (saveCompleter != null) {
      return saveCompleter!.future;
    }
    return super.addVisit(visit);
  }
}

/// Custom fake records repository that throws unexpected exceptions
class ThrowingRecordsRepository implements RecordsRepository {
  bool throwOnUpload = false;
  bool throwOnAddRecord = false;
  final List<String> deletedStorageFiles = [];
  final Map<String, List<int>> storage = {};

  @override
  Future<Result<String>> uploadFile({
    required String ownerId,
    required String subjectId,
    required String recordId,
    required AppPlatformFile file,
    void Function(double progress)? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (throwOnUpload) {
      throw Exception('Simulated network socket connection drop');
    }
    final path = '$ownerId/$subjectId/$recordId/${file.name}';
    storage[path] = file.bytes ?? [];
    onProgress?.call(1.0);
    return Result.success(path);
  }

  @override
  Future<Result<MedicalRecord>> addRecord(MedicalRecord record) async {
    if (throwOnAddRecord) {
      throw Exception('Simulated database write timeout');
    }
    return Result.success(record);
  }

  @override
  Future<Result<void>> deleteStorageFile(String storagePath) async {
    deletedStorageFiles.add(storagePath);
    storage.remove(storagePath);
    return const Result.success(null);
  }

  @override
  Future<Result<List<MedicalRecord>>> getRecords({
    String? subjectId,
    String? profileName,
    String? searchQuery,
    String? recordType,
    RecordSortOrder sortOrder = RecordSortOrder.newestFirst,
  }) async => const Result.success([]);

  @override
  Future<Result<MedicalRecord>> updateRecord(MedicalRecord record) async =>
      Result.success(record);

  @override
  Future<Result<void>> deleteRecord(String recordId) async =>
      const Result.success(null);

  @override
  Future<Result<String>> getSignedUrl(
    String recordId, {
    Duration expiresIn = const Duration(minutes: 15),
  }) async => const Result.success('https://example.com/signed.pdf');
}

/// Profile repository that throws unexpected exceptions
class ThrowingProfileRepository extends FakeProfileRepository {
  bool throwOnUpdate = false;

  ThrowingProfileRepository({super.initialProfile, super.initialFamily});

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    if (throwOnUpdate) {
      throw Exception('Unexpected server crash during profile update');
    }
    return super.updateProfile(profile);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
    0x31, 0x2E, 0x34, 0x0A,
  ]);

  group('AddVisitScreen - Persistence, Async Feedback & Debouncing', () {
    late FakeVisitsRepository fakeVisitsRepo;
    late FakeRecordsRepository fakeRecordsRepo;

    final primaryProfile = const UserProfile(
      id: 'patient-primary-uuid',
      name: 'Primary Patient',
      email: 'patient@example.com',
      phone: '+919876543210',
      dateOfBirth: '1990-01-01',
      gender: 'Male',
      height: '175',
      weight: '70',
      bloodGroup: 'O+',
      allergies: ['Dust'],
      chronicConditions: ['None'],
    );

    final spouseMember = const FamilyMember(
      id: 'member-001',
      name: 'Jane Doe',
      relation: 'Spouse',
      phone: '+919876543211',
      isEmergencyContact: true,
      bloodGroup: 'A+',
    );

    setUp(() {
      fakeRecordsRepo = FakeRecordsRepository();
      fakeVisitsRepo = FakeVisitsRepository(recordsRepository: fakeRecordsRepo);

      ProfileController.resetForTesting(
        repository: FakeProfileRepository(
          initialProfile: primaryProfile,
          initialFamily: [spouseMember],
        ),
        initialProfile: primaryProfile,
        initialFamily: [spouseMember],
      );
      VisitsController.resetForTesting(repository: fakeVisitsRepo);
      RecordsController.resetForTesting(repository: fakeRecordsRepo);
    });

    testWidgets('AddVisitScreen awaits persistence and pops only on success', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const AddVisitScreen()),
                ),
                child: const Text('Launch Visit Screen'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Launch Visit Screen'));
      await tester.pumpAndSettle();

      // Select profile
      await tester.tap(find.text('Profiles'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jane Doe').last);
      await tester.pumpAndSettle();

      // Fill in details
      await tester.ensureVisible(find.text('Visit details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visit details'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Cardiology Checkup');
      await tester.enterText(textFields.at(1), 'Annual heart review');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.ensureVisible(find.text('Save Visit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Visit'));
      await tester.pumpAndSettle();

      // Success feedback displayed and screen popped
      expect(find.text('Doctor visit added successfully!'), findsOneWidget);
      expect(find.text('Launch Visit Screen'), findsOneWidget);
      expect(find.text('Add New Visit'), findsNothing);
    });

    testWidgets(
      'AddVisitScreen preserves form data and shows error feedback when persistence fails',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        // Set repository to fail
        fakeVisitsRepo.shouldFail = true;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const AddVisitScreen()),
                  ),
                  child: const Text('Launch Visit Screen'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Launch Visit Screen'));
        await tester.pumpAndSettle();

        // Select profile
        await tester.tap(find.text('Profiles'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Jane Doe').last);
        await tester.pumpAndSettle();

        // Fill in details
        await tester.ensureVisible(find.text('Visit details'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Visit details'));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'Failed Cardiology Checkup');
        await tester.enterText(textFields.at(1), 'Specialist diagnosis');
        await tester.pumpAndSettle();

        // Tap Save
        await tester.ensureVisible(find.text('Save Visit'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save Visit'));
        await tester.pumpAndSettle();

        // Error message displayed
        expect(find.text('Failed to save visit'), findsOneWidget);

        // Screen is NOT popped!
        expect(find.text('Add New Visit'), findsOneWidget);

        // Form fields preserved for retry
        expect(
          find.widgetWithText(TextField, 'Failed Cardiology Checkup'),
          findsOneWidget,
        );
        expect(find.text('Specialist diagnosis'), findsAtLeastNWidgets(1));

        // Save button is re-enabled
        expect(find.text('Save Visit'), findsOneWidget);
      },
    );

    testWidgets(
      'AddVisitScreen debounces duplicate taps while save is in flight',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final delayableRepo = DelayableVisitsRepository(
          recordsRepository: fakeRecordsRepo,
        );
        delayableRepo.saveCompleter = Completer<Result<Visit>>();
        VisitsController.resetForTesting(repository: delayableRepo);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const AddVisitScreen()),
                  ),
                  child: const Text('Launch Visit Screen'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Launch Visit Screen'));
        await tester.pumpAndSettle();

        // Select profile
        await tester.tap(find.text('Profiles'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Jane Doe').last);
        await tester.pumpAndSettle();

        // Fill in details
        await tester.ensureVisible(find.text('Visit details'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Visit details'));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), 'Flight Checkup');
        await tester.pumpAndSettle();

        // Tap Save
        await tester.ensureVisible(find.text('Save Visit'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save Visit'));
        await tester.pump(); // Advance one frame to start in-flight state

        // Indicator is visible and text 'Save Visit' is replaced
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Save Visit'), findsNothing);

        // Complete save
        delayableRepo.saveCompleter!.complete(
          Result.success(
            Visit(
              id: 'new-id',
              userId: 'u1',
              subjectId: 's1',
              profileName: 'Jane Doe',
              date: '25 October 2026',
              visitDate: DateTime.now(),
              title: 'Flight Checkup',
              subtitle: 'Checkup details',
              createdAt: DateTime.now(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Doctor visit added successfully!'), findsOneWidget);
        expect(find.text('Launch Visit Screen'), findsOneWidget);
      },
    );
  });

  group('Family Profile Forms - Persistence, Async Feedback & Validation', () {
    late FakeProfileRepository profileRepo;

    final primaryProfile = const UserProfile(
      id: 'user-id-1',
      name: 'Primary User',
      email: 'user@example.com',
      phone: '9876543210',
      dateOfBirth: '01/01/1990',
      height: '175',
      weight: '70',
      gender: 'Male',
      bloodGroup: 'O+',
      allergies: [],
      chronicConditions: [],
    );

    final timmyMember = const FamilyMember(
      id: 'member-child',
      name: 'Little Timmy',
      relation: 'Son',
    );

    setUp(() {
      profileRepo = FakeProfileRepository(
        initialProfile: primaryProfile,
        initialFamily: [timmyMember],
      );
      ProfileController.resetForTesting(
        repository: profileRepo,
        initialProfile: primaryProfile,
        initialFamily: [timmyMember],
      );
    });

    testWidgets(
      'AddFamilyMemberScreen pops and shows confirmation on success',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const AddFamilyMemberScreen(),
                    ),
                  ),
                  child: const Text('Open Add Member'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Add Member'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Grandma Rose');
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Add New Profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add New Profile'));
        await tester.pumpAndSettle();

        expect(find.text('Family member added successfully!'), findsOneWidget);
        expect(find.text('Open Add Member'), findsOneWidget);
      },
    );

    testWidgets(
      'AddFamilyMemberScreen handles repository failure without popping and retains input',
      (tester) async {
        profileRepo.shouldFail = true;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const AddFamilyMemberScreen(),
                    ),
                  ),
                  child: const Text('Open Add Member'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Add Member'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Grandma Rose');
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Add New Profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add New Profile'));
        await tester.pumpAndSettle();

        // Failure SnackBar is displayed
        expect(find.text('Failed to add family member'), findsOneWidget);

        // Screen is NOT dismissed
        expect(find.text('Add New Profile'), findsOneWidget);
        expect(find.text('Grandma Rose'), findsOneWidget);
      },
    );

    testWidgets(
      'EditFamilyMemberScreen handles repository failure without popping and retains input',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => EditFamilyMemberScreen(
                        memberData: {
                          'id': 'member-child',
                          'name': 'Little Timmy',
                          'relation': 'Son',
                        },
                        index: 0,
                      ),
                    ),
                  ),
                  child: const Text('Open Edit Member'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Edit Member'));
        await tester.pumpAndSettle();

        // Configure failure before saving
        profileRepo.shouldFail = true;

        await tester.enterText(
          find.byType(TextField).first,
          'Timmy Updated Name',
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Save'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Failure SnackBar is displayed
        expect(find.text('Failed to update family member'), findsOneWidget);

        // Screen remains open with edited content
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Timmy Updated Name'), findsOneWidget);
      },
    );

    test(
      'ProfileController rejects updating family member with empty name',
      () async {
        final ctrl = ProfileController.instance;
        final result = await ctrl.updateFamilyMember(
          FamilyMember(id: 'member-child', name: '   ', relation: 'Son'),
        );

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        expect(
          result.failureOrNull?.message,
          'Family member name cannot be empty',
        );
      },
    );

    test(
      'FamilyController returns ValidationFailure when updating non-existent family member',
      () async {
        final familyCtrl = FamilyController();
        final result = await familyCtrl.updateFamilyMember(
          'non-existent-uuid-999',
          {'name': 'Ghost Member'},
        );

        expect(result.isFailure, isTrue);
        expect(result.failureOrNull, isA<ValidationFailure>());
        expect(result.failureOrNull?.message, 'Family member not found');
      },
    );
  });

  group('RecordsController - Exception Resilience & Storage Cleanliness', () {
    late ThrowingRecordsRepository throwingRepo;
    late RecordsController recordsCtrl;

    final primaryProfile = const UserProfile(
      id: 'owner-uuid-1',
      name: 'Test Owner',
      email: 'owner@example.com',
      phone: '',
      dateOfBirth: '',
      height: '',
      weight: '',
      gender: '',
      bloodGroup: '',
      allergies: [],
      chronicConditions: [],
    );

    setUp(() {
      throwingRepo = ThrowingRecordsRepository();
      ProfileController.resetForTesting(
        repository: FakeProfileRepository(initialProfile: primaryProfile),
        initialProfile: primaryProfile,
      );
      RecordsController.resetForTesting(repository: throwingRepo);
      recordsCtrl = RecordsController.instance;
    });

    test(
      'Resets isUploading to false when repository upload throws unexpected exception',
      () async {
        throwingRepo.throwOnUpload = true;

        final testFile = AppPlatformFile(
          name: 'report.pdf',
          size: pdfBytes.length,
          bytes: pdfBytes,
        );

        final result = await recordsCtrl.uploadAndSaveRecord(
          title: 'Blood Test',
          recordType: 'Lab Report',
          date: '2026-10-25',
          file: testFile,
        );

        expect(result.isFailure, isTrue);
        expect(recordsCtrl.isUploading, isFalse);
        expect(
          recordsCtrl.uploadError,
          contains('Simulated network socket connection drop'),
        );
      },
    );

    test(
      'Deletes orphaned storage file when record persistence throws unexpected exception',
      () async {
        throwingRepo.throwOnUpload = false;
        throwingRepo.throwOnAddRecord = true;

        final testFile = AppPlatformFile(
          name: 'prescription.pdf',
          size: pdfBytes.length,
          bytes: pdfBytes,
        );

        final result = await recordsCtrl.uploadAndSaveRecord(
          title: 'Prescription Doc',
          recordType: 'Prescription',
          date: '2026-10-25',
          file: testFile,
        );

        expect(result.isFailure, isTrue);
        expect(recordsCtrl.isUploading, isFalse);

        // Orphaned storage file must have been cleaned up
        expect(throwingRepo.deletedStorageFiles.length, 1);
        expect(
          throwingRepo.deletedStorageFiles.first,
          contains('prescription.pdf'),
        );
        expect(throwingRepo.storage.isEmpty, isTrue);
      },
    );

    test(
      'Permits subsequent upload attempts after an initial failure',
      () async {
        throwingRepo.throwOnUpload = true;

        final testFile = AppPlatformFile(
          name: 'scan.pdf',
          size: pdfBytes.length,
          bytes: pdfBytes,
        );

        // First attempt fails
        final firstResult = await recordsCtrl.uploadAndSaveRecord(
          title: 'MRI Scan',
          recordType: 'Scan',
          date: '2026-10-25',
          file: testFile,
        );
        expect(firstResult.isFailure, isTrue);
        expect(recordsCtrl.isUploading, isFalse);

        // Resolve failure condition
        throwingRepo.throwOnUpload = false;

        // Second attempt succeeds immediately without being locked out
        final secondResult = await recordsCtrl.uploadAndSaveRecord(
          title: 'MRI Scan',
          recordType: 'Scan',
          date: '2026-10-25',
          file: testFile,
        );
        expect(secondResult.isSuccess, isTrue);
        expect(recordsCtrl.isUploading, isFalse);
        expect(recordsCtrl.records.length, 1);
      },
    );
  });

  group('ProfileController - State Consistency & Optimistic Rollback', () {
    late ThrowingProfileRepository throwingProfileRepo;
    late ProfileController profileCtrl;

    final originalProfile = const UserProfile(
      id: 'user-stable-uuid',
      name: 'Original Patient Name',
      email: 'patient@example.com',
      phone: '1112223333',
      dateOfBirth: '15/05/1985',
      height: '180',
      weight: '75',
      gender: 'Male',
      bloodGroup: 'A+',
      allergies: [],
      chronicConditions: [],
    );

    setUp(() {
      throwingProfileRepo = ThrowingProfileRepository(
        initialProfile: originalProfile,
      );
      ProfileController.resetForTesting(
        repository: throwingProfileRepo,
        initialProfile: originalProfile,
      );
      profileCtrl = ProfileController.instance;
    });

    test(
      'Rolls back in-memory profile state when repository update throws unexpected exception',
      () async {
        throwingProfileRepo.throwOnUpdate = true;

        final modifiedProfile = profileCtrl.profile.copyWith(
          name: 'Unsaved Mutated Name',
          phone: '9999999999',
        );

        final result = await profileCtrl.updateProfile(modifiedProfile);

        expect(result.isFailure, isTrue);

        // In-memory state rolled back cleanly
        expect(profileCtrl.profile.name, 'Original Patient Name');
        expect(profileCtrl.profile.phone, '1112223333');
      },
    );
  });
}
