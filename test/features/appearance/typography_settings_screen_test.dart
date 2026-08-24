import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/typography_settings_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _FakeTypographyStore implements TypographyStore {
  TypographySettings settings;
  _FakeTypographyStore([this.settings = const TypographySettings()]);

  @override
  TypographySettings read() => settings;

  @override
  Future<void> save(TypographySettings s) async {
    settings = s;
  }
}

Widget _wrap(Widget child, {TypographyStore? store}) {
  return ProviderScope(
    overrides: [
      if (store != null) typographyStoreProvider.overrideWithValue(store),
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
  group('TypographySettings & Controller tests', () {
    test('TypographySettings defaults to sans and 16pt', () {
      const settings = TypographySettings();
      expect(settings.fontFamily, EntryFontFamily.sans);
      expect(settings.fontSize, 16.0);
      expect(settings.fontFamily.fontName, isNull);
      expect(EntryFontFamily.serif.fontName, 'serif');
      expect(EntryFontFamily.monospace.fontName, 'monospace');
    });

    test(
      'SharedPreferencesTypographyStore saves and restores correctly',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final prefs = await SharedPreferences.getInstance();
        final store = SharedPreferencesTypographyStore(prefs);

        expect(store.read().fontFamily, EntryFontFamily.sans);
        expect(store.read().fontSize, 16.0);

        await store.save(
          const TypographySettings(
            fontFamily: EntryFontFamily.serif,
            fontSize: 20.0,
          ),
        );

        expect(prefs.getString('entry_font_family_v1'), 'serif');
        expect(prefs.getDouble('entry_font_size_v1'), 20.0);

        final restored = store.read();
        expect(restored.fontFamily, EntryFontFamily.serif);
        expect(restored.fontSize, 20.0);
      },
    );
  });

  group('TypographySettingsScreen widget tests', () {
    testWidgets('renders preview card, font options, slider, and presets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = _FakeTypographyStore();
      await tester.pumpWidget(
        _wrap(const TypographySettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reading Typography'), findsOneWidget);
      expect(find.text('LIVE PREVIEW'), findsOneWidget);
      expect(find.text('Quiet Reflections'), findsOneWidget);
      expect(find.text('BODY FONT FAMILY'), findsOneWidget);
      expect(find.text('BODY FONT SIZE'), findsOneWidget);

      // Verify font options exist
      expect(find.byKey(const Key('typography-font-sans')), findsOneWidget);
      expect(find.byKey(const Key('typography-font-serif')), findsOneWidget);
      expect(
        find.byKey(const Key('typography-font-monospace')),
        findsOneWidget,
      );

      // Verify slider and presets exist
      expect(find.byKey(const Key('typography-size-slider')), findsOneWidget);
      expect(find.byKey(const Key('typography-preset-small')), findsOneWidget);
      expect(find.byKey(const Key('typography-preset-large')), findsOneWidget);
    });

    testWidgets('selecting font family updates store', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = _FakeTypographyStore();
      await tester.pumpWidget(
        _wrap(const TypographySettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // Tap Book Serif
      await tester.tap(find.byKey(const Key('typography-font-serif')));
      await tester.pumpAndSettle();
      expect(store.settings.fontFamily, EntryFontFamily.serif);

      // Tap Monospace
      await tester.tap(find.byKey(const Key('typography-font-monospace')));
      await tester.pumpAndSettle();
      expect(store.settings.fontFamily, EntryFontFamily.monospace);
    });

    testWidgets('tapping preset chips updates font size', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = _FakeTypographyStore();
      await tester.pumpWidget(
        _wrap(const TypographySettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // Tap Large preset (20pt)
      await tester.tap(find.byKey(const Key('typography-preset-large')));
      await tester.pumpAndSettle();
      expect(store.settings.fontSize, 20.0);

      // Tap Small preset (14pt)
      await tester.tap(find.byKey(const Key('typography-preset-small')));
      await tester.pumpAndSettle();
      expect(store.settings.fontSize, 14.0);
    });

    testWidgets('reset button resets typography to defaults', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = _FakeTypographyStore(
        const TypographySettings(
          fontFamily: EntryFontFamily.monospace,
          fontSize: 22.0,
        ),
      );
      await tester.pumpWidget(
        _wrap(const TypographySettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      expect(store.settings.fontFamily, EntryFontFamily.monospace);
      expect(store.settings.fontSize, 22.0);

      await tester.tap(find.byKey(const Key('typography-reset-button')));
      await tester.pumpAndSettle();

      expect(store.settings.fontFamily, EntryFontFamily.sans);
      expect(store.settings.fontSize, 16.0);
      expect(find.text('Typography reset to default.'), findsOneWidget);
    });
  });
}
