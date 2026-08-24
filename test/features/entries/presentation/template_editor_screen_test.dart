import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_editor_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _buildTestApp({
  required AppDatabase db,
  UserTemplate? existingTemplate,
}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: TemplateEditorScreen(existingTemplate: existingTemplate),
    ),
  );
}

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('template_editor_test');
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
    'TemplateEditorScreen creates a new custom template with token insertion',
    (tester) async {
      await tester.pumpWidget(_buildTestApp(db: db));
      await tester.pumpAndSettle();

      expect(find.text('New Template'), findsOneWidget);
      expect(find.byKey(const Key('template-name-field')), findsOneWidget);
      expect(
        find.byKey(const Key('template-default-title-field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('save-template-button')), findsOneWidget);

      // Enter name
      await tester.enterText(
        find.byKey(const Key('template-name-field')),
        'Weekly Recap',
      );

      // Focus default title field and tap token chip for {{today}}
      await tester.tap(find.byKey(const Key('template-default-title-field')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('template-default-title-field')),
        'Recap ',
      );
      await tester.tap(find.byKey(const Key('token-chip-today')));
      await tester.pumpAndSettle();

      expect(find.text('Recap {{today}}'), findsOneWidget);

      // Save template
      await tester.tap(find.byKey(const Key('save-template-button')));
      await tester.pumpAndSettle();

      final templates = await db.userTemplatesDao.getAllUserTemplates();
      expect(templates, hasLength(1));
      expect(templates.first.name, 'Weekly Recap');
      expect(templates.first.defaultTitle, 'Recap {{today}}');
    },
  );

  testWidgets('TemplateEditorScreen edits an existing template', (
    tester,
  ) async {
    final id = await db.userTemplatesDao.createUserTemplate(
      UserTemplatesCompanion.insert(
        name: 'Initial Name',
        description: const Value('Initial Desc'),
        defaultTitle: const Value('Initial Title'),
        contentJson: '[]',
      ),
    );

    final existing = await db.userTemplatesDao.getUserTemplateById(id);
    expect(existing, isNotNull);

    await tester.pumpWidget(_buildTestApp(db: db, existingTemplate: existing));
    await tester.pumpAndSettle();

    expect(find.text('Edit Template'), findsOneWidget);
    expect(find.text('Initial Name'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('template-name-field')),
      'Modified Name',
    );

    await tester.tap(find.byKey(const Key('save-template-button')));
    await tester.pumpAndSettle();

    final templates = await db.userTemplatesDao.getAllUserTemplates();
    expect(templates, hasLength(1));
    expect(templates.first.name, 'Modified Name');
  });
}
