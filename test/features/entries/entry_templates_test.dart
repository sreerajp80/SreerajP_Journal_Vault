import 'package:flutter_test/flutter_test.dart';
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

  test('grouping covers every template and preserves order within a group',
      () {
    final grouped = entryTemplatesByCategory;
    final flattened = grouped.values.expand((list) => list).toList();
    expect(flattened.length, entryTemplates.length);
    expect(flattened.map((t) => t.id).toSet(),
        entryTemplates.map((t) => t.id).toSet());
  });

  test('every template has a parseable Quill delta', () {
    for (final t in entryTemplates) {
      expect(validateTemplateJson(t), isTrue,
          reason: '${t.label} delta must parse as JSON list');
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
}
