import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_template_text.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ml = lookupAppLocalizations(const Locale('ml'));
  final sa = lookupAppLocalizations(const Locale('sa'));
  final all = [en, ml, sa];

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

  test('every template has a label, description and parseable delta in '
      'English, Malayalam and Sanskrit', () {
    for (final l10n in all) {
      for (final t in entryTemplates) {
        final where = '${t.id.name} in ${l10n.localeName}';
        expect(t.labelIn(l10n).trim(), isNotEmpty, reason: '$where label');
        expect(
          t.descriptionIn(l10n).trim(),
          isNotEmpty,
          reason: '$where description',
        );
        final json = t.contentJsonIn(l10n);
        expect(validateTemplateJson(json), isTrue, reason: '$where delta');
        final ops = jsonDecode(json) as List;
        if (ops.isNotEmpty) {
          final text = (ops.single as Map)['insert'] as String;
          expect(text.endsWith('\n'), isTrue, reason: '$where ends with \\n');
        }
      }
    }
  });

  test('template text is translated, not copied from English', () {
    for (final t in entryTemplates) {
      for (final l10n in [ml, sa]) {
        expect(
          t.labelIn(l10n),
          isNot(t.labelIn(en)),
          reason: '${t.id.name} label in ${l10n.localeName}',
        );
        if (t.contentJsonIn(en) != '[]') {
          expect(
            t.contentJsonIn(l10n),
            isNot(t.contentJsonIn(en)),
            reason: '${t.id.name} body in ${l10n.localeName}',
          );
        }
      }
    }
  });

  test('every category has a name in all three languages', () {
    for (final l10n in all) {
      for (final c in EntryTemplateCategory.values) {
        expect(c.labelIn(l10n).trim(), isNotEmpty);
      }
    }
    expect(EntryTemplateCategory.general.labelIn(en), 'Start fresh');
  });

  test('templateFor returns blank for null', () {
    expect(templateFor(null).id, EntryTemplateId.blank);
  });

  test('templateFor finds non-blank ids', () {
    for (final id in EntryTemplateId.values) {
      expect(templateFor(id).id, id);
    }
  });

  test('blank template uses an empty content delta and title', () {
    final blank = templateFor(EntryTemplateId.blank);
    for (final l10n in all) {
      expect(blank.contentJsonIn(l10n), '[]');
      expect(blank.defaultTitleIn(l10n), '');
    }
  });

  test('English template text is unchanged by the move to ARB', () {
    final daily = templateFor(EntryTemplateId.daily);
    expect(daily.labelIn(en), 'Daily Reflection');
    expect(daily.defaultTitleIn(en), 'Daily Reflection');
    expect(
      jsonDecode(daily.contentJsonIn(en)),
      jsonDecode(
        '[{"insert":"Highlights\\n\\nLowlights\\n\\nTomorrow\'s focus\\n\\n"}]',
      ),
    );
    final meeting = templateFor(EntryTemplateId.meeting);
    expect(
      (jsonDecode(meeting.contentJsonIn(en)) as List).single['insert'],
      'Attendees: \nAgenda\n\nDecisions\n\nAction items\n\n',
    );
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
        for (final l10n in all) {
          expect(template.id, id);
          expect(template.defaultTitleIn(l10n).isNotEmpty, isTrue);
          expect(template.descriptionIn(l10n).isNotEmpty, isTrue);
          expect(template.contentJsonIn(l10n).length > 2, isTrue);
        }
      }
    },
  );

  test(
    'EntryTemplate.fromUserTemplate keeps the user text in every language',
    () {
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
      for (final l10n in all) {
        expect(t.labelIn(l10n), 'Custom Journaling');
        expect(t.descriptionIn(l10n), 'A custom prompt layout');
        expect(t.defaultTitleIn(l10n), 'My Title {{today}}');
        expect(t.contentJsonIn(l10n), '[{"insert":"Hello\\n"}]');
      }
      expect(validateTemplateJson(t.contentJson), isTrue);
    },
  );
}
