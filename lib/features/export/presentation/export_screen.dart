import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/providers/export_providers.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_html_builder.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_scope.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_service.dart';
import 'package:sreerajp_journal_vault/features/export/services/html_pdf_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Lets the user take entries out of the vault as a file.
///
/// Reached from three places: the entry editor (one entry), the journal detail
/// screen (that journal), and Settings (pick a journal first). Whichever door
/// was used, the caller has already passed the journal's lock — this screen
/// never opens a locked journal by itself.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({
    super.key,
    required this.journalId,
    required this.journalTitle,
    this.entryId,
    this.entryTitle,
  });

  final int journalId;
  final String journalTitle;

  /// Set when the screen was opened from a single entry. That entry is then
  /// the default choice, and "this entry" is offered as a scope.
  final int? entryId;
  final String? entryTitle;

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  late ExportScopeKind _scopeKind;
  ExportFormat _format = ExportFormat.markdown;
  bool _includeAttachments = false;
  bool _includeMetadata = true;
  DateTimeRange? _dateRange;

  bool _isExporting = false;
  List<ExportOmission>? _skipped;

  /// Seal the finished file under a password instead of writing it in the
  /// clear. Off by default: an export that only this app can open is not what
  /// most exports are for.
  bool _encrypt = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scopeKind = widget.entryId != null
        ? ExportScopeKind.singleEntry
        : ExportScopeKind.wholeJournal;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pdfAvailable = ref.watch(pdfExportAvailableProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(ExportStrings.screenTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            ExportStrings.fromJournal(widget.journalTitle),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          const _SectionHeader(ExportStrings.sectionWhat),
          RadioGroup<ExportScopeKind>(
            groupValue: _scopeKind,
            // RadioGroup takes a non-null callback, so "disabled while
            // exporting" is a guard inside it rather than a null.
            onChanged: (value) {
              if (_isExporting) return;
              _setScope(value);
            },
            child: Column(
              children: [
                if (widget.entryId != null)
                  RadioListTile<ExportScopeKind>(
                    key: const Key('export-scope-entry'),
                    value: ExportScopeKind.singleEntry,
                    title: const Text(ExportStrings.scopeThisEntry),
                    subtitle: widget.entryTitle == null
                        ? null
                        : Text(
                            widget.entryTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                const RadioListTile<ExportScopeKind>(
                  key: Key('export-scope-journal'),
                  value: ExportScopeKind.wholeJournal,
                  title: Text(ExportStrings.scopeWholeJournal),
                ),
                RadioListTile<ExportScopeKind>(
                  key: const Key('export-scope-range'),
                  value: ExportScopeKind.dateRange,
                  title: const Text(ExportStrings.scopeDateRange),
                  subtitle: Text(
                    _dateRange == null
                        ? ExportStrings.dateRangeNotSet
                        : ExportStrings.dateRangeLabel(
                            formatDateOnly(_dateRange!.start),
                            formatDateOnly(_dateRange!.end),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_scopeKind == ExportScopeKind.dateRange)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: OutlinedButton.icon(
                key: const Key('export-pick-dates'),
                onPressed: _isExporting ? null : _pickDateRange,
                icon: const Icon(Icons.date_range),
                label: const Text(ExportStrings.pickDateRange),
              ),
            ),

          const Divider(height: 32),
          const _SectionHeader(ExportStrings.sectionFormat),
          RadioGroup<ExportFormat>(
            groupValue: _format,
            onChanged: (value) {
              if (_isExporting || value == null) return;
              setState(() => _format = value);
            },
            child: Column(
              children: [
                for (final format in ExportFormat.values)
                  _formatTile(format, pdfAvailable),
              ],
            ),
          ),

          const Divider(height: 32),
          const _SectionHeader(ExportStrings.sectionOptions),
          SwitchListTile(
            key: const Key('export-include-attachments'),
            value: _includeAttachments,
            title: const Text(ExportStrings.includeAttachments),
            subtitle: const Text(ExportStrings.includeAttachmentsHint),
            onChanged: _isExporting
                ? null
                : (value) => setState(() => _includeAttachments = value),
          ),
          SwitchListTile(
            key: const Key('export-include-metadata'),
            value: _includeMetadata,
            title: const Text(ExportStrings.includeMetadata),
            subtitle: const Text(ExportStrings.includeMetadataHint),
            onChanged: _isExporting
                ? null
                : (value) => setState(() => _includeMetadata = value),
          ),

          SwitchListTile(
            key: const Key('export-encrypt'),
            value: _encrypt,
            title: Text(l10n.exportProtectTitle),
            subtitle: Text(l10n.exportProtectHint),
            onChanged: _isExporting
                ? null
                : (value) => setState(() => _encrypt = value),
          ),

          if (_encrypt) ...[
            const SizedBox(height: 8),
            TextField(
              key: const Key('export-password-field'),
              controller: _passwordController,
              obscureText: true,
              enabled: !_isExporting,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.exportPasswordLabel,
                errorText: _passwordTooShort
                    ? l10n.exportPasswordTooShort(minimumVaultPasswordLength)
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('export-password-confirm-field'),
              controller: _confirmController,
              obscureText: true,
              enabled: !_isExporting,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.exportPasswordConfirmLabel,
                errorText: _passwordsDiffer
                    ? l10n.exportPasswordMismatch
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 16),
          // An export takes content out of an encrypted vault. The user is
          // told that here, in the screen, not only in a document. With the
          // password switch on the warning changes rather than disappearing:
          // a forgotten password is its own way to lose the file.
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _encrypt ? Icons.lock_outline : Icons.lock_open,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _encrypt
                          ? l10n.exportEncryptedNotice
                          : ExportStrings.notEncryptedWarning,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('export-run-button'),
            onPressed: _canExport ? _runExport : null,
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt),
            label: Text(
              _isExporting
                  ? ExportStrings.exporting
                  : ExportStrings.exportAction,
            ),
          ),

          if (_skipped != null && _skipped!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionHeader(ExportStrings.skippedHeading),
            for (final omission in _skipped!)
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(omission.message),
              ),
          ],
        ],
      ),
    );
  }

  Widget _formatTile(ExportFormat format, AsyncValue<bool> pdfAvailable) {
    // PDF is the only format that can be unavailable — the other three are
    // produced in pure Dart. It is shown disabled with a reason rather than
    // hidden, so the user knows it exists and why they cannot have it.
    final unavailable =
        format.needsNativeRenderer &&
        pdfAvailable.maybeWhen(data: (value) => !value, orElse: () => false);

    return RadioListTile<ExportFormat>(
      key: Key('export-format-${format.name}'),
      value: format,
      title: Text(format.label),
      subtitle: Text(unavailable ? ExportStrings.pdfUnavailable : format.hint),
      // An unavailable format is greyed out here, individually, rather than by
      // the group — the other three formats stay usable.
      enabled: !unavailable,
    );
  }

  bool get _canExport {
    if (_isExporting) return false;
    // A date range with no dates chosen cannot be exported.
    if (_scopeKind == ExportScopeKind.dateRange && _dateRange == null) {
      return false;
    }
    if (_encrypt && !_passwordIsUsable) return false;
    return true;
  }

  /// The password rule is the backup's rule — one length for the whole app.
  bool get _passwordIsUsable =>
      _passwordController.text.length >= minimumVaultPasswordLength &&
      _passwordController.text == _confirmController.text;

  /// Only complain once something has been typed. An empty field nobody has
  /// touched yet is not an error.
  bool get _passwordTooShort =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text.length < minimumVaultPasswordLength;

  bool get _passwordsDiffer =>
      _confirmController.text.isNotEmpty &&
      _confirmController.text != _passwordController.text;

  void _setScope(ExportScopeKind? kind) {
    if (kind == null) return;
    setState(() => _scopeKind = kind);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (picked != null && mounted) {
      setState(() => _dateRange = picked);
    }
  }

  ExportScope _buildScope() {
    switch (_scopeKind) {
      case ExportScopeKind.singleEntry:
        return ExportScope.singleEntry(
          journalId: widget.journalId,
          entryId: widget.entryId!,
          includeAttachments: _includeAttachments,
          includeMetadata: _includeMetadata,
        );
      case ExportScopeKind.wholeJournal:
        return ExportScope.wholeJournal(
          journalId: widget.journalId,
          includeAttachments: _includeAttachments,
          includeMetadata: _includeMetadata,
        );
      case ExportScopeKind.dateRange:
        return ExportScope.dateRange(
          journalId: widget.journalId,
          from: _dateRange!.start,
          to: _dateRange!.end,
          includeAttachments: _includeAttachments,
          includeMetadata: _includeMetadata,
        );
    }
  }

  Future<void> _runExport() async {
    // Captured before the first await so no stale context is touched later.
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isExporting = true;
      _skipped = null;
    });

    try {
      final scope = _buildScope();
      final bundle = await ref.read(exportCollectorProvider).collect(scope);

      if (bundle.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text(ExportStrings.nothingToExport)),
        );
        return;
      }

      // `docs/security.md` section 14: a plaintext export needs an explicit
      // confirmation step. It is asked here, once the entry count is known, so
      // the question can say exactly how much is about to leave the vault.
      // A password-protected export is not a plaintext export, so it does
      // not ask — turning the switch on was the deliberate act.
      final confirmed =
          _encrypt || await _confirmUnencryptedExport(bundle.entryCount);
      if (!confirmed) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text(ExportStrings.exportCancelled)),
        );
        return;
      }

      final result = await ref
          .read(exportServiceProvider)
          .build(
            bundle,
            format: _format,
            includeAttachments: _includeAttachments,
            includeMetadata: _includeMetadata,
            password: _encrypt ? _passwordController.text : null,
          );

      // The system save dialog: scoped storage, no permission needed, and it
      // preserves a Unicode file name. Sharing through a content URI would
      // percent-encode a Malayalam name and garble it.
      final savedPath = await FilePicker.saveFile(
        dialogTitle: ExportStrings.saveDialogTitle,
        fileName: result.fileName,
        bytes: result.bytes,
      );

      if (!mounted) return;

      if (savedPath == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text(ExportStrings.exportCancelled)),
        );
        return;
      }

      await _logExport(scope: scope, result: result);

      setState(() => _skipped = result.skipped);
      messenger.showSnackBar(
        SnackBar(
          content: Text(ExportStrings.exportedEntries(result.entryCount)),
        ),
      );
    } on HtmlPdfException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } on ExportException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      AppLogger.error('export: run failed', error: AppLogger.redact(error));
      messenger.showSnackBar(
        const SnackBar(content: Text(ExportStrings.exportFailed)),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// Asks the user to confirm writing their journal out unencrypted.
  ///
  /// Required by `docs/security.md` section 14. Returns false if the user backs
  /// out or dismisses the dialog, and the export is then abandoned before any
  /// file is built.
  Future<bool> _confirmUnencryptedExport(int entryCount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('export-confirm-dialog'),
        title: const Text(ExportStrings.confirmTitle),
        content: Text(ExportStrings.confirmBody(entryCount, _format.label)),
        actions: [
          TextButton(
            key: const Key('export-confirm-cancel'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(ExportStrings.cancel),
          ),
          FilledButton(
            key: const Key('export-confirm-accept'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(ExportStrings.confirmAction),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Records the export in the audit log.
  ///
  /// `export_attempt` is a type the `SecurityEvents` table already documents
  /// but that nothing wrote until now. It records **what shape** the export
  /// was, never any entry content — no titles, no text, no file names.
  Future<void> _logExport({
    required ExportScope scope,
    required ExportResult result,
  }) async {
    try {
      await ref
          .read(appDatabaseProvider)
          .securityEventsDao
          .logEvent(
            SecurityEventsCompanion.insert(
              eventType: 'export_attempt',
              severity: const Value('info'),
              description: 'Journal data exported',
              metadata: Value(
                jsonEncode({
                  'scope': scope.kind.name,
                  'format': _format.name,
                  'journalId': scope.journalId,
                  'entryCount': result.entryCount,
                  'includedAttachments': _includeAttachments,
                  'encrypted': result.isEncrypted,
                  'skippedCount': result.skipped.length,
                }),
              ),
            ),
          );
    } catch (error) {
      // Losing an audit line must never lose the user their export.
      AppLogger.warning(
        'export: could not write the audit event',
        error: AppLogger.redact(error),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
