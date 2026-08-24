# Plan: C3 — Time Capsules and Letters to Your Future Self

**Status:** Proposed
**Date:** 2026-08-24
**Feature:** C3 Time Capsules (Cryptographically Sealed Entries)

---

## 1. Overview and Problem Statement

A user writes an entry today intended for their future self (e.g. 6 months, 1 year, 5 years, or on a special milestone date).
Unlike novelty "email your future self" web services, this app provides a **true cryptographic seal inside the encrypted local vault**:
- The entry is encrypted under a dedicated AES-256-GCM symmetric key.
- The cleartext content (`plainText` and `contentJson`) is wiped from the `Entries` table.
- The entry is completely excluded from full-text search (FTS5).
- The app's date-gated key release engine **strictly refuses** to release or decrypt the key until `DateTime.now() >= unlockDate`.
- Clock rollback tampering is detected and blocked via a persisted monotonic high-water mark timestamp.
- Cross-device backup and restore preserves the sealed capsule safely: restoring to a new phone does not leak the entry early, nor does it lose the entry forever.
- On the unlock date, the user receives a notification (system notification and in-app celebration banner) and can unseal the entry, restoring it to full readability and editing.

---

## 2. Proposed Changes

### Core & Database Layer
- **`lib/core/database/app_database.dart`**:
  - Increment `schemaVersion` from `9` to `10`.
  - Add `TimeCapsules` table:
    - `id` (int autoIncrement)
    - `entryId` (int, references `Entries.id`, cascade delete, unique)
    - `unlockDate` (DateTime)
    - `sealedAt` (DateTime)
    - `isOpened` (bool, default false)
    - `openedAt` (DateTime, nullable)
    - `sealedCiphertext` (text, AES-256-GCM encrypted content)
    - `ivBase64` (text)
    - `macBase64` (text)
    - `sealedKeyCiphertext` (text, nullable, wrapped key material)
    - `teaserMessage` (text, nullable, optional letter hint/note)
    - `createdAt` (DateTime)
  - Add `TimeCapsulesDao` with CRUD, unseal, query, and lookup methods.
  - Add migration in `onUpgrade` for `from < 10`: `m.createTable(timeCapsules)`.
  - Update `searchEntries` to filter out entries that have an unopened `TimeCapsule` where `unlockDate > now`.

### Service & Crypto Layer
- **`lib/features/entries/services/time_capsule_service.dart`** (New):
  - Encrypts entry content with AES-256-GCM when sealing.
  - Enforces date-gated key release: throws `TimeCapsuleLockedException` if requested before `unlockDate`.
  - Enforces clock tampering protection: verifies current device time against persisted high-water mark; throws `ClockRollbackTamperException` if clock was turned backwards.
  - Updates entry record by clearing plain text / content json on seal, and restoring them on unseal.
- **`lib/features/entries/services/platform_notification_service.dart`** (New):
  - Manages local notifications for unlocked time capsules via Android `MethodChannel` and in-app alerts.
- **`lib/features/entries/providers/time_capsule_providers.dart`** (New):
  - Riverpod providers for `timeCapsuleServiceProvider`, watch queries for sealed capsules, ready-to-open capsules, and notification checks.

### Presentation & UI Layer
- **`lib/features/entries/presentation/time_capsule_seal_dialog.dart`** (New):
  - Dialog in editor to configure unlock date (presets: 1 month, 6 months, 1 year, 3 years, 5 years, or custom date/time picker), optional teaser note, and seal confirmation.
- **`lib/features/entries/presentation/time_capsule_sealed_screen.dart`** (New):
  - Visual time capsule viewer with hourglass/lock graphics, live countdown timer, unlock date, teaser note, and "Unseal Capsule" button (active when date is reached).
- **`lib/features/entries/presentation/time_capsules_list_screen.dart`** (New):
  - Overview screen listing all active and opened time capsules with countdowns, status, and direct access.
- **`lib/features/entries/presentation/entry_editor_screen.dart`**:
  - Add "Seal as Time Capsule" option in AppBar popup menu.
  - Wire sealing flow to `TimeCapsuleSealDialog` and `TimeCapsuleService`.
- **`lib/app/app.dart`**:
  - Update `_JournalEntriesScreen` to display time capsule badges / countdown on sealed entries, and route to `TimeCapsuleSealedScreen` on tap.
  - Add ready-to-open celebration banner on Home tab if any time capsule has reached its unlock date.
  - Add Time Capsules entry point in Settings / Features screen.
- **`lib/features/timeline/presentation/timeline_screen.dart`**:
  - Show time capsule status indicators in timeline entries.

### Backup & Restore
- **`lib/features/backup/services/backup_service.dart`**:
  - Export `timeCapsules` in backup archive manifest and data JSON.
- **`lib/features/backup/services/backup_restore_service.dart`**:
  - Restore `timeCapsules` table records during backup restore.

### Android Native Layer
- **`android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`**:
  - Add `sreerajp.journal_vault/notifications` channel for displaying local notifications when capsules unlock.

### Localization
- **`lib/l10n/app_en.arb`**:
  - Add all localized user-facing strings and descriptions.

---

## 3. Verification Plan

### Automated Tests
1. `test/features/entries/time_capsule_service_test.dart`:
   - Test sealing an entry: ensures body text is removed from `Entries` and stored in `TimeCapsules` ciphertext.
   - Test date-gating: attempting to unseal before `unlockDate` throws `TimeCapsuleLockedException`.
   - Test clock tampering detection: advancing then rewinding time triggers rollback rejection.
   - Test unsealing on or after `unlockDate`: restores entry title, plainText, and delta json perfectly.
   - Test search exclusion: sealed entry body and text are not matched by `searchEntries`.
2. `test/features/entries/time_capsule_widget_test.dart`:
   - Test sealing flow via `TimeCapsuleSealDialog`.
   - Test `TimeCapsuleSealedScreen` displays countdown and disables unseal before date.
   - Test unsealing flow displays celebratory unseal UI when date is reached.
3. `test/features/backup/backup_time_capsule_test.dart`:
   - Test backup and restore round trip preserves sealed time capsules and date-gating across devices.
4. Static Analysis & formatting:
   - `flutter analyze`
   - `flutter test`
   - `dart format lib test`
