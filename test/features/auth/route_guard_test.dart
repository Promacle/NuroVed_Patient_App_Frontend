import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthRepository fakeAuth;

  setUp(() {
    fakeAuth = FakeAuthRepository();
    AppRouter.authRepository = fakeAuth;
  });

  tearDown(() {
    fakeAuth.dispose();
  });

  group('Route Guards - Unauthenticated Access', () {
    testWidgets(
      'unauthenticated user accessing protected /home is redirected to /login',
      (tester) async {
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.home),
        );

        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.name, equals(AppRouter.login));
      },
    );

    testWidgets(
      'unauthenticated user accessing protected /records is redirected to /login',
      (tester) async {
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.records),
        );

        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.name, equals(AppRouter.login));
      },
    );

    testWidgets(
      'unauthenticated user accessing protected /visits is redirected to /login',
      (tester) async {
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.visits),
        );

        expect(route, isA<MaterialPageRoute>());
        expect(route.settings.name, equals(AppRouter.login));
      },
    );

    testWidgets('unauthenticated user is allowed to access public routes', (
      tester,
    ) async {
      final loginRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.login),
      );
      expect(loginRoute.settings.name, equals(AppRouter.login));

      final signupRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.signup),
      );
      expect(signupRoute.settings.name, equals(AppRouter.signup));

      final forgotRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.forgotPassword),
      );
      expect(forgotRoute.settings.name, equals(AppRouter.forgotPassword));

      final loadingRoute = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.loading),
      );
      expect(loadingRoute.settings.name, equals(AppRouter.loading));
    });
  });

  group('Route Guards - Authenticated Access', () {
    setUp(() async {
      await fakeAuth.signUp(
        email: 'authenticated@example.com',
        password: 'Password123!',
        name: 'Authenticated User',
        acknowledgedTerms: true,
      );
    });

    testWidgets(
      'authenticated user navigating to /login is redirected to /home',
      (tester) async {
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.login),
        );

        expect(route.settings.name, equals(AppRouter.home));
      },
    );

    testWidgets(
      'authenticated user navigating to /signup is redirected to /home',
      (tester) async {
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.signup),
        );

        expect(route.settings.name, equals(AppRouter.home));
      },
    );

    testWidgets(
      'authenticated user navigating to /splash is redirected to /home',
      (tester) async {
        final route = AppRouter.generateRoute(
          const RouteSettings(name: AppRouter.splash),
        );

        expect(route.settings.name, equals(AppRouter.home));
      },
    );

    testWidgets('authenticated user can access protected /home', (
      tester,
    ) async {
      final route = AppRouter.generateRoute(
        const RouteSettings(name: AppRouter.home),
      );

      expect(route.settings.name, equals(AppRouter.home));
    });
  });
}
