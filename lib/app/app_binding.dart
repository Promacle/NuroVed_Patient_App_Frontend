import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/fake/fake_auth_repository.dart';
import '../core/repositories/supabase/supabase_auth_repository.dart';
import '../features/auth/controllers/auth_controller.dart';
import 'app_router.dart';

/// Root dependency injection binding widget.
///
/// Registers [AuthRepository] and [AuthController] as ancestors of MaterialApp.
class AppBinding extends StatelessWidget {
  final Widget child;
  final AuthRepository? authRepository;

  const AppBinding({super.key, required this.child, this.authRepository});

  @override
  Widget build(BuildContext context) {
    final effectiveAuthRepo =
        authRepository ??
        (AppConfig.isBackendConfigured
            ? SupabaseAuthRepository()
            : FakeAuthRepository());

    // Update static router repository for route guards
    AppRouter.authRepository = effectiveAuthRepo;

    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: effectiveAuthRepo),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(authRepository: effectiveAuthRepo),
        ),
      ],
      child: child,
    );
  }
}
