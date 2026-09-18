import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
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

  testWidgets('Locked journals require password before detail access', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await unlockPhoneLock(tester);

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

    await disposeApp(tester);
  });

  testWidgets('Journal detail groups entries and reacts to entry CRUD', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    await unlockPhoneLock(tester);

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
    // enterText does not pump, so the setState that flips the dirty flag has
    // not rebuilt yet. Without this the save button still reads
    // "No unsaved changes" and byTooltip('Save') matches nothing.
    await tester.pump();
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
    await tester.pump();
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

    await disposeApp(tester);
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

      await unlockPhoneLock(tester);
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

      await disposeApp(tester);

      await pumpApp(tester);

      await unlockPhoneLock(tester);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Travel entries'), findsOneWidget);

      await tester.tap(find.text('Travel entries'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search-section-entries')), findsOneWidget);
      expect(find.byKey(const Key('search-section-journals')), findsNothing);
      expect(find.text('Travel checklist'), findsOneWidget);

      await disposeApp(tester);
    },
  );

  testWidgets('Search results build lazily and reach the last of many', (
    WidgetTester tester,
  ) async {
    final journalId = await testDatabase.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Garden'),
    );
    for (var i = 0; i < 30; i++) {
      await testDatabase.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: Value('Seedling note $i'),
          contentJson: const Value('[{"insert":"seedling\n"}]'),
          plainText: const Value('seedling'),
        ),
      );
    }

    await pumpApp(tester);
    await unlockPhoneLock(tester);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('search-query-field')),
      'seedling',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('search-section-entries')), findsOneWidget);
    // Rows far below the fold are not built until scrolled to.
    expect(find.text('Seedling note 29'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Seedling note 29'),
      300,
      scrollable: find
          .ancestor(
            of: find.byKey(const Key('search-section-entries')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Seedling note 29'), findsOneWidget);

    await disposeApp(tester);
  });

  // Ported from the removed journal_lock_controller_test, which asserted this
  // against a JournalLockController that nothing in the app used. The live
  // path is AppLockNotifier._onLocked clearing the unlocked-journal set.
  testWidgets('re-locking the app clears session-unlocked journals', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    await unlockPhoneLock(tester);

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

    // Unlock it for this session.
    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-unlock-password-field')),
      'secret-pass',
    );
    await tester.tap(find.byKey(const Key('journal-unlock-button')));
    await tester.pumpAndSettle();
    expect(find.text('Add entry'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Background the app so it re-locks, then come back through the gate.
    await cycleLifecyclePauseResume(tester);
    await tester.pumpAndSettle();
    await unlockPhoneLock(tester);

    // The journal must ask for its password again — the session unlock is gone.
    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Journal is locked'), findsOneWidget);
    expect(find.text('Add entry'), findsNothing);

    await disposeApp(tester);
  });
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
