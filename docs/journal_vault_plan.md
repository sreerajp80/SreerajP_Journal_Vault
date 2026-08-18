# SreerajP_Journal_Vault Implementation Plan

## Core Direction

- App name: `SreerajP_Journal_Vault`
- Platform: Android (Flutter `3.44.8`, Dart `3.12.2`, minimum Android API 28)
- Storage: Drift (SQLite) + encrypted attachment files (default app-private, optional SD card migration)
- Security: app lock with mutually exclusive modes (either phone lock or separate app lock), optional journal lock, attachment-level lock

## Milestone Plan (V1, V2, V3)

- Team assumption for estimates: 1 Flutter developer full-time.
- Estimation unit: person-weeks (pw).
- Buffer recommendation: add 20% contingency to each milestone for device/plugin variability.

### V1 - Secure MVP Foundation

- Goal: Ship a production-ready core journal app with security, attachments, permissions, and baseline backup/export.
- Scope:
  - App scaffold, navigation, theming, Riverpod boundaries.
  - Drift schema, DAOs, migrations, repositories.
  - Journal CRUD, tags, grouping, saved basic filters.
  - Rich text editor baseline.
  - Attachment import/open for PDF/audio/ZIP/7z with encrypted file storage.
  - App lock with single active mode at a time (phone lock default or separate app lock), optional journal lock.
  - Permissions center + explicit runtime permission flow + settings controls.
  - Theme selection in Settings (`Light` / `Dark`) with persistent user preference.
  - About page (author, AI used, IDE used, version, build timestamp).
  - Timeline/Insights as minimal UI shells to keep navigation contract stable.
  - Attachment storage migration app-private <-> SD card.
  - One-tap encrypted export per journal (baseline).
- Estimated effort:
  - Core architecture and data layer: 3-4 pw
  - Journal/editor/attachments and security: 4-5 pw
  - Permissions/settings/about + migration/export: 2-3 pw
  - Stabilization/testing/release hardening: 2 pw
  - Total: 11-14 pw
- Exit criteria:
  - Core user flows stable on Android API 28+.
  - Attachment encryption and lock flows pass integration tests.
  - Permissions and settings behavior transparent and user-controlled.
  - All primary screens are validated in both Light and Dark themes.

### V2 - Knowledge, Productivity, and Reliability

- Goal: Make journaling smarter and more productive while strengthening backup/import workflows.
- Scope:
  - Templates (daily, travel, meeting, gratitude, mood).
  - Journal backlinks (wiki style).
  - Full-text search with FTS5 over entry text + indexed attachment text.
  - Smart tags and advanced saved filters.
  - Timeline/calendar view (full feature set beyond V1 shell).
  - Duplicate/near-duplicate detection.
  - Advanced editor blocks (tables, checklists, code blocks, callouts).
  - Handwriting/drawing support.
  - Voice notes with speech-to-text transcript.
  - Embedded media previews (audio waveform, PDF thumb, archive preview).
  - Version history per entry (restore flow).
  - Import from Markdown, DOCX, plain text, Evernote/Notion-style exports.
  - Background auto-backup schedule + backup health dashboard.
- Estimated effort:
  - Search/FTS/backlinks/tags/filters/timeline/duplicates: 4-6 pw
  - Editor/media/voice/version history: 4-6 pw
  - Import + backup scheduler + reliability work: 3-4 pw
  - Stabilization and UX polishing: 2 pw
  - Total: 13-18 pw
- Exit criteria:
  - Search relevance and duplicate detection meet acceptance thresholds.
  - Import/backup/version-history flows are reliable under interruptions.
  - Productivity features are performant on large local datasets.

### V3 - Intelligence, Sync, and Insight Platform

- Goal: Evolve from single-device secure journal into an intelligent, multi-device personal knowledge system.
- Scope:
  - Multi-device encrypted sync with conflict resolution UI.
  - Auto-lock profiles (immediate, 30s, custom), attachment-level lock.
  - Tamper alerts with optional silent mode.
  - Local-only mode toggle with strict zero telemetry/analytics behavior.
  - Mood tracking and trends.
  - Writing streaks and consistency metrics.
  - Tag heatmap over time.
  - "This day in past years" memories.
  - Weekly reflection auto-generated from entries.
