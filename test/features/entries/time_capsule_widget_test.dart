import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_seal_dialog.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_sealed_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsules_list_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/time_capsule_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _buildTestApp({
  required Widget child,
  required AppDatabase database,
  required TimeCapsuleService service,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      timeCapsuleServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SharedPreferences prefs;
  late TimeCapsuleService service;
  late int journalId;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = TimeCapsuleService(db, prefs: prefs);

    journalId = await db
        .into(db.journals)
        .insert(JournalsCompanion.insert(title: 'Capsule Test Journal'));
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('TimeCapsuleSealDialog selects preset and confirms', (
    tester,
  ) async {
    TimeCapsuleSealConfig? result;

    await tester.pumpWidget(
      _buildTestApp(
        database: db,
        service: service,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<TimeCapsuleSealConfig>(
                context: context,
                builder: (_) => const TimeCapsuleSealDialog(),
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify title and presets are visible
    expect(find.byKey(const Key('time-capsule-seal-dialog')), findsOneWidget);
    expect(find.byKey(const Key('time-capsule-preset-1y')), findsOneWidget);

    // Tap 1 year preset
    await tester.tap(find.byKey(const Key('time-capsule-preset-1y')));
    await tester.pumpAndSettle();

    // Enter teaser message
    await tester.enterText(
      find.byKey(const Key('time-capsule-teaser-field')),
      'Thoughts on turning 30',
    );
    await tester.pumpAndSettle();

    // Confirm seal
    await tester.tap(find.byKey(const Key('time-capsule-confirm-seal-button')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.teaserMessage, equals('Thoughts on turning 30'));
    expect(
      result!.unlockDate.isAfter(DateTime.now().add(const Duration(days: 360))),
      isTrue,
    );
  });

  testWidgets(
    'TimeCapsuleSealedScreen shows countdown clock and teaser for locked capsule',
    (tester) async {
      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: const Value('Future Thoughts'),
              contentJson: const Value('[{"insert":"Secret message\\n"}]'),
              plainText: const Value('Secret message'),
            ),
          );

      await service.sealEntry(
        entryId: entryId,
        unlockDate: DateTime.now().add(const Duration(days: 100)),
        teaserMessage: 'Future goals note',
      );

      await tester.pumpWidget(
        _buildTestApp(
          database: db,
          service: service,
          child: TimeCapsuleSealedScreen(entryId: entryId),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('time-capsule-sealed-screen')),
        findsOneWidget,
      );
      expect(find.text('Future goals note'), findsOneWidget);
      expect(
        find.byKey(const Key('time-capsule-countdown-display')),
        findsOneWidget,
      );

      // Sealed banner should indicate locked
      expect(
        find.byKey(const Key('time-capsule-unseal-button')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets('TimeCapsulesListScreen displays active and ready capsules', (
    tester,
  ) async {
    final entryId = await db
        .into(db.entries)
        .insert(
          EntriesCompanion.insert(
            journalId: journalId,
            title: const Value('Capsule in List'),
            contentJson: const Value('[{"insert":"Vault letter\\n"}]'),
            plainText: const Value('Vault letter'),
          ),
        );

    await service.sealEntry(
      entryId: entryId,
      unlockDate: DateTime.now().add(const Duration(days: 50)),
      teaserMessage: 'List teaser preview',
    );

    await tester.pumpWidget(
      _buildTestApp(
        database: db,
        service: service,
        child: const TimeCapsulesListScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('time-capsules-list-screen')), findsOneWidget);
    expect(find.text('Capsule in List'), findsOneWidget);
    expect(find.textContaining('List teaser preview'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('TimeCapsulesListScreen builds a long list lazily', (
    tester,
  ) async {
    for (var i = 0; i < 30; i++) {
      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: Value('Letter $i'),
              contentJson: const Value('[{"insert":"Letter\n"}]'),
              plainText: const Value('Letter'),
            ),
          );
      await service.sealEntry(
        entryId: entryId,
        unlockDate: DateTime.now().add(Duration(days: 10 + i)),
      );
    }

    await tester.pumpWidget(
      _buildTestApp(
        database: db,
        service: service,
        child: const TimeCapsulesListScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Letter 0'), findsOneWidget);
    expect(find.text('Letter 29'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Letter 29'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Letter 29'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
