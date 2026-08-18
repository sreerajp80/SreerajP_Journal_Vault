# AI Development Prompts - SreerajP_Journal_Vault

Use this playbook to build the app in small, testable slices without exceeding context limits.

## How to Use This File

- Run one prompt at a time.
- Do not combine prompts unless explicitly stated.
- Always include only relevant files in context.
- After each prompt:
  - run formatting/lint/tests for changed scope,
  - verify acceptance criteria,
  - commit (optional) with a focused message.

## Critical Path (Quick Execution Guide)

- Strict V1 backbone: `00 -> 01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 -> 08 -> 12 -> 13 -> 14`.
- Parallel-safe after scaffold (`00`): `09` (permissions), `10` (theme), `11` (about).
- Security-sensitive chain: `05 -> 06 -> 12` and `07 -> 08`.
- V2 starts after V1 hardening (`14`): `15`, `16`, `18` (with `17` after `15/16`).
- V3 starts after stable V2 foundation: `19 -> 20`.
- If uncertain, follow prompt numbers in order and do not parallelize.

## Global Constraints (include in every prompt)

- Target stack: Flutter `3.44.8`, Dart `3.12.2`, Android min API `28`.
- App name: `SreerajP_Journal_Vault`.
- Use `flutter_riverpod`, Drift (SQLite), encrypted attachments (AES-256-GCM via Keystore strategy).
- App lock modes are mutually exclusive: `phone_lock` OR `app_lock`.
- Theme support required for both `Light` and `Dark`.
- Keep changes minimal and scoped to this prompt only.
- Add/update tests for modified behavior.
- Avoid introducing unrelated refactors.

---

## Prompt 00 - Project Scaffold and Architecture [COMPLETED]

**Prompt to AI**

Create the base Flutter project architecture for `SreerajP_Journal_Vault` with feature-first folders and Riverpod setup.

Depends on: None (starting point).

Tasks:
- Create app shell, routing, dependency boundaries, and app-level theme provider.
- Add placeholder screens: LockGate, Home, Search, Timeline (shell), Insights (shell), Settings.
- Add baseline `pubspec.yaml` dependencies needed for current scope only.

Acceptance:
- App launches and navigates to shell screens.
- No lints in changed files.
- Light/Dark theme toggle wiring exists (can still be placeholder UI).

---

## Prompt 01 - Drift Schema v1 [COMPLETED]

**Prompt to AI**

Implement initial Drift database schema and DAOs for V1 core.

Depends on: Prompt 00.

Tasks:
- Add tables: journals, entries, tags, journal_tags, attachments, app_security, app_settings.
- Include fields required by plan (including storage mode and lock mode fields).
- Add migration scaffolding and repository interfaces.

Acceptance:
- DB compiles with generated files.
- CRUD smoke tests for journals/entries/tags pass.

---

## Prompt 02 - Home and Journal CRUD UI [COMPLETED]

**Prompt to AI**

Build Home (Journal Box) screen and journal CRUD flows.

Depends on: Prompt 01.

Tasks:
- Journal list with card UI, lock indicator, last updated timestamp.
- Create/edit/delete journal flows.
- Tag assignment basics.

Acceptance:
- User can create, edit, delete journal.
- Empty/loading/error states present.
- Widget tests for list and CRUD actions.

---

## Prompt 03 - Journal Detail and Entry List [COMPLETED]

**Prompt to AI**

Implement Journal Detail screen and entries list grouped by date.

Depends on: Prompt 02.

Tasks:
- Journal header with title, tags, lock state.
- Entry listing, add entry action, open editor navigation.

Acceptance:
- Entry list updates reactively after create/update/delete.
- Grouping by date works.

---

## Prompt 04 - Rich Text Editor Baseline [COMPLETED]

**Prompt to AI**

Integrate `flutter_quill` for entry editing.

Depends on: Prompt 03.

Tasks:
- Entry editor screen with title + rich text toolbar + content area.
- Persist Quill delta JSON to DB.
- Basic autosave or explicit save indicator.

Acceptance:
- Entry content is restored correctly on reopen.
- Widget/integration test for create/edit/reopen workflow.

---

## Prompt 05 - Attachment Import + Open [COMPLETED]

