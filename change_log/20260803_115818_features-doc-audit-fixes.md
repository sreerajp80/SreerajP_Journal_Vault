# Change log: fix small gaps in docs/features.md

Implements plan `plans/20260803_115818_features-doc-audit-fixes.md`.

## What changed

Ran a codebase audit of `docs/features.md` against `lib/`. The App Description
paragraph and overall section structure were already accurate and complete — no
structural gaps, no stale references to deleted files. Found and fixed five small
citation gaps where the doc described a feature but didn't name the file/class that
implements it:

- **Section 1** (Security): added `attachment_key_manager.dart` / `AttachmentKeyManager`
  next to the existing `attachment_crypto_storage.dart` citation in the
  hardware-backed attachment encryption bullet.
- **Section 3** (Media Attachments):
  - Added `attachment_open_router.dart` / `AttachmentOpenRouter` as the class that
    decides in-app-viewer vs. external-app-chooser routing.
  - Added `attachment_picker_service.dart` / `AttachmentPickerService` (interface)
    alongside the existing `file_picker_attachment_picker_service.dart` (impl).
  - Added `attachment_open_service.dart` (`AttachmentImportService`,
    `AttachmentOpenService`) to the Entry Attachment Tray bullet.
- **Section 6** (Import/Export/Backup): noted the shared `import_adapter.dart` base
  interface that the three concrete import adapters implement.
- **Section 8** (App Architecture): added `app_permissions_service.dart` /
  `AppPermissionsService` (interface) alongside the existing
  `permission_handler_app_permissions_service.dart` (impl) in the Permissions
  Management Center bullet.

No prose was rewritten, no bullets were restructured, and the App Description
paragraph was left unchanged — it already covered every feature area.

## File changed

- `docs/features.md`
