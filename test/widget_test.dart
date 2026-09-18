import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'app_test_support.dart';

void main() {
  late AppDatabase testDatabase;
  late FakeBiometricAuthenticator fakeBiometric;
  late InMemoryAppPinKeystore fakePinKeystore;

  setUp(() async {
    testDatabase = AppDatabase.forExecutor(NativeDatabase.memory());
    fakeBiometric = FakeBiometricAuthenticator();
    fakePinKeystore = InMemoryAppPinKeystore();
    // Seed lock mode so tests bypass the first-launch setup screen.
    await testDatabase.appSecurityDao.updateLockState(
      const AppSecurityCompanion(
        lockMode: Value('phone_lock'),
        isLocked: Value(true),
      ),
    );
  });

  tearDown(() async {
    await testDatabase.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    ThemeModeStore? themeModeStore,
    List<Override> overrides = const [],
  }) async {
    // Use a tall surface so the rebuilt 5-section Settings list (with the
    // Coming Soon, Storage, and Permissions rows) renders all chips inside
    // the cache extent.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: testDatabase,
        themeModeStore: themeModeStore,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(fakeBiometric),
          appPinKeystoreProvider.overrideWithValue(fakePinKeystore),
          ...overrides,
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('App navigates to shell and updates theme from settings', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Journal is locked'), findsOneWidget);
    expect(find.text('Use phone lock'), findsOneWidget);

    await unlockPhoneLock(tester);

    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);

    // Theme now lives on the Appearance section page.
    await tester.tap(find.byKey(const Key('settings-card-appearance')));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.byKey(const Key('appearance-card-theme-mode')), findsOneWidget);
    expect(
      find.byKey(const Key('appearance-card-accent-color')),
      findsOneWidget,
    );

    // Tap into Theme Mode settings
    await tester.tap(find.byKey(const Key('appearance-card-theme-mode')));
    await tester.pumpAndSettle();

    expect(find.text('THEME MODE'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(
      find.text('Theme updated: Dark mode is now active.'),
      findsOneWidget,
    );
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await disposeApp(tester);
  });

  testWidgets('Theme preference restores on app restart', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'theme_mode_v1': 'dark',
    });
    final preferences = await SharedPreferences.getInstance();

    await pumpApp(
      tester,
      themeModeStore: SharedPreferencesThemeModeStore(preferences),
    );

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await disposeApp(tester);
  });

  testWidgets('Theme save failure reverts selection and shows error toast', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, themeModeStore: FailingThemeModeStore());

    await unlockPhoneLock(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-card-appearance')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('appearance-card-theme-mode')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save theme setting. Please try again.'),
      findsOneWidget,
    );
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await disposeApp(tester);
  });

  testWidgets('About screen renders required metadata fields', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      overrides: <Override>[
        aboutMetadataProvider.overrideWith(
          (ref) async => const AboutMetadata(
            appName: LocalizedText.plain('SreerajP_Journal_Vault'),
            description: LocalizedText.plain('A private, encrypted journal.'),
            versionBuild: '1.0.0 (build 7)',
            lastBuildTimestamp: '2026-03-19 12:34:56',
            details: {
              'author': LocalizedText.plain('Sreeraj P'),
              'aiUsed': LocalizedText.plain('OpenAI Codex'),
              'ideUsed': LocalizedText.plain('Visual Studio Code'),
            },
          ),
        ),
      ],
    );

    await unlockPhoneLock(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Security'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // The About card opens the About screen directly.
    await tester.tap(find.byKey(const Key('settings-card-about')));
    await tester.pumpAndSettle();

    expect(find.text('SreerajP_Journal_Vault'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Sreeraj P'), findsOneWidget);
    expect(find.text('AI used'), findsOneWidget);
    expect(find.text('OpenAI Codex'), findsOneWidget);
    expect(find.text('IDE used'), findsOneWidget);
    expect(find.text('Visual Studio Code'), findsOneWidget);
    expect(find.text('App Version / Build'), findsOneWidget);
    expect(find.text('1.0.0 (build 7)'), findsOneWidget);
    expect(find.text('Last Build Timestamp'), findsOneWidget);
    expect(find.text('2026-03-19 12:34:56'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('Lock mode switch persists and relocks on app lifecycle change', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await unlockPhoneLock(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-card-security')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Separate App Lock'));
    await tester.pumpAndSettle();

    expect(find.text('Switch lock mode?'), findsOneWidget);
    expect(
      find.text(
        'This will switch app protection to Separate App Lock and disable Phone Lock. Continue?',
      ),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Switch'), findsOneWidget);

    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();

    // Switching to app_lock now requires setting a PIN.
    expect(find.text('Set app-lock PIN'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('settings-pin-field')), '1234');
    await tester.enterText(
      find.byKey(const Key('settings-pin-confirm-field')),
      '1234',
    );
    await tester.tap(find.byKey(const Key('settings-pin-save-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Lock mode updated: Separate App Lock is now active.'),
      findsOneWidget,
    );

    final securitySettings = await testDatabase.appSecurityDao
        .getSecuritySettings();
    expect(securitySettings.lockMode, 'app_lock');

    // switchLockMode immediately locks the app, so the lock gate is already
    // shown. Pause/resume should leave it locked.
    expect(find.text('Journal is locked'), findsOneWidget);

    await cycleLifecyclePauseResume(tester);

    expect(find.text('Journal is locked'), findsOneWidget);
    expect(find.text('Separate App Lock'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-pin-field')), findsOneWidget);

    // Wrong PIN denied.
    await tester.enterText(find.byKey(const Key('app-lock-pin-field')), '0000');
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect PIN.'), findsOneWidget);

    // Correct PIN unlocks.
    await tester.enterText(find.byKey(const Key('app-lock-pin-field')), '1234');
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);

    await disposeApp(tester);
  });

  testWidgets('Home shows empty then journal CRUD updates list', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await unlockPhoneLock(tester);

    expect(find.text('No journals yet'), findsOneWidget);

    await tester.tap(find.text('New journal'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Work');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Daily planning notes',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Comma-separated tags'),
      'important, focus',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('#important'), findsOneWidget);
    expect(find.text('#focus'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit journal'));
    await tester.pumpAndSettle();

    final editTitle = find.widgetWithText(TextFormField, 'Title');
    await tester.enterText(editTitle, 'Work Updated');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Work Updated'), findsOneWidget);
    expect(find.text('Work'), findsNothing);

    await tester.tap(find.byTooltip('Delete journal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No journals yet'), findsOneWidget);

    await disposeApp(tester);
  });
}
