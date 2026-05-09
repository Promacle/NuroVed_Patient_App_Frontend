import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NuroVed',
      theme: AppTheme.lightTheme, // Using the new theme file
      initialRoute: AppRouter.loading,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
