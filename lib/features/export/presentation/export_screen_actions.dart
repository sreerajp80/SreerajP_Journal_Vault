part of 'export_screen.dart';

extension _ExportScreenStatePart1 on _ExportScreenState {
  Widget _formatTile(
    AppLocalizations l10n,
    ExportFormat format,
    AsyncValue<bool> pdfAvailable,
  ) {
    // PDF is the only format that can be unavailable — the other three are
    // produced in pure Dart. It is shown disabled with a reason rather than
    // hidden, so the user knows it exists and why they cannot have it.
    final unavailable =
        format.needsNativeRenderer &&
        pdfAvailable.maybeWhen(data: (value) => !value, orElse: () => false);

    return RadioListTile<ExportFormat>(
      key: Key('export-format-${format.name}'),
      value: format,
      title: Text(format.labelIn(l10n)),
      subtitle: Text(
        unavailable ? l10n.bodyExportPdfUnavailable : format.hintIn(l10n),
      ),
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
    _rebuild(() => _scopeKind = kind);
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
      _rebuild(() => _dateRange = picked);
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
    final l10n = AppLocalizations.of(context);

    _rebuild(() {
      _isExporting = true;
      _skipped = null;
    });

    try {
      final scope = _buildScope();
      final bundle = await ref.read(exportCollectorProvider).collect(scope);

      if (bundle.isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.errorExportNothing)),
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
          SnackBar(content: Text(l10n.bodyExportCancelled)),
        );
        return;
      }

      final result = await ref
          .read(exportServiceProvider)
          .build(
            bundle,
            format: _format,
            // The file is written in the language the user is using now.
            labels: exportLabelsFor(l10n),
            includeAttachments: _includeAttachments,
            includeMetadata: _includeMetadata,
            password: _encrypt ? _passwordController.text : null,
          );

      // The system save dialog: scoped storage, no permission needed, and it
      // preserves a Unicode file name. Sharing through a content URI would
      // percent-encode a Malayalam name and garble it.
      final savedPath = await FilePicker.saveFile(
        dialogTitle: l10n.titleExportSaveDialog,
        fileName: result.fileName,
        bytes: result.bytes,
      );

      if (!mounted) return;

      if (savedPath == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.bodyExportCancelled)),
        );
        return;
      }

      await _logExport(scope: scope, result: result);

      _rebuild(() => _skipped = result.skipped);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bodyExportDone(result.entryCount))),
      );
    } on HtmlPdfException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.textIn(l10n))));
    } on ExportException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.textIn(l10n))));
    } catch (error) {
      AppLogger.error('export: run failed', error: AppLogger.redact(error));
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorExportFailed)));
    } finally {
      if (mounted) _rebuild(() => _isExporting = false);
    }
  }

  /// Asks the user to confirm writing their journal out unencrypted.
  ///
  /// Required by `docs/security.md` section 14. Returns false if the user backs
  /// out or dismisses the dialog, and the export is then abandoned before any
  /// file is built.
  Future<bool> _confirmUnencryptedExport(int entryCount) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('export-confirm-dialog'),
        title: Text(l10n.titleExportConfirm),
        content: Text(
          l10n.bodyExportConfirm(entryCount, _format.labelIn(l10n)),
        ),
        actions: [
          TextButton(
            key: const Key('export-confirm-cancel'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.actionCommonCancel),
          ),
          FilledButton(
            key: const Key('export-confirm-accept'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.actionExportAnyway),
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
  /// was, never any entry content — no titles, no text, no file names. The
  /// description is a fixed log line, not text for the user; the events screen
  /// words each event type in the user's language.
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
