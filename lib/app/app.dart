import 'package:flutter/material.dart';

import '../core/localization/locale_controller.dart';
import '../core/repositories/auth_repository.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'app_binding.dart';
import 'app_router.dart';

class MyApp extends StatelessWidget {
  final AuthRepository? authRepository;
  final Locale? initialLocale;

  const MyApp({super.key, this.authRepository, this.initialLocale});

  @override
  Widget build(BuildContext context) {
    final localeController = LocaleController.instance;

    return AppBinding(
      authRepository: authRepository,
      child: ListenableBuilder(
        listenable: localeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NuroVed',
            theme: AppTheme.lightTheme,
            initialRoute: AppRouter.loading,
            onGenerateRoute: AppRouter.generateRoute,
            locale: initialLocale ?? localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (initialLocale != null) return initialLocale;
              if (localeController.isInitialized) {
                return localeController.locale;
              }
              return LocaleController.resolveLocale(
                deviceLocales: deviceLocale != null ? [deviceLocale] : null,
              );
            },
          );
        },
      ),
    );
  }
}
