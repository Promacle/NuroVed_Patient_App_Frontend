import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// Extension on [BuildContext] for ergonomic and safe access to [AppLocalizations].
extension AppLocalizationsContext on BuildContext {
  /// Returns the nearest [AppLocalizations] in the widget tree.
  ///
  /// If no [AppLocalizations] delegate is found in the current context (such as
  /// when a widget is pumped in an isolated unit/widget test without delegates),
  /// this safely falls back to [AppLocalizationsEn] rather than throwing a null exception.
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}
