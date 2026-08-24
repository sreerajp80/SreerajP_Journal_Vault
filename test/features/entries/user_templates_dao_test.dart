import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('user_templates_test');
    final dbFile = File('${tempDir.path}/vault.sqlite');
    db = AppDatabase.forExecutor(NativeDatabase(dbFile));
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('UserTemplatesDao', () {
    test('creates and fetches user templates in alphabetical order', () async {
      await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(
          name: 'Zebra Review',
          contentJson: '[{"insert":"Zebra"}]',
        ),
      );
      await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(
          name: 'Alpha Standup',
          description: const Value('Morning routine'),
          defaultTitle: const Value('Standup {{today}}'),
          contentJson: '[{"insert":"Alpha"}]',
        ),
      );

      final templates = await db.userTemplatesDao.getAllUserTemplates();
      expect(templates.length, 2);
      expect(templates[0].name, 'Alpha Standup');
      expect(templates[0].description, 'Morning routine');
      expect(templates[0].defaultTitle, 'Standup {{today}}');
      expect(templates[1].name, 'Zebra Review');
    });

    test('updates an existing user template', () async {
      final id = await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(name: 'Old Name', contentJson: '[]'),
      );

      final template = await db.userTemplatesDao.getUserTemplateById(id);
      expect(template, isNotNull);

      final success = await db.userTemplatesDao.updateUserTemplate(
        template!.copyWith(
          name: 'Updated Name',
          defaultTitle: const Value('New Title'),
        ),
      );
      expect(success, isTrue);

      final reloaded = await db.userTemplatesDao.getUserTemplateById(id);
      expect(reloaded?.name, 'Updated Name');
      expect(reloaded?.defaultTitle, 'New Title');
    });

    test('deletes a user template by id', () async {
      final id = await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(name: 'To Delete', contentJson: '[]'),
      );

      expect(await db.userTemplatesDao.getUserTemplateById(id), isNotNull);

      await db.userTemplatesDao.deleteUserTemplate(id);

      expect(await db.userTemplatesDao.getUserTemplateById(id), isNull);
    });

    test('watchAllUserTemplates emits stream updates on mutation', () async {
      final stream = db.userTemplatesDao.watchAllUserTemplates();
      expect(stream, emitsInOrder([isEmpty, hasLength(1)]));

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await db.userTemplatesDao.createUserTemplate(
        UserTemplatesCompanion.insert(
          name: 'Streamed Template',
          contentJson: '[]',
        ),
      );
    });
  });
}