- Estimated effort:
  - Encrypted sync + conflict handling: 6-9 pw
  - Advanced security controls and tamper features: 2-3 pw
  - Insights and reflection engine: 3-5 pw
  - Scale/performance/security hardening: 2-3 pw
  - Total: 13-20 pw
- Exit criteria:
  - Sync conflict handling preserves data integrity.
  - Insights are accurate, explainable, and user-editable.
  - Security events and lock policies work consistently across lifecycle transitions.

## Required Enhancements (Added)

### Authoring and Organization

- Templates: daily journal, travel log, meeting notes, gratitude, mood log.
- Journal backlinks: link entries/journals in wiki style.
- Full-text search across rich text + attachment text (PDF OCR later).
- Smart tags from content.
- Saved filters (for example: Work + audio + last 30 days).
- Timeline/calendar view.
- Duplicate/near-duplicate detection.

### Security and Privacy

- Auto-lock profiles (immediate, 30s, custom).
- Attachment-level lock.
- Tamper alerts with optional silent mode.
- Local-only mode with zero analytics/telemetry toggle.

### Sync, Import, Export, Backup

- Multi-device sync with conflict resolution.
- One-tap encrypted export per journal.
- Imports from Markdown, DOCX, plain text, Evernote/Notion-style exports.
- Background auto-backup schedule and backup health status.

### Editor and Media

- Advanced rich editor blocks: tables, checklists, code blocks, callouts.
- Handwriting/drawing support (stylus canvas).
- Voice notes with speech-to-text transcript.
- Embedded media previews: audio waveform, PDF thumbnail, archive preview.
- Version history per entry with restore.

### Insights

- Mood tracking and trends.
- Writing streaks and consistency metrics.
- Tag heatmap over time.
- "This day in past years" memories.
- Weekly reflection auto-generated from entries.

## Data and Security Notes

- Attachment encryption standard: AES-256-GCM with per-file IV and Android Keystore-backed key hierarchy.
- Explicit permission strategy with rationale dialogs and denied/permanently denied handling.
- SD-card migration supports rollback-safe move operations and SAF URI persistence.
- Lock policy: phone lock and separate app lock are mutually exclusive; changing mode disables the previously active mode.
- UX policy: show a mandatory confirmation dialog before switching lock modes, with clear warning that the previous mode will be disabled.

### Attachment Open Strategy (V1 Baseline, V2 Enhancements)

- General rule:
  - Prefer in-app open where supported; use external app handoff only as fallback.
  - Resolve handling by MIME type first, extension second.
  - If type is unknown, show explicit `Unsupported file type` state with available actions.
- Secure open lifecycle:
  - Keep encrypted files at rest in configured storage (app-private by default, SD card if migrated).
  - On open request, decrypt to app-managed temporary cache file only.
  - Use a short-lived open session token and clear temp file on close, app background timeout, or crash recovery startup sweep.
  - Never expose raw encryption keys or write plaintext into user-visible shared directories.
- File-type behavior:
  - `PDF`: open with in-app PDF viewer in V1; support page thumbnail generation and search index hooks for V2+.
  - `Audio` (`mp3`, `m4a`, `wav`, `aac`, `ogg`): open with in-app audio player in V1; add waveform preview in V2.
  - `ZIP` / `7z`: show in-app archive contents list (name, size, path) without auto-extracting to shared storage.
  - `Images` (`jpg`, `jpeg`, `png`, `webp`, `gif`): in-app viewer support targeted for V2 unless delivered earlier under V1 stretch.
  - `Text-like docs` (`txt`, `md`): open in read-only viewer in V2 import/open phase.
  - `DOCX` and other office formats: open through external intent fallback until dedicated in-app rendering exists.
