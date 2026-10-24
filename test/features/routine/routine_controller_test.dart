import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/medicine_routine.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';

void main() {
  group('RoutineController Tests', () {
    late RoutineController controller;

    setUp(() {
      ProfileController.resetForTesting(
        initialProfile: const UserProfile(
          id: 'subject-patient-001',
          name: 'Test Patient',
          email: 'patient@example.com',
          phone: '+919876543210',
          dateOfBirth: '1980-05-15',
          gender: 'Male',
          height: '175',
          weight: '70',
          bloodGroup: 'B+',
          allergies: ['Peanuts'],
          chronicConditions: ['Type 2 Diabetes'],
        ),
        initialFamily: [
          const FamilyMember(
            id: 'subject-family-001',
            name: 'Spouse Test',
            relation: 'Spouse',
          ),
        ],
      );
      RoutineController.resetForTesting();
      controller = RoutineController();
    });

    test(
      'initial primary user has default verified prescription routines and accurate progress',
      () {
        expect(controller.medicines.length, 3);
        // Default: 1 of 3 is completed
        expect(controller.progress, closeTo(1 / 3, 0.001));
        expect(controller.progressText, '1/3 Completed');

        // Verify default sources are verifiedPrescription
        for (final med in controller.medicines) {
          expect(med['source'], RoutineSource.verifiedPrescription.name);
          expect(med['source_display'], 'Verified Prescription');
        }
      },
    );

    test(
      'progress calculation handles 0 total items cleanly without NaN or division by zero',
      () {
        controller.setSubject('subject-family-001');
        expect(controller.medicines.isEmpty, isTrue);
        expect(controller.progress, 0.0);
        expect(controller.progressText, '0/0 Completed');
      },
    );

    test(
      'toggleMedicine updates completion status and recalculates progress',
      () {
        // Index 0 is initially false
        expect(controller.medicines[0]['isCompleted'], isFalse);
        controller.toggleMedicine(0);
        expect(controller.medicines[0]['isCompleted'], isTrue);
        expect(controller.progress, closeTo(2 / 3, 0.001));
        expect(controller.progressText, '2/3 Completed');

        // Toggle index 1 to true -> 3/3
        controller.toggleMedicine(1);
        expect(controller.progress, 1.0);
        expect(controller.progressText, '3/3 Completed');

        // Toggle back
        controller.toggleMedicine(0);
        expect(controller.progress, closeTo(2 / 3, 0.001));
      },
    );

    test(
      'addMedicine tags user-entered routines as selfEntered and preserves exact dosage',
      () {
        controller.addMedicine({
          'name': 'Glimepiride 2mg',
          'dosage': '2mg',
          'instruction': '1 tablet before breakfast',
          'time': '07:30',
        });

        expect(controller.medicines.length, 4);
        final added = controller.medicines.last;
        expect(added['name'], 'Glimepiride 2mg');
        expect(added['dosage'], '2mg');
        expect(added['source'], RoutineSource.selfEntered.name);
        expect(added['source_display'], 'Self-Entered');
        expect(added['isCompleted'], isFalse);
      },
    );

    test(
      'updateMedicine preserves subjectId and updates details without altering dose format',
      () {
        controller.updateMedicine(0, {
          'name': 'Atorvastatin 20mg',
          'dosage': '20mg',
          'instruction': '1 tablet at bedtime',
        });

        final updated = controller.medicines[0];
        expect(updated['name'], 'Atorvastatin 20mg');
        expect(updated['dosage'], '20mg');
        expect(updated['instruction'], '1 tablet at bedtime');
        expect(updated['subjectId'], 'subject-patient-001');
      },
    );

    test('deleteMedicine removes routine by index and updates progress', () {
      // Initially 3 medicines, 1 completed (index 2)
      controller.deleteMedicine(0);
      expect(controller.medicines.length, 2);
      expect(controller.progress, 0.5);
      expect(controller.progressText, '1/2 Completed');
    });

    test('deleteMedicineById removes routine by UUID', () {
      final idToDelete = controller.medicines.first['id'] as String;
      controller.deleteMedicineById(idToDelete);
      expect(controller.medicines.any((m) => m['id'] == idToDelete), isFalse);
      expect(controller.medicines.length, 2);
    });

    test('strict isolation between primary patient and family subject', () {
      // Patient has 3 medicines
      expect(controller.medicines.length, 3);

      // Switch to family member
      ProfileController.instance.switchSubject('subject-family-001');
      expect(controller.medicines.isEmpty, isTrue);

      // Add medicine for family member
      controller.addMedicine({
        'name': 'Multivitamin',
        'dosage': '1 gummy',
        'instruction': 'Daily morning',
      });
      expect(controller.medicines.length, 1);
      expect(controller.medicines.first['name'], 'Multivitamin');

      // Switch back to primary patient
      ProfileController.instance.switchSubject('subject-patient-001');
      expect(controller.medicines.length, 3);
      expect(
        controller.medicines.any((m) => m['name'] == 'Multivitamin'),
        isFalse,
      );
    });
  });
}
