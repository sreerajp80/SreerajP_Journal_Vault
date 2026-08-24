import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_manager_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _buildTestApp({required AppDatabase db}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: TemplateManagerScreen(),
    ),
  );
}

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('template_manager_test');
    final dbFile = File('${tempDir.path}/vault.sqlite');
    db = AppDatabase.forExecutor(NativeDatabase(dbFile));
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets(
    'TemplateManagerScreen shows empty state when no templates exist',
    (tester) async {
      await tester.pumpWidget(_buildTestApp(db: db));
      await tester.pumpAndSettle();

      expect(find.text('Custom Templates'), findsOneWidget);
      expect(find.byKey(const Key('add-template-fab')), findsOneWidget);
      expect(
        find.byKey(const Key('create-first-template-button')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TemplateManagerScreen lists custom templates and supports deletion',
    (tester) async {
      await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(
          name: 'Daily Checkin',
          description: const Value('Daily routine'),
          defaultTitle: const Value('Checkin {{today}}'),
          contentJson: '[]',
        ),
      );

      await tester.pumpWidget(_buildTestApp(db: db));
      await tester.pumpAndSettle();

      expect(find.text('Daily Checkin'), findsOneWidget);
      expect(find.text('Daily routine'), findsOneWidget);

      // Open popup menu on template tile
      final tile = await db.userTemplatesDao.getAllUserTemplates();
      final templateId = tile.first.id;

      await tester.tap(find.byKey(Key('template-actions-$templateId')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Template'), findsOneWidget);
      expect(find.text('Edit Template'), findsOneWidget);

      // Tap Delete Template
      await tester.tap(find.text('Delete Template'));
      await tester.pumpAndSettle();

      expect(find.text('Delete template?'), findsOneWidget);
      expect(
        find.byKey(const Key('confirm-delete-template-button')),
        findsOneWidget,
      );

      // Confirm deletion
      await tester.tap(find.byKey(const Key('confirm-delete-template-button')));
      await tester.pumpAndSettle();

      // Ensure list is now empty and empty state is displayed
      expect(find.text('Daily Checkin'), findsNothing);
      expect(
        find.byKey(const Key('create-first-template-button')),
        findsOneWidget,
      );
    },
  );
}
