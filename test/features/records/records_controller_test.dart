import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRecordsRepository fakeRepo;
  late RecordsController controller;
  late ProfileController profileController;

  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
    0x31, 0x2E, 0x34, 0x0A,
  ]);

  setUp(() {
    ProfileController.resetForTesting(repository: FakeProfileRepository());
    profileController = ProfileController.instance;

    fakeRepo = FakeRecordsRepository();
    RecordsController.resetForTesting(repository: fakeRepo);
    controller = RecordsController.instance;
  });

  group('RecordsController Upload Pipeline', () {
    test('uploads file, reports progress, and persists metadata upon success', () async {
      final file = AppPlatformFile(
        name: 'hba1c_report.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );

      final result = await controller.uploadAndSaveRecord(
        title: 'HbA1c Lab Report',
        recordType: 'Lab',
        date: '2026-01-10T10:00:00Z',
        doctorName: 'Dr. Mehta',
        hospitalName: 'Apollo Hospital',
        description: 'HbA1c level 6.8%',
        file: file,
      );

      expect(result.isSuccess, isTrue);
      final created = result.dataOrNull!;
      expect(created.title, 'HbA1c Lab Report');
      expect(created.recordType, 'Lab');
      expect(created.storagePath, isNotNull);
      expect(created.storagePath, contains('hba1c_report.pdf'));
      expect(created.fileSize, pdfBytes.length);

      // Confirm persisted in controller
      expect(controller.records.any((r) => r.id == created.id), isTrue);
      expect(controller.isUploading, isFalse);
      expect(controller.uploadProgress, 1.0);
    });

    test('protects against duplicate upload submission', () async {
      final file = AppPlatformFile(
        name: 'report.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );

      // Artificially start an upload and simulate in-flight collision
      fakeRepo.uploadDelayMs = 100;
      final future1 = controller.uploadAndSaveRecord(
        title: 'Upload 1',
        recordType: 'Lab',
        date: '2026-01-10',
        file: file,
      );

      // Second upload initiated while first is in progress
      final result2 = await controller.uploadAndSaveRecord(
        title: 'Upload 2',
        recordType: 'Lab',
        date: '2026-01-10',
        file: file,
      );

      expect(result2.isFailure, isTrue);
      expect(result2.failureOrNull!.message, contains('already in progress'));

      await future1;
    });

    test('cleans up orphaned storage object when metadata save fails', () async {
      fakeRepo.shouldFailRecordSave = true;

      final file = AppPlatformFile(
        name: 'corrupt_metadata.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );

      final result = await controller.uploadAndSaveRecord(
        title: 'Failing Record',
        recordType: 'Medical Records',
        date: '2026-01-10',
        file: file,
      );

      expect(result.isFailure, isTrue);
      // Storage file must be cleaned up (no orphaned files left)
      expect(fakeRepo.storageFiles.isEmpty, isTrue);
      expect(controller.isUploading, isFalse);
    });

    test('cancels in-flight upload on user cancellation', () async {
      fakeRepo.uploadDelayMs = 200;

      final file = AppPlatformFile(
        name: 'large_scan.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );

      final uploadFuture = controller.uploadAndSaveRecord(
        title: 'Scan',
        recordType: 'Lab',
        date: '2026-01-10',
        file: file,
      );

      // Cancel mid-way
      controller.cancelUpload();
      final result = await uploadFuture;

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull!.message, contains('cancelled'));
      expect(controller.isUploading, isFalse);
    });
  });

  group('RecordsController Retrieval & Signed URLs', () {
    test('fetches short-lived signed URL for storage path', () async {
      final file = AppPlatformFile(
        name: 'test_doc.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );

      final result = await controller.uploadAndSaveRecord(
        title: 'Test Doc',
        recordType: 'Lab',
        date: '2026-01-10',
        file: file,
      );

      final record = result.dataOrNull!;
      final signedUrlResult = await controller.getSignedUrl(record.storagePath!);

      expect(signedUrlResult.isSuccess, isTrue);
      final signedUrl = signedUrlResult.dataOrNull!;
      expect(signedUrl, contains('token='));
      expect(signedUrl, contains(record.storagePath!));
    });
  });

  group('RecordsController Filtering, Search, and Soft Delete', () {
    setUp(() async {
      // Seed records
      for (int i = 1; i <= 3; i++) {
        final file = AppPlatformFile(
          name: 'doc_$i.pdf',
          size: pdfBytes.length,
          bytes: pdfBytes,
        );
        await controller.uploadAndSaveRecord(
          title: i == 1 ? 'Sugar Test' : (i == 2 ? 'Hospital Bill' : 'CBC Lab'),
          recordType: i == 1 ? 'Lab' : (i == 2 ? 'Bills' : 'Lab'),
          date: '2026-01-0$i',
          file: file,
        );
      }
    });

    test('filters records by type chip', () async {
      controller.setFilter('Bills');
      await controller.loadRecords();

      expect(controller.records.length, 1);
      expect(controller.records.first.title, 'Hospital Bill');

      controller.setFilter('All');
      await controller.loadRecords();
      expect(controller.records.length, 3);
    });

    test('searches records by query keyword', () async {
      await controller.loadRecords('Sugar');
      expect(controller.records.length, 1);
      expect(controller.records.first.title, 'Sugar Test');
    });

    test('soft delete sets deletedAt and removes record from active view', () async {
      final target = controller.records.first;
      final delResult = await controller.softDeleteRecord(target.id);

      expect(delResult.isSuccess, isTrue);
      expect(controller.records.any((r) => r.id == target.id), isFalse);

      // Confirm in repo internal list that deletedAt is populated
      final inRepo = fakeRepo.internalRecords.firstWhere((r) => r.id == target.id);
      expect(inRepo.isDeleted, isTrue);
      expect(inRepo.deletedAt, isNotNull);
    });
  });

  group('RecordsController Subject Isolation', () {
    test('strictly isolates records per active subject ID', () async {
      // 1. Add record for Self (Subject A)
      final fileA = AppPlatformFile(
        name: 'self_doc.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );
      await controller.uploadAndSaveRecord(
        title: "Self's Record",
        recordType: 'Lab',
        date: '2026-01-10',
        file: fileA,
      );

      expect(controller.records.any((r) => r.title == "Self's Record"), isTrue);

      // 2. Add family member (Subject B) and switch
      await profileController.addFamilyMember(
        const FamilyMember(
          id: 'member-uncle-uuid',
          name: 'Uncle Ben',
          relation: 'Uncle',
        ),
      );
      profileController.switchSubjectByName('Uncle Ben');
      await controller.loadRecords();

      // Subject B must have 0 records from Subject A
      expect(controller.records.any((r) => r.title == "Self's Record"), isFalse);

      // 3. Add record for Subject B
      final fileB = AppPlatformFile(
        name: 'uncle_doc.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );
      await controller.uploadAndSaveRecord(
        title: "Uncle's Cardiology Report",
        recordType: 'Medical Records',
        date: '2026-01-12',
        file: fileB,
      );

      expect(controller.records.any((r) => r.title == "Uncle's Cardiology Report"), isTrue);

      // 4. Switch back to Self (Subject A)
      profileController.switchSubjectToSelf();
      await controller.loadRecords();

      // Subject A has Self's record, never Subject B's record
      expect(controller.records.any((r) => r.title == "Self's Record"), isTrue);
      expect(controller.records.any((r) => r.title == "Uncle's Cardiology Report"), isFalse);
    });
  });
}