> The `open` half was a stub until 2026-07-25 — `AttachmentOpenRouter.open` threw
> `UnimplementedError`, so tapping any attachment crashed. Now implemented on
> `open_filex` with every failure mapped to `AttachmentOpenFailure`.

**Prompt to AI**

Add attachment import/open pipeline for PDF/audio/ZIP/7z using an in-app-first strategy with safe external fallback.

Depends on: Prompt 04.

Tasks:
- File picking integration.
- Save attachment metadata.
- Keep at-rest storage compliant with global constraints (no plaintext attachment persistence; use encrypted storage contract/adapter even if service internals are finalized in Prompt 06).
- Add `AttachmentOpenRouter` (resolve by MIME first, extension fallback).
- Implement V1 open behavior:
  - PDF: in-app viewer.
  - Audio: in-app player baseline.
  - ZIP/7z: in-app archive preview (list/metadata) when possible.
- Add external fallback using Android `ACTION_VIEW` + `FileProvider` content URI with read-only grant.
- Add first-time external-open warning (`This file will be opened in another app.`) and `Open with...` chooser.
- Implement deterministic failure mapping: `decrypt_failed`, `permission_denied`, `no_compatible_app`, `corrupt_file`, `unsupported_type`.
- Build attachment tray in editor/detail.

Acceptance:
- User can add and open PDF/audio/ZIP/7z attachments from attachment tray in <= 2 taps after selection.
- In-app-first open path is used when renderer/player is available.
- Graceful unsupported-file and no-compatible-app handling exists with actionable recovery UI.
- Widget/integration tests cover open route selection and failure-state recovery actions.

---

## Prompt 06 - Attachment Encryption Storage Service [COMPLETED]

**Prompt to AI**

Implement encrypted attachment file storage and secure temp-open lifecycle service.

Depends on: Prompt 05.

Tasks:
- AES-256-GCM encryption/decryption abstraction.
- File save/open pipeline with IV + key reference metadata.
- Keep implementation centralized in one crypto/storage service.
- Add `AttachmentTempFileManager` for decrypt-to-app-cache temporary plaintext files only.
- Add cleanup policy: remove temp files on viewer close, app background timeout, and startup orphan-temp sweep.
- Ensure plaintext is never written to user-visible shared directories.

Acceptance:
- Encrypted files can be saved and opened.
- Failure paths handled safely.
- Temp plaintext cache is removed after close and after forced process restart cleanup.
- Unit tests for encrypt/decrypt, metadata persistence, and temp cleanup lifecycle.

---

## Prompt 07 - App Lock Modes (Mutually Exclusive) [COMPLETED]

**Prompt to AI**

Implement lock system with mutually exclusive `phone_lock` and `app_lock`. Use exact UX wording from `journal_vault_plan.md` (`Data and Security Notes`, `Settings Screen Wireframe Order (Exact)`).

Depends on: Prompt 01.

Tasks:
- Lock mode settings and persistence.
- Confirmation dialog exact copy from plan when switching modes.
- Enforce single active mode only.

Acceptance:
- Switching mode disables previous mode.
- Lock gate enforces active mode correctly.
- Tests for mode switch and app lifecycle lock behavior.

---

## Prompt 08 - Journal Lock and Security Basics [COMPLETED]

**Prompt to AI**

Add optional per-journal password protection.

Depends on: Prompt 07.

Tasks:
- Journal lock toggle and secure credential handling.
- Journal unlock flow before access.
- Use Keystore-backed key handling strategy and ensure secrets/derived credentials are never stored in plaintext or reversible form.

Acceptance:
- Locked journal cannot be opened without auth.
- Credential handling not stored in plaintext.

---

## Prompt 09 - Permissions Center + Settings Controls [COMPLETED]

**Prompt to AI**

Implement permissions UX and controls.

Depends on: Prompt 00.

Tasks:
- Runtime permission requests with rationale before use.
- Permissions screen with explicit + implicit permissions and status.
- Settings actions: request again/open system settings.

Acceptance:
- Denied/permanently denied paths handled.
- Permissions page status updates correctly.

---

## Prompt 10 - Theme Selection (Exact UX Copy) [COMPLETED]

**Prompt to AI**

Implement Light/Dark theme selection in Settings with exact behavior and copy from `journal_vault_plan.md` (`Theme and UI Policy`, `Settings Screen Wireframe Order (Exact)`).

Depends on: Prompt 00.

