# Fix small gaps in docs/features.md found during feature audit

**Status:** completed

## Files to be changed

- `docs/features.md`

## What the issue is

I checked `docs/features.md` against the real code in `lib/`. The good news: the App
Description paragraph at the top already covers every major feature area, and all 16
feature folders map cleanly onto the 8 documented sections. Nothing big is missing.

I did find a handful of small gaps. The doc names the *concrete* class for a few
features, but not the *interface/abstraction* file that actually defines the
contract. In a few cases the doc describes behavior in prose without citing the file
that implements it at all. These are minor, but worth fixing for accuracy:

1. **Attachment open routing is undocumented by file name.** Section 3 says "Only
   PDF, audio, and `.zip` render in a built-in viewer... via the device's external
   app chooser" but never names the file that does this routing:
   `lib/features/attachments/domain/attachment_open_router.dart`
   (`AttachmentOpenRouter`) and `attachment_open_models.dart`. The service that
   opens/imports attachments, `attachment_open_service.dart`
   (`AttachmentImportService`, `AttachmentOpenSession`, `AttachmentOpenService`), is
   also never cited.

2. **Attachment key management interface not named.** Section 1 names the impl
   `platform_attachment_key_manager.dart` but not the abstraction it implements,
   `lib/features/attachments/services/attachment_key_manager.dart`
   (`AttachmentKeyManager`, `AttachmentKeyMaterial`,
   `AttachmentKeyUnavailableException`).

3. **Attachment picker interface not named.** Neither the interface
   `attachment_picker_service.dart` (`AttachmentPickerService`,
   `PickedAttachmentData`) nor its impl `file_picker_attachment_picker_service.dart`
   is mentioned in Section 3, even though file picking is part of the attachment
   flow described there.

4. **Import adapter base interface not named.** Section 6 names the three concrete
   import adapters (Markdown, DOCX, plain text) but not the shared base interface
   `lib/features/import/services/import_adapter.dart` that they implement.

5. **Permissions service interface not named.** Section 8 names the impl
   `permission_handler_app_permissions_service.dart` but not the abstraction
   `lib/features/permissions/services/app_permissions_service.dart`
   (`AppPermissionsService`).

Everything else the audit checked — DAO count, deleted/renamed files
(`home_screen.dart`, `search_screen.dart`, `attachment_storage_location_service.dart`),
provider files, and folder-to-section coverage — already matches the doc. No stale
references were found.

## The plan for the fix

Make small, targeted edits to `docs/features.md`, adding the missing file/class names
in parentheses next to the existing prose, in the same style already used throughout
the doc (e.g. `(file_name.dart, ClassName)`). No new bullet points, no rewrite of
prose, no changes to the App Description paragraph (it doesn't need any).

Specifically:

- **Section 1** (`## 1. Security, Privacy & Data Protection`): in the "Hardware-Backed
  AES-256-GCM Attachment Encryption" bullet, add `attachment_key_manager.dart`
  (`AttachmentKeyManager`) alongside the existing `attachment_crypto_storage.dart`
  citation.

- **Section 3** (`## 3. Media Attachments & Secure Viewers`):
  - In "Wide Media & Document Format Support" / the built-in-viewer bullet, add a
    citation for `attachment_open_router.dart` (`AttachmentOpenRouter`) as the class
    that decides in-app-viewer vs. external-app-chooser.
  - Add `attachment_open_service.dart` (`AttachmentImportService`,
    `AttachmentOpenService`) to the "Entry Attachment Tray" or "Built-in In-App
    Secure Viewers" bullet, wherever it fits best contextually.
  - Add `attachment_picker_service.dart` (`AttachmentPickerService`) and
    `file_picker_attachment_picker_service.dart` to the same section, near the
    existing attachment-handling bullets.

- **Section 6** (`## 6. Document Import, Export & Backup Management`): in "Multi-Format
  Document Import Adapters", add a mention of the shared `import_adapter.dart` base
  interface that the three concrete adapters implement.

- **Section 8** (`## 8. App Architecture, Navigation & User Experience`): in
  "Permissions Management Center", add `app_permissions_service.dart`
  (`AppPermissionsService`) alongside the existing
  `permission_handler_app_permissions_service.dart` citation.

After edits, re-read the file once to confirm formatting/markdown stayed valid.

## Change log

Will be written to `change_log/` after this plan is implemented, listing the exact
lines changed.
