import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;
  late AuthController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = FakeAuthRepository();
    controller = AuthController(authRepository: fakeAuth);

    // Seed an authenticated user
    await fakeAuth.signUp(
      email: 'activepatient@example.com',
      password: 'OldPassword123!',
      name: 'Active Patient',
      acknowledgedTerms: true,
    );
  });

  tearDown(() {
    controller.dispose();
    fakeAuth.dispose();
  });

  group('Logout Cleanup', () {
    test(
      'logout clears user profile, resets form state, and emits null auth state',
      () async {
        expect(controller.isAuthenticated, isTrue);

        UserProfile? emittedUser = controller.currentUser;
        final sub = fakeAuth.authStateChanges.listen((user) {
          emittedUser = user;
        });

        controller.emailController.text = 'lingering@example.com';
        controller.passwordController.text = 'secret';

        await controller.logout();

        expect(controller.isAuthenticated, isFalse);
        expect(controller.currentUser, isNull);
        expect(controller.emailController.text, isEmpty);
        expect(controller.passwordController.text, isEmpty);
        expect(emittedUser, isNull);

        await sub.cancel();
      },
    );
  });

  group('Change Password with Reauthentication', () {
    test('rejects change password without current password', () async {
      final result = await controller.changePassword(
        currentPassword: '',
        newPassword: 'NewPassword123!',
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.message,
        contains('Current password is required'),
      );
    });

    test('rejects change password with incorrect current password', () async {
      final result = await controller.changePassword(
        currentPassword: 'IncorrectPassword',
        newPassword: 'NewPassword123!',
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.message,
        contains('Current password is incorrect'),
      );
    });

    test('rejects change password with short new password', () async {
      final result = await controller.changePassword(
        currentPassword: 'OldPassword123!',
        newPassword: 'short',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, contains('at least 8 characters'));
    });

    test(
      'succeeds with correct current password and updates credentials',
      () async {
        final result = await controller.changePassword(
          currentPassword: 'OldPassword123!',
          newPassword: 'BrandNewPassword123!',
        );

        expect(result.isSuccess, isTrue);

        // Verify sign in with new password succeeds
        await controller.logout();
        controller.emailController.text = 'activepatient@example.com';
        controller.passwordController.text = 'BrandNewPassword123!';
        final loginSuccess = await controller.signIn();
        expect(loginSuccess, isTrue);
      },
    );
  });

  group('Change Email with Verification', () {
    test('rejects invalid new email format', () async {
      final result = await controller.changeEmail(
        newEmail: 'invalid-email',
        password: 'OldPassword123!',
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects change email with incorrect password', () async {
      final result = await controller.changeEmail(
        newEmail: 'newemail@example.com',
        password: 'WrongPassword',
      );

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.message,
        contains('Password confirmation failed'),
      );
    });

    test('succeeds with correct password and updates email', () async {
      final result = await controller.changeEmail(
        newEmail: 'updatedpatient@example.com',
        password: 'OldPassword123!',
      );

      expect(result.isSuccess, isTrue);
      expect(
        controller.currentUser?.email,
        equals('updatedpatient@example.com'),
      );
    });
  });

  group('Permanent Account Deletion', () {
    test('rejects deletion without password confirmation', () async {
      final result = await controller.deleteAccount(passwordConfirm: '');

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.message,
        contains('Password confirmation is required'),
      );
      expect(controller.isAuthenticated, isTrue);
    });

    test('rejects deletion with incorrect password', () async {
      final result = await controller.deleteAccount(
        passwordConfirm: 'WrongPassword',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, contains('Incorrect password'));
      expect(controller.isAuthenticated, isTrue);
    });

    test(
      'succeeds with correct password and permanently purges user',
      () async {
        final result = await controller.deleteAccount(
          passwordConfirm: 'OldPassword123!',
        );

        expect(result.isSuccess, isTrue);
        expect(controller.isAuthenticated, isFalse);
        expect(controller.currentUser, isNull);

        // Attempting to sign in with deleted account fails
        controller.emailController.text = 'activepatient@example.com';
        controller.passwordController.text = 'OldPassword123!';
        final loginSuccess = await controller.signIn();
        expect(loginSuccess, isFalse);
      },
    );
  });
}
