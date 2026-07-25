import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/entry_providers.dart';

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
    final revisionsAsync = ref.watch(entryRevisionsProvider(entryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Version history')),
      body: revisionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading revisions: $e')),
        data: (revisions) {
          if (revisions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No previous versions yet.\n\nVersions are saved automatically when you edit an entry.',
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
      builder: (context) => AlertDialog(
        title: const Text('Restore this version?'),
        content: const Text(
          'Your current content will be saved as a new version before restoring.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final service = ref.read(entryRevisionServiceProvider);
    await service.restoreRevision(
      entryId: entryId,
      revisionId: revision.id,
    );

    onRevisionRestored();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Version restored')),
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
        child: Icon(
          Icons.history,
          color: theme.colorScheme.onPrimaryContainer,
        ),
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
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: onRestore,
            tooltip: 'Restore this version',
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
    return plainText.length > 120 ? '${plainText.substring(0, 120)}...' : plainText;
  }
}

/// Read-only preview of a specific revision's content.
class _RevisionPreviewScreen extends StatefulWidget {
  const _RevisionPreviewScreen({required this.revision});

  final EntryRevision revision;

  @override
  State<_RevisionPreviewScreen> createState() =>
      _RevisionPreviewScreenState();
}

class _RevisionPreviewScreenState extends State<_RevisionPreviewScreen> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.revision.title?.isNotEmpty == true
        ? widget.revision.title!
        : 'Untitled';

    return Scaffold(
      appBar: AppBar(title: Text('Preview: $title')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: QuillEditor.basic(controller: _controller),
      ),
    );
  }
}
