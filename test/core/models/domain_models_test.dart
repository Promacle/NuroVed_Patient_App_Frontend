import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/errors/failures.dart';
import 'package:nuroved_patient/core/models/medical_record.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/utils/result.dart';
import 'package:nuroved_patient/core/utils/uuid_generator.dart';

void main() {
  group('UuidGenerator.v4', () {
    test('generates valid RFC 4122 v4 UUIDs', () {
      final uuid = UuidGenerator.v4();
      expect(uuid.length, equals(36));
      expect(
        RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$').hasMatch(uuid),
        isTrue,
      );
    });

    test('generates unique values', () {
      final id1 = UuidGenerator.v4();
      final id2 = UuidGenerator.v4();
      expect(id1, isNot(equals(id2)));
    });
  });

  group('Result<T>', () {
    test('handles Success correctly with fold and when', () {
      const result = Result.success('patient_data');
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('patient_data'));
      expect(result.failureOrNull, isNull);

      final folded = result.fold(
        (f) => 'failed',
        (data) => 'got: $data',
      );
      expect(folded, equals('got: patient_data'));

      final mapped = result.map((data) => data.toUpperCase());
      expect(mapped.dataOrNull, equals('PATIENT_DATA'));
    });

    test('handles FailureResult correctly with fold and when', () {
      const result = Result<String>.failure(ServerFailure(message: 'Server error'));
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull?.message, equals('Server error'));

      final folded = result.fold(
        (f) => 'failure: ${f.message}',
        (data) => 'success',
      );
      expect(folded, equals('failure: Server error'));
    });
  });

  group('UserProfile Model', () {
    test('UserProfile.empty provides clean unassigned default state', () {
      final empty = UserProfile.empty();
      expect(empty.name, equals('Not provided'));
      expect(empty.email, equals('Not provided'));
      expect(empty.phone, equals('Not provided'));
      expect(empty.dateOfBirth, equals('Not provided'));
      expect(empty.allergies, isEmpty);
      expect(empty.chronicConditions, isEmpty);
      expect(empty.id, isNotEmpty);
    });

    test('serialization round-trip (toMap / fromMap)', () {
      final profile = UserProfile(
        id: 'test-uuid-123',
        name: 'Test Patient',
        email: 'patient@example.com',
        phone: '+91 99999 00000',
        dateOfBirth: '01/01/1990',
        gender: 'female',
        height: '165',
        weight: '60',
        bloodGroup: 'A+',
        allergies: const ['Peanuts'],
        chronicConditions: const ['Type 2 Diabetes'],
      );

      final map = profile.toMap();
      final reconstructed = UserProfile.fromMap(map);

      expect(reconstructed.id, equals(profile.id));
      expect(reconstructed.name, equals(profile.name));
      expect(reconstructed.email, equals(profile.email));
      expect(reconstructed.allergies, equals(['Peanuts']));
      expect(reconstructed.chronicConditions, equals(['Type 2 Diabetes']));
    });
  });

  group('FakeRecordsRepository', () {
    late FakeRecordsRepository repo;

    setUp(() {
      repo = FakeRecordsRepository();
    });

    test('adds, retrieves, and filters medical records', () async {
      final record1 = MedicalRecord(
        id: '',
        profileName: 'Self',
        title: 'HbA1c Blood Test',
        recordType: 'Lab Report',
        date: '10/01/2026',
        doctorName: 'Dr. Test Physician',
        hospitalName: 'General Hospital',
      );

      final record2 = MedicalRecord(
        id: '',
        profileName: 'Self',
        title: 'Insulin Prescription',
        recordType: 'Prescription',
        date: '12/01/2026',
      );

      final addResult1 = await repo.addRecord(record1);
      final addResult2 = await repo.addRecord(record2);

      expect(addResult1.isSuccess, isTrue);
      expect(addResult2.isSuccess, isTrue);
      expect(addResult1.dataOrNull?.id, isNotEmpty);

      // Fetch all
      final allResult = await repo.getRecords(profileName: 'Self');
      expect(allResult.isSuccess, isTrue);
      expect(allResult.dataOrNull?.length, equals(2));

      // Filter by type
      final labResult = await repo.getRecords(profileName: 'Self', recordType: 'Lab Report');
      expect(labResult.dataOrNull?.length, equals(1));
      expect(labResult.dataOrNull?.first.title, equals('HbA1c Blood Test'));

      // Search query
      final searchResult = await repo.getRecords(searchQuery: 'Insulin');
      expect(searchResult.dataOrNull?.length, equals(1));
      expect(searchResult.dataOrNull?.first.title, equals('Insulin Prescription'));

      // Delete record
      final deleteResult = await repo.deleteRecord(addResult1.dataOrNull!.id);
      expect(deleteResult.isSuccess, isTrue);

      final afterDelete = await repo.getRecords(profileName: 'Self');
      expect(afterDelete.dataOrNull?.length, equals(1));
    });
  });

  group('FakeAuthRepository', () {
    test('authenticates and manages mock session', () async {
      final authRepo = FakeAuthRepository();

      final initial = await authRepo.getCurrentUser();
      expect(initial.dataOrNull, isNull);

      final signInResult = await authRepo.signIn(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(signInResult.isSuccess, isTrue);
      expect(signInResult.dataOrNull?.email, equals('test@example.com'));

      final current = await authRepo.getCurrentUser();
      expect(current.dataOrNull?.name, equals('Test Patient'));

      await authRepo.signOut();
      final afterSignOut = await authRepo.getCurrentUser();
      expect(afterSignOut.dataOrNull, isNull);
    });
  });
}
