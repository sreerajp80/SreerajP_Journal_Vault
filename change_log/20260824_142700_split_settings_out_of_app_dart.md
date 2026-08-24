# Change Log: Split Settings UI out of app.dart

**Date:** 2026-08-24
**Plan:** `plans/20260824_142100_split_settings_out_of_app_dart.md`
**Topic:** Enhancement A6.8 — Split up app.dart

---

## 1. Summary of Changes

The Settings UI, its sub-screens, sections, and dialogs were extracted from `lib/app/app.dart` into a dedicated feature module `lib/features/settings/presentation/`. Shared providers and utilities were also organized into their appropriate feature and core layers.

### Created Files
- `lib/core/utils/date_formatters.dart`: Standardized `formatShortDate(DateTime d)` (`YYYY-MM-DD`).
- `lib/features/journal_lock/providers/journal_lock_providers.dart`: Shared `unlockedJournalIdsProvider` and `UnlockedJournalIdsNotifier`.
- `lib/features/settings/presentation/settings_tab.dart`: `SettingsTab` and `SettingsSectionCard`.
- `lib/features/settings/presentation/security_settings_screen.dart`: `SecuritySettingsScreen`, `ScreenSecurityTile`, and `PinSetupDialog`.
- `lib/features/settings/presentation/locked_attachments_screen.dart`: `LockedAttachmentsScreen` for managing attachment-level encryption locks.
- `lib/features/settings/presentation/storage_settings_screen.dart`: `StorageSettingsScreen`, `StorageSection`, `MigrationProgressController`, and `MigrationProgressDialog`.
- `lib/features/settings/presentation/permissions_settings_screen.dart`: `PermissionsSettingsScreen` and `PermissionsSection`.

### Updated Files
- `lib/features/lock_gate/providers/lock_gate_providers.dart`: Added `AppLockState`, `AppLockNotifier`, and `appLockProvider`.
- `lib/app/app.dart`: Removed over 1,400 lines of settings UI and state implementations. Added clean imports to `SettingsTab`, `unlockedJournalIdsProvider`, and `formatShortDate`.
- `docs/enhancement_ideas.md`: Marked item A6.8 as implemented.

---

## 2. Verification & Testing

- `flutter analyze`: Completed with 0 issues.
- `flutter test`: All 758 unit and widget tests passed with zero regressions.
