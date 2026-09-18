import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Names and explains a permission in the user's language.
extension AppPermissionText on AppPermissionItem {
  String titleIn(AppLocalizations l10n) {
    switch (id) {
      case AppPermissionId.attachmentImport:
        return l10n.titlePermissionAttachmentImport;
      case AppPermissionId.documentPicker:
        return l10n.titlePermissionDocumentPicker;
    }
  }

  String descriptionIn(AppLocalizations l10n) {
    switch (id) {
      case AppPermissionId.attachmentImport:
        return l10n.descPermissionAttachmentImport;
      case AppPermissionId.documentPicker:
        return l10n.descPermissionDocumentPicker;
    }
  }

  /// The extra note shown when the system file picker already covers this
  /// permission, or null when there is nothing to add.
  String? detailIn(AppLocalizations l10n) =>
      isGrantedViaFilePicker ? l10n.descPermissionSafGranted : null;
}
