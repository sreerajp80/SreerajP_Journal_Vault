import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/accent_color_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/appearance_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/theme_mode_settings_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/typography_settings_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _FakeThemeModeStore extends ThemeModeStore {
  AppThemeMode appMode = AppThemeMode.light;

  @override
  ThemeMode read() => appMode.toFlutterThemeMode();

  @override
  AppThemeMode readAppThemeMode() => appMode;

  @override
  Future<void> save(ThemeMode m) async {
    appMode = switch (m) {
      ThemeMode.dark => AppThemeMode.dark,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.system => AppThemeMode.system,
    };
  }

  @override
  Future<void> saveAppThemeMode(AppThemeMode m) async {
    appMode = m;
  }
}

Widget _wrap(Widget child, {ThemeModeStore? store}) {
  return ProviderScope(
    overrides: [
      themeModeStoreProvider.overrideWithValue(store ?? _FakeThemeModeStore()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  setUp(() {});

  testWidgets(
    'AppearanceScreen renders Theme Mode, Accent Color, and Typography cards',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const AppearanceScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(
        find.byKey(const Key('appearance-card-theme-mode')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('appearance-card-accent-color')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('appearance-card-typography')),
        findsOneWidget,
      );

      // Tap Theme Mode card opens ThemeModeSettingsScreen
      await tester.tap(find.byKey(const Key('appearance-card-theme-mode')));
      await tester.pumpAndSettle();

      expect(find.text('THEME MODE'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Paper / Sepia'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('OLED / True Black'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    },
  );

  testWidgets(
    'ThemeModeSettingsScreen switches between light, sepia, dark, oled, and system',
    (tester) async {
      final store = _FakeThemeModeStore();
      await tester.pumpWidget(
        _wrap(const ThemeModeSettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // Tap Paper / Sepia
      await tester.tap(find.byKey(const Key('theme-mode-option-sepia')));
      await tester.pumpAndSettle();
      expect(store.appMode, AppThemeMode.sepia);
      expect(store.read(), ThemeMode.light);

      // Tap Dark
      await tester.tap(find.byKey(const Key('theme-mode-option-dark')));
      await tester.pumpAndSettle();
      expect(store.appMode, AppThemeMode.dark);
      expect(store.read(), ThemeMode.dark);

      // Tap OLED / True Black
      await tester.tap(find.byKey(const Key('theme-mode-option-oled')));
      await tester.pumpAndSettle();
      expect(store.appMode, AppThemeMode.oled);
      expect(store.read(), ThemeMode.dark);

      // Tap System
      await tester.tap(find.byKey(const Key('theme-mode-option-system')));
      await tester.pumpAndSettle();
      expect(store.appMode, AppThemeMode.system);
      expect(store.read(), ThemeMode.system);
    },
  );

  testWidgets('AppearanceScreen navigates to TypographySettingsScreen on tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const AppearanceScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('appearance-card-typography')));
    await tester.pumpAndSettle();

    expect(find.byType(TypographySettingsScreen), findsOneWidget);
    expect(find.text('Reading Typography'), findsOneWidget);
  });

  testWidgets(
    'AccentColorSettingsScreen renders preview, presets and reset button',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const AccentColorSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Accent Color'), findsOneWidget);
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('PRESETS'), findsOneWidget);
      expect(find.text('CUSTOM COLOR WHEEL'), findsOneWidget);
      expect(
        find.byKey(const Key('accent-reset-default-button')),
        findsOneWidget,
      );

      // Tap reset button
      await tester.tap(find.byKey(const Key('accent-reset-default-button')));
      await tester.pumpAndSettle();
    },
  );
}
