import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/appearance_screen.dart';
import 'package:sreerajp_journal_vault/features/appearance/presentation/language_settings_screen.dart';

/// A MaterialApp driven by the locale controller, like the real app, so a
/// change on the picker re-renders the screen in the new language.
class _Host extends ConsumerWidget {
  const _Host({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      locale: ref.watch(localeControllerProvider).locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      localeResolutionCallback: resolveAppLocale,
      home: home,
    );
  }
}

void main() {
  late InMemoryAppLanguageStore store;

  Widget wrap(Widget home) => ProviderScope(
    overrides: [appLanguageStoreProvider.overrideWithValue(store)],
    child: _Host(home: home),
  );

  setUp(() => store = InMemoryAppLanguageStore(AppLanguage.en));

  testWidgets('offers System default first, then each language endonym', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LanguageSettingsScreen()));
    await tester.pumpAndSettle();

    final tiles = tester
        .widgetList<RadioListTile<AppLanguage>>(
          find.byType(RadioListTile<AppLanguage>),
        )
        .map((tile) => tile.value)
        .toList();
    expect(tiles, AppLanguage.values);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('മലയാളം'), findsOneWidget);
    expect(find.text('संस्कृतम्'), findsOneWidget);
  });

  testWidgets('choosing a language applies at once and is saved', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const LanguageSettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-option-ml')));
    await tester.pumpAndSettle();

    expect(store.read(), AppLanguage.ml);
    // Same screen, now in Malayalam — no restart, no navigation.
    expect(find.byType(LanguageSettingsScreen), findsOneWidget);
    expect(find.text('ഭാഷ'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-option-sa')));
    await tester.pumpAndSettle();
    expect(store.read(), AppLanguage.sa);
    expect(find.text('भाषा'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Appearance card names the current language for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(wrap(const AppearanceScreen()));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Language: English'), findsOneWidget);

    await tester.tap(find.byKey(const Key('appearance-card-language')));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSettingsScreen), findsOneWidget);
    semantics.dispose();
  });
}
