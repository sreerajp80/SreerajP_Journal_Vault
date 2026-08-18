import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/tags/domain/tag_colors.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Lists every tag in the vault and lets the user rename, recolour or delete
/// one.
///
/// Tags are global — a tag edited here changes everywhere it is used, on every
/// journal and entry.
class TagManagerScreen extends ConsumerWidget {
  const TagManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tagsAsync = ref.watch(allTagsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tagsTitle)),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.tagsLoadError(error.toString()))),
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.tagsEmpty, textAlign: TextAlign.center),
              ),
            );
          }

          final sorted = [...tags]..sort((a, b) => a.name.compareTo(b.name));

          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _TagTile(tag: sorted[index], key: ValueKey(sorted[index].id)),
          );
        },
      ),
    );
  }
}

class _TagTile extends ConsumerWidget {
  const _TagTile({required this.tag, super.key});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = colorForTag(tag);

    return ListTile(
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text('#${tag.name}', style: TextStyle(color: color)),
      subtitle: hasCustomColor(tag) ? null : Text(l10n.tagsAutomaticColour),
      trailing: PopupMenuButton<_TagAction>(
        tooltip: l10n.tagsActionsTooltip,
        onSelected: (action) => _handle(context, ref, action),
        itemBuilder: (context) => [
          PopupMenuItem(value: _TagAction.rename, child: Text(l10n.tagsRename)),
          PopupMenuItem(
            value: _TagAction.color,
            child: Text(l10n.tagsChooseColour),
          ),
          if (hasCustomColor(tag))
            PopupMenuItem(
              value: _TagAction.resetColor,
              child: Text(l10n.tagsResetColour),
            ),
          PopupMenuItem(
            value: _TagAction.delete,
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _TagAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);
    final messenger = ScaffoldMessenger.of(context);

    switch (action) {
      case _TagAction.rename:
        final name = await _promptForName(context, tag.name);
        if (name == null) return;
        final ok = await db.tagsDao.renameTag(tag.id, name);
        if (!ok) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.tagsRenameFailed)),
          );
          return;
        }

      case _TagAction.color:
        final picked = await _promptForColor(context, colorForTag(tag));
        if (picked == null) return;
        await db.tagsDao.setTagColor(tag.id, picked.toARGB32());

      case _TagAction.resetColor:
        await db.tagsDao.setTagColor(tag.id, null);

      case _TagAction.delete:
        final confirmed = await _confirmDelete(context, tag.name);
        if (confirmed != true) return;
        await db.tagsDao.deleteTagWithLinks(tag.id);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.tagsDeleted(tag.name))),
        );
    }

    ref.invalidate(allTagsProvider);
    ref.invalidate(homeJournalsProvider);
  }

  Future<String?> _promptForName(BuildContext context, String current) {
    return showDialog<String>(
      context: context,
      builder: (_) => _RenameTagDialog(currentName: current),
    );
  }

  Future<Color?> _promptForColor(BuildContext context, Color current) {
    return showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext).tagsChooseColour),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in kTagPalette)
              InkWell(
                key: ValueKey('tag-color-${color.toARGB32()}'),
                onTap: () => Navigator.pop(dialogContext, color),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: color.toARGB32() == current.toARGB32()
                        ? Border.all(
                            color: Theme.of(
                              dialogContext,
                            ).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(dialogContext).commonCancel),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.tagsDeleteTitle),
          content: Text(l10n.tagsDeleteBody(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
  }
}

enum _TagAction { rename, color, resetColor, delete }

/// Asks for a new tag name.
///
/// Stateful so the dialog itself owns the controller — disposing it from the
/// caller would tear it down while the dialog is still animating away.
class _RenameTagDialog extends StatefulWidget {
  const _RenameTagDialog({required this.currentName});

  final String currentName;

  @override
  State<_RenameTagDialog> createState() => _RenameTagDialogState();
}

class _RenameTagDialogState extends State<_RenameTagDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.tagsRenameTitle),
      content: TextField(
        key: const Key('tag-rename-field'),
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.tagsNameLabel),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
