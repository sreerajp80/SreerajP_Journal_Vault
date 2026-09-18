// Test doubles shared by the tests next to this file.

import 'dart:async';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/app_permissions_service.dart';

class FakeBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.success;
}

class InMemoryPinKeystore implements AppPinKeystore {
  AppPinCredentialPayload? _stored;

  @override
  Future<AppPinCredentialPayload?> getCredential() async => _stored;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    _stored = AppPinCredentialPayload(
      saltBase64: saltBase64,
      verifierBase64: verifierBase64,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    _stored = null;
  }
}

class FakePermissionsService implements AppPermissionsService {
  bool openSettingsCalled = false;

  @override
  Future<AppPermissionItem> getPermission(AppPermissionId id) async =>
      _itemFor(id);

  @override
  Future<PermissionsSnapshot> getSnapshot() async {
    return PermissionsSnapshot(
      explicitPermissions: [_itemFor(AppPermissionId.attachmentImport)],
      implicitPermissions: [_itemFor(AppPermissionId.documentPicker)],
    );
  }

  @override
  Future<AppPermissionState> requestPermission(AppPermissionId id) async =>
      AppPermissionState.granted;

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionId id) async => false;

  @override
  Future<bool> openSystemSettings() async {
    openSettingsCalled = true;
    return true;
  }

  AppPermissionItem _itemFor(AppPermissionId id) {
    return AppPermissionItem(
      id: id,
      category: id == AppPermissionId.attachmentImport
          ? AppPermissionCategory.explicit
          : AppPermissionCategory.implicit,
      status: AppPermissionState.granted,
    );
  }
}

/// Records calls to `migrateStoredFile` and lets the test gate the loop so
/// the migration dialog stays visible while we assert against it. Cancel
/// causes the next call to throw via the `isCancelled` flag.
class SlowCryptoStorage implements AttachmentCryptoStorage {
  bool holdMigration = false;
  final List<Completer<void>> _pendingHolds = [];

  void releaseAll() {
    for (final c in _pendingHolds) {
      if (!c.isCompleted) c.complete();
    }
    _pendingHolds.clear();
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {
    if (holdMigration) {
      final c = Completer<void>();
      _pendingHolds.add(c);
      await c.future;
    }
    return 'app_private/$fileName.enc';
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return false;
  }

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) {
    throw UnimplementedError();
  }
}
