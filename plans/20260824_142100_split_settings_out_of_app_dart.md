# Plan: Split Settings UI out of app.dart into lib/features/settings/

**Status:** Completed
**Date:** 2026-08-24
**Topic:** Enhancement A6.8 — Split up app.dart

---

## 1. Issue & Motivation

`lib/app/app.dart` has grown to over 3,700 lines. It currently combines:
- App entry and root providers
- App lock state and lock gate UI
- Home tab and journal detail views
- Search tab and search preset dialogs
- Settings tab and multiple full settings sub-screens (Security, Storage, Permissions, Locked Attachments, Migration progress, Pin setup dialog, and Screen security toggle)

Having all settings screens inside `lib/app/app.dart` violates Tier 2 feature-first architecture (`lib/features/settings/`), creates high merge risk for any feature touching settings, and inflates the root shell file unnecessarily.

---

## 2. Proposed Changes

### A. New Utilities & Shared Providers
- **`lib/core/utils/date_formatters.dart`**: Extract `formatShortDate(DateTime d)` helper for standardized `YYYY-MM-DD` string formatting.
- **`lib/features/journal_lock/providers/journal_lock_providers.dart`**: Move `unlockedJournalIdsProvider` and `UnlockedJournalIdsNotifier` out of `lib/app/app.dart` into the `journal_lock` feature providers layer.

### B. New Settings Feature Screens (`lib/features/settings/presentation/`)
- **`settings_tab.dart`**: Contains `SettingsTab` and `SettingsSectionCard`. Represents the main settings landing page linking to sections (Security, Appearance, Time Capsules, Ritual, Storage, Features, Permissions, Help, About).
- **`security_settings_screen.dart`**: Contains `SecuritySettingsScreen`, `ScreenSecurityTile`, and `PinSetupDialog`.
- **`locked_attachments_screen.dart`**: Contains `LockedAttachmentsScreen` for managing attachment-level encryption locks.
- **`storage_settings_screen.dart`**: Contains `StorageSettingsScreen`, `StorageSection`, `MigrationProgressController`, and `MigrationProgressDialog`.
- **`permissions_settings_screen.dart`**: Contains `PermissionsSettingsScreen` and `PermissionsSection`.

### C. Refactor `lib/app/app.dart`
- Remove all settings-related widgets and classes (`_SettingsTab`, `_SettingsSectionCard`, `_SecuritySettingsScreen`, `_StorageSettingsScreen`, `_PermissionsSettingsScreen`, `_ScreenSecurityTile`, `_PinSetupDialog`, `_StorageSection`, `_MigrationProgressController`, `_MigrationProgressDialog`, `_PermissionsSection`, `_LockedAttachmentsScreen`).
- Replace with clean imports from `package:sreerajp_journal_vault/features/settings/presentation/settings_tab.dart` and `package:sreerajp_journal_vault/features/journal_lock/providers/journal_lock_providers.dart`.
- Update internal references to `_unlockedJournalIdsProvider` and `_fmtDate` to use `unlockedJournalIdsProvider` and `formatShortDate`.

### D. Documentation Updates
- Update `docs/enhancement_ideas.md` to mark **A6.8 Split up `app.dart`** as implemented (`[COMPLETED]`), referencing this plan and change log.

---

## 3. Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis warnings/errors.
- Run `flutter test` across all unit and widget tests (including `test/app/settings_screen_security_test.dart` and `test/widget_test.dart`) to ensure no regressions.