Tasks:
- Appearance section + Theme setting.
- Persist selection and apply immediately across routes.
- Success/failure toast behavior exactly as specified.

Acceptance:
- Theme persists on app restart.
- No hardcoded colors in changed screens.

---

## Prompt 11 - About Screen + Build Metadata [COMPLETED]

**Prompt to AI**

Implement About screen with required metadata.

Depends on: Prompt 00.

Tasks:
- Show: author, AI used, IDE used, app version/build, last build timestamp.
- Wire app/package metadata and build-time define for timestamp.

Acceptance:
- About fields render correctly.
- Value fallback behavior for missing build define.

---

## Prompt 12 - Storage Migration (App Private <-> SD Card) [COMPLETED]

> The Dart half was a stub until 2026-07-25. `migrateStoredFile` threw
> `UnimplementedError`, and `encryptAndStore` always wrote app-private no matter
> what the setting said — so choosing SD card silently did nothing. The native SAF
> layer had been complete the whole time; only the Dart calls were missing.

**Prompt to AI**

Implement attachment storage migration with progress and rollback safety.

Depends on: Prompt 06.

Tasks:
- Storage location setting.
- Migration service using streamed I/O.
- Handle revoked SAF URI/card removal/interruption.

Acceptance:
- Migration is resumable or rollback-safe.
- No metadata/file mismatch after migration.

---

## Prompt 13 - Search v1 (Basic + Saved Filters) [COMPLETED]

**Prompt to AI**

Implement basic search and saved filters in V1 shape.

Depends on: Prompt 01, Prompt 02, Prompt 03, Prompt 04.

Tasks:
- Search across journal titles, entry titles/content (available fields).
- Saved filter presets and recall.

Acceptance:
- Search results grouped and filterable.
- Saved filters persist and reload.

---

## Prompt 14 - V1 Polish and Release Hardening [COMPLETED]

**Prompt to AI**

Stabilize V1 end-to-end.

Depends on: Prompts 00-13.

Tasks:
- Resolve UI state gaps (empty/loading/error).
- Add missing tests for critical flows.
- Verify Light/Dark parity and accessibility basics.

Acceptance:
- Critical V1 flows pass integration tests.
- Lint clean for changed scope.

---

## Prompt 15 - V2 Templates + Backlinks [COMPLETED]

**Prompt to AI**

Implement templates and journal/entry backlinks.

Depends on: Prompt 14.

Tasks:
- Template chooser with 5 templates.
- Backlink data model and inline link rendering.

Acceptance:
- Template creates structured starter content.
- Backlinks are navigable and stable after edits.

---

## Prompt 16 - V2 FTS5 + Smart Tags + Timeline [COMPLETED]

> FTS5 and Timeline were wired all along. Smart Tags was not — the service, its
> providers, and `SmartTagChipBar` were built and unit-tested, but no screen
> imported any of it. The chip bar was mounted in the entry editor on 2026-07-25.

**Prompt to AI**

Add full-text search pipeline and productivity discovery features.

Depends on: Prompt 14.

Tasks:
- FTS5 index for entry content and attachment-extracted text for supported file types (define supported formats and extraction source explicitly in implementation notes).
- Smart tag suggestions.
- Timeline/calendar full view.

Acceptance:
- FTS query performance acceptable on medium dataset.
- Smart tag suggestions are relevant and non-destructive.

---

## Prompt 17 - V2 Editor Advanced Blocks + Media [COMPLETED]

**Prompt to AI**

Extend editor capabilities and media experience.

Depends on: Prompt 15, Prompt 16.

Tasks:
- Add tables/checklists/code blocks/callouts.
- Voice notes + transcript baseline.
- Embedded media previews.
- Version history per entry with restore.

Acceptance:
- Revision restore is deterministic.
- Media preview works for supported file types.

---

## Prompt 18 - V2 Import + Backup Scheduler [COMPLETED]

**Prompt to AI**

Implement import adapters and background backup health.

Depends on: Prompt 14, Prompt 16.

Tasks:
- Import from Markdown/DOCX/plain text and mapped external exports.
- Background encrypted auto-backup scheduling.
- Backup health dashboard and failure diagnostics.

Acceptance:
- Import preserves core content structure.
- Scheduled backups run and status updates correctly.

---

## Prompt 19 - V3 Encrypted Sync + Conflict Resolution [PARTIAL]

