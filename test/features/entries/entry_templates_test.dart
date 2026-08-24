import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';

void main() {
  test('still exposes the 5 plan-required templates plus blank', () {
    // V3 added many more templates; the original V2 set must remain present
    // so existing entries and tests continue to work.
    final ids = entryTemplates.map((t) => t.id).toSet();
    expect(
      ids,
      containsAll(<EntryTemplateId>{
        EntryTemplateId.blank,
        EntryTemplateId.daily,
        EntryTemplateId.travel,
        EntryTemplateId.meeting,
        EntryTemplateId.gratitude,
        EntryTemplateId.mood,
      }),
    );
  });

  test('every template id appears exactly once in the registry', () {
    final ids = entryTemplates.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every EntryTemplateId is registered', () {
    final ids = entryTemplates.map((t) => t.id).toSet();
    for (final id in EntryTemplateId.values) {
      expect(ids, contains(id), reason: '$id is missing from entryTemplates');
    }
  });

  test('blank is the first entry so templateFor(null) returns it', () {
    expect(entryTemplates.first.id, EntryTemplateId.blank);
  });

  test('grouping covers every template and preserves order within a group', () {
    final grouped = entryTemplatesByCategory;
    final flattened = grouped.values.expand((list) => list).toList();
    expect(flattened.length, entryTemplates.length);
    expect(
      flattened.map((t) => t.id).toSet(),
      entryTemplates.map((t) => t.id).toSet(),
    );
  });

  test('every template has a parseable Quill delta', () {
    for (final t in entryTemplates) {
      expect(
        validateTemplateJson(t),
        isTrue,
        reason: '${t.label} delta must parse as JSON list',
      );
    }
  });

  test('templateFor returns blank for null', () {
    expect(templateFor(null).id, EntryTemplateId.blank);
  });

  test('templateFor finds non-blank ids', () {
    for (final id in EntryTemplateId.values) {
      expect(templateFor(id).id, id);
    }
  });

  test('blank template uses an empty content delta', () {
    final blank = templateFor(EntryTemplateId.blank);
    expect(blank.contentJson, '[]');
    expect(blank.defaultTitle, '');
  });

  test(
    'domain-specific and topic templates are present with structured content',
    () {
      final domainTemplates = <EntryTemplateId>[
        EntryTemplateId.topicDeepDive,
        EntryTemplateId.sysadminRunbook,
        EntryTemplateId.sanathanaDharmaStudy,
        EntryTemplateId.diyProject,
        EntryTemplateId.homeMaintenance,
        EntryTemplateId.kitchenRecipe,
      ];

      for (final id in domainTemplates) {
        final template = templateFor(id);
        expect(template.id, id);
        expect(template.defaultTitle.isNotEmpty, isTrue);
        expect(template.description.isNotEmpty, isTrue);
        expect(template.contentJson.length > 2, isTrue);
        expect(validateTemplateJson(template), isTrue);
      }
    },
  );

  test('EntryTemplate.fromUserTemplate correctly wraps UserTemplate', () {
    final ut = UserTemplate(
      id: 99,
      name: 'Custom Journaling',
      description: 'A custom prompt layout',
      defaultTitle: 'My Title {{today}}',
      contentJson: '[{"insert":"Hello\\n"}]',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final t = EntryTemplate.fromUserTemplate(ut);
    expect(t.isCustom, isTrue);
    expect(t.customId, 99);
    expect(t.category, EntryTemplateCategory.custom);
    expect(t.label, 'Custom Journaling');
    expect(t.description, 'A custom prompt layout');
    expect(t.defaultTitle, 'My Title {{today}}');
    expect(t.contentJson, '[{"insert":"Hello\\n"}]');
    expect(validateTemplateJson(t), isTrue);
  });
}
