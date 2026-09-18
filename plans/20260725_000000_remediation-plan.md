# SreerajP_Journal_Vault — Remediation Plan

**Status:** completed

This plan addresses the gap between [ai_development_prompts.md](../ai_development_prompts.md) (which marked all 21 prompts `[COMPLETED]`) and the actual integrated state of the running app. Most V2/V3 features exist as orphan modules in `lib/features/` but are not wired into the app shell, the V1 lock gate is a no-op button, and journal secrets are stored in memory in production.

Each task below is a discrete, testable unit. Mark `[x]` when shipped. Slice ordering reflects impact and dependency — execute A → B → C → D → E.

## Audit Reference (gaps that motivated this plan)

- App lock gate is a fake button at [app.dart:239-243](../SreerajP_Journal_Vault/lib/app/app.dart) — no biometric, no PIN.
- Journal secret store defaults to `_InMemoryJournalSecretStore` in production at [app.dart:89-91](../SreerajP_Journal_Vault/lib/app/app.dart). Secrets lost on every restart.
- Bottom nav has 3 tabs (`Home`, `Search`, `Settings`); plan requires 5 (`Home`, `Search`, `Timeline`, `Insights`, `Settings`).
- Settings screen has only `Security`, `Appearance`, `About`. Plan requires `Storage` and `Permissions` sections too.
- Orphan screens (built but unreachable): `InsightsScreen`, `TimelineScreen`, `BackupHealthScreen`, `ImportScreen`, `PermissionsScreen`, `SecurityEventsScreen`, `ConflictResolutionScreen`, `SyncStatusWidget`, `SyncHealthDashboard`.
- DAOs without UI: `AutoLockProfiles`, `AttachmentLocks`, `EntryMoods`, `SecurityEvents`.
- `integration_test/` directory is empty.
- No tests for: `insights`, `security`, `sync`, `timeline`, `backup`, `import`, `smart_tags`.

---

## Slice A — Fix V1 Security Holes (CRITICAL — do first)

### A1. Real app lock gate
- [x] Add `local_auth` to [pubspec.yaml](../SreerajP_Journal_Vault/pubspec.yaml).
- [x] Phone-lock mode: invoke `local_auth` device-credential prompt; only set `_isAppLocked = false` on success.
- [x] App-lock mode: PIN/password verifier stored via Keystore (extend the existing `sreerajp.journal_vault/attachment_keys` MethodChannel pattern in [MainActivity.kt](../SreerajP_Journal_Vault/android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt) — add a separate channel that stores PBKDF2 salt + verifier, never the raw PIN).
- [x] First-launch flow: if `lockMode` is null, force user to choose a mode and set credential before reaching `_MainShell`.
- [x] Replace local `_isAppLockedProvider` bool in [app.dart](../SreerajP_Journal_Vault/lib/app/app.dart) with a Riverpod-exposed `AppLockController` so its `didChangeAppLifecycleState` actually drives the gate and persists `isLocked` to DB.

### A2. Persist journal secrets in Keystore
- [x] Implement a real `JournalSecretStore` (either extend the attachment-keys MethodChannel to vend journal secrets keyed by `credentialReference`, or add `flutter_secure_storage` — Keystore-backed by default on API 28+).
- [x] Override `_journalSecretStoreProvider` in [main.dart](../SreerajP_Journal_Vault/lib/main.dart) with the real implementation. Keep `_InMemoryJournalSecretStore` only as a test default.
- [x] Verify locked journals stay locked across app restarts.

### A3. Tests for Slice A
- [x] Add `integration_test/lock_gate_test.dart` covering: cold launch locked → unlock with wrong creds (denied) → unlock with right creds → background → relock → restart → still locked. *(A1 portion only; A2 will add journal-secret persistence coverage.)*
- [x] Add unit tests for the new PIN-verifier MethodChannel adapter (mock channel).
- [x] Update existing [test/features/lock_gate/](../SreerajP_Journal_Vault/test/features/lock_gate/) suite to assert `AppLockController` drives the gate.

---

## Slice B — Wire Orphaned V1 Screens into Settings

Rebuild the Settings list in [app.dart:738-808](../SreerajP_Journal_Vault/lib/app/app.dart) to match the plan's exact wireframe order.

- [x] **Security section** — add rows: `Auto-Lock Timeout`, `Attachment-Level Lock`, `Tamper Alerts` marked "Coming soon" (real wiring lands in Slice D).
- [x] **Appearance section** — remove the third `System` chip (plan specifies only `Light` / `Dark`).
- [x] **Storage section (new)** — `Attachment Storage Location` (App Private / SD Card), `Migrate Storage` action with progress UI (wire to [attachment_storage_migration_service.dart](../SreerajP_Journal_Vault/lib/features/attachments/services/attachment_storage_migration_service.dart)), `Storage Usage` summary.
- [x] **Permissions section (new)** — status summary tile, `Manage Permissions` row pushing [PermissionsScreen](../SreerajP_Journal_Vault/lib/features/permissions/presentation/permissions_screen.dart), `Open System Settings` action.
- [x] **About section** — already wired; verify ordering matches plan.

### B Tests
- [x] Widget test asserting Settings renders all 5 sections in plan order.
- [x] Widget test for `Manage Permissions` tap → `PermissionsScreen` push.
- [x] Widget test for `Migrate Storage` flow renders progress and handles cancel.

---

## Slice C — Wire V2 Features into Navigation

### C1. Bottom nav → 5 tabs
- [x] Extend `tabs` list in [app.dart:259](../SreerajP_Journal_Vault/lib/app/app.dart) to `[_HomeTab, _SearchTab, TimelineScreen, InsightsScreen, _SettingsTab]`.
- [x] Add `Timeline` and `Insights` `BottomNavigationBarItem` entries.
- [x] Verify Light + Dark theme parity on both new tabs.