- External open fallback:
  - If in-app renderer is unavailable, open via Android `ACTION_VIEW` with `FileProvider` content URI and least-privilege read grant.
  - Prompt user before first external open: `This file will be opened in another app.`
  - Provide `Open with...` chooser and remember user preference per MIME family (user-resettable in Settings).
- Failure and recovery states:
  - Distinguish failures as `decrypt_failed`, `permission_denied`, `no_compatible_app`, `corrupt_file`, `unsupported_type`.
  - Reuse recovery CTAs: `Retry`, `Open Settings`, and context-specific `Open with...` where available.
  - Log non-sensitive diagnostics (error code + MIME + source flow) for local troubleshooting only; no telemetry in local-only mode.
- Acceptance criteria:
  - PDF/audio/ZIP/7z attachments can be opened from entry attachment tray in <= 2 taps after selection.
  - Temp plaintext cache is removed after close and after forced process restart cleanup.
  - Unknown/unsupported types always show a deterministic error state with user-actionable recovery.

### Attachment Open Implementation Checklist (V1)

- Slice 1 - Type detection and routing:
  - Build `AttachmentOpenRouter` service (MIME-first, extension fallback).
  - Persist per-MIME `Open with...` preference in settings store.
  - Verify: route correctness for `pdf`, `audio/*`, `application/zip`, `application/x-7z-compressed`.
- Slice 2 - Secure temp-file lifecycle:
  - Implement `AttachmentTempFileManager` for decrypt-to-cache and cleanup.
  - Add startup orphan-temp sweep and lifecycle cleanup on background/close.
  - Verify: no plaintext leftovers after close, restart, or failed open.
- Slice 3 - In-app PDF viewer:
  - Use `syncfusion_flutter_pdfviewer` (or equivalent maintained viewer) for in-app rendering.
  - Add loading/error/empty states aligned with app error policy.
  - Verify: open multi-page PDF, rotate device, reopen after lock/unlock.
- Slice 4 - In-app audio player:
  - Use `just_audio` (+ `audio_session`) for playback controls and lifecycle-safe pause/resume.
  - Add minimal player UI: play/pause, seek bar, elapsed/total duration.
  - Verify: background/foreground transitions and lock-gate resume behavior.
- Slice 5 - Archive preview (ZIP/7z):
  - ZIP: list entries via archive parser package (for example `archive`).
  - 7z: if parser support is limited, provide metadata preview + external fallback with clear UX.
  - Verify: listing for sample archives and graceful handling for encrypted/corrupt archives.
- Slice 6 - External open fallback:
  - Use Android intent handoff through `FileProvider` content URI with read-only grant.
  - Add first-time warning dialog and `Open with...` chooser flow.
  - Verify: `no_compatible_app` state and recovery CTA behavior.
- Slice 7 - Screen wiring:
  - `Entry Editor` attachment tray invokes router (`add/open/remove/relock`).
  - `Attachment Viewer` host screen handles type-specific widget injection + shared error shell.
  - Verify: open from both entry screen and search result attachment hit.
- Slice 8 - Permissions and storage edges:
  - Validate app-private and SAF-backed SD-card storage paths produce valid temp-open flows.
  - Add explicit recovery links to permissions/settings for denied paths.
  - Verify: permission denied/permanently denied scenarios on API 28+ devices.
- Slice 9 - Testing matrix:
  - Unit tests: router mapping, error code mapping, temp cleanup policy.
  - Widget tests: viewer error states and retry/open-with interactions.
  - Integration tests: PDF/audio/ZIP/7z open flow, lock transitions, process restart cleanup.
  - Verify: test suite passes in both `Light` and `Dark` themes.

### Security Feature Availability (Milestone Guardrails)

- V1: app lock mode switch (phone lock/app lock) and optional journal lock.
- V3: auto-lock profiles, attachment-level lock, and tamper alerts.
- Until V3, Settings may show these as `Coming soon` or hide them behind feature flags.

## Theme and UI Policy