> **Status corrected 2026-07-25.** Was marked complete, but sync cannot run.
> `SyncEncryptionService`, `ConflictResolutionService`, the Drift tables, and the
> screens are all built and tested. What is missing is the transport: `SyncProtocol`
> has no concrete implementation, and `SyncEngine` is constructed by nothing —
> no provider, no screen, no test. Nothing can push or pull.
>
> The sync UI is therefore hidden behind `AppFlavorConfig.enableSyncUi` (off), so
> the app no longer reports sync health for a sync that cannot happen. Finishing
> this needs a transport decision (REST, WebDAV, folder sync) and its own plan.
> See `docs/architecture.md` section 21.

**Prompt to AI**

Implement multi-device encrypted sync with explicit conflict handling.

Depends on: Prompt 14, Prompt 18.

Tasks:
- Sync protocol abstraction and deterministic IDs.
- Conflict resolution UI for merge choice.

Acceptance:
- Data integrity preserved under conflict scenarios.
- Sync retries and failure states are recoverable.

**Completed Implementation:**
- Database: `SyncMetadata`, `SyncConflicts`, `SyncLogs` tables with DAOs + migration v5.
- `SyncIdGenerator`: deterministic UUID v5 from deviceId + table + localId.
- `SyncProtocol`: abstract transport layer (push/pull/availability check).
- `SyncEncryptionService`: AES-256-GCM end-to-end encryption for sync payloads.
- `SyncEngine`: full bidirectional sync lifecycle with exponential back-off retry (up to 3 retries).
- `ConflictResolutionService`: field-level diff computation, keep-local/keep-remote/merge strategies.
- `ConflictResolutionScreen`: lists pending conflicts with side-by-side diff dialog and action buttons.
- `SyncStatusWidget`: compact sync state indicator with conflict badge.
- `SyncHealthDashboard`: metrics card (last sync, failures, conflicts, recent log).
- Riverpod providers for sync state, conflict streams, and health metrics.
- Backup service updated to include sync metadata in exports.

---

## Prompt 20 - V3 Security Extensions + Insights ✅

**Prompt to AI**

Add V3 security features and insights suite.

Depends on: Prompt 19.

Tasks:
- Auto-lock profiles, attachment-level lock, tamper alerts.
- Mood trends, streaks, tag heatmap, memories, weekly reflection generation.

Acceptance:
- Security events are logged and visible to user where applicable.
- Insights calculations are reproducible and user-editable where needed.

**Completed. Changes:**

Database (schema v6 migration):
- Added `AutoLockProfiles` table — configurable timeout, lock-on-minimize, optional cron schedule.
- Added `AttachmentLocks` table — per-attachment lock with credential reference.
- Added `SecurityEvents` table — audit log with event type, severity, and JSON metadata.
- Added `EntryMoods` table — 1–5 mood rating per entry, user-editable.
- DAOs: AutoLockProfilesDao, AttachmentLocksDao, SecurityEventsDao, EntryMoodsDao.

Security feature (`lib/features/security/`):
- `SecurityEventService` — centralized event logging, tamper detection (integrity checks), auth failure tracking.
- `AutoLockService` — CRUD profiles, inactivity timer, lock-on-minimize, activity recording.
- `AttachmentLockService` — lock/unlock/relock individual attachments with event logging.
- `SecurityEventsScreen` — chronological event log with severity indicators and metadata drill-down.
- Riverpod providers for all security state (events stream, profile watch, lock status).

Insights feature (`lib/features/insights/`):
- `InsightsService` — mood trends (daily averages), writing streaks (current + longest), tag heatmap (usage frequency), memories ("On This Day" from prior years), weekly reflection generation (entries, words, avg mood, top tags, streak).
- `InsightsScreen` — dashboard with streak card, mood trend chart, tag heatmap chips, memories list, weekly reflection summary.
- Riverpod providers for all insights data (mood stream, trends, streaks, heatmap, memories, weekly reflection).

---

## Reusable Mini-Prompt Template (for any small task)

Copy this when creating additional micro-prompts:

1. Goal:
2. Files in context (max 8-12 files):
3. Exact tasks (3-7 bullets):
4. Non-goals:
5. Acceptance criteria:
6. Tests to add/run:
7. Output format (changed files + short rationale + test results):











