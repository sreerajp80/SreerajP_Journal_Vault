import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';

abstract class AppPermissionsService {
  Future<AppPermissionItem> getPermission(AppPermissionId id);
  Future<PermissionsSnapshot> getSnapshot();
  Future<AppPermissionState> requestPermission(AppPermissionId id);
  Future<bool> shouldShowRequestRationale(AppPermissionId id);
  Future<bool> openSystemSettings();
}
