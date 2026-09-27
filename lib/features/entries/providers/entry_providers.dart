import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/inline_image_store.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_deletion_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_editor_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_revision_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/user_template_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_saver.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Provides the [EntryRevisionService] for managing version history.
final entryRevisionServiceProvider = Provider<EntryRevisionService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return EntryRevisionService(db);
});

/// Loads, creates and saves entries for the editor.
///
/// The attachment import service is read only when an attachment is added,
/// as before this provider existed.
final entryEditorServiceProvider = Provider<EntryEditorService>((ref) {
  return EntryEditorService(
    db: ref.watch(appDatabaseProvider),
    importService: () => ref.read(attachmentImportServiceProvider),
    revisionService: ref.watch(entryRevisionServiceProvider),
  );
});

/// Creates, changes and deletes the user's own entry templates.
final userTemplateServiceProvider = Provider<UserTemplateService>((ref) {
  return UserTemplateService(ref.watch(appDatabaseProvider));
});

/// Watches all revisions for a specific entry.
final entryRevisionsProvider = StreamProvider.family<List<EntryRevision>, int>((
  ref,
  entryId,
) {
  final service = ref.read(entryRevisionServiceProvider);
  return service.watchRevisions(entryId);
});

/// Deletes entries, journals and attachments together with their files.
///
/// The crypto storage is read only when there is a file to delete, so a screen
/// that deletes an entry without attachments never needs it.
final entryDeletionServiceProvider = Provider<EntryDeletionService>((ref) {
  return EntryDeletionService(
    db: ref.watch(appDatabaseProvider),
    deleteStoredFile: (path) =>
        ref.read(attachmentCryptoStorageProvider).deleteStoredFile(path),
  );
});

/// Saves a finished recording as an encrypted attachment.
final voiceNoteSaverProvider = Provider<VoiceNoteSaver>((ref) {
  return VoiceNoteSaver(
    importService: ref.watch(attachmentImportServiceProvider),
    db: ref.watch(appDatabaseProvider),
  );
});

/// Provides a single [VoiceNoteService] instance.
final voiceNoteServiceProvider = Provider<VoiceNoteService>((ref) {
  final service = VoiceNoteService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Builds the per-screen store that decrypts inline images for the editor.
///
/// Not a provider: the store owns decrypted temp files and must be disposed
/// with the screen that made it, not kept alive by the container. Every
/// dependency is read inside a callback rather than up front, so a screen that
/// holds no images never touches the crypto storage provider at all.
InlineImageStore buildInlineImageStore(WidgetRef ref) {
  return InlineImageStore(
    loadSource: (attachmentId) async {
      final row = await ref
          .read(appDatabaseProvider)
          .attachmentsDao
          .getAttachmentById(attachmentId);
      return InlineImageSource(
        fileName: row.fileName,
        encryptedPath: row.encryptedPath,
        nonceBase64: row.nonceBase64,
        keyReference: row.keyReference,
      );
    },
    isLocked: (attachmentId) =>
        ref.read(attachmentLockServiceProvider).isLocked(attachmentId),
    decrypt: (source) => ref
        .read(attachmentCryptoStorageProvider)
        .decryptToTempFile(
          encryptedPath: source.encryptedPath,
          nonceBase64: source.nonceBase64,
          keyReference: source.keyReference,
          fileName: source.fileName,
        ),
    authenticate: (fileName) async {
      // No BuildContext here, so the language comes from the locale
      // controller rather than Localizations.of.
      final l10n = lookupAppLocalizations(
        effectiveAppLocale(ref.read(localeControllerProvider)),
      );
      final result = await ref
          .read(biometricAuthenticatorProvider)
          .authenticate(reason: l10n.descBiometricReasonFile(fileName));
      return result == BiometricAuthResult.success;
    },
  );
}

/// Watches voice notes for a specific entry.
final entryVoiceNotesProvider = StreamProvider.family<List<VoiceNote>, int>((
  ref,
  entryId,
) {
  final db = ref.read(appDatabaseProvider);
  return db.voiceNotesDao.watchVoiceNotesForEntry(entryId);
});
