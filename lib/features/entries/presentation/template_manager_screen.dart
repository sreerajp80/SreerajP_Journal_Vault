import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_editor_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen displaying and managing all custom entry templates created by the user.
///
/// Allows creating, editing, previewing, and deleting user templates.
class TemplateManagerScreen extends ConsumerWidget {
  const TemplateManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final templatesAsync = ref.watch(allUserTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.templateManagerTitle),
        actions: [
          IconButton(
            key: const Key('add-template-appbar-button'),
            icon: const Icon(Icons.add),
            tooltip: l10n.templateCreateNew,
            onPressed: () => _openEditor(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-template-fab'),
        tooltip: l10n.templateCreateNew,
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading templates: $err')),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.templateEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const Key('create-first-template-button'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.templateCreateNew),
                      onPressed: () => _openEditor(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: templates.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final template = templates[index];
              return _TemplateListTile(
                template: template,
                key: ValueKey(template.id),
                onTap: () => _openEditor(context, template: template),
              );
            },
          );
        },
      ),
    );
  }

  void _openEditor(BuildContext context, {UserTemplate? template}) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TemplateEditorScreen(existingTemplate: template),
      ),
    );
  }
}

enum _TemplateAction { edit, delete }

class _TemplateListTile extends ConsumerWidget {
  const _TemplateListTile({
    required this.template,
    required this.onTap,
    super.key,
  });

  final UserTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    String? subtitleText;
    if (template.description != null && template.description!.isNotEmpty) {
      subtitleText = template.description;
    } else if (template.defaultTitle != null &&
        template.defaultTitle!.isNotEmpty) {
      subtitleText = 'Title: ${template.defaultTitle}';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.dashboard_customize_outlined,
          color: theme.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        template.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onTap,
      trailing: PopupMenuButton<_TemplateAction>(
        key: Key('template-actions-${template.id}'),
        tooltip: l10n.tagsActionsTooltip,
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _TemplateAction.edit,
            child: Text(l10n.templateEdit),
          ),
          PopupMenuItem(
            value: _TemplateAction.delete,
            child: Text(l10n.templateDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _TemplateAction action,
  ) async {
    final l10n = AppLocalizations.of(context);

    switch (action) {
      case _TemplateAction.edit:
        onTap();
        break;
      case _TemplateAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: Text(l10n.templateDeleteConfirmTitle),
            content: Text(l10n.templateDeleteConfirmMessage(template.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                key: const Key('confirm-delete-template-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: Text(l10n.commonDelete),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          final db = ref.read(appDatabaseProvider);
          await db.userTemplatesDao.deleteUserTemplate(template.id);
          ref.invalidate(allUserTemplatesProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.templateDeleteSuccess)));
          }
        }
        break;
    }
  }
}
