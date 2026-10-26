import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/localization/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController Resolution Algorithm', () {
    test(
      '1. First-launch falls back to English on unsupported device locale',
      () {
        final resolved = LocaleController.resolveLocale(
          savedPreference: null,
          deviceLocales: [const Locale('fr', 'FR'), const Locale('de', 'DE')],
        );
        expect(resolved, equals(LocaleController.localeEnglish));
      },
    );

    test('2. First-launch Gujarati on gu / gu_IN device locale', () {
      final resolvedGu = LocaleController.resolveLocale(
        savedPreference: null,
        deviceLocales: [const Locale('gu', 'IN')],
      );
      expect(resolvedGu, equals(LocaleController.localeGujarati));

      final resolvedGuBare = LocaleController.resolveLocale(
        savedPreference: null,
        deviceLocales: [const Locale('gu')],
      );
      expect(resolvedGuBare, equals(LocaleController.localeGujarati));
    });

    test('3. First-launch Hindi on hi / hi_IN device locale', () {
      final resolvedHi = LocaleController.resolveLocale(
        savedPreference: null,
        deviceLocales: [const Locale('hi', 'IN')],
      );
      expect(resolvedHi, equals(LocaleController.localeHindi));

      final resolvedHiBare = LocaleController.resolveLocale(
        savedPreference: null,
        deviceLocales: [const Locale('hi')],
      );
      expect(resolvedHiBare, equals(LocaleController.localeHindi));
    });

    test(
      '4. Returning user saved preference strictly overrides device locale',
      () {
        // User chose English manually, even though phone OS is Hindi
        final resolvedEn = LocaleController.resolveLocale(
          savedPreference: 'en',
          deviceLocales: [const Locale('hi', 'IN')],
        );
        expect(resolvedEn, equals(LocaleController.localeEnglish));

        // User chose Gujarati manually, even though phone OS is English
        final resolvedGu = LocaleController.resolveLocale(
          savedPreference: 'gu',
          deviceLocales: [const Locale('en', 'US')],
        );
        expect(resolvedGu, equals(LocaleController.localeGujarati));

        // User chose Hindi manually, even though phone OS is English
        final resolvedHi = LocaleController.resolveLocale(
          savedPreference: 'hi',
          deviceLocales: [const Locale('en', 'US')],
        );
        expect(resolvedHi, equals(LocaleController.localeHindi));
      },
    );

    test('5. Defense against corrupt or unsupported saved value', () {
      // Corrupt value with German device -> falls back safely to English
      final resolvedCorrupt = LocaleController.resolveLocale(
        savedPreference: 'corrupted_lang_999',
        deviceLocales: [const Locale('de', 'DE')],
      );
      expect(resolvedCorrupt, equals(LocaleController.localeEnglish));

      // Corrupt value with Hindi device -> falls back to detected Hindi
      final resolvedCorruptWithHi = LocaleController.resolveLocale(
        savedPreference: 'invalid_code',
        deviceLocales: [const Locale('hi', 'IN')],
      );
      expect(resolvedCorruptWithHi, equals(LocaleController.localeHindi));
    });

    test('6. Empty or null device locales gracefully defaults to English', () {
      final resolvedEmpty = LocaleController.resolveLocale(
        savedPreference: null,
        deviceLocales: [],
      );
      expect(resolvedEmpty, equals(LocaleController.localeEnglish));
    });
  });

  group('LocaleController State & Persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('init loads saved preference from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        LocaleController.prefKeyLanguage: 'gu',
      });
      final prefs = await SharedPreferences.getInstance();

      final controller = LocaleController.instance;
      await controller.init(preferences: prefs);

      expect(controller.locale, equals(const Locale('gu')));
      expect(controller.currentLanguageCode, equals('gu'));
      expect(controller.currentLanguageNativeName, equals('ગુજરાતી'));
      expect(controller.isInitialized, isTrue);
    });

    test(
      'setLanguageCode updates locale, notifies listeners, and persists',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final controller = LocaleController.instance;
        await controller.init(preferences: prefs);

        bool notified = false;
        void listener() => notified = true;
        controller.addListener(listener);

        await controller.setLanguageCode('hi', preferences: prefs);

        expect(notified, isTrue);
        expect(controller.locale, equals(const Locale('hi')));
        expect(controller.currentLanguageCode, equals('hi'));
        expect(controller.currentLanguageNativeName, equals('हिन्दी'));
        expect(prefs.getString(LocaleController.prefKeyLanguage), equals('hi'));

        controller.removeListener(listener);
      },
    );

    test(
      'setLocale with duplicate code does not trigger redundant notifications',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final controller = LocaleController.instance;
        await controller.init(preferences: prefs);
        await controller.setLanguageCode('en', preferences: prefs);

        int notificationCount = 0;
        void listener() => notificationCount++;
        controller.addListener(listener);

        await controller.setLanguageCode('en', preferences: prefs);
        expect(notificationCount, equals(0));

        controller.removeListener(listener);
      },
    );

    test('isSupported and getNativeName validate correctly', () {
      expect(LocaleController.isSupported('en'), isTrue);
      expect(LocaleController.isSupported('EN'), isTrue);
      expect(LocaleController.isSupported('gu'), isTrue);
      expect(LocaleController.isSupported('hi'), isTrue);
      expect(LocaleController.isSupported('fr'), isFalse);
      expect(LocaleController.isSupported('es'), isFalse);

      expect(LocaleController.getNativeName('en'), equals('English'));
      expect(LocaleController.getNativeName('gu'), equals('ગુજરાતી'));
      expect(LocaleController.getNativeName('hi'), equals('हिन्दी'));
    });
  });

  group('ARB Catalog 100% Parity Test', () {
    test(
      'app_en.arb, app_gu.arb, and app_hi.arb have identical keys',
      () async {
        final enFile = File('lib/l10n/app_en.arb');
        final guFile = File('lib/l10n/app_gu.arb');
        final hiFile = File('lib/l10n/app_hi.arb');

        expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');
        expect(guFile.existsSync(), isTrue, reason: 'app_gu.arb must exist');
        expect(hiFile.existsSync(), isTrue, reason: 'app_hi.arb must exist');

        final Map<String, dynamic> enMap = jsonDecode(
          await enFile.readAsString(),
        );
        final Map<String, dynamic> guMap = jsonDecode(
          await guFile.readAsString(),
        );
        final Map<String, dynamic> hiMap = jsonDecode(
          await hiFile.readAsString(),
        );

        final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
        final guKeys = guMap.keys.where((k) => !k.startsWith('@')).toSet();
        final hiKeys = hiMap.keys.where((k) => !k.startsWith('@')).toSet();

        final missingInGu = enKeys.difference(guKeys);
        final missingInHi = enKeys.difference(hiKeys);
        final extraInGu = guKeys.difference(enKeys);
        final extraInHi = hiKeys.difference(enKeys);

        expect(
          missingInGu,
          isEmpty,
          reason: 'Keys missing in Gujarati catalog: $missingInGu',
        );
        expect(
          missingInHi,
          isEmpty,
          reason: 'Keys missing in Hindi catalog: $missingInHi',
        );
        expect(
          extraInGu,
          isEmpty,
          reason: 'Extra keys in Gujarati catalog not in English: $extraInGu',
        );
        expect(
          extraInHi,
          isEmpty,
          reason: 'Extra keys in Hindi catalog not in English: $extraInHi',
        );

        expect(guKeys.length, equals(enKeys.length));
        expect(hiKeys.length, equals(enKeys.length));
      },
    );
  });
}
