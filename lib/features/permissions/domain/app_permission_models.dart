enum AppPermissionId { attachmentImport, documentPicker }

enum AppPermissionCategory { explicit, implicit }

enum AppPermissionState { granted, denied, permanentlyDenied, userSelected }

/// One permission the app uses, as a value with no words in it.
///
/// The name and the explanation come from `AppPermissionText` in the
/// presentation layer, keyed by [id], so this service-level model stays free
/// of user-visible text.
class AppPermissionItem {
  const AppPermissionItem({
    required this.id,
    required this.category,
    required this.status,
    this.isGrantedViaFilePicker = false,
    this.canRequestAgain = false,
    this.canOpenSystemSettings = false,
  });

  final AppPermissionId id;
  final AppPermissionCategory category;
  final AppPermissionState status;

  /// True on Android 13 and later, where the system file picker covers this
  /// permission and no separate grant is needed. The screen adds a note.
  final bool isGrantedViaFilePicker;

  final bool canRequestAgain;
  final bool canOpenSystemSettings;
}

class PermissionsSnapshot {
  const PermissionsSnapshot({
    required this.explicitPermissions,
    required this.implicitPermissions,
  });

  final List<AppPermissionItem> explicitPermissions;
  final List<AppPermissionItem> implicitPermissions;

  AppPermissionItem permissionFor(AppPermissionId id) {
    return [
      ...explicitPermissions,
      ...implicitPermissions,
    ].firstWhere((p) => p.id == id);
  }
}
