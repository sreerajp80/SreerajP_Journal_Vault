# Change Log: Time Capsules and Cryptographically Sealed Entries (C3)

**Date:** 2026-08-24  
**Status:** Complete  
**Reference Plan:** [plans/20260824_131500_time_capsules_sealed_entries.md](plans/20260824_131500_time_capsules_sealed_entries.md)

---

## 1. Overview

Implemented feature **C3: Time Capsules and Letters to Your Future Self**. This allows users to write journal entries and seal them until a chosen future unlock date (1 month, 6 months, 1 year, 3 years, 5 years, or a custom date). 

While sealed:
- The entry body (`contentJson` and `plainText`) is wiped from cleartext database storage and stored as an AES-256-GCM encrypted payload with an ephemeral key.
- The app refuses to release the decryption key until the unlock date arrives.
- The entry is excluded from FTS search queries.
- Clock rollback tampering is detected and rejected via monotonic high-water mark tracking.
- When the unlock date arrives, a notification is posted and the user can unseal and read the entry.

---

## 2. Changes Made

### A. Database Schema & Migration (v10)
- [lib/core/database/app_database.dart](lib/core/database/app_database.dart):
  - Added `TimeCapsules` table (`id`, `entryId`, `unlockDate`, `sealedAt`, `isOpened`, `openedAt`, `sealedCiphertext`, `ivBase64`, `macBase64`, `sealedKeyCiphertext`, `teaserMessage`, `createdAt`).
  - Added `TimeCapsulesDao` with queries to create, watch, list, unseal, and delete capsules.
  - Bumped `schemaVersion` from 9 to 10 with migration step `await m.createTable(timeCapsules);`.
  - Updated `searchEntries()` SQL query to filter out unopened sealed entries.
- Regenerated Drift database code in [lib/core/database/app_database.g.dart](lib/core/database/app_database.g.dart).

### B. Core Services and Cryptography
- [lib/features/entries/services/time_capsule_service.dart](lib/features/entries/services/time_capsule_service.dart):
  - Encrypts entry payload with AES-256-GCM on sealing and wipes plaintext from `entries` table.
  - Rejects early unsealing attempts (`TimeCapsuleLockedException`).
  - Enforces monotonic clock integrity checks against `SharedPreferences` high-water mark (`TimeCapsuleClockTamperException`).
  - Unseals and restores plaintext upon reaching unlock date.
- [lib/features/entries/services/platform_notification_service.dart](lib/features/entries/services/platform_notification_service.dart):
  - Bridges local notifications on capsule unlock dates.
- [lib/features/entries/providers/time_capsule_providers.dart](lib/features/entries/providers/time_capsule_providers.dart):
  - Riverpod stream and future providers for active, ready, and per-entry time capsules.

### C. Presentation & User Experience
- [lib/features/entries/presentation/time_capsule_seal_dialog.dart](lib/features/entries/presentation/time_capsule_seal_dialog.dart):
  - Dialog with presets (1m, 6m, 1y, 3y, 5y, custom date), optional teaser note, and confirmation.
- [lib/features/entries/presentation/time_capsule_sealed_screen.dart](lib/features/entries/presentation/time_capsule_sealed_screen.dart):
  - Live countdown clock (Days, Hours, Mins, Secs), teaser card, timestamp details, security assurance note, and unseal action button.
- [lib/features/entries/presentation/time_capsules_list_screen.dart](lib/features/entries/presentation/time_capsules_list_screen.dart):
  - Categorized list showing Ready to Open, Sealed, and Opened time capsules.
- [lib/features/entries/presentation/entry_editor_screen.dart](lib/features/entries/presentation/entry_editor_screen.dart):
  - Added "Seal as Time Capsule" AppBar action.
- [lib/app/app.dart](lib/app/app.dart):
  - Added ready capsule celebration banner on Home tab.
  - Added Time Capsules entry point in Home AppBar and Settings tab.
  - Rendered sealed indicator on journal entry tiles with routing to sealed countdown screen.
- [lib/features/timeline/presentation/timeline_screen.dart](lib/features/timeline/presentation/timeline_screen.dart):
  - Rendered time capsule status and routing on timeline entry items.

### D. Backup and Restore Integration
- [lib/features/backup/services/backup_service.dart](lib/features/backup/services/backup_service.dart):
  - Added `timeCapsules` table to JSON export.
- [lib/features/backup/services/backup_restore_service.dart](lib/features/backup/services/backup_restore_service.dart):
  - Added `timeCapsules` mapping, row insertion, and foreign key cascade clearing on restore.

### E. Android Platform Integration
- [android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt](android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt):
  - Added `sreerajp.journal_vault/notifications` MethodChannel handler for local notifications.

### F. Localization & Tests
- [lib/l10n/app_en.arb](lib/l10n/app_en.arb):
  - Added localized strings for time capsules.
- [test/core/database/migration_test.dart](test/core/database/migration_test.dart):
  - Updated to verify schema version 10 and `time_capsules` table migration.
- [test/features/entries/time_capsule_service_test.dart](test/features/entries/time_capsule_service_test.dart):
  - Unit tests for encryption, cleartext wiping, early unlock refusal, clock rollback detection, search exclusion, and unsealing.
- [test/features/entries/time_capsule_widget_test.dart](test/features/entries/time_capsule_widget_test.dart):
  - Widget tests for seal dialog, countdown screen, and capsules list screen.

---

## 3. Verification

- Ran static analysis: `flutter analyze` -> 0 issues found.
- Ran full test suite: `flutter test` -> 758 tests passed (100% pass rate).
- Formatted all code: `dart format lib test`.
