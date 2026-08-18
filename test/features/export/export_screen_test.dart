import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/export/providers/export_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Drives the export screen itself.
///
/// `docs/enhancement_ideas.md` B1 is blunt about this project's habit of
/// building a service, passing its unit tests, and never wiring it to a screen
/// the user can reach. A feature is only done when a test drives it through the
/// UI, so these tests exist to keep the export screen honest.
void main() {
  late AppDatabase database;
  late int journalId;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'My Journal'),
    );
    await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('An entry'),
        entryDate: Value(DateTime(2026, 8, 15)),
      ),
    );
  });

  tearDown(() async => database.close());

  Future<void> pumpScreen(
    WidgetTester tester, {
    int? entryId,
    String? entryTitle,
    bool pdfAvailable = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          pdfExportAvailableProvider.overrideWith((ref) async => pdfAvailable),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ExportScreen(
            journalId: journalId,
            journalTitle: 'My Journal',
            entryId: entryId,
            entryTitle: entryTitle,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the journal it will export from', (tester) async {
    await pumpScreen(tester);

    expect(find.text(ExportStrings.fromJournal('My Journal')), findsOneWidget);
  });

  testWidgets(
    'offers only journal and range scopes when opened from settings',
    (tester) async {
      await pumpScreen(tester);

      // No entry was named, so "this entry" is not a choice.
      expect(find.byKey(const Key('export-scope-entry')), findsNothing);
      expect(find.byKey(const Key('export-scope-journal')), findsOneWidget);
      expect(find.byKey(const Key('export-scope-range')), findsOneWidget);
    },
  );

  testWidgets('offers the single-entry scope when opened from an entry', (
    tester,
  ) async {
    await pumpScreen(tester, entryId: 1, entryTitle: 'An entry');

    expect(find.byKey(const Key('export-scope-entry')), findsOneWidget);
    expect(find.text('An entry'), findsOneWidget);
  });

  testWidgets('offers all four formats', (tester) async {
    await pumpScreen(tester);

    expect(find.byKey(const Key('export-format-markdown')), findsOneWidget);
    expect(find.byKey(const Key('export-format-html')), findsOneWidget);
    expect(find.byKey(const Key('export-format-plainText')), findsOneWidget);
    expect(find.byKey(const Key('export-format-pdf')), findsOneWidget);
  });

  testWidgets('disables PDF with a reason when the device cannot render one', (
    tester,
  ) async {
    // Rule 6 — never a dead button. PDF is shown, disabled, and explained,
    // rather than being offered and then failing.
    await pumpScreen(tester, pdfAvailable: false);

    final pdfTile = tester.widget<RadioListTile<Object?>>(
      find.byKey(const Key('export-format-pdf')),
    );
    expect(pdfTile.enabled, isFalse);
    expect(find.text(ExportStrings.pdfUnavailable), findsOneWidget);

    // The other three formats stay usable.
    final markdownTile = tester.widget<RadioListTile<Object?>>(
      find.byKey(const Key('export-format-markdown')),
    );
    expect(markdownTile.enabled, isTrue);
  });

  testWidgets('keeps PDF enabled when the device can render one', (
    tester,
  ) async {
    await pumpScreen(tester);

    final pdfTile = tester.widget<RadioListTile<Object?>>(
      find.byKey(const Key('export-format-pdf')),
    );
    expect(pdfTile.enabled, isTrue);
  });

  testWidgets('always tells the user the export is not encrypted', (
    tester,
  ) async {
    // This warning is not optional: an export takes content out of a vault and
    // writes it somewhere the vault does not protect.
    await pumpScreen(tester);

    expect(find.text(ExportStrings.notEncryptedWarning), findsOneWidget);
  });

  testWidgets('will not export a date range until dates are chosen', (
    tester,
  ) async {
    await pumpScreen(tester);

    // The button starts enabled for the whole-journal scope.
    var button = tester.widget<FilledButton>(
      find.byKey(const Key('export-run-button')),
    );
    expect(button.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('export-scope-range')));
    await tester.pumpAndSettle();

    button = tester.widget<FilledButton>(
      find.byKey(const Key('export-run-button')),
    );
    expect(button.onPressed, isNull);
    expect(find.text(ExportStrings.dateRangeNotSet), findsOneWidget);
    expect(find.byKey(const Key('export-pick-dates')), findsOneWidget);
  });

  testWidgets('attachments are off by default and metadata is on', (
    tester,
  ) async {
    // Attachments default off because they make the export much larger and
    // copy decrypted files out of the vault; metadata defaults on because a
    // dated entry is what makes an export readable later.
    await pumpScreen(tester);

    final attachments = tester.widget<SwitchListTile>(
      find.byKey(const Key('export-include-attachments')),
    );
    final metadata = tester.widget<SwitchListTile>(
      find.byKey(const Key('export-include-metadata')),
    );

    expect(attachments.value, isFalse);
    expect(metadata.value, isTrue);
  });

  group('the unencrypted-export confirmation', () {
    // `docs/security.md` section 14 says no plaintext export may happen
    // without an explicit confirmation step. These tests hold that line.
    //
    // Note for future authors: `pumpAndSettle` cannot be used after tapping
    // Export. The button shows a CircularProgressIndicator while the export
    // runs, and that animation never settles, so pumpAndSettle times out.
    // Pump a fixed number of frames instead.
    Future<void> tapExport(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('export-run-button')));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('is asked before anything is written', (tester) async {
      await pumpScreen(tester);
      await tapExport(tester);

      expect(find.byKey(const Key('export-confirm-dialog')), findsOneWidget);
      expect(find.text(ExportStrings.confirmTitle), findsOneWidget);
    });

    testWidgets('says how many entries and which format', (tester) async {
      await pumpScreen(tester);
      await tapExport(tester);

      // One entry was seeded, and Markdown is the default format.
      expect(
        find.text(ExportStrings.confirmBody(1, ExportStrings.formatMarkdown)),
        findsOneWidget,
      );
    });

    testWidgets('backing out cancels the export', (tester) async {
      await pumpScreen(tester);
      await tapExport(tester);

      await tester.tap(find.byKey(const Key('export-confirm-cancel')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('export-confirm-dialog')), findsNothing);
      expect(find.text(ExportStrings.exportCancelled), findsOneWidget);
      // The screen is usable again rather than stuck in its exporting state.
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('export-run-button')),
      );
      expect(button.onPressed, isNotNull);
    });
  });

  group('the password switch', () {
    Future<void> turnOnEncryption(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('export-encrypt')));
      await tester.pumpAndSettle();
    }

    bool exportEnabled(WidgetTester tester) =>
        tester
            .widget<FilledButton>(find.byKey(const Key('export-run-button')))
            .onPressed !=
        null;

    testWidgets('is off to begin with, and the fields are hidden', (
      tester,
    ) async {
      await pumpScreen(tester);

      final switchTile = tester.widget<SwitchListTile>(
        find.byKey(const Key('export-encrypt')),
      );
      expect(switchTile.value, isFalse);
      expect(find.byKey(const Key('export-password-field')), findsNothing);
    });

    testWidgets('blocks the export until the password is long enough', (
      tester,
    ) async {
      await pumpScreen(tester);
      await turnOnEncryption(tester);

      expect(exportEnabled(tester), isFalse);

      await tester.enterText(
        find.byKey(const Key('export-password-field')),
        'short',
      );
      await tester.enterText(
        find.byKey(const Key('export-password-confirm-field')),
        'short',
      );
      await tester.pumpAndSettle();

      expect(exportEnabled(tester), isFalse);
    });

    testWidgets('blocks the export while the two passwords differ', (
      tester,
    ) async {
      await pumpScreen(tester);
      await turnOnEncryption(tester);

      await tester.enterText(
        find.byKey(const Key('export-password-field')),
        'correct-horse-battery',
      );
      await tester.enterText(
        find.byKey(const Key('export-password-confirm-field')),
        'correct-horse-batteries',
      );
      await tester.pumpAndSettle();

      expect(exportEnabled(tester), isFalse);

      await tester.enterText(
        find.byKey(const Key('export-password-confirm-field')),
        'correct-horse-battery',
      );
      await tester.pumpAndSettle();

      expect(exportEnabled(tester), isTrue);
    });

    testWidgets('replaces the "not encrypted" warning', (tester) async {
      await pumpScreen(tester);

      expect(find.text(ExportStrings.notEncryptedWarning), findsOneWidget);

      await turnOnEncryption(tester);

      expect(find.text(ExportStrings.notEncryptedWarning), findsNothing);
    });
  });

  testWidgets('the options can be switched', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('export-include-attachments')));
    await tester.pumpAndSettle();

    final attachments = tester.widget<SwitchListTile>(
      find.byKey(const Key('export-include-attachments')),
    );
    expect(attachments.value, isTrue);
  });
}
