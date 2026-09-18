import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/utils/date_formatters.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen listing all attachments protected by dedicated attachment-level PIN locks.
class LockedAttachmentsScreen extends ConsumerStatefulWidget {
  const LockedAttachmentsScreen({super.key});

  @override
  ConsumerState<LockedAttachmentsScreen> createState() =>
      _LockedAttachmentsScreenState();
}

class _LockedAttachmentsScreenState
    extends ConsumerState<LockedAttachmentsScreen> {
  List<(AttachmentLock, Attachment)>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final svc = ref.read(attachmentLockServiceProvider);
    final locks = await svc.getLockedAttachments();
    final pairs = <(AttachmentLock, Attachment)>[];
    for (final l in locks) {
      try {
        final a = await db.attachmentsDao.getAttachmentById(l.attachmentId);
        pairs.add((l, a));
      } catch (_) {
        /* attachment missing — skip */
      }
    }
    if (mounted) setState(() => _entries = pairs);
  }

  Future<void> _remove(int attachmentId) async {
    final svc = ref.read(attachmentLockServiceProvider);
    await svc.removeLock(attachmentId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = _entries;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleLockedAttachments)),
      body: entries == null
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.emptyLockedAttachments,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final (lock, attachment) = entries[i];
                return ListTile(
                  key: Key('locked-attachment-${attachment.id}'),
                  leading: const Icon(Icons.lock),
                  title: Text(attachment.fileName),
                  subtitle: Text(
                    l10n.labelLockedAttachmentSince(
                      formatShortDate(lock.lockedAt),
                    ),
                  ),
                  trailing: TextButton(
                    key: Key('locked-attachment-remove-${attachment.id}'),
                    onPressed: () => _remove(attachment.id),
                    child: Text(l10n.actionLockedAttachmentRemove),
                  ),
                );
              },
            ),
    );
  }
}
