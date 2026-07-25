import 'package:cryptography/cryptography.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_router.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_temp_file_manager.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/file_picker_attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/platform_attachment_key_manager.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/method_channel_journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/permission_handler_app_permissions_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logging first, so every step below can report failures.
  AppLogger.init();
  AppLogger.info('App starting');

  final database = AppDatabase.forExecutor(
    driftDatabase(name: 'journal_vault'),
  );

  final keyManager = PlatformAttachmentKeyManager();
  final tempFileManager = AttachmentTempFileManager(
    cacheDirectoryProvider: getTemporaryDirectory,
  );
  final cryptoStorage = AesGcmAttachmentCryptoStorage(
    algorithm: AesGcm.with256bits(),
    keyManager: keyManager,
    tempFileManager: tempFileManager,
    documentsDirectoryProvider: getApplicationDocumentsDirectory,
  );

  runApp(
    JournalVaultAppHost(
      database: database,
      overrides: [
        attachmentCryptoStorageProvider.overrideWithValue(cryptoStorage),
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
