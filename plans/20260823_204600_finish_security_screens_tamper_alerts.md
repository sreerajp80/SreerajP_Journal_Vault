# Plan: Finish Security Screens (Tamper Alerts & Remove Dead Placeholders)

**Status:** completed
**Author:** AI Agent
**Date:** 2026-08-23
**Related Issue / Task:** A5.6 Finish the security screens

---

## 1. Overview and Problem

In Settings, the Security section previously contained a disabled placeholder tile marked "Coming soon" for **Tamper Alerts**. Additionally, when the sync UI flag (`AppFlavorConfig.instance.enableSyncUi`) is disabled, Settings rendered disabled "Coming soon" placeholder tiles for **Sync Conflicts** (under Security) and **Sync Health** (under Storage).

Under the engineering standard's **Rule 6 — "Never a Dead Button"**, components must report their own operational state or offer a valid setup/fallback path, and must not present dead or disabled placeholders.

This task resolves both issues:
1. Builds a dedicated, functional **Tamper Alerts** screen (`TamperAlertsScreen`) and connects it to the Security settings section.
2. Removes dead "Coming soon" placeholder tiles when the sync UI feature flag is disabled, eliminating dead buttons across Settings.

---

## 2. Files to Change

### New Files
- `lib/features/security/presentation/tamper_alerts_screen.dart` — Tamper alerts and vault integrity verification screen.
- `test/features/security/presentation/tamper_alerts_screen_test.dart` — Unit and widget tests for the new tamper alerts screen and integrity verification flow.

### Modified Files
- `lib/core/database/app_database.dart` — Add `watchEventsByType` stream query method to `SecurityEventsDao`.
- `lib/features/security/services/security_event_service.dart` — Add `runVaultIntegrityCheck` and `watchTamperEvents` methods.
- `lib/features/security/providers/security_providers.dart` — Expose `tamperEventsProvider` stream.
- `lib/app/app.dart` — Replace the disabled tamper alerts placeholder with an active `ListTile` opening `TamperAlertsScreen`. Remove dead `_ComingSoonTile` fallbacks for sync rows and remove the obsolete `_ComingSoonTile` widget class.
- `lib/l10n/app_en.arb` — Add user-facing strings for vault integrity status, scan actions, and tamper alert details.
- `test/features/settings/settings_tab_test.dart` — Update tests to verify the active `settings-tamper-alerts` tile and absence of dead placeholder tiles.
- `docs/enhancement_ideas.md` — Mark A5.6 as completed.
- `docs/features.md` — Update feature documentation regarding security settings and tamper alerts.

---

## 3. Detailed Technical Steps

1. **Database & Services**:
   - In `SecurityEventsDao` (`lib/core/database/app_database.dart`), add `Stream<List<SecurityEvent>> watchEventsByType(String eventType, {int limit = 50})`.
   - In `SecurityEventService` (`lib/features/security/services/security_event_service.dart`):
     - Define `VaultIntegrityReport` class (holds `scannedJournals`, `scannedEntries`, `tamperIssues`, `checkedAt`).
     - Add `Future<VaultIntegrityReport> runVaultIntegrityCheck()` that scans all journals and entries, records any tampering detected, and returns the summary report.
     - Add `Stream<List<SecurityEvent>> watchTamperEvents({int limit = 50})`.
   - In `lib/features/security/providers/security_providers.dart`, add `tamperEventsProvider`.

2. **Tamper Alerts Screen**:
   - Create `TamperAlertsScreen` in `lib/features/security/presentation/tamper_alerts_screen.dart`:
     - **Status Banner**: Displays vault integrity status (clean vs detected issues) with visual indicators.
     - **Manual Integrity Scan**: Button to run on-demand vault integrity verification across all journals and entries, updating status reactively.
     - **Architecture & Protection Info**: Expandable / informative card detailing SQLCipher AES-256 database encryption, Keystore secret management, and integrity checks.
     - **Alert History**: Live reactive list of logged `tamper_detected` security events with timestamps, descriptions, severity badges, and metadata dialog.
     - **Empty State**: Clear, reassuring message when no tamper events exist.

3. **Settings Navigation & Dead Tile Removal**:
   - In `lib/app/app.dart`:
     - Wire `settings-tamper-alerts` to navigate to `TamperAlertsScreen`.
     - Remove `_ComingSoonTile` fallbacks when `enableSyncUi` is false.
     - Delete unused `_ComingSoonTile` class.

4. **Localization**:
   - Add required ARB keys to `lib/l10n/app_en.arb`.
   - Run `flutter gen-l10n`.

5. **Testing & Quality Assurance**:
   - Add widget tests in `test/features/security/presentation/tamper_alerts_screen_test.dart`.
   - Update `test/features/settings/settings_tab_test.dart`.
   - Run `flutter analyze`, `flutter test`, and `dart format lib test`.

---

## 4. Verification Plan

- `flutter gen-l10n`
- `flutter test test/features/security/presentation/tamper_alerts_screen_test.dart`
- `flutter test test/features/settings/settings_tab_test.dart`
- `flutter test`
- `flutter analyze`
- `dart format lib test`
