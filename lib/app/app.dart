import 'package:flutter/material.dart';

import '../core/repositories/auth_repository.dart';
import '../core/theme/app_theme.dart';
import 'app_binding.dart';
import 'app_router.dart';

class MyApp extends StatelessWidget {
  final AuthRepository? authRepository;

  const MyApp({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    return AppBinding(
      authRepository: authRepository,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NuroVed',
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.loading,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
