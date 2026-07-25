import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

void main() {
  late AppDatabase testDatabase;
  late _FakeBiometricAuthenticator fakeBiometric;
  late _InMemoryAppPinKeystore fakePinKeystore;

  setUp(() async {
    testDatabase = AppDatabase.forExecutor(NativeDatabase.memory());
    fakeBiometric = _FakeBiometricAuthenticator();
    fakePinKeystore = _InMemoryAppPinKeystore();
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

    expect(find.text('App Lock Gate'), findsOneWidget);
    expect(find.text('Unlock with Phone Lock'), findsOneWidget);

    await _unlockPhoneLock(tester);

    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Security'), findsOneWidget);
    expect(find.text('App Lock Mode'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Appearance'),
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(
      find.text('Choose how SreerajP_Journal_Vault looks.'),
      findsOneWidget,
    );
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );

    await tester.tap(find.byKey(const Key('settings-theme-chip-dark')));
    await tester.pumpAndSettle();

    expect(
      find.text('Theme updated: Dark mode is now active.'),
      findsOneWidget,
    );
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await _disposeApp(tester);
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

    await _disposeApp(tester);
  });

  testWidgets('Theme save failure reverts selection and shows error toast', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, themeModeStore: _FailingThemeModeStore());

    await _unlockPhoneLock(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Appearance'),
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.dragUntilVisible(
      find.text('Dark'),
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );

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

    await _disposeApp(tester);
  });

  testWidgets('About screen renders required metadata fields', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      overrides: <Override>[
        aboutMetadataProvider.overrideWith(
          (ref) async => const AboutMetadata(
            appName: 'SreerajP_Journal_Vault',
            description: 'A private, encrypted journal.',
            versionBuild: '1.0.0 (build 7)',
            lastBuildTimestamp: '2026-03-19 12:34:56',
            details: {
              'Author': 'Sreeraj P',
              'AI Used': 'OpenAI Codex',
              'IDE Used': 'Visual Studio Code',
            },
          ),
        ),
      ],
    );

    await _unlockPhoneLock(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Security'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('About this app'),
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    expect(find.text('About this app'), findsOneWidget);

    await tester.tap(find.text('About this app'));
    await tester.pumpAndSettle();

    expect(find.text('SreerajP_Journal_Vault'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.text('Sreeraj P'), findsOneWidget);
    expect(find.text('AI Used'), findsOneWidget);
    expect(find.text('OpenAI Codex'), findsOneWidget);
    expect(find.text('IDE Used'), findsOneWidget);
    expect(find.text('Visual Studio Code'), findsOneWidget);
    expect(find.text('App Version / Build'), findsOneWidget);
    expect(find.text('1.0.0 (build 7)'), findsOneWidget);
    expect(find.text('Last Build Timestamp'), findsOneWidget);
    expect(find.text('2026-03-19 12:34:56'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('Lock mode switch persists and relocks on app lifecycle change', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await _unlockPhoneLock(tester);
    await tester.tap(find.text('Settings'));
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
    await tester.enterText(
      find.byKey(const Key('settings-pin-field')),
      '1234',
    );
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
    expect(find.text('App Lock Gate'), findsOneWidget);

    await _cycleLifecyclePauseResume(tester);

    expect(find.text('App Lock Gate'), findsOneWidget);
    expect(find.text('Separate App Lock'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-pin-field')), findsOneWidget);

    // Wrong PIN denied.
    await tester.enterText(
      find.byKey(const Key('app-lock-pin-field')),
      '0000',
    );
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect PIN.'), findsOneWidget);

    // Correct PIN unlocks.
    await tester.enterText(
      find.byKey(const Key('app-lock-pin-field')),
      '1234',
    );
    await tester.tap(find.byKey(const Key('app-lock-unlock-button')));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);

    await _disposeApp(tester);
  });

  testWidgets('Home shows empty then journal CRUD updates list', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await _unlockPhoneLock(tester);

    expect(find.text('No journals yet'), findsOneWidget);

    await tester.tap(find.text('New journal'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Work');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Daily planning notes',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tags (comma separated)'),
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

    await _disposeApp(tester);
  });

  testWidgets('Locked journals require password before detail access', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await _unlockPhoneLock(tester);

    await tester.tap(find.text('New journal'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Vault',
    );
    await tester.tap(find.text('Lock journal'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-password-field')),
      'secret-pass',
    );
    await tester.enterText(
      find.byKey(const Key('journal-password-confirm-field')),
      'secret-pass',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final journal = (await testDatabase.journalsDao.getAllJournals()).single;
    expect(journal.isLocked, isTrue);
    expect(journal.credentialReference, isNotNull);
    expect(journal.passwordSaltBase64, isNot(contains('secret-pass')));
    expect(journal.passwordVerifierBase64, isNot(contains('secret-pass')));

    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Journal is locked'), findsOneWidget);
    expect(
      find.byKey(const Key('journal-unlock-password-field')),
      findsOneWidget,
    );
    expect(find.text('Add entry'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('journal-unlock-password-field')),
      'wrong-pass',
    );
    await tester.tap(find.byKey(const Key('journal-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect password.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('journal-unlock-password-field')),
      'secret-pass',
    );
    await tester.tap(find.byKey(const Key('journal-unlock-button')));
    await tester.pumpAndSettle();

    expect(find.text('Add entry'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('Journal detail groups entries and reacts to entry CRUD', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await _unlockPhoneLock(tester);

    await tester.tap(find.text('New journal'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Travel',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final createdJournal =
        (await testDatabase.journalsDao.getAllJournals()).single;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await testDatabase.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: createdJournal.id,
        title: const Value('Yesterday note'),
        contentJson: const Value('[{"insert":"Packed bags\\n"}]'),
        plainText: const Value('Packed bags'),
        entryDate: Value(yesterday),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();

    expect(find.text('Unlocked'), findsOneWidget);
    expect(find.text(_formatDate(yesterday)), findsOneWidget);
    expect(find.text('Yesterday note'), findsOneWidget);

    await tester.tap(find.text('Add entry'));
    await tester.pumpAndSettle();
    // The new-entry flow now opens a template chooser; pick Blank.
    await tester.tap(find.byKey(const Key('entry-template-blank')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('entry-title-field')),
      'Today note',
    );
    // Editor's Save is a tooltip-only IconButton in the AppBar; it persists
    // the entry but does not pop. Use byTooltip and then page back to land
    // on the journal detail with the refreshed entries list.
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Today note'), findsOneWidget);
    expect(find.text(_formatDate(DateTime.now())), findsOneWidget);

    await tester.tap(find.text('Yesterday note'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('entry-title-field')),
      'Yesterday note updated',
    );
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Yesterday note updated'), findsOneWidget);
    expect(find.text('Yesterday note'), findsNothing);
    final updatedYesterday =
        (await testDatabase.entriesDao.getEntriesForJournal(
          createdJournal.id,
        )).firstWhere((entry) => entry.title == 'Yesterday note updated');
    // Quill's toPlainText appends a trailing newline; strip before comparing.
    expect(updatedYesterday.plainText?.trimRight(), 'Packed bags');
    expect(updatedYesterday.contentJson, contains('Packed bags'));

    await tester.tap(find.text('Yesterday note updated'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('entry-delete-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Yesterday note updated'), findsNothing);
    expect(find.text('Today note'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets(
    'Search groups matches, filters by type, and reloads saved presets',
    (WidgetTester tester) async {
      final travelJournalId = await testDatabase.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Travel Plans'),
      );
      final lockedJournalId = await testDatabase.journalsDao.createJournal(
        JournalsCompanion.insert(
          title: 'Private Vault',
          isLocked: const Value(true),
        ),
      );
      await testDatabase.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: travelJournalId,
          title: const Value('Travel checklist'),
          contentJson: const Value('[{"insert":"Pack travel bag\\n"}]'),
          plainText: const Value('Pack travel bag and passport'),
        ),
      );
      await testDatabase.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: lockedJournalId,
          title: const Value('Hidden memo'),
          contentJson: const Value('[{"insert":"secret route\\n"}]'),
          plainText: const Value('secret route'),
        ),
      );

      await pumpApp(tester);

      await _unlockPhoneLock(tester);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('search-query-field')),
        'travel',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search-section-journals')), findsOneWidget);
      expect(find.byKey(const Key('search-section-entries')), findsOneWidget);
      expect(find.text('Travel Plans'), findsWidgets);
      expect(find.text('Travel checklist'), findsOneWidget);

      await tester.tap(find.byKey(const Key('search-filter-entries')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search-section-journals')), findsNothing);
      expect(find.byKey(const Key('search-section-entries')), findsOneWidget);
      expect(find.text('Travel checklist'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('search-query-field')),
        'secret',
      );
      await tester.pumpAndSettle();

      expect(find.text('Hidden memo'), findsNothing);
      expect(find.text('No matches found for this filter.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('search-query-field')),
        'travel',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('search-save-preset-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('search-preset-name-field')),
        'Travel entries',
      );
      await tester.tap(
        find.byKey(const Key('search-save-preset-confirm-button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Travel entries'), findsOneWidget);

      await _disposeApp(tester);

      await pumpApp(tester);

      await _unlockPhoneLock(tester);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Travel entries'), findsOneWidget);

      await tester.tap(find.text('Travel entries'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search-section-entries')), findsOneWidget);
      expect(find.byKey(const Key('search-section-journals')), findsNothing);
      expect(find.text('Travel checklist'), findsOneWidget);

      await _disposeApp(tester);
    },
  );
}

Future<void> _unlockPhoneLock(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
  await tester.pumpAndSettle();
}

/// Walks the app through paused → hidden → inactive → resumed so any
/// `AppLifecycleListener` registered by Flutter or plugins observes valid
/// transitions.
Future<void> _cycleLifecyclePauseResume(WidgetTester tester) async {
  for (final state in const [
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pumpAndSettle();
  }
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.idle();
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pumpAndSettle();
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

class _FailingThemeModeStore implements ThemeModeStore {
  @override
  ThemeMode read() => ThemeMode.light;

  @override
  Future<void> save(ThemeMode mode) async {
    throw const ThemeModePersistenceException();
  }
}

class _FakeBiometricAuthenticator implements BiometricAuthenticator {
  BiometricAuthResult nextResult = BiometricAuthResult.success;

  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      nextResult;
}

class _InMemoryAppPinKeystore implements AppPinKeystore {
  AppPinCredentialPayload? _stored;

  @override
  Future<AppPinCredentialPayload?> getCredential() async => _stored;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    _stored = AppPinCredentialPayload(
      saltBase64: saltBase64,
      verifierBase64: verifierBase64,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    _stored = null;
  }
}
