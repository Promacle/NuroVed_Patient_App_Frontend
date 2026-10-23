import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/care_access_grant.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeProfileRepository fakeRepo;
  late UserProfile testProfile;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    testProfile = const UserProfile(
      id: 'patient-grantor-uuid',
      name: 'Alice Patient',
      email: 'alice@example.com',
      phone: '+919876543210',
      dateOfBirth: '20/06/1990',
      gender: 'female',
      height: '165',
      weight: '60',
      bloodGroup: 'A+',
      allergies: [],
      chronicConditions: [],
    );

    fakeRepo = FakeProfileRepository(initialProfile: testProfile);
    ProfileController.resetForTesting(
      repository: fakeRepo,
      initialProfile: testProfile,
    );
  });

  group('Caregiver Access Grant - Invite, Accept, Scopes, and Revoke', () {
    test('inviting caregiver creates pending grant with specified scopes', () async {
      final controller = ProfileController.instance;

      final inviteResult = await controller.inviteCaregiver(
        email: 'caregiver@example.com',
        name: 'Dr. Rahul Sharma',
        scopes: ['medical_records', 'health_timeline'],
        accessType: 'view_only',
        purpose: 'Diabetes consultation review',
      );

      expect(inviteResult.isSuccess, isTrue);
      final grant = controller.caregiverGrant;
      expect(grant, isNotNull);
      expect(grant!.granteeEmail, 'caregiver@example.com');
      expect(grant.granteeName, 'Dr. Rahul Sharma');
      expect(grant.status, 'pending');
      expect(grant.isValid, isFalse); // Pending grant is not yet active
      expect(grant.scopes, containsAll(['medical_records', 'health_timeline']));
      expect(grant.hasScope('medical_records'), isFalse); // Not valid until accepted
    });

    test('accepting caregiver invite activates grant and enables scope checking', () async {
      final controller = ProfileController.instance;

      final inviteResult = await controller.inviteCaregiver(
        email: 'nurse.joy@clinic.com',
        name: 'Nurse Joy',
        scopes: ['medical_records'],
        accessType: 'view_and_edit',
      );

      final grantId = inviteResult.dataOrNull!.id;
      final acceptResult = await controller.acceptCaregiverInvite(grantId);

      expect(acceptResult.isSuccess, isTrue);
      final activeGrant = controller.caregiverGrant;
      expect(activeGrant!.status, 'active');
      expect(activeGrant.isValid, isTrue);

      // Verify in-scope access is allowed
      expect(activeGrant.hasScope('medical_records'), isTrue);

      // Verify out-of-scope access is denied
      expect(activeGrant.hasScope('medications'), isFalse);
      expect(activeGrant.hasScope('full_profile'), isFalse);

      // Verify permissions
      expect(activeGrant.canEdit(), isTrue);
    });

    test('updating scopes dynamically expands or narrows authorized access', () async {
      final controller = ProfileController.instance;

      final invite = await controller.inviteCaregiver(
        email: 'doc@hospital.org',
        name: 'Dr. Mehta',
        scopes: ['medical_records'],
      );
      await controller.acceptCaregiverInvite(invite.dataOrNull!.id);

      expect(controller.caregiverGrant!.hasScope('medications'), isFalse);

      // Expand scope to include medications
      final updateResult = await controller.updateCaregiverScopes(
        invite.dataOrNull!.id,
        ['medical_records', 'medications'],
      );

      expect(updateResult.isSuccess, isTrue);
      expect(controller.caregiverGrant!.hasScope('medications'), isTrue);
      expect(controller.caregiverGrant!.hasScope('medical_records'), isTrue);
      expect(controller.caregiverGrant!.hasScope('health_timeline'), isFalse);
    });

    test('revoking caregiver immediately denies all resource access', () async {
      final controller = ProfileController.instance;

      final invite = await controller.inviteCaregiver(
        email: 'doc@hospital.org',
        name: 'Dr. Mehta',
        scopes: ['medical_records', 'full_profile'],
      );
      await controller.acceptCaregiverInvite(invite.dataOrNull!.id);

      expect(controller.caregiverGrant!.isValid, isTrue);

      // Revoke grant
      final revokeResult = await controller.revokeCaregiver(invite.dataOrNull!.id);
      expect(revokeResult.isSuccess, isTrue);

      final revokedGrant = controller.caregiverGrant!;
      expect(revokedGrant.status, 'revoked');
      expect(revokedGrant.revokedAt, isNotNull);
      expect(revokedGrant.isValid, isFalse);

      // All scopes MUST be denied immediately
      expect(revokedGrant.hasScope('medical_records'), isFalse);
      expect(revokedGrant.hasScope('full_profile'), isFalse);
      expect(revokedGrant.canEdit(), isFalse);
    });

    test('expired grant is rejected by isValid and scope checks', () {
      final expiredGrant = CareAccessGrant(
        id: 'grant-expired-1',
        patientId: testProfile.id,
        granteeEmail: 'old.caregiver@example.com',
        granteeName: 'Old Caregiver',
        accessType: 'view_only',
        scopes: ['medical_records'],
        purpose: 'Past visit',
        status: 'active',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)), // Expired yesterday
      );

      expect(expiredGrant.isValid, isFalse);
      expect(expiredGrant.hasScope('medical_records'), isFalse);
    });
  });
}
