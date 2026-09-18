import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_template_text.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_manager_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Modal dialog allowing users to choose an entry template from grouped
/// categories, including user-created custom templates.
///
/// Categories are individually expandable and collapsible, with the first
/// category ("Start fresh" or "My templates" if present) expanded by default.
/// An "Expand all" / "Collapse all" button in the header allows toggling all
/// sections at once.
class EntryTemplateChooserDialog extends ConsumerStatefulWidget {
  const EntryTemplateChooserDialog({super.key});

  @override
  ConsumerState<EntryTemplateChooserDialog> createState() =>
      _EntryTemplateChooserDialogState();
}

class _EntryTemplateChooserDialogState
    extends ConsumerState<EntryTemplateChooserDialog> {
  /// Set of currently expanded category groups. Starts with `general` expanded.
  final Set<EntryTemplateCategory> _expandedCategories = {
    EntryTemplateCategory.general,
  };

  bool _allExpanded(Set<EntryTemplateCategory> allCategories) =>
      _expandedCategories.length == allCategories.length;

  void _toggleExpandAll(Set<EntryTemplateCategory> allCategories) {
    setState(() {
      if (_allExpanded(allCategories)) {
        _expandedCategories.clear();
      } else {
        _expandedCategories.addAll(allCategories);
      }
    });
  }

  void _toggleCategory(EntryTemplateCategory category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
  }

  IconData _iconForCategory(EntryTemplateCategory category) {
    switch (category) {
      case EntryTemplateCategory.custom:
        return Icons.dashboard_customize_outlined;
      case EntryTemplateCategory.general:
        return Icons.auto_awesome_outlined;
      case EntryTemplateCategory.reflective:
        return Icons.self_improvement_outlined;
      case EntryTemplateCategory.thoughts:
        return Icons.lightbulb_outline;
      case EntryTemplateCategory.projects:
        return Icons.assignment_outlined;
      case EntryTemplateCategory.people:
        return Icons.people_outline;
      case EntryTemplateCategory.health:
        return Icons.favorite_outline;
      case EntryTemplateCategory.learning:
        return Icons.school_outlined;
      case EntryTemplateCategory.creative:
        return Icons.brush_outlined;
      case EntryTemplateCategory.planning:
        return Icons.event_note_outlined;
      case EntryTemplateCategory.specialty:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);

    final userTemplatesAsync = ref.watch(allUserTemplatesProvider);
    final userTemplates = userTemplatesAsync.value ?? [];

    final grouped = <EntryTemplateCategory, List<EntryTemplate>>{};
    if (userTemplates.isNotEmpty) {
      grouped[EntryTemplateCategory.custom] = userTemplates
          .map((ut) => EntryTemplate.fromUserTemplate(ut))
          .toList();
    }
    grouped.addAll(entryTemplatesByCategory);

    final allCategoryKeys = grouped.keys.toSet();
    final isAllExpanded = _allExpanded(allCategoryKeys);

    return Dialog(
      key: const Key('entry-template-chooser'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: mediaQuery.size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header bar with Title, Manage link, and Expand/Collapse All toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.titleTemplateChooser,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('template-chooser-manage-button'),
                    icon: const Icon(Icons.tune, size: 20),
                    tooltip: l10n.titleTemplateManager,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TemplateManagerScreen(),
                        ),
                      );
                      ref.invalidate(allUserTemplatesProvider);
                    },
                  ),
                  TextButton.icon(
                    key: const Key('template-expand-collapse-all-button'),
                    onPressed: () => _toggleExpandAll(allCategoryKeys),
                    icon: Icon(
                      isAllExpanded
                          ? Icons.unfold_less_rounded
                          : Icons.unfold_more_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isAllExpanded
                          ? l10n.actionTemplateCollapseAll
                          : l10n.actionTemplateExpandAll,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable list of expandable category sections
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: grouped.entries.length,
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
                  final category = entry.key;
                  final templates = entry.value;
                  final isExpanded = _expandedCategories.contains(category);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: isExpanded ? 1.0 : 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isExpanded
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category Header (tap to toggle)
                        InkWell(
                          key: Key('template-category-${category.name}'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _toggleCategory(category),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _iconForCategory(category),
                                  size: 20,
                                  color: isExpanded
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    category.labelIn(l10n),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isExpanded
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${templates.length}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expanded template items
                        if (isExpanded) ...[
                          const Divider(height: 1, indent: 14, endIndent: 14),
                          for (final template in templates)
                            InkWell(
                              key: template.isCustom
                                  ? Key(
                                      'entry-template-custom-${template.customId}',
                                    )
                                  : Key('entry-template-${template.id.name}'),
                              onTap: () => Navigator.pop(context, template),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            template.labelIn(l10n),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (template
                                              .descriptionIn(l10n)
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              template.descriptionIn(l10n),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (template.isCustom)
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),
            // Footer with "Create new template" and Cancel button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  TextButton.icon(
                    key: const Key('create-custom-template-chooser-button'),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.actionTemplateCreateNew),
                    onPressed: () async {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => const TemplateEditorScreen(),
                        ),
                      );
                      if (created == true) {
                        ref.invalidate(allUserTemplatesProvider);
                        setState(() {
                          _expandedCategories.add(EntryTemplateCategory.custom);
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    key: const Key('template-chooser-cancel-button'),
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionCommonCancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
