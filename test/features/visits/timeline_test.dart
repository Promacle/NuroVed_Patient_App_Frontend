import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_visits_repository.dart';
import 'package:nuroved_patient/core/utils/date_parser.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVisitsRepository fakeVisitsRepo;
  late FakeRecordsRepository fakeRecordsRepo;
  late VisitsController visitsCtrl;
  late RecordsController recordsCtrl;
  late ProfileController profileCtrl;

  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
    0x31, 0x2E, 0x34, 0x0A,
  ]);

  setUp(() {
    ProfileController.resetForTesting(repository: FakeProfileRepository());
    profileCtrl = ProfileController.instance;

    fakeRecordsRepo = FakeRecordsRepository();
    RecordsController.resetForTesting(repository: fakeRecordsRepo);
    recordsCtrl = RecordsController.instance;

    fakeVisitsRepo = FakeVisitsRepository(recordsRepository: fakeRecordsRepo);
    VisitsController.resetForTesting(repository: fakeVisitsRepo, empty: true);
    visitsCtrl = VisitsController.instance;
  });

  group('Timeline Chronological Merging & Edge Dates', () {
    test('merges visits and records into unified chronological order (newest first)', () async {
      // Clear initial seed visits to test clean sequence
      fakeVisitsRepo = FakeVisitsRepository(recordsRepository: fakeRecordsRepo);
      VisitsController.resetForTesting(repository: fakeVisitsRepo, empty: true);
      visitsCtrl = VisitsController.instance;

      // Event 1 (Oldest): Record on 2026-01-05
      await recordsCtrl.uploadAndSaveRecord(
        title: 'Initial Fasting Blood Sugar',
        recordType: 'Lab',
        date: '2026-01-05T08:00:00Z',
        file: AppPlatformFile(name: 'fbs.pdf', size: pdfBytes.length, bytes: pdfBytes),
      );

      // Event 2 (Middle): Visit on 2026-01-10
      await visitsCtrl.addVisit({
        'title': 'Consultation with Endocrinologist',
        'subtitle': 'Quarterly checkup',
        'date': '2026-01-10T11:00:00Z',
      });

      // Event 3 (Newest): Record on 2026-01-20
      await recordsCtrl.uploadAndSaveRecord(
        title: 'HbA1c Follow-up Lab',
        recordType: 'Lab',
        date: '2026-01-20T09:30:00Z',
        file: AppPlatformFile(name: 'hba1c.pdf', size: pdfBytes.length, bytes: pdfBytes),
      );

      final timeline = visitsCtrl.getTimelineItems(recordsController: recordsCtrl);

      expect(timeline.length, 3);
      // Newest first
      expect(timeline[0].title, 'HbA1c Follow-up Lab');
      expect(timeline[0].type, TimelineItemType.record);

      expect(timeline[1].title, 'Consultation with Endocrinologist');
      expect(timeline[1].type, TimelineItemType.visit);

      expect(timeline[2].title, 'Initial Fasting Blood Sugar');
      expect(timeline[2].type, TimelineItemType.record);
    });

    test('handles leap day (2024-02-29) and month boundaries accurately', () {
      final leapDateStr = '2024-02-29T10:00:00Z';
      final marchBoundaryStr = '2024-03-31T23:59:59Z';
      final aprilBoundaryStr = '2024-04-01T00:00:01Z';

      final leapDate = DateParser.parse(leapDateStr);
      final marchDate = DateParser.parse(marchBoundaryStr);
      final aprilDate = DateParser.parse(aprilBoundaryStr);

      expect(leapDate, isNotNull);
      expect(leapDate!.year, 2024);
      expect(leapDate.month, 2);
      expect(leapDate.day, 29);

      expect(marchDate!.month, 3);
      expect(marchDate.day, 31);

      expect(aprilDate!.month, 4);
      expect(aprilDate.day, 1);

      // Chronological comparison
      expect(marchDate.isAfter(leapDate), isTrue);
      expect(aprilDate.isAfter(marchDate), isTrue);
    });

    test('handles timezone offsets accurately during chronological sorting', () async {
      fakeVisitsRepo = FakeVisitsRepository(recordsRepository: fakeRecordsRepo);
      VisitsController.resetForTesting(repository: fakeVisitsRepo, empty: true);
      visitsCtrl = VisitsController.instance;

      // Event A: 2026-05-10 10:00:00 UTC
      await visitsCtrl.addVisit({
        'title': 'Event UTC Morning',
        'date': '2026-05-10T10:00:00Z',
      });

      // Event B: 2026-05-10 16:00:00 IST (+05:30) which is 10:30:00 UTC (later than Event A)
      await visitsCtrl.addVisit({
        'title': 'Event IST Afternoon',
        'date': '2026-05-10T16:00:00+05:30',
      });

      final timeline = visitsCtrl.getTimelineItems(recordsController: recordsCtrl);
      expect(timeline.length, 2);

      // Event B is 10:30 UTC, Event A is 10:00 UTC -> Event B is newer
      expect(timeline[0].title, 'Event IST Afternoon');
      expect(timeline[1].title, 'Event UTC Morning');
    });

    test('returns empty timeline when subject has no visits or records', () async {
      await profileCtrl.addFamilyMember(
        const FamilyMember(
          id: 'member-baby-uuid',
          name: 'Fresh Baby',
          relation: 'Child',
        ),
      );
      profileCtrl.switchSubjectByName('Fresh Baby');
      await visitsCtrl.loadVisits();
      await recordsCtrl.loadRecords();

      final timeline = visitsCtrl.getTimelineItems(recordsController: recordsCtrl);
      expect(timeline.isEmpty, isTrue);
    });
  });
}
