enum AppPermissionId {
  attachmentImport,
  documentPicker,
}

enum AppPermissionCategory {
  explicit,
  implicit,
}

enum AppPermissionState {
  granted,
  denied,
  permanentlyDenied,
  userSelected,
}

class AppPermissionItem {
  const AppPermissionItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    this.statusDetail,
    this.canRequestAgain = false,
    this.canOpenSystemSettings = false,
  });

  final AppPermissionId id;
  final AppPermissionCategory category;
  final String title;
  final String description;
  final AppPermissionState status;
  final String? statusDetail;
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
    return [...explicitPermissions, ...implicitPermissions]
        .firstWhere((p) => p.id == id);
  }
}
