import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application-wide controller managing language detection, persistence, and reactive switching.
///
/// Precedence Algorithm:
/// 1. Returning user with saved preference: Uses saved valid language code ('en', 'gu', 'hi').
///    Does not silently overwrite user preference on subsequent OS locale changes.
/// 2. First launch without preference or corrupt preference:
///    - If device language is Gujarati ('gu', 'gu_IN') -> Gujarati ('gu').
///    - If device language is Hindi ('hi', 'hi_IN') -> Hindi ('hi').
///    - Otherwise -> English ('en').
class LocaleController extends ChangeNotifier {
  static const String prefKeyLanguage = 'app_language_code';

  static const Locale localeEnglish = Locale('en');
  static const Locale localeGujarati = Locale('gu');
  static const Locale localeHindi = Locale('hi');

  static const List<Locale> supportedLocales = [
    localeEnglish,
    localeGujarati,
    localeHindi,
  ];

  static const Map<String, String> nativeLanguageNames = {
    'en': 'English',
    'gu': 'ગુજરાતી',
    'hi': 'हिन्दी',
  };

  static final LocaleController _instance = LocaleController._internal();
  static LocaleController get instance => _instance;
  factory LocaleController() => _instance;

  LocaleController._internal();

  Locale _locale = localeEnglish;
  bool _initialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _initialized;
  String get currentLanguageCode => _locale.languageCode;

  String get currentLanguageNativeName =>
      nativeLanguageNames[_locale.languageCode] ?? 'English';

  /// Initializes the controller by inspecting saved preferences or device locale.
  Future<void> init({SharedPreferences? preferences}) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final savedCode = prefs.getString(prefKeyLanguage);

    _locale = resolveLocale(
      savedPreference: savedCode,
      deviceLocales: ui.PlatformDispatcher.instance.locales,
    );

    _initialized = true;
    notifyListeners();
  }

  /// Sets the application locale immediately, persists to SharedPreferences,
  /// and notifies listeners so MaterialApp rebuilds without an app restart.
  Future<void> setLocale(
    Locale newLocale, {
    SharedPreferences? preferences,
  }) async {
    final code = newLocale.languageCode.toLowerCase();
    if (!isSupported(code)) return;

    if (_locale.languageCode == code) return;

    _locale = Locale(code);
    final prefs = preferences ?? await SharedPreferences.getInstance();
    await prefs.setString(prefKeyLanguage, code);

    notifyListeners();
  }

  /// Changes language by string code ('en', 'gu', 'hi').
  Future<void> setLanguageCode(
    String code, {
    SharedPreferences? preferences,
  }) async {
    await setLocale(Locale(code), preferences: preferences);
  }

  /// Deterministic resolution algorithm matching task requirements.
  static Locale resolveLocale({
    String? savedPreference,
    List<Locale>? deviceLocales,
  }) {
    // 1. Returning user with valid saved preference
    if (savedPreference != null) {
      final normalized = savedPreference.trim().toLowerCase();
      if (isSupported(normalized)) {
        return Locale(normalized);
      }
      // If corrupted or unsupported, fall through to device detection
    }

    // 2. First launch or invalid saved preference: Inspect device locales
    final candidateLocales =
        deviceLocales ?? ui.PlatformDispatcher.instance.locales;
    for (final loc in candidateLocales) {
      final lang = loc.languageCode.toLowerCase();
      if (lang == 'gu') {
        return localeGujarati;
      }
      if (lang == 'hi') {
        return localeHindi;
      }
      if (lang == 'en') {
        return localeEnglish;
      }
    }

    // 3. Fallback to English
    return localeEnglish;
  }

  /// Checks if a language code is supported.
  static bool isSupported(String code) {
    final lang = code.toLowerCase();
    return lang == 'en' || lang == 'gu' || lang == 'hi';
  }

  /// Returns the native representation of a language name (e.g. ગુજરાતી, हिन्दी).
  static String getNativeName(String languageCode) {
    return nativeLanguageNames[languageCode.toLowerCase()] ?? languageCode;
  }

  /// Reset state for unit and widget testing.
  @visibleForTesting
  void resetForTesting({Locale? initialLocale}) {
    _locale = initialLocale ?? localeEnglish;
    _initialized = true;
    notifyListeners();
  }
}
