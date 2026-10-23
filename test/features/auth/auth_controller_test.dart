import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;
  late AuthController controller;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    controller = AuthController(authRepository: fakeAuth);
  });

  tearDown(() {
    controller.dispose();
    fakeAuth.dispose();
  });

  group('AuthController - Sign In', () {
    test('rejects empty or invalid email', () async {
      controller.emailController.text = 'invalid-email';
      controller.passwordController.text = 'ValidPassword123!';

      final success = await controller.signIn();

      expect(success, isFalse);
      expect(controller.errorMessage, contains('valid email address'));
      expect(controller.isAuthenticated, isFalse);
    });

    test('rejects empty password', () async {
      controller.emailController.text = 'test@example.com';
      controller.passwordController.text = '';

      final success = await controller.signIn();

      expect(success, isFalse);
      expect(controller.errorMessage, contains('Password is required'));
      expect(controller.isAuthenticated, isFalse);
    });

    test('fails with wrong credentials', () async {
      controller.emailController.text = 'nonexistent@example.com';
      controller.passwordController.text = 'WrongPassword123!';

      final success = await controller.signIn();

      expect(success, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.isAuthenticated, isFalse);
    });

    test('succeeds with registered credentials and clears form', () async {
      // First register a test user
      await fakeAuth.signUp(
        email: 'patient@example.com',
        password: 'Password123!',
        name: 'Test Patient',
        acknowledgedTerms: true,
      );
      await fakeAuth.signOut();

      controller.emailController.text = 'patient@example.com';
      controller.passwordController.text = 'Password123!';

      final success = await controller.signIn();

      expect(success, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser?.email, equals('patient@example.com'));
      expect(controller.errorMessage, isNull);
      expect(controller.emailController.text, isEmpty);
      expect(controller.passwordController.text, isEmpty);
    });
  });

  group('AuthController - Step 1 Validation & Next Step', () {
    test('validateStepOne rejects invalid email', () {
      controller.emailController.text = 'bad_email';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';

      expect(controller.validateStepOne(), isFalse);
      expect(controller.errorMessage, isNotNull);
    });

    test('validateStepOne rejects password under 8 characters', () {
      controller.emailController.text = 'patient@example.com';
      controller.passwordController.text = 'short';
      controller.confirmPasswordController.text = 'short';

      expect(controller.validateStepOne(), isFalse);
      expect(controller.errorMessage, contains('at least 8 characters'));
    });

    test('validateStepOne rejects mismatched passwords', () {
      controller.emailController.text = 'patient@example.com';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'DifferentPassword123!';

      expect(controller.validateStepOne(), isFalse);
      expect(controller.showPasswordError, isTrue);
      expect(controller.errorMessage, contains('do not match'));
    });

    test('validateStepOne passes with valid matching credentials', () {
      controller.emailController.text = 'patient@example.com';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';

      expect(controller.validateStepOne(), isTrue);
      expect(controller.showPasswordError, isFalse);
      expect(controller.errorMessage, isNull);
    });
  });

  group('AuthController - Step 2 & Complete Sign Up', () {
    setUp(() {
      controller.emailController.text = 'newpatient@example.com';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';
    });

    test('rejects signup without full name', () async {
      controller.nameController.text = '';
      controller.setAcknowledgedTerms(true);

      final success = await controller.completeSignUp();

      expect(success, isFalse);
      expect(controller.errorMessage, contains('Full name'));
      expect(controller.isAuthenticated, isFalse);
    });

    test('rejects signup without terms acknowledgement', () async {
      controller.nameController.text = 'Test Patient';
      controller.setAcknowledgedTerms(false);

      final success = await controller.completeSignUp();

      expect(success, isFalse);
      expect(controller.errorMessage, contains('terms and conditions'));
      expect(controller.isAuthenticated, isFalse);
    });

    test('rejects signup with invalid date of birth', () async {
      controller.nameController.text = 'Test Patient';
      controller.dobController.text = '31/02/2000'; // Invalid date
      controller.setAcknowledgedTerms(true);

      final success = await controller.completeSignUp();

      expect(success, isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.isAuthenticated, isFalse);
    });

    test('rejects duplicate email registration', () async {
      await fakeAuth.signUp(
        email: 'duplicate@example.com',
        password: 'Password123!',
        name: 'First User',
        acknowledgedTerms: true,
      );
      await fakeAuth.signOut();

      controller.emailController.text = 'duplicate@example.com';
      controller.passwordController.text = 'Password123!';
      controller.confirmPasswordController.text = 'Password123!';
      controller.nameController.text = 'Second User';
      controller.setAcknowledgedTerms(true);

      final success = await controller.completeSignUp();

      expect(success, isFalse);
      expect(controller.errorMessage, contains('already exists'));
    });

    test(
      'completes signup with valid inputs and terms acknowledgement',
      () async {
        controller.nameController.text = 'Test Patient';
        controller.dobController.text = '15/08/1990';
        controller.phoneController.text = '9876543210';
        controller.setSelectedGender('Female');
        controller.setAcknowledgedTerms(true);

        final success = await controller.completeSignUp();

        expect(success, isTrue);
        expect(controller.isAuthenticated, isTrue);
        expect(controller.currentUser?.name, equals('Test Patient'));
        expect(controller.currentUser?.gender, equals('Female'));
      },
    );
  });

  group('AuthController - Password & UI Visibility State', () {
    test('toggles password visibility', () {
      expect(controller.isPasswordVisible, isFalse);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, isTrue);
      controller.togglePasswordVisibility();
      expect(controller.isPasswordVisible, isFalse);
    });

    test('toggles confirm password visibility', () {
      expect(controller.isConfirmPasswordVisible, isFalse);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible, isTrue);
      controller.toggleConfirmPasswordVisibility();
      expect(controller.isConfirmPasswordVisible, isFalse);
    });
  });
}