### C2. Backup + Import entry points
- [x] Add `Backup Health` row under Settings → Storage → push [BackupHealthScreen](../SreerajP_Journal_Vault/lib/features/backup/presentation/backup_health_screen.dart).
- [x] Add `Import Data` row under Settings → Storage → push [ImportScreen](../SreerajP_Journal_Vault/lib/features/import/presentation/import_screen.dart).

### C3. Templates + backlinks UX
- [x] Verify entry editor exposes a template chooser on new-entry creation (5 templates per plan: daily, travel, meeting, gratitude, mood).
- [x] Wire backlink rendering inside Quill editor using [BacklinksDao](../SreerajP_Journal_Vault/lib/core/database/app_database.dart) and [vault_backlinks.dart](../SreerajP_Journal_Vault/lib/core/links/vault_backlinks.dart).
- [x] Add a "Linked from" panel on the entry editor showing inbound backlinks.

### C Tests
- [x] Widget test: 5 tabs render and are switchable.
- [x] Integration test: navigate to each tab, verify no crashes, no missing providers.

---

## Slice D — Wire V3 Features into Navigation

### D1. Sync UI
- [x] Mount `SyncStatusWidget` in `_HomeTab` app bar.
- [x] Add `Sync Conflicts` row in Settings → Security → push [ConflictResolutionScreen](../SreerajP_Journal_Vault/lib/features/sync/presentation/conflict_resolution_screen.dart).
- [x] Add `Sync Health` row in Settings → Storage → push the existing sync health dashboard widget.

### D2. Security events
- [x] Add `Security Events` row in Settings → Security → push [SecurityEventsScreen](../SreerajP_Journal_Vault/lib/features/security/presentation/security_events_screen.dart).

### D3. Auto-lock profiles UI
- [x] Build CRUD screen for `AutoLockProfiles` table (currently DAO-only).
- [x] Surface from Settings → Security → `Auto-Lock Timeout` (replace "Coming soon" placeholder from Slice B).

### D4. Attachment-level lock UI
- [x] Add lock/unlock action in attachment tray inside entry editor.
- [x] Toggles `AttachmentLocks` table; locked attachments require re-auth before decrypt-to-temp.
- [x] Replace "Coming soon" placeholder for `Attachment-Level Lock` in Settings.

### D5. Mood entry (must precede meaningful Insights)
- [x] Surface a 1–5 mood picker on entry save in [entry_editor_screen.dart](../SreerajP_Journal_Vault/lib/features/entries/presentation/entry_editor_screen.dart).
- [x] Persist to `EntryMoods` table.
- [x] Verify InsightsScreen mood trend renders real data (was empty before).

### D Tests
- [x] Unit test: auto-lock profile activation deactivates all others.
- [x] Integration test: lock attachment → close viewer → reopen → re-auth required. *(Service-level + widget-level coverage; full integration_test still recommended on real device.)*
- [x] Integration test: conflict resolution end-to-end (create conflict → resolve keep_local → verify state).

---

## Slice E — Test Coverage Backfill

`test/features/` currently covers only V1 modules. Backfill the rest.

- [x] `test/features/insights/` — service-layer tests for mood aggregation, streak computation, tag heatmap, "On This Day" memories.
- [x] `test/features/security/` — auto-lock timer logic, attachment-lock state machine, security event logging.
- [x] `test/features/sync/` — sync ID generation determinism, conflict detection, encryption round-trip.
- [x] `test/features/timeline/` — date-bucket grouping, month query results.
- [x] `test/features/backup/` — backup log creation, history queries, log truncation. *(Real backup creation/restore needs path_provider — covered by the verifyBackup contract; full round-trip best run on device.)*
- [x] `test/features/import/` — markdown adapter, docx adapter, plain-text adapter.
- [x] `test/features/smart_tags/` — tag suggestion ranking.

---

## Out-of-Scope Items (track separately)

These were called out during the audit but are not part of the V1/V2/V3 prompt sequence and should be backlogged as follow-ups, not bundled into this remediation:

- Handwriting / drawing (stylus canvas) — V2 plan item, no module exists.
- PDF OCR for attachment text extraction — plan defers to "later".
- Audio waveform preview — V2 plan item, partial via `media_preview_embed.dart`.
- Duplicate / near-duplicate detection — V2 plan item, no module.
- Local-only mode toggle (zero telemetry) — V3 plan item, no dedicated UI.
- DOCX in-app rendering — plan explicitly defers to external intent.

---

## Execution Notes

- **One slice per branch/PR** to keep blast radius small.
- **Update [ai_development_prompts.md](../ai_development_prompts.md)** when a slice closes — replace stale `[COMPLETED]` claims with accurate state, since several were premature.
- **Light + Dark theme parity** is required for every UI change (per [journal_vault_plan.md](../journal_vault_plan.md) Theme and UI Policy).
- **No new orphan files**: every screen added by a slice must be reachable by the user via navigation before the slice is marked done.

## Progress Tracker

| Slice | Status | Notes |
|---|---|---|
| A — V1 security holes | Complete | A1 + A2 + A3 |
| B — V1 Settings sections | Complete | 5 sections + tests |
| C — V2 navigation wiring | Complete | 5 tabs + Backup/Import entries + templates + backlinks |
| D — V3 navigation wiring | Complete | Sync UI + Security events + Auto-lock + Attachment-lock + Mood |
| E — Test coverage backfill | Complete | 7 module test files; uncovered drift datetime + markdown bugs fixed along the way |
