/// Opens a password-protected export file again.
///
/// Layer: presentation. An encrypted export nobody can unwrap would not be a
/// feature, so this is the other half of the password switch on the export
/// screen.
///
/// It **only** unwraps the file: pick it, give the password, and save what was
/// inside under its original name. It never puts anything back into the vault
/// — that is what restoring a backup is for, and a second, weaker import path
/// would be one more way for bad data to get in.
library;

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/core/security/vault_payload.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// A file the user pointed at, read into memory.
class PickedSealedFile {
  const PickedSealedFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

/// Asks the system for a file. Returns null if the user backed out.
typedef SealedFilePicker = Future<PickedSealedFile?> Function();

/// Writes [bytes] out under [fileName]. Returns null if the user backed out.
typedef SealedFileSaver =
    Future<String?> Function({
      required String dialogTitle,
      required String fileName,
      required Uint8List bytes,
    });

class OpenEncryptedExportScreen extends StatefulWidget {
  const OpenEncryptedExportScreen({
    super.key,
    this._envelope,
    this._picker,
    this._saver,
  });

  /// All three are injectable only so a widget test can run without the system
  /// dialogs and without real Argon2id, which takes seconds per call.
  /// Production passes none of them.
  final VaultEnvelope? _envelope;
  final SealedFilePicker? _picker;
  final SealedFileSaver? _saver;

  @override
  State<OpenEncryptedExportScreen> createState() =>
      _OpenEncryptedExportScreenState();
}

class _OpenEncryptedExportScreenState extends State<OpenEncryptedExportScreen> {
  final TextEditingController _passwordController = TextEditingController();

  late final VaultEnvelope _envelope = widget._envelope ?? VaultEnvelope();
  late final SealedFilePicker _picker = widget._picker ?? _pickWithSystem;
  late final SealedFileSaver _saver = widget._saver ?? _saveWithSystem;

  /// The chosen file, held in memory. Nothing is written until the password
  /// has opened it.
  PickedSealedFile? _chosen;

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.openEncryptedTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(l10n.openEncryptedIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            key: const Key('open-encrypted-pick-file'),
            onPressed: _busy ? null : _pickFile,
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.openEncryptedPickFile),
          ),
          if (_chosen != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.openEncryptedChosenFile(_chosen!.fileName),
              style: theme.textTheme.bodySmall,
            ),
          ],

          const Divider(height: 32),

          TextField(
            key: const Key('open-encrypted-password-field'),
            controller: _passwordController,
            obscureText: true,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.openEncryptedPasswordLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            key: const Key('open-encrypted-run'),
            onPressed: _busy || _chosen == null ? null : _openAndSave,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open),
            label: Text(
              _busy ? l10n.openEncryptedWorking : l10n.openEncryptedAction,
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 20),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _error!,
                  key: const Key('open-encrypted-error'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final picked = await _picker();
    if (picked == null || !mounted) return;

    setState(() {
      _chosen = picked;
      _error = null;
    });
  }

  Future<void> _openAndSave() async {
    final chosen = _chosen;
    if (chosen == null) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      // Checked before the password is used, so "you picked the wrong file"
      // and "you typed the wrong password" stay two different answers.
      if (!VaultEnvelope.isSealed(chosen.bytes)) {
        setState(() => _error = l10n.openEncryptedErrorNotSealed);
        return;
      }

      final plain = await _envelope.open(
        sealedBytes: chosen.bytes,
        password: _passwordController.text,
      );
      final payload = unwrapVaultPayload(plain);

      // A payload with no header was sealed before headers existed. Fall back
      // to the outer name with the `.jvenc` taken off.
      final suggestedName =
          payload.header?.fileName ?? _strippedName(chosen.fileName);

      final savedPath = await _saver(
        dialogTitle: l10n.openEncryptedSaveDialogTitle,
        fileName: suggestedName,
        bytes: payload.bytes,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null
                ? l10n.openEncryptedCancelled
                : l10n.openEncryptedSaved,
          ),
        ),
      );
    } on VaultVersionTooNewException {
      setState(() => _error = l10n.openEncryptedErrorTooNew);
    } on VaultCorruptedException {
      // A wrong password and a damaged file are the same event to AES-GCM, so
      // they get the same sentence.
      setState(() => _error = l10n.openEncryptedErrorWrongPassword);
    } catch (error) {
      // Never the file name and never the bytes — only that it failed.
      AppLogger.error(
        'open encrypted export: failed',
        error: AppLogger.redact(error),
      );
      setState(() => _error = l10n.openEncryptedErrorFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// `journal_export_2026-08-18.jvenc` becomes `journal_export_2026-08-18`.
  String _strippedName(String name) {
    final base = name.isEmpty ? 'export' : name;
    return base.endsWith('.$vaultSealedFileExtension')
        ? base.substring(0, base.length - vaultSealedFileExtension.length - 1)
        : base;
  }

  Future<PickedSealedFile?> _pickWithSystem() async {
    // `withData` is on: the file is opened in memory and never staged on disk
    // in the clear.
    final result = await FilePicker.pickFiles(withData: true);
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    return PickedSealedFile(fileName: file.name, bytes: bytes);
  }

  Future<String?> _saveWithSystem({
    required String dialogTitle,
    required String fileName,
    required Uint8List bytes,
  }) {
    return FilePicker.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: bytes,
    );
  }
}
