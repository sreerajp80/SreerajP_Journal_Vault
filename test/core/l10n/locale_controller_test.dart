import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';

void main() {
  group('AppLanguage', () {
    test('system has no locale; the others map to their language code', () {
      expect(AppLanguage.system.locale, isNull);
      expect(AppLanguage.en.locale, const Locale('en'));
      expect(AppLanguage.ml.locale, const Locale('ml'));
      expect(AppLanguage.sa.locale, const Locale('sa'));
    });

    test('unknown or missing stored values fall back to system', () {
      expect(AppLanguage.fromStorage(null), AppLanguage.system);
      expect(AppLanguage.fromStorage('hi'), AppLanguage.system);
      expect(AppLanguage.fromStorage('sa'), AppLanguage.sa);
    });
  });

  group('SharedPreferencesAppLanguageStore', () {
    test('persists under app_language with the standard values', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = SharedPreferencesAppLanguageStore(prefs);

      expect(store.read(), AppLanguage.system);
      await store.save(AppLanguage.ml);
      expect(prefs.getString('app_language'), 'ml');
      expect(SharedPreferencesAppLanguageStore(prefs).read(), AppLanguage.ml);

      await store.save(AppLanguage.system);
      expect(prefs.getString('app_language'), 'system');
    });
  });

  group('LocaleController', () {
    test('starts from the store and saves every change', () async {
      final store = InMemoryAppLanguageStore(AppLanguage.en);
      final container = ProviderContainer(
        overrides: [appLanguageStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      expect(container.read(localeControllerProvider), AppLanguage.en);

      await container
          .read(localeControllerProvider.notifier)
          .setLanguage(AppLanguage.sa);
      expect(container.read(localeControllerProvider), AppLanguage.sa);
      expect(store.read(), AppLanguage.sa);
    });

    test('rolls back when saving fails', () async {
      final container = ProviderContainer(
        overrides: [
          appLanguageStoreProvider.overrideWithValue(_FailingStore()),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(localeControllerProvider.notifier)
            .setLanguage(AppLanguage.ml),
        throwsA(isA<StateError>()),
      );
      expect(container.read(localeControllerProvider), AppLanguage.system);
    });
  });

  group('resolveAppLocale', () {
    test('keeps a supported device language, otherwise English', () {
      expect(
        resolveAppLocale(const Locale('ml', 'IN'), appSupportedLocales),
        const Locale('ml'),
      );
      expect(
        resolveAppLocale(const Locale('sa'), appSupportedLocales),
        const Locale('sa'),
      );
      expect(
        resolveAppLocale(const Locale('hi', 'IN'), appSupportedLocales),
        const Locale('en'),
      );
      expect(resolveAppLocale(null, appSupportedLocales), const Locale('en'));
    });

    test('supported locales are exactly en, ml, sa in that order', () {
      expect(appSupportedLocales, const [
        Locale('en'),
        Locale('ml'),
        Locale('sa'),
      ]);
    });
  });
}

class _FailingStore implements AppLanguageStore {
  @override
  AppLanguage read() => AppLanguage.system;

  @override
  Future<void> save(AppLanguage language) async =>
      throw StateError('disk full');
}
