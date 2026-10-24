import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_visits_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVisitsRepository fakeVisitsRepo;
  late FakeRecordsRepository fakeRecordsRepo;
  late VisitsController controller;
  late RecordsController recordsController;
  late ProfileController profileController;

  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
    0x31, 0x2E, 0x34, 0x0A,
  ]);

  setUp(() {
    ProfileController.resetForTesting(repository: FakeProfileRepository());
    profileController = ProfileController.instance;

    fakeRecordsRepo = FakeRecordsRepository();
    RecordsController.resetForTesting(repository: fakeRecordsRepo);
    recordsController = RecordsController.instance;

    fakeVisitsRepo = FakeVisitsRepository(recordsRepository: fakeRecordsRepo);
    VisitsController.resetForTesting(repository: fakeVisitsRepo);
    controller = VisitsController.instance;
  });

  group('VisitsController CRUD & Canonical Linking', () {
    test(
      'creates visit with timezone-safe date and persists properly',
      () async {
        final result = await controller.addVisit({
          'title': 'Consultation with Dr. Sharma',
          'subtitle': 'Quarterly diabetic neuropathy review',
          'doctor': 'Dr. Sharma',
          'specialty': 'Neurologist',
          'hospital': 'Max Healthcare',
          'date': '2026-02-15T14:30:00+05:30',
          'notes': 'Vibration perception threshold normal in lower limbs.',
        });

        expect(result.isSuccess, isTrue);
        final created = result.dataOrNull!;
        expect(created.title, 'Consultation with Dr. Sharma');
        expect(created.doctorName, 'Dr. Sharma');
        expect(created.safeVisitDate.year, 2026);
        expect(created.safeVisitDate.month, 2);
        expect(created.safeVisitDate.day, 15);

        expect(controller.visits.any((v) => v.id == created.id), isTrue);
      },
    );

    test('deduplicates canonical related record IDs upon linking', () async {
      // 1. Upload a canonical record
      final file = AppPlatformFile(
        name: 'neuropathy_scan.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );
      final recResult = await recordsController.uploadAndSaveRecord(
        title: 'EMG Scan',
        recordType: 'Lab',
        date: '2026-02-15',
        file: file,
      );
      final recordId = recResult.dataOrNull!.id;

      // 2. Add visit with duplicate record IDs in input
      final visitResult = await controller.addVisit({
        'title': 'Follow-up EMG',
        'subtitle': 'Review of EMG results',
        'date': '2026-02-16',
        'relatedRecordIds': [recordId, recordId, recordId], // 3 duplicates
      });

      expect(visitResult.isSuccess, isTrue);
      final visit = visitResult.dataOrNull!;
      // Canonical deduplication: must contain exactly 1 occurrence
      expect(visit.relatedRecordIds.length, 1);
      expect(visit.relatedRecordIds.first, recordId);

      // 3. Retrieve related canonical records
      final related = await controller.getRelatedRecords(visit.id);
      expect(related.length, 1);
      expect(related.first.id, recordId);
      expect(related.first.title, 'EMG Scan');
    });

    test('updates visit details successfully', () async {
      final addRes = await controller.addVisit({
        'title': 'Initial Check',
        'subtitle': 'Initial notes',
        'date': '2026-01-10',
      });
      final visit = addRes.dataOrNull!;

      final updated = visit.copyWith(
        title: 'Updated Checkup Title',
        notes: 'Updated clinical observations',
      );
      final updateRes = await controller.updateVisit(updated);

      expect(updateRes.isSuccess, isTrue);
      final fetched = controller.visits.firstWhere((v) => v.id == visit.id);
      expect(fetched.title, 'Updated Checkup Title');
      expect(fetched.notes, 'Updated clinical observations');
    });

    test(
      'soft delete sets deletedAt and removes visit from active list',
      () async {
        final addRes = await controller.addVisit({
          'title': 'Visit to Delete',
          'subtitle': 'Will be deleted',
          'date': '2026-01-10',
        });
        final visit = addRes.dataOrNull!;
        expect(controller.visits.any((v) => v.id == visit.id), isTrue);

        final delRes = await controller.deleteVisit(visit.id);
        expect(delRes.isSuccess, isTrue);
        expect(controller.visits.any((v) => v.id == visit.id), isFalse);

        // In repository internal visits, deletedAt is set
        final inRepo = fakeVisitsRepo.internalVisits.firstWhere(
          (v) => v.id == visit.id,
        );
        expect(inRepo.isDeleted, isTrue);
        expect(inRepo.deletedAt, isNotNull);
      },
    );
  });

  group('VisitsController Subject Isolation', () {
    test('strictly isolates visits per active subject ID', () async {
      // 1. Create visit for Self (Subject A)
      await controller.addVisit({
        'title': "Self's Endocrinologist Consultation",
        'subtitle': 'Insulin titration',
        'date': '2026-01-10',
      });
      expect(
        controller.visits.any(
          (v) => v.title == "Self's Endocrinologist Consultation",
        ),
        isTrue,
      );

      // 2. Add family member (Subject B) and switch
      await profileController.addFamilyMember(
        const FamilyMember(
          id: 'member-aunt-uuid',
          name: 'Aunt May',
          relation: 'Aunt',
        ),
      );
      profileController.switchSubjectByName('Aunt May');
      await controller.loadVisits();

      // Subject B active: Self's visit must NOT appear
      expect(
        controller.visits.any(
          (v) => v.title == "Self's Endocrinologist Consultation",
        ),
        isFalse,
      );

      // 3. Add visit for Subject B
      await controller.addVisit({
        'title': "Aunt May's Ophthalmologist Exam",
        'subtitle': 'Diabetic retinopathy screening',
        'date': '2026-01-15',
      });
      expect(
        controller.visits.any(
          (v) => v.title == "Aunt May's Ophthalmologist Exam",
        ),
        isTrue,
      );

      // 4. Switch back to Self
      profileController.switchSubjectToSelf();
      await controller.loadVisits();

      expect(
        controller.visits.any(
          (v) => v.title == "Self's Endocrinologist Consultation",
        ),
        isTrue,
      );
      expect(
        controller.visits.any(
          (v) => v.title == "Aunt May's Ophthalmologist Exam",
        ),
        isFalse,
      );
    });
  });
}
