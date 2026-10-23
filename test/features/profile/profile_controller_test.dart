import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeProfileRepository fakeRepo;
  late UserProfile testProfile;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testProfile = const UserProfile(
      id: 'patient-uuid-1234',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+919876543210',
      dateOfBirth: '15/05/1985',
      gender: 'male',
      height: '175',
      weight: '72',
      bloodGroup: 'O+',
      allergies: ['Penicillin'],
      chronicConditions: ['Type 2 Diabetes'],
    );
    fakeRepo = FakeProfileRepository(initialProfile: testProfile);
    ProfileController.resetForTesting(
      repository: fakeRepo,
      initialProfile: testProfile,
    );
  });

  group('ProfileController - Initial State & Loading', () {
    test('initializes with given profile and active subject is patient', () {
      final controller = ProfileController.instance;
      expect(controller.profile.id, 'patient-uuid-1234');
      expect(controller.profile.name, 'John Doe');
      expect(controller.activeSubjectId, 'patient-uuid-1234');
      expect(controller.isMainPatientActive, isTrue);
      expect(controller.activeProfileName, 'John Doe');
    });

    test('loadProfile updates state from repository', () async {
      final updatedRemote = testProfile.copyWith(name: 'Johnathan Doe');
      fakeRepo = FakeProfileRepository(initialProfile: updatedRemote);
      final controller = ProfileController(repository: fakeRepo);

      await controller.loadProfile();

      expect(controller.profile.name, 'Johnathan Doe');
      expect(controller.isOffline, isFalse);
      expect(controller.isLoading, isFalse);
    });

    test('loadProfile handles offline state with retry', () async {
      fakeRepo.shouldFail = true;
      final controller = ProfileController.instance;

      await controller.loadProfile();

      expect(controller.isOffline, isTrue);
      expect(controller.errorMessage, contains('Failed to retrieve profile'));

      // Retry after network restores
      fakeRepo.shouldFail = false;
      await controller.retry();

      expect(controller.isOffline, isFalse);
      expect(controller.errorMessage, isNull);
    });
  });

  group('ProfileController - Optimistic UI with Rollback on Failure', () {
    test('updateProfile succeeds and persists state', () async {
      final controller = ProfileController.instance;
      final edited = testProfile.copyWith(
        name: 'Jane Doe',
        bloodGroup: 'AB+',
        height: '168',
      );

      final result = await controller.updateProfile(edited);

      expect(result.isSuccess, isTrue);
      expect(controller.profile.name, 'Jane Doe');
      expect(controller.profile.bloodGroup, 'AB+');
      expect(controller.profile.height, '168');
    });

    test('updateProfile rolls back to previous state on failure', () async {
      final controller = ProfileController.instance;
      final originalName = controller.profile.name;
      fakeRepo.shouldFail = true;

      final edited = testProfile.copyWith(name: 'Malicious Overwrite');
      final result = await controller.updateProfile(edited);

      expect(result.isFailure, isTrue);
      // State MUST roll back to original
      expect(controller.profile.name, originalName);
      expect(controller.errorMessage, contains('Failed to update profile'));
    });

    test('addAllergy and removeAllergy with rollback on failure', () async {
      final controller = ProfileController.instance;
      expect(controller.profile.allergies, ['Penicillin']);

      // Add allergy successfully
      await controller.addAllergy('Sulfa');
      expect(controller.profile.allergies, contains('Sulfa'));

      // Remove allergy successfully
      await controller.removeAllergy('Penicillin');
      expect(controller.profile.allergies, isNot(contains('Penicillin')));

      // Test failure rollback
      fakeRepo.shouldFail = true;
      final beforeAllergies = List<String>.from(controller.profile.allergies);
      final failResult = await controller.addAllergy('Aspirin');

      expect(failResult.isFailure, isTrue);
      expect(controller.profile.allergies, equals(beforeAllergies));
    });

    test('addChronicCondition and removeChronicCondition with rollback on failure', () async {
      final controller = ProfileController.instance;
      expect(controller.profile.chronicConditions, ['Type 2 Diabetes']);

      // Add condition
      await controller.addChronicCondition('Hypertension');
      expect(controller.profile.chronicConditions, contains('Hypertension'));

      // Failure rollback
      fakeRepo.shouldFail = true;
      final beforeConditions =
          List<String>.from(controller.profile.chronicConditions);
      final failResult = await controller.removeChronicCondition('Hypertension');

      expect(failResult.isFailure, isTrue);
      expect(controller.profile.chronicConditions, equals(beforeConditions));
    });
  });

  group('ProfileController - Photo Validation (Size & Extension)', () {
    test('accepts valid JPG/PNG files under 10MB', () {
      final controller = ProfileController.instance;
      final validJpg = AppPlatformFile(
        name: 'avatar.jpg',
        bytes: Uint8List.fromList(List.filled(1024 * 1024, 0)), // 1MB
        size: 1024 * 1024,
      );
      final result = controller.validateProfilePhoto(validJpg);
      expect(result.isSuccess, isTrue);

      final validPng = AppPlatformFile(
        name: 'profile.png',
        bytes: Uint8List.fromList(List.filled(2 * 1024 * 1024, 0)), // 2MB
        size: 2 * 1024 * 1024,
      );
      expect(controller.validateProfilePhoto(validPng).isSuccess, isTrue);
    });

    test('rejects disallowed file extensions (e.g. .exe, .pdf, .gif)', () {
      final controller = ProfileController.instance;
      final pdfFile = AppPlatformFile(
        name: 'avatar.pdf',
        bytes: Uint8List.fromList(List.filled(100, 0)),
        size: 100,
      );
      final result = controller.validateProfilePhoto(pdfFile);
      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Should have failed'),
        failure: (f) => expect(f.message, contains('format .pdf is not allowed')),
      );
    });

    test('rejects files exceeding 10MB limit', () {
      final controller = ProfileController.instance;
      final oversizedFile = AppPlatformFile(
        name: 'avatar.jpg',
        bytes: Uint8List.fromList(List.filled(11 * 1024 * 1024, 0)), // 11MB
        size: 11 * 1024 * 1024,
      );
      final result = controller.validateProfilePhoto(oversizedFile);
      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Should have failed'),
        failure: (f) => expect(f.message, contains('exceeds maximum allowed limit of 10.0MB')),
      );
    });
  });

  group('ProfileController - Age Calculation', () {
    test('calculates correct age from valid DD/MM/YYYY date of birth', () {
      final controller = ProfileController.instance;
      final ageStr = controller.calculateAge();
      expect(ageStr, contains('years'));
      final ageNum = int.tryParse(ageStr.split(' ')[0]);
      expect(ageNum, isNotNull);
      expect(ageNum! >= 35, isTrue);
    });

    test('returns N/A when date of birth is missing or invalid', () {
      ProfileController.resetForTesting(
        initialProfile: testProfile.copyWith(dateOfBirth: 'Not provided'),
      );
      expect(ProfileController.instance.calculateAge(), 'N/A');

      ProfileController.resetForTesting(
        initialProfile: testProfile.copyWith(dateOfBirth: 'invalid-date'),
      );
      expect(ProfileController.instance.calculateAge(), 'N/A');
    });
  });
}
