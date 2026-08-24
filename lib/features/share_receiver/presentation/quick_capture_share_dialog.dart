import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/open_encrypted_export_screen.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class QuickCaptureShareDialog extends ConsumerStatefulWidget {
  const QuickCaptureShareDialog({
    super.key,
    required this.payload,
    required this.onDismissed,
  });

  final SharedIntentPayload payload;
  final VoidCallback onDismissed;

  @override
  ConsumerState<QuickCaptureShareDialog> createState() =>
      _QuickCaptureShareDialogState();
}

class _QuickCaptureShareDialogState
    extends ConsumerState<QuickCaptureShareDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int? _selectedJournalId;
  bool _saving = false;
  List<Journal> _journals = const [];
  bool _loadingJournals = true;

  @override
  void initState() {
    super.initState();
    _initFields();
    _loadJournals();
  }

  void _initFields() {
    String initialTitle = '';
    if (widget.payload.subject != null &&
        widget.payload.subject!.trim().isNotEmpty) {
      initialTitle = widget.payload.subject!.trim();
    } else if (widget.payload.text != null &&
        widget.payload.text!.trim().isNotEmpty) {
      final firstLine = widget.payload.text!.trim().split('\n').first;
      initialTitle = firstLine.length > 50
          ? '${firstLine.substring(0, 47)}...'
          : firstLine;
    } else if (widget.payload.mediaItems.isNotEmpty) {
      initialTitle = widget.payload.mediaItems.first.fileName;
    } else {
      initialTitle = 'Note - ${DateFormat.yMMMd().format(DateTime.now())}';
    }

    _titleController = TextEditingController(text: initialTitle);
    _contentController = TextEditingController(text: widget.payload.text ?? '');
  }

  Future<void> _loadJournals() async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!mounted) return;
    setState(() {
      _journals = journals;
      _loadingJournals = false;
      if (journals.isNotEmpty) {
        _selectedJournalId = journals.first.id;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  List<PickedAttachmentData> _convertMediaItems() {
    return widget.payload.mediaItems.map((item) {
      return PickedAttachmentData(
        fileName: item.fileName,
        bytes: item.bytes,
        mimeType: item.mimeType,
      );
    }).toList();
  }

  Future<void> _saveDirectlyToJournal() async {
    if (_selectedJournalId == null) return;
    setState(() => _saving = true);

    final l10n = AppLocalizations.of(context);
    final db = ref.read(appDatabaseProvider);
    final journalTitle = _journals
        .firstWhere(
          (j) => j.id == _selectedJournalId,
          orElse: () => _journals.first,
        )
        .title;

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text;

      // Construct Delta content JSON
      final deltaOps = <Map<String, dynamic>>[];
      if (content.isNotEmpty) {
        deltaOps.add({'insert': '$content\n'});
      } else {
        deltaOps.add({'insert': '\n'});
      }

      final entryId = await db.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: _selectedJournalId!,
          title: Value(title),
          contentJson: Value(jsonEncode(deltaOps)),
        ),
      );

      // Import attachments
      final mediaItems = _convertMediaItems();
      final updatedOps = List<Map<String, dynamic>>.from(deltaOps);

      for (final media in mediaItems) {
        try {
          final attachmentId = await ref
              .read(attachmentImportServiceProvider)
              .importToEntry(database: db, entryId: entryId, picked: media);
          if (media.mimeType.startsWith('image/')) {
            final embed = VaultImageEmbed.create(
              attachmentId: attachmentId,
              fileName: media.fileName,
            );
            updatedOps.add({'insert': embed.toJson()});
            updatedOps.add({'insert': '\n'});
          }
        } catch (_) {}
      }

      await db.entriesDao.updateEntryById(
        entryId,
        EntriesCompanion(contentJson: Value(jsonEncode(updatedOps))),
      );

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      widget.onDismissed();
      Navigator.of(context).pop();

      messenger.showSnackBar(
        SnackBar(content: Text(l10n.shareSavedSuccess(journalTitle))),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.shareSaveFailed)));
      }
    }
  }

  void _openInEditor() {
    if (_selectedJournalId == null) return;
    final title = _titleController.text.trim();
    final content = _contentController.text;
    final attachments = _convertMediaItems();
    final journalId = _selectedJournalId!;

    widget.onDismissed();
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryEditorScreen(
          journalId: journalId,
          initialTitle: title.isNotEmpty ? title : null,
          initialPlainText: content.isNotEmpty ? content : null,
          initialAttachments: attachments.isNotEmpty ? attachments : null,
        ),
      ),
    );
  }

  void _openEncryptedFile() {
    final sealedItem = widget.payload.mediaItems.firstWhere(
      (m) => m.isSealedFile,
      orElse: () => widget.payload.mediaItems.first,
    );

    widget.onDismissed();
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpenEncryptedExportScreen(
          initialFile: PickedSealedFile(
            fileName: sealedItem.fileName,
            bytes: sealedItem.bytes,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (widget.payload.isSealedFile) {
      final sealed = widget.payload.mediaItems.firstWhere(
        (m) => m.isSealedFile,
        orElse: () => widget.payload.mediaItems.first,
      );
      final sizeKb = (sealed.bytes.lengthInBytes / 1024).toStringAsFixed(1);

      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.enhanced_encryption_rounded, color: colors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.shareSealedFileDetected)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.lock_rounded,
                size: 36,
                color: colors.primary,
              ),
              title: Text(
                sealed.fileName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('$sizeKb KB • Encrypted Vault Archive'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onDismissed();
              Navigator.of(context).pop();
            },
            child: Text(l10n.shareDiscard),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.lock_open_rounded),
            label: Text(l10n.shareOpenEncryptedExport),
            onPressed: _openEncryptedFile,
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shareQuickCaptureTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.shareQuickCaptureSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loadingJournals)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_journals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(l10n.shareNoJournalsFound),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          widget.onDismissed();
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.commonCancel),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: _selectedJournalId,
                          decoration: InputDecoration(
                            labelText: l10n.shareSelectJournal,
                            prefixIcon: const Icon(Icons.book_rounded),
                            border: const OutlineInputBorder(),
                          ),
                          items: _journals.map((j) {
                            return DropdownMenuItem<int>(
                              value: j.id,
                              child: Text(j.title),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedJournalId = val);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: l10n.shareEntryTitleLabel,
                            hintText: l10n.shareEntryTitleHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentController,
                          maxLines: 4,
                          minLines: 2,
                          decoration: InputDecoration(
                            labelText: l10n.shareContentLabel,
                            hintText: l10n.shareContentHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (widget.payload.mediaItems.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            l10n.shareAttachmentsLabel(
                              widget.payload.mediaItems.length,
                            ),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.payload.mediaItems.map((m) {
                              final sizeKb = (m.bytes.lengthInBytes / 1024)
                                  .toStringAsFixed(1);
                              return Chip(
                                avatar: Icon(
                                  m.isImage
                                      ? Icons.image_rounded
                                      : Icons.attach_file_rounded,
                                  size: 18,
                                ),
                                label: Text('${m.fileName} ($sizeKb KB)'),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (!_loadingJournals && _journals.isNotEmpty) ...[
                const SizedBox(height: 16),
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () {
                              widget.onDismissed();
                              Navigator.of(context).pop();
                            },
                      child: Text(l10n.shareDiscard),
                    ),
                    OutlinedButton(
                      onPressed: _saving ? null : _openInEditor,
                      child: Text(l10n.shareOpenInEditor),
                    ),
                    FilledButton(
                      onPressed: _saving ? null : _saveDirectlyToJournal,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.shareSaveToJournal),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
