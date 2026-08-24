import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/callout_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/table_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen that displays version history for an entry and allows restoring
/// any previous revision.
///
/// Restoration is deterministic: the current entry content is snapshotted
/// first, then overwritten with an exact copy of the selected revision.
class VersionHistoryScreen extends ConsumerWidget {
  const VersionHistoryScreen({
    super.key,
    required this.entryId,
    required this.onRevisionRestored,
  });

  final int entryId;

  /// Called after a revision has been restored, so the editor can reload.
  final VoidCallback onRevisionRestored;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final revisionsAsync = ref.watch(entryRevisionsProvider(entryId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.versionHistoryTitle)),
      body: revisionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.versionHistoryLoadFailed(e.toString()))),
        data: (revisions) {
          if (revisions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.versionHistoryEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: revisions.length,
            itemBuilder: (context, index) {
              final revision = revisions[index];
              return _RevisionTile(
                revision: revision,
                onRestore: () => _restoreRevision(context, ref, revision),
                onPreview: () => _previewRevision(context, revision),
              );
            },
          );
        },
      ),
    );
  }

  void _previewRevision(BuildContext context, EntryRevision revision) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RevisionPreviewScreen(revision: revision),
      ),
    );
  }

  Future<void> _restoreRevision(
    BuildContext context,
    WidgetRef ref,
    EntryRevision revision,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.versionRestoreTitle),
          content: Text(l10n.versionRestoreBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.commonRestore),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final service = ref.read(entryRevisionServiceProvider);
    await service.restoreRevision(entryId: entryId, revisionId: revision.id);

    onRevisionRestored();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).versionRestored)),
      );
      Navigator.pop(context);
    }
  }
}

class _RevisionTile extends StatelessWidget {
  const _RevisionTile({
    required this.revision,
    required this.onRestore,
    required this.onPreview,
  });

  final EntryRevision revision;
  final VoidCallback onRestore;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = _formatDate(revision.createdAt);
    final title = revision.title?.isNotEmpty == true
        ? revision.title!
        : 'Untitled';
    final preview = _extractPreview(revision.plainText);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.history, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr, style: theme.textTheme.bodySmall),
          if (preview.isNotEmpty)
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      isThreeLine: preview.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: onPreview,
            tooltip: AppLocalizations.of(context).versionPreview,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: onRestore,
            tooltip: AppLocalizations.of(context).versionRestoreTooltip,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _extractPreview(String? plainText) {
    if (plainText == null || plainText.isEmpty) return '';
    return plainText.length > 120
        ? '${plainText.substring(0, 120)}...'
        : plainText;
  }
}

/// Read-only preview of a specific revision's content.
class _RevisionPreviewScreen extends ConsumerStatefulWidget {
  const _RevisionPreviewScreen({required this.revision});

  final EntryRevision revision;

  @override
  ConsumerState<_RevisionPreviewScreen> createState() =>
      _RevisionPreviewScreenState();
}

class _RevisionPreviewScreenState
    extends ConsumerState<_RevisionPreviewScreen> {
  late final QuillController _controller;
  late final InlineImageStore _imageStore;

  /// The same builders the editor uses. Without them a revision holding a
  /// table, a callout or an image renders as a failed embed instead of the
  /// content the user is trying to compare against.
  late final List<EmbedBuilder> _embedBuilders;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _imageStore = buildInlineImageStore(ref);
    _embedBuilders = [
      TableEmbedBuilder(),
      CalloutEmbedBuilder(),
      VaultImageEmbedBuilder(store: _imageStore),
      DrawingEmbedBuilder(store: _imageStore),
    ];
  }

  QuillController _buildController() {
    final json = widget.revision.contentJson;
    if (json != null && json.isNotEmpty) {
      try {
        final delta = Document.fromJson(jsonDecode(json) as List);
        return QuillController(
          document: delta,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (_) {
        // Fall through to empty controller.
      }
    }
    return QuillController.basic()..readOnly = true;
  }

  @override
  void dispose() {
    unawaited(_imageStore.dispose());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.revision.title?.isNotEmpty == true
        ? widget.revision.title!
        : 'Untitled';
    final typography = ref.watch(typographyProvider);
    final theme = Theme.of(context);
    final baseStyles = DefaultStyles.getInstance(context);
    final entryBodyStyle = typography.toTextStyle(
      color: theme.colorScheme.onSurface,
    );
    final customStyles = baseStyles.merge(
      DefaultStyles(
        paragraph: DefaultTextBlockStyle(
          entryBodyStyle,
          const HorizontalSpacing(0, 0),
          const VerticalSpacing(0, 6),
          const VerticalSpacing(0, 0),
          null,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).versionPreviewTitle(title)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: entryBodyStyle,
          child: QuillEditor.basic(
            controller: _controller,
            config: QuillEditorConfig(
              embedBuilders: _embedBuilders,
              customStyles: customStyles,
            ),
          ),
        ),
      ),
    );
  }
}
