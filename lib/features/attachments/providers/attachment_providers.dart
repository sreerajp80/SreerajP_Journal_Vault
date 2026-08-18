import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_migration_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_picker.dart';

final attachmentCryptoStorageProvider = Provider<AttachmentCryptoStorage>((
  ref,
) {
  throw UnimplementedError(
    'attachmentCryptoStorageProvider must be overridden before use.',
  );
});

final attachmentPickerServiceProvider = Provider<AttachmentPickerService>((
  ref,
) {
  throw UnimplementedError(
    'attachmentPickerServiceProvider must be overridden before use.',
  );
});

/// Encrypts a picked file and writes its `Attachments` row.
final attachmentImportServiceProvider = Provider<AttachmentImportService>((
  ref,
) {
  return AttachmentImportService(ref.watch(attachmentCryptoStorageProvider));
});

final attachmentOpenServiceProvider = Provider<AttachmentOpenService>((ref) {
  throw UnimplementedError(
    'attachmentOpenServiceProvider must be overridden before use.',
  );
});

/// Migrates attachment files between app-private and SD card.
final attachmentStorageMigrationServiceProvider =
    Provider<AttachmentStorageMigrationService>((ref) {
      return AttachmentStorageMigrationService(
        database: ref.watch(appDatabaseProvider),
        storage: ref.watch(attachmentCryptoStorageProvider),
      );
    });

/// Launches the platform tree picker so the user can select an SD card folder.
final attachmentStoragePickerProvider = Provider<AttachmentStoragePicker>((
  ref,
) {
  return MethodChannelAttachmentStoragePicker();
});