- App must support both `Light` and `Dark` themes as first-class modes.
- Settings screen must provide explicit theme selection: `Light` and `Dark`.
- Selected theme is persisted locally and applied on next app launch.
- Theme coverage is required for all major screens, dialogs, and editor surfaces.
- Use theme tokens (colors/typography/spacing) to avoid hardcoded colors.

### Theme Settings Copy (Exact Text)

- Settings section label: `Appearance`
- Settings item label: `Theme`
- Options label: `Light` and `Dark`
- Helper text: `Choose how SreerajP_Journal_Vault looks.`
- Confirmation toast (Light): `Theme updated: Light mode is now active.`
- Confirmation toast (Dark): `Theme updated: Dark mode is now active.`

### Theme Toggle Behavior (Exact Rules)

- On selecting `Light`, apply theme immediately across current screen and all routes.
- On selecting `Dark`, apply theme immediately across current screen and all routes.
- Persist selected mode in local settings store and restore it on next app start.
- If persistence write fails, keep current theme and show: `Could not save theme setting. Please try again.`
- While theme update is in progress, disable repeated taps on theme options to prevent duplicate writes.

## Settings Screen Wireframe Order (Exact)

- Section 1: `Security`
  - `App Lock Mode` (Phone Lock / Separate App Lock)
  - `Auto-Lock Timeout` (Immediate / 30s / Custom) - V3
  - `Attachment-Level Lock` - V3
  - `Tamper Alerts` - V3
- Section 2: `Appearance`
  - `Theme` (Light / Dark)
- Section 3: `Storage`
  - `Attachment Storage Location` (App Private / SD Card)
  - `Migrate Storage` action with progress
  - `Storage Usage` summary
- Section 4: `Permissions`
  - `Permission Status` summary
  - `Manage Permissions` entry (to Permissions page)
  - `Open System Settings` action
- Section 5: `About`
  - `Author`
  - `AI Used`
  - `IDE Used`
  - `App Version / Build`
  - `Last Build Date and Time`

## Broader UI Plan

### App Navigation Structure

- Entry flow:
  - Splash
  - App lock gate
  - Journal home
- Primary navigation:
  - Bottom tabs: `Home`, `Search`, `Timeline`, `Insights`, `Settings`
- Milestone behavior:
  - V1: `Timeline` and `Insights` may be minimal shell screens.
  - V2+: `Timeline` becomes fully functional.
  - V3+: `Insights` becomes fully functional.
- Secondary navigation:
  - Journal details -> entries list
  - Entry editor
  - Attachment viewer
  - Permissions page
  - About page

### Screen-Level Wireframe Plan

- `Home (Journal Box)`:
  - Top app bar: app name, quick add, filter, global search shortcut.
  - Journal cards list with tag chips, lock icon, last updated time.
  - FAB: `New Journal`.
- `Journal Detail`:
  - Header with journal title, tags, lock state, quick actions.
  - Entry list grouped by date.
  - FAB: `New Entry`.
- `Entry Editor`:
  - Title field + rich editor toolbar + content canvas.
  - Attachment tray (add/open/remove/relock).
  - Save indicator and version history shortcut.
- `Search`:
  - Query input + filter chips + saved filters row.
  - Result groups: Journals, Entries, Attachments, Tags.
- `Timeline`:
  - Calendar/month strip + entries for selected day.
  - Quick jump to previous years for memory feature.
- `Insights`:
  - V1: placeholder shell card/state.
  - V3: mood trend chart, streak card, tag heatmap, weekly reflection card.
- `Permissions`:
  - Explicit permissions section.
  - Implicit permissions section.
  - Current status badges and actions.
- `About`:
  - Author, AI used, IDE used, version/build, last build timestamp.

### Reusable UI Components

- `JournalCard`, `EntryCard`, `AttachmentChip`, `TagChip`, `StatusBadge`.
- `PermissionStatusTile` with action buttons.
- `SettingSectionHeader` and `SettingActionRow`.
- `InlineWarningBanner` for denied permissions and storage issues.
- `ConfirmationDialog` variant for lock mode switch and destructive actions.

