import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/features/family/controllers/family_controller.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeProfileRepository fakeRepo;
  late UserProfile primaryPatient;
  late FamilyMember memberFather;
  late FamilyMember memberMother;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    primaryPatient = const UserProfile(
      id: 'patient-primary-uuid',
      name: 'John Patient',
      email: 'john@example.com',
      phone: '+919876543210',
      dateOfBirth: '10/10/1980',
      gender: 'male',
      height: '178',
      weight: '75',
      bloodGroup: 'B+',
      allergies: ['Dust'],
      chronicConditions: ['Type 2 Diabetes'],
    );

    memberFather = const FamilyMember(
      id: 'member-father-uuid',
      name: 'Robert Patient',
      relation: 'Father',
      isEmergencyContact: true,
      phone: '+919876543211',
      bloodGroup: 'B+',
    );

    memberMother = const FamilyMember(
      id: 'member-mother-uuid',
      name: 'Mary Patient',
      relation: 'Mother',
      isEmergencyContact: false,
      phone: '+919876543212',
      bloodGroup: 'O+',
    );

    fakeRepo = FakeProfileRepository(
      initialProfile: primaryPatient,
      initialFamily: [memberFather, memberMother],
    );

    ProfileController.resetForTesting(
      repository: fakeRepo,
      initialProfile: primaryPatient,
      initialFamily: [memberFather, memberMother],
    );

    RecordsController.resetForTesting();
    VisitsController.resetForTesting();
    RoutineController.resetForTesting();
  });

  group('Family Profiles - CRUD with Stable UUIDs', () {
    test(
      'family members have stable IDs and can be added, updated, and deleted',
      () async {
        final familyCtrl = FamilyController();
        final profileCtrl = ProfileController.instance;

        // Verify initial members
        expect(profileCtrl.familyMembersList.length, 2);
        expect(profileCtrl.familyMembersList[0].id, 'member-father-uuid');
        expect(profileCtrl.familyMembersList[1].id, 'member-mother-uuid');

        // Add new member with stable ID
        final addResult = await familyCtrl.addFamilyMember({
          'id': 'member-child-uuid',
          'name': 'Tommy Patient',
          'relation': 'Son',
          'blood': 'B+',
        });

        expect(addResult.isSuccess, isTrue);
        expect(profileCtrl.familyMembersList.length, 3);
        expect(
          profileCtrl.familyMembersList.any((m) => m.id == 'member-child-uuid'),
          isTrue,
        );

        // Update existing member
        final updateResult = await familyCtrl.updateFamilyMember(
          'member-child-uuid',
          {'name': 'Thomas Patient', 'relation': 'Son'},
        );
        expect(updateResult.isSuccess, isTrue);
        final updated = profileCtrl.familyMembersList.firstWhere(
          (m) => m.id == 'member-child-uuid',
        );
        expect(updated.name, 'Thomas Patient');

        // Remove member by stable ID
        final deleteResult = await familyCtrl.removeFamilyMemberById(
          'member-child-uuid',
        );
        expect(deleteResult.isSuccess, isTrue);
        expect(profileCtrl.familyMembersList.length, 2);
        expect(
          profileCtrl.familyMembersList.any((m) => m.id == 'member-child-uuid'),
          isFalse,
        );
      },
    );

    test(
      'deleting active subject member resets active subject to primary patient',
      () async {
        final profileCtrl = ProfileController.instance;

        // Switch active subject to Father
        profileCtrl.switchSubject('member-father-uuid');
        expect(profileCtrl.activeSubjectId, 'member-father-uuid');
        expect(profileCtrl.isMainPatientActive, isFalse);

        // Remove Father
        await profileCtrl.removeFamilyMember('member-father-uuid');

        // Active subject MUST fall back to primary patient UUID
        expect(profileCtrl.activeSubjectId, 'patient-primary-uuid');
        expect(profileCtrl.isMainPatientActive, isTrue);
        expect(profileCtrl.activeProfileName, 'John Patient');
      },
    );
  });

  group('Profile Switching & Strict Subject Isolation', () {
    test(
      'records strictly isolate by subject UUID; switching never leaks stale data',
      () {
        final profileCtrl = ProfileController.instance;
        final recordsCtrl = RecordsController();

        // 1. Add Record for Primary Patient
        profileCtrl.switchSubject(primaryPatient.id);
        recordsCtrl.addRecord({
          'id': 'rec-patient-1',
          'title': 'John HbA1c Lab Report',
          'type': 'Lab Report',
          'date': '2026-10-10',
        });

        expect(recordsCtrl.filteredRecords.length, 1);
        expect(
          recordsCtrl.filteredRecords.first['title'],
          'John HbA1c Lab Report',
        );

        // 2. Switch to Father: records MUST immediately purge and be empty
        profileCtrl.switchSubject(memberFather.id);
        expect(recordsCtrl.filteredRecords.isEmpty, isTrue);

        // 3. Add Record for Father
        recordsCtrl.addRecord({
          'id': 'rec-father-1',
          'title': 'Father Cardiac ECG',
          'type': 'Imaging/X-Ray',
          'date': '2026-10-15',
        });

        expect(recordsCtrl.filteredRecords.length, 1);
        expect(
          recordsCtrl.filteredRecords.first['title'],
          'Father Cardiac ECG',
        );
        expect(
          recordsCtrl.filteredRecords.any(
            (r) => r['title'] == 'John HbA1c Lab Report',
          ),
          isFalse,
        );

        // 4. Switch to Mother: empty
        profileCtrl.switchSubject(memberMother.id);
        expect(recordsCtrl.filteredRecords.isEmpty, isTrue);

        // 5. Switch back to Primary Patient: only John records appear, never Father records
        profileCtrl.switchSubject(primaryPatient.id);
        expect(recordsCtrl.filteredRecords.length, 1);
        expect(
          recordsCtrl.filteredRecords.first['title'],
          'John HbA1c Lab Report',
        );
        expect(
          recordsCtrl.filteredRecords.any(
            (r) => r['title'] == 'Father Cardiac ECG',
          ),
          isFalse,
        );
      },
    );

    test(
      'visits strictly isolate by subject UUID; switching reloads and purges previous',
      () {
        final profileCtrl = ProfileController.instance;
        final visitsCtrl = VisitsController();

        // Add visit for Father
        profileCtrl.switchSubject(memberFather.id);
        visitsCtrl.addVisit({
          'id': 'visit-father-1',
          'title': 'Father Cardiologist Consultation',
          'date': '2026-10-20',
        });

        expect(visitsCtrl.filteredVisits.length, 1);
        expect(
          visitsCtrl.filteredVisits.first['title'],
          'Father Cardiologist Consultation',
        );

        // Switch to Mother: Father visit MUST NOT appear
        profileCtrl.switchSubject(memberMother.id);
        expect(visitsCtrl.filteredVisits.isEmpty, isTrue);

        // Switch back to Father: Father visit restored
        profileCtrl.switchSubject(memberFather.id);
        expect(visitsCtrl.filteredVisits.length, 1);
        expect(
          visitsCtrl.filteredVisits.first['title'],
          'Father Cardiologist Consultation',
        );
      },
    );

    test('routine medications strictly isolate by subject UUID', () {
      final profileCtrl = ProfileController.instance;
      final routineCtrl = RoutineController();

      // Primary patient has default diabetic routine
      profileCtrl.switchSubject(primaryPatient.id);
      expect(routineCtrl.medicines.isNotEmpty, isTrue);
      expect(
        routineCtrl.medicines.any((m) => m['name'].contains('Metformin')),
        isTrue,
      );

      // Switch to Father: initial routine is empty (never leaks John's Metformin)
      profileCtrl.switchSubject(memberFather.id);
      expect(
        routineCtrl.medicines.any((m) => m['name'].contains('Metformin')),
        isFalse,
      );

      // Add Father medication
      routineCtrl.addMedicine({
        'name': 'Amlodipine 5mg',
        'instruction': '1 tablet * 08:00',
        'isCompleted': false,
      });
      expect(routineCtrl.medicines.length, 1);
      expect(routineCtrl.medicines.first['name'], 'Amlodipine 5mg');

      // Switch back to Primary Patient: Metformin present, Amlodipine NOT present
      profileCtrl.switchSubject(primaryPatient.id);
      expect(
        routineCtrl.medicines.any((m) => m['name'].contains('Metformin')),
        isTrue,
      );
      expect(
        routineCtrl.medicines.any((m) => m['name'].contains('Amlodipine')),
        isFalse,
      );
    });
  });
}
