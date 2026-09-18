import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:sreerajp_journal_vault/features/import/providers/import_providers.dart';
import 'package:sreerajp_journal_vault/features/import/services/import_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Screen for importing files into a journal.
///
/// Allows users to pick one or more files (Markdown, DOCX, plain text)
/// and import them as new entries in the selected journal.
class ImportScreen extends ConsumerStatefulWidget {
  final int journalId;
  final String journalTitle;

  const ImportScreen({
    super.key,
    required this.journalId,
    required this.journalTitle,
  });

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _isImporting = false;
  Map<String, ImportFileResult>? _results;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final importService = ref.read(importServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleImport)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.titleImportIntoJournal(widget.journalTitle),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.labelImportSupportedFormats(
                        [
                          l10n.labelImportFormatPlainText,
                          l10n.labelImportFormatMarkdown,
                          l10n.labelImportFormatWord,
                        ].join(', '),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.labelImportSupportedExtensions(
                        importService.supportedExtensions.join(', '),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isImporting
                  ? null
                  : () => _pickAndImport(importService),
              icon: _isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_open),
              label: Text(
                _isImporting
                    ? l10n.bodyImportSelecting
                    : l10n.actionImportSelectFiles,
              ),
            ),
            const SizedBox(height: 24),
            if (_results != null) ...[
              Text(l10n.titleImportResults, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _results!.length,
                  itemBuilder: (context, index) {
                    final entry = _results!.entries.elementAt(index);
                    final result = entry.value;
                    return ListTile(
                      leading: Icon(
                        result.isSuccess ? Icons.check_circle : Icons.error,
                        color: result.isSuccess
                            ? Colors.green
                            : theme.colorScheme.error,
                      ),
                      title: Text(entry.key),
                      subtitle: result.isSuccess
                          ? Text(l10n.labelImportFileSucceeded)
                          : Text(
                              result.error ?? l10n.errorCommonUnknown,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                    );
                  },
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.bodyImportSelectFilesPrompt,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImport(ImportService importService) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'markdown', 'docx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isImporting = true;
      _results = null;
    });

    final inputs = <ImportFileInput>[];
    for (final file in result.files) {
      if (file.bytes != null) {
        inputs.add(ImportFileInput(fileName: file.name, bytes: file.bytes!));
      }
    }

    final importResults = await importService.importFiles(
      journalId: widget.journalId,
      files: inputs,
    );

    if (mounted) {
      setState(() {
        _isImporting = false;
        _results = importResults;
      });

      final successCount = importResults.values
          .where((r) => r.isSuccess)
          .length;
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).descImportCountSucceeded(successCount),
            ),
          ),
        );
      }
    }
  }
}
