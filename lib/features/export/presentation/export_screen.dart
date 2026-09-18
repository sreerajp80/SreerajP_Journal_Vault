import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_text.dart';
import 'package:sreerajp_journal_vault/features/export/providers/export_providers.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_format.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_html_builder.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_scope.dart';
import 'package:sreerajp_journal_vault/features/export/services/export_service.dart';
import 'package:sreerajp_journal_vault/features/export/services/html_pdf_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

part 'export_screen_actions.dart';

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
  /// Lets the extensions in this library's part files rebuild the
  /// widget: `setState` is protected, so they cannot call it directly.
  void _rebuild(VoidCallback fn) => setState(fn);

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
      appBar: AppBar(title: Text(l10n.titleExport)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            l10n.descExportFromJournal(widget.journalTitle),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          _SectionHeader(l10n.titleExportSectionWhat),
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
                    title: Text(l10n.labelExportScopeThisEntry),
                    subtitle: widget.entryTitle == null
                        ? null
                        : Text(
                            widget.entryTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                RadioListTile<ExportScopeKind>(
                  key: const Key('export-scope-journal'),
                  value: ExportScopeKind.wholeJournal,
                  title: Text(l10n.labelExportScopeWholeJournal),
                ),
                RadioListTile<ExportScopeKind>(
                  key: const Key('export-scope-range'),
                  value: ExportScopeKind.dateRange,
                  title: Text(l10n.labelExportScopeDateRange),
                  subtitle: Text(
                    _dateRange == null
                        ? l10n.descExportDateRangeNotSet
                        : l10n.descExportDateRange(
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
                label: Text(l10n.actionExportPickDateRange),
              ),
            ),

          const Divider(height: 32),
          _SectionHeader(l10n.titleExportSectionFormat),
          RadioGroup<ExportFormat>(
            groupValue: _format,
            onChanged: (value) {
              if (_isExporting || value == null) return;
              setState(() => _format = value);
            },
            child: Column(
              children: [
                for (final format in ExportFormat.values)
                  _formatTile(l10n, format, pdfAvailable),
              ],
            ),
          ),

          const Divider(height: 32),
          _SectionHeader(l10n.titleExportSectionOptions),
          SwitchListTile(
            key: const Key('export-include-attachments'),
            value: _includeAttachments,
            title: Text(l10n.labelExportIncludeAttachments),
            subtitle: Text(l10n.descExportIncludeAttachments),
            onChanged: _isExporting
                ? null
                : (value) => setState(() => _includeAttachments = value),
          ),
          SwitchListTile(
            key: const Key('export-include-metadata'),
            value: _includeMetadata,
            title: Text(l10n.labelExportIncludeMetadata),
            subtitle: Text(l10n.descExportIncludeMetadata),
            onChanged: _isExporting
                ? null
                : (value) => setState(() => _includeMetadata = value),
          ),

          SwitchListTile(
            key: const Key('export-encrypt'),
            value: _encrypt,
            title: Text(l10n.titleExportProtect),
            subtitle: Text(l10n.descExportProtect),
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
                labelText: l10n.labelExportPassword,
                errorText: _passwordTooShort
                    ? l10n.errorExportPassword(minimumVaultPasswordLength)
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
                labelText: l10n.labelExportPasswordConfirm,
                errorText: _passwordsDiffer
                    ? l10n.errorExportPasswordMismatch
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
                          ? l10n.bodyExportEncryptedNotice
                          : l10n.bodyExportNotEncrypted,
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
              _isExporting ? l10n.bodyExportExporting : l10n.actionExport,
            ),
          ),

          if (_skipped != null && _skipped!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(l10n.titleExportSkipped),
            for (final omission in _skipped!)
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.remove_circle_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(omission.textIn(l10n)),
              ),
          ],
        ],
      ),
    );
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
