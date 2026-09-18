import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/tamper_alerts_screen.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  late AppDatabase database;
  late SecurityEventService securityEventService;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    securityEventService = SecurityEventService(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('SecurityEventService vault integrity tests', () {
    test('clean vault reports zero tamper issues', () async {
      final journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Clean Journal'),
      );
      await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Valid Entry'),
          plainText: const Value('Valid entry body'),
        ),
      );

      final report = await securityEventService.runVaultIntegrityCheck();
      expect(report.isClean, isTrue);
      expect(report.scannedJournals, 1);
      expect(report.scannedEntries, 1);
      expect(report.tamperIssues, 0);

      final events = await database.securityEventsDao.getEventsByType(
        'tamper_detected',
      );
      expect(events, isEmpty);
    });

    test('tampered entry timestamp triggers tamper alert logging', () async {
      final journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Vault'),
      );
      final now = DateTime.now();
      await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Bad Timestamp'),
          plainText: const Value('Some text'),
          createdAt: Value(now),
          updatedAt: Value(now.subtract(const Duration(days: 3))),
        ),
      );

      final report = await securityEventService.runVaultIntegrityCheck();
      expect(report.isClean, isFalse);
      expect(report.tamperIssues, 1);

      final events = await database.securityEventsDao.getEventsByType(
        'tamper_detected',
      );
      expect(events, isNotEmpty);
      expect(events.first.severity, 'critical');
    });
  });

  group('TamperAlertsScreen widget tests', () {
    Future<void> pumpScreen(
      WidgetTester tester, {
      List<SecurityEvent> events = const [],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            securityEventServiceProvider.overrideWithValue(
              securityEventService,
            ),
            tamperEventsProvider.overrideWith((ref) => Stream.value(events)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TamperAlertsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'initial state displays vault integrity verified and no history',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('Tamper Alerts'), findsOneWidget);
        expect(find.text('Vault Integrity Verified'), findsOneWidget);
        expect(find.text('How this works'), findsOneWidget);
        expect(find.text('Tamper Alert History'), findsOneWidget);
        expect(
          find.text(
            'No tamper alerts recorded. Your vault entries are secure.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tamper-alerts-verify-button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('triggering scan updates report summary and snackbar', (
      tester,
    ) async {
      final journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'My Journal'),
      );
      await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Clean Entry'),
          plainText: const Value('Hello world'),
        ),
      );

      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('tamper-alerts-verify-button')));
      await tester.pumpAndSettle();

      expect(find.text('1 entries (1 journals)'), findsOneWidget);
      expect(
        find.text('Vault scan complete: all entries verified clean.'),
        findsOneWidget,
      );
      expect(find.text('Vault Integrity Verified'), findsOneWidget);
    });

    testWidgets('displays tamper events and opens metadata dialog', (
      tester,
    ) async {
      final now = DateTime(2026, 8, 23, 20);
      final fakeEvent = SecurityEvent(
        id: 1,
        eventType: 'tamper_detected',
        severity: 'critical',
        description: 'Entry 42 has updatedAt before createdAt',
        metadata: '{"entryId": 42, "reason": "timestamp_inversion"}',
        createdAt: now,
      );

      await pumpScreen(tester, events: [fakeEvent]);

      expect(
        find.text('Entry 42 has updatedAt before createdAt'),
        findsOneWidget,
      );
      expect(find.text('CRITICAL'), findsOneWidget);

      // Open metadata dialog
      final infoButton = find.byIcon(Icons.info_outline).last;
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      expect(find.text('Event Details'), findsOneWidget);
      expect(find.textContaining('timestamp_inversion'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Event Details'), findsNothing);
    });
  });
}
