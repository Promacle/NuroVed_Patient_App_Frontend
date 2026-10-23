import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';
import 'package:nuroved_patient/features/auth/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;
  late AuthController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakeAuth = FakeAuthRepository();
    controller = AuthController(authRepository: fakeAuth);
  });

  tearDown(() {
    controller.dispose();
    fakeAuth.dispose();
  });

  group('Session Restoration Lifecycle', () {
    test('returns false when no session is stored', () async {
      final restored = await controller.restoreSession();

      expect(restored, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.currentUser, isNull);
    });

    test('restores active session across restarts', () async {
      // 1. User signs in
      await fakeAuth.signUp(
        email: 'patient@example.com',
        password: 'Password123!',
        name: 'Test Patient',
        acknowledgedTerms: true,
      );

      // Verify signed in
      expect(fakeAuth.currentUser, isNotNull);

      // 2. Simulate app restart with a fresh repository and controller
      final restartedAuth = FakeAuthRepository(
        initialUser: fakeAuth.currentUser,
      );
      final restartedController = AuthController(authRepository: restartedAuth);

      final restored = await restartedController.restoreSession();

      expect(restored, isTrue);
      expect(restartedController.isAuthenticated, isTrue);
      expect(
        restartedController.currentUser?.email,
        equals('patient@example.com'),
      );

      restartedController.dispose();
      restartedAuth.dispose();
    });

    test(
      'handles expired session by purging credentials and returning unauthenticated',
      () async {
        // Sign up and set simulateExpiredSession flag
        await fakeAuth.signUp(
          email: 'patient@example.com',
          password: 'Password123!',
          name: 'Test Patient',
          acknowledgedTerms: true,
        );

        fakeAuth.simulateExpiredSession = true;

        final restored = await controller.restoreSession();

        expect(restored, isFalse);
        expect(controller.isAuthenticated, isFalse);
        expect(controller.currentUser, isNull);
        expect(controller.errorMessage, contains('Session expired'));
      },
    );

    test('cleans up corrupt session storage cleanly', () async {
      // Put corrupt session data in preferences
      SharedPreferences.setMockInitialValues({
        'nuroved_fake_auth_token': 'fake_token',
        'nuroved_fake_auth_user': '{corrupt_json_structure!!!',
      });

      final corruptAuth = FakeAuthRepository();
      final corruptController = AuthController(authRepository: corruptAuth);

      final restored = await corruptController.restoreSession();

      expect(restored, isFalse);
      expect(corruptController.isAuthenticated, isFalse);
      expect(corruptController.currentUser, isNull);

      corruptController.dispose();
      corruptAuth.dispose();
    });
  });
}
