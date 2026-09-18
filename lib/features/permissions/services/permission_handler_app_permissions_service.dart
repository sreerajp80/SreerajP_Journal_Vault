import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/app_permissions_service.dart';

/// Platform implementation of [AppPermissionsService] backed by
/// the `permission_handler` package.
class PermissionHandlerAppPermissionsService implements AppPermissionsService {
  PermissionHandlerAppPermissionsService({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _deviceInfo;
  int? _cachedAndroidSdkInt;

  @override
  Future<AppPermissionItem> getPermission(AppPermissionId id) async {
    switch (id) {
      case AppPermissionId.attachmentImport:
        if (await _isAndroidSafOnly()) {
          return _safAttachmentImportItem;
        }
        return _buildAttachmentImportItem(await _storagePermission.status);
      case AppPermissionId.documentPicker:
        return _documentPickerItem;
    }
  }

  @override
  Future<PermissionsSnapshot> getSnapshot() async {
    final attachmentImport = await getPermission(
      AppPermissionId.attachmentImport,
    );
    return PermissionsSnapshot(
      explicitPermissions: [attachmentImport],
      implicitPermissions: [_documentPickerItem],
    );
  }

  @override
  Future<AppPermissionState> requestPermission(AppPermissionId id) async {
    if (id == AppPermissionId.documentPicker) {
      return AppPermissionState.userSelected;
    }
    if (await _isAndroidSafOnly()) {
      return AppPermissionState.granted;
    }
    final status = await _storagePermission.request();
    return _toAppPermissionState(status);
  }

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionId id) async {
    if (id == AppPermissionId.documentPicker) return false;
    if (await _isAndroidSafOnly()) return false;
    return _storagePermission.shouldShowRequestRationale;
  }

  @override
  Future<bool> openSystemSettings() => openAppSettings();

  // ── helpers ───────────────────────────────────────────────────────────────

  Permission get _storagePermission => Permission.storage;

  /// True on Android 13+ (API 33+), where attachment import goes through the
  /// Storage Access Framework via the system file picker and no runtime
  /// storage permission is needed (or even declarable —
  /// `READ_EXTERNAL_STORAGE` is capped at `maxSdkVersion="32"` in the
  /// manifest).
  Future<bool> _isAndroidSafOnly() async {
    if (!Platform.isAndroid) return false;
    final cached = _cachedAndroidSdkInt;
    if (cached != null) return cached >= 33;
    final info = await _deviceInfo.androidInfo;
    _cachedAndroidSdkInt = info.version.sdkInt;
    return _cachedAndroidSdkInt! >= 33;
  }

  AppPermissionItem _buildAttachmentImportItem(PermissionStatus status) {
    final state = _toAppPermissionState(status);
    return AppPermissionItem(
      id: AppPermissionId.attachmentImport,
      category: AppPermissionCategory.explicit,
      status: state,
      canRequestAgain: state == AppPermissionState.denied,
      canOpenSystemSettings:
          state == AppPermissionState.denied ||
          state == AppPermissionState.permanentlyDenied,
    );
  }

  static const AppPermissionItem _safAttachmentImportItem = AppPermissionItem(
    id: AppPermissionId.attachmentImport,
    category: AppPermissionCategory.explicit,
    status: AppPermissionState.granted,
    isGrantedViaFilePicker: true,
  );

  static const AppPermissionItem _documentPickerItem = AppPermissionItem(
    id: AppPermissionId.documentPicker,
    category: AppPermissionCategory.implicit,
    status: AppPermissionState.userSelected,
  );

  static AppPermissionState _toAppPermissionState(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited ||
      PermissionStatus.provisional => AppPermissionState.granted,
      PermissionStatus.permanentlyDenied =>
        AppPermissionState.permanentlyDenied,
      _ => AppPermissionState.denied,
    };
  }
}
