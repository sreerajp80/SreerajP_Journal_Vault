import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/home/presentation/home_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('loading state renders in dark theme with visible progress', (
    WidgetTester tester,
  ) async {
    final completer = Completer<List<JournalListItem>>();

    await _pumpHome(
      tester,
      database: database,
      themeMode: ThemeMode.dark,
      overrides: <Override>[
        homeJournalsProvider.overrideWith((ref) => completer.future),
      ],
    );

    await tester.pump();

    expect(find.text('Loading journals...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const <JournalListItem>[]);
    await tester.pumpAndSettle();
  });

  testWidgets('error state retries and recovers journal list content', (
    WidgetTester tester,
  ) async {
    await database.journalsDao.createJournal(
      JournalsCompanion.insert(
        title: 'Work',
        description: const Value('Daily planning notes'),
      ),
    );

    var attempts = 0;
    await _pumpHome(
      tester,
      database: database,
      overrides: <Override>[
        homeJournalsProvider.overrideWith((ref) async {
          attempts += 1;
          if (attempts == 1) {
            throw StateError('temporary failure');
          }

          final database = ref.read(appDatabaseProvider);
          final journals = await database.journalsDao.getAllJournals();
          final items = <JournalListItem>[];
          for (final journal in journals) {
            final tags = await database.journalTagsDao.getTagsForJournal(
              journal.id,
            );
            items.add(JournalListItem(journal: journal, tags: tags));
          }
          return items;
        }),
      ],
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to load journals'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);
    expect(find.byTooltip('New journal'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required AppDatabase database,
  ThemeMode themeMode = ThemeMode.light,
  List<Override> overrides = const <Override>[],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(database),
        ...overrides,
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: themeMode,
        home: const HomeScreen(),
      ),
    ),
  );
}
