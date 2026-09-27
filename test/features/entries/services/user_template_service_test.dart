import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/services/user_template_service.dart';

void main() {
  late AppDatabase db;
  late UserTemplateService service;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = UserTemplateService(db);
  });

  tearDown(() => db.close());

  Future<List<UserTemplate>> all() => db.userTemplatesDao.getAllUserTemplates();

  test('createTemplate stores empty description and title as none', () async {
    await service.createTemplate(
      name: 'Mine',
      description: '',
      defaultTitle: '',
      contentJson: '[]',
    );

    final template = (await all()).single;
    expect(template.name, 'Mine');
    expect(template.description, isNull);
    expect(template.defaultTitle, isNull);
  });

  test('updateTemplate replaces the fields', () async {
    await service.createTemplate(
      name: 'Old',
      description: 'd',
      defaultTitle: 't',
      contentJson: '[]',
    );
    final existing = (await all()).single;

    await service.updateTemplate(
      existing,
      name: 'New',
      description: '',
      defaultTitle: 'Title',
      contentJson: '[{"insert":"x\\n"}]',
    );

    final updated = (await all()).single;
    expect(updated.name, 'New');
    expect(updated.description, isNull);
    expect(updated.defaultTitle, 'Title');
    expect(updated.contentJson, '[{"insert":"x\\n"}]');
  });

  test('deleteTemplate removes it', () async {
    final id = await service.createTemplate(
      name: 'Gone',
      description: '',
      defaultTitle: '',
      contentJson: '[]',
    );

    await service.deleteTemplate(id);

    expect(await all(), isEmpty);
  });
}
