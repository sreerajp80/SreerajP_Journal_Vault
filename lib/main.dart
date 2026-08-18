import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/app/vault_unavailable_app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
import 'package:sreerajp_journal_vault/core/database/encrypted_database_opener.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_router.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_picker.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/file_picker_attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/platform_attachment_key_manager.dart';
import 'package:sreerajp_journal_vault/features/backup/providers/backup_providers.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/method_channel_journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/permission_handler_app_permissions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logging first, so every step below can report failures.
  AppLogger.init();
  AppLogger.info('App starting');

  // The vault is encrypted at rest with a key held in the Android Keystore.
  // A journal from an older, unencrypted install is converted on the way in.
  // If it cannot be opened there is nothing safe left to do, so the app says
  // so plainly instead of starting with an empty vault.
  final AppDatabase database;
  try {
    database = await EncryptedDatabaseOpener().open();
  } on DatabaseOpenFailure catch (failure) {
    AppLogger.fatal('Startup stopped: ${failure.kind.name}');
    runApp(VaultUnavailableApp(failure: failure));
    return;
  } catch (error, stackTrace) {
    AppLogger.fatal(
      'Startup stopped: the vault could not be opened',
      error: error,
      stackTrace: stackTrace,
    );
    runApp(
      const VaultUnavailableApp(
        failure: DatabaseOpenFailure(DatabaseOpenFailureKind.openFailed),
      ),
    );
    return;
  }

  final keyManager = PlatformAttachmentKeyManager();
  final tempFileManager = AttachmentTempFileManager(
    cacheDirectoryProvider: getTemporaryDirectory,
  );
  final cryptoStorage = AesGcmAttachmentCryptoStorage(
    algorithm: AesGcm.with256bits(),
    keyManager: keyManager,
    tempFileManager: tempFileManager,
    documentsDirectoryProvider: getApplicationDocumentsDirectory,
    documentClient: MethodChannelAttachmentStorageDocumentClient(),
    // Read on every write rather than captured once, so switching the
    // location in Settings takes effect without an app restart.
    activeTargetProvider: () async {
      final settings = await database.appSettingsDao.getSettings();
      return AttachmentStorageTarget(
        location: AttachmentStorageLocation.fromSettingsValue(
          settings.attachmentStorageLocation,
        ),
        treeUri: settings.attachmentStorageTreeUri,
      );
    },
  );

  runApp(
    JournalVaultAppHost(
      database: database,
      overrides: [
        attachmentCryptoStorageProvider.overrideWithValue(cryptoStorage),
        // Backup decrypts attachments on the way out and encrypts them again
        // for this device on the way back in, so a restored backup opens on a
        // phone that never held the original key.
        backupAttachmentCipherProvider.overrideWithValue(
          AttachmentStorageBackupCipher(
            cryptoStorage,
            documentsDirectoryProvider: getApplicationDocumentsDirectory,
          ),
        ),
        attachmentPickerServiceProvider.overrideWithValue(
          FilePickerAttachmentPickerService(),
        ),
        attachmentOpenServiceProvider.overrideWithValue(
          AttachmentOpenService(
            storage: cryptoStorage,
            router: AttachmentOpenRouter(),
          ),
        ),
        appPermissionsServiceProvider.overrideWithValue(
          PermissionHandlerAppPermissionsService(),
        ),
        journalSecretStoreProvider.overrideWithValue(
          MethodChannelJournalSecretStore(),
        ),
      ],
    ),
  );
}