### Empty, Loading, and Error States

- Empty states:
  - No journals, no entries, no search results, no backups.
- Loading states:
  - Skeleton placeholders for lists/cards.
  - Progress indicators for migration, import/export, backup, sync.
- Error states:
  - Inline retry panels for file open failures and permission denial.
  - Dedicated recovery CTA (`Retry`, `Open Settings`, `Restore Backup`).

### Dialog and Feedback Plan

- Global toast/snackbar patterns:
  - Success, warning, error, and info.
- Confirm dialogs for:
  - Lock mode switch.
  - Storage migration.
  - Delete journal/entry/attachment.
  - Restore from backup.
- Long-running tasks show cancellable progress UI where safe.

### Accessibility and Responsiveness

- Support dynamic text scaling without layout breakage.
- Minimum tap target size for all actions and list items.
- Full semantic labels for icons and lock/security indicators.
- Color contrast compliance in both Light and Dark themes.
- Responsive layout for phone portrait first; adaptive behavior for tablets/foldables.

### UI Acceptance Criteria

- All primary user journeys complete with <= 3 taps from home where feasible.
- No critical action lacks visible success/failure feedback.
- Same feature parity in Light and Dark modes.
- Permissions and lock/security states always visible and understandable.

## V1 UI Screen Build Priority (Design + Implementation Order)

1. `App Shell + Theme Foundation`
   - Why first: establishes navigation, global styles, typography, spacing, and Light/Dark parity baseline.
2. `App Lock Gate Screen`
   - Why second: security entry requirement blocks all downstream flows.
3. `Home (Journal Box) Screen`
   - Why third: primary landing screen and launch point for all core journeys.
4. `Journal Detail Screen`
   - Why fourth: needed to navigate and manage entries within each journal.
5. `Entry Editor Screen`
   - Why fifth: core content creation experience (rich text + save).
6. `Attachment Picker and Viewer Screens`
   - Why sixth: enables file workflows central to product promise.
7. `Search Screen (basic + tags/filters)`
   - Why seventh: validates discoverability and organization.
8. `Settings Screen (wireframe order already defined)`
   - Why eighth: central place for security mode, theme, storage, and controls.
9. `Permissions Screen`
   - Why ninth: supports transparency and recovery for denied permissions.
10. `About Screen`
    - Why tenth: final metadata/compliance screen, low dependency risk.
11. `Timeline Screen (basic V1 shape)`
    - Why eleventh: included after core CRUD to reduce launch risk.
12. `Insights Screen (V1 placeholder or minimal metrics)`
    - Why twelfth: reserve full insights for later milestones while keeping nav contract stable.

### V1 UI Freeze Checkpoint

- Freeze after screens 1-10 are functionally complete and validated in Light/Dark themes.
- Screens 11-12 can launch as minimal versions if core V1 scope and quality gates are met.
- If screens 11-12 are deferred, hide their tabs behind feature flags until enabled.

### Lock Mode Switch Dialog Copy (Exact Text)

- Title: `Switch lock mode?`
- Message (switching to phone lock): `This will switch app protection to Phone Lock and disable Separate App Lock. Continue?`
- Message (switching to separate app lock): `This will switch app protection to Separate App Lock and disable Phone Lock. Continue?`
- Primary button: `Switch`
- Secondary button: `Cancel`
- Post-success toast (to phone lock): `Lock mode updated: Phone Lock is now active.`
- Post-success toast (to separate app lock): `Lock mode updated: Separate App Lock is now active.`

## Delivery Sequence

1. Complete V1 and release stable baseline.
2. Execute V2 in two increments:
   - V2.1: search/templates/backlinks/editor upgrades.
   - V2.2: import + backup + version history + media enhancements.
3. Execute V3 in two increments:
   - V3.1: encrypted sync + conflict resolution.
   - V3.2: insights + reflection + advanced security controls.
4. End each increment with regression testing, theme parity checks (Light/Dark), migration validation, and release candidate sign-off.
