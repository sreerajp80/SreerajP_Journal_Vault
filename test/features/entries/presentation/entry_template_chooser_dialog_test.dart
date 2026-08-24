import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_template_chooser_dialog.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _buildTestApp({
  required void Function(EntryTemplate?) onSelected,
  List<UserTemplate> userTemplates = const [],
}) {
  return ProviderScope(
    overrides: [
      userTemplatesStreamProvider.overrideWith(
        (ref) => Stream.value(userTemplates),
      ),
      allUserTemplatesProvider.overrideWith((ref) async => userTemplates),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final res = await showDialog<EntryTemplate>(
                context: context,
                builder: (_) => const EntryTemplateChooserDialog(),
              );
              onSelected(res);
            },
            child: const Text('Open Chooser'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'EntryTemplateChooserDialog opens with Start fresh expanded by default',
    (tester) async {
      await tester.pumpWidget(_buildTestApp(onSelected: (_) {}));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Chooser'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('entry-template-chooser')), findsOneWidget);
      expect(find.text('Choose a template'), findsOneWidget);
      expect(
        find.byKey(const Key('template-expand-collapse-all-button')),
        findsOneWidget,
      );
      expect(find.text('Expand all'), findsOneWidget);

      // Start fresh is expanded:
      expect(find.byKey(const Key('entry-template-blank')), findsOneWidget);

      // Other category templates are collapsed initially:
      expect(find.byKey(const Key('entry-template-daily')), findsNothing);
      expect(
        find.byKey(const Key('entry-template-sysadminRunbook')),
        findsNothing,
      );
    },
  );

  testWidgets('Tapping a category header toggles its expansion', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(onSelected: (_) {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Chooser'));
    await tester.pumpAndSettle();

    // Collapse 'Start fresh'
    await tester.tap(find.byKey(const Key('template-category-general')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('entry-template-blank')), findsNothing);

    // Expand 'Thoughts & ideas'
    await tester.tap(find.byKey(const Key('template-category-thoughts')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('entry-template-ideaCapture')), findsOneWidget);

    // Collapse 'Thoughts & ideas'
    await tester.tap(find.byKey(const Key('template-category-thoughts')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('entry-template-ideaCapture')), findsNothing);
  });

  testWidgets('Expand all and Collapse all toggle all categories', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp(onSelected: (_) {}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Chooser'));
    await tester.pumpAndSettle();

    // Tap "Expand all"
    await tester.tap(
      find.byKey(const Key('template-expand-collapse-all-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Collapse all'), findsOneWidget);
    expect(find.byKey(const Key('entry-template-blank')), findsOneWidget);

    // Tap "Collapse all"
    await tester.tap(
      find.byKey(const Key('template-expand-collapse-all-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Expand all'), findsOneWidget);
    expect(find.byKey(const Key('entry-template-blank')), findsNothing);
    expect(
      find.byKey(const Key('entry-template-sysadminRunbook')),
      findsNothing,
    );
  });

  testWidgets('Tapping a template selects it and dismisses dialog', (
    tester,
  ) async {
    EntryTemplate? selected;
    await tester.pumpWidget(_buildTestApp(onSelected: (t) => selected = t));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Chooser'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('entry-template-blank')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('entry-template-chooser')), findsNothing);
    expect(selected, isNotNull);
    expect(selected?.id, EntryTemplateId.blank);
  });

  testWidgets('Custom templates appear under My templates and are selectable', (
    tester,
  ) async {
    final customTemplate = UserTemplate(
      id: 42,
      name: 'Custom Standup',
      description: 'My standup',
      defaultTitle: 'Standup {{today}}',
      contentJson: '[{"insert":"Custom content\\n"}]',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    EntryTemplate? selected;
    await tester.pumpWidget(
      _buildTestApp(
        onSelected: (t) => selected = t,
        userTemplates: [customTemplate],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Chooser'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('template-category-custom')), findsOneWidget);
    expect(find.text('My templates'), findsOneWidget);

    // Tap 'My templates' category to expand it
    await tester.tap(find.byKey(const Key('template-category-custom')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('entry-template-custom-42')), findsOneWidget);
    expect(find.text('Custom Standup'), findsOneWidget);

    // Tap the custom template
    await tester.tap(find.byKey(const Key('entry-template-custom-42')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('entry-template-chooser')), findsNothing);
    expect(selected, isNotNull);
    expect(selected?.isCustom, isTrue);
    expect(selected?.customId, 42);
    expect(selected?.label, 'Custom Standup');
    expect(selected?.defaultTitle, 'Standup {{today}}');
  });

  testWidgets('Tapping Cancel dismisses dialog with null result', (
    tester,
  ) async {
    EntryTemplate? selected;
    await tester.pumpWidget(_buildTestApp(onSelected: (t) => selected = t));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Chooser'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('template-chooser-cancel-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('entry-template-chooser')), findsNothing);
    expect(selected, isNull);
  });
}
