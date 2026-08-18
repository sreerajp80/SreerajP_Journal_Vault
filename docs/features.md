# App Description: SreerajP Journal Vault (`sreerajp_journal_vault`)

`SreerajP_Journal_Vault` is a production-grade, security-hardened, privacy-first offline personal journal, diary, and knowledge vault application built with Flutter (3.44.8) and Dart (3.12.2) for Android (minimum API 28 / Android 9.0+). It is governed by three strict engineering profiles: **Core Baseline**, **Production App Extension**, and **Sensitive Data Extension**.

The application features a journal library home screen for creating, editing, and deleting journals (with tagging and optional password protection at creation time), window-wide `FLAG_SECURE` screen protection (blocking system screenshots, screen recording, and task switcher preview thumbnails), hardware Keystore-backed AES-256-GCM attachment encryption, multi-mode app locking (Device Credential / Biometric lock vs. custom Keystore-hashed 6-digit PIN lock), granular journal-level password encryption (Argon2/PBKDF2 key derivation with Android Keystore native secret storage), fine-grained per-attachment security locks, rich text authoring with Flutter Quill, custom interactive Quill embeds (grid tables, callout admonitions, inline voice recordings), speech-to-text live transcription, entry version history snapshot restoration, a combined journal-and-entry search screen backed by a SQLite FTS5 full-text search engine indexing entries and extracted attachment content (.txt, .pdf, .md, .csv), saveable search presets and multi-criteria filtering (date range, journal, tag, mood, lock status, attachment presence), smart tag management with live auto-completion chip bar, wiki-style double-bracket (`[[Entry Title]]`) backlinks with inbound "Linked From" reference discovery, multi-format document import adapters (Markdown with frontmatter parsing, Microsoft Word DOCX, Plain Text), entry and journal export to Markdown, HTML, plain text and PDF (with Malayalam-correct, selectable PDF text rendered through a native offline WebView, optional decrypted attachment bundling, and an optional password that seals the exported file with the same versioned envelope the backup archive uses), customizable entry templates, background backup scheduler & health monitoring dashboard, restore from an encrypted backup archive with preview, replace-or-merge and dry-run modes, a user-cancellable attachment storage location migration engine (App-Private Storage <-> SD Card / External Storage via Storage Access Framework), a chronological timeline feed with a calendar entry navigator showing writing-activity and mood heatmaps, dynamic analytics & insight engine (word counts, writing streaks, 1-5 scale mood trends chart, tag heatmaps, "On This Day" memory resurfacing, automated weekly reflection summaries), integrated in-app secure viewers (PDF viewer, audio player with waveform visualizer, ZIP/7z archive browser), auto-lock profiles with cron schedules and minimize locking, security audit event logging with a basic tamper check (its Settings entry point is currently a disabled "Coming soon" placeholder — see Section 8), multi-device vector clock sync engine with E2E AES-GCM payload encryption and visual side-by-side conflict resolution UI (implemented and tested, but currently hidden from the UI — see Section 7), a unified Settings screen, built-in permissions transparency center, asset-configured About metadata, dev/prod build flavors with flavor-gated verbose logging, a console-only structured logger that redacts sensitive content by policy, and an offline-first architecture with zero telemetry and no network permission requirement in production.

The app is still being hardened toward the release standard it targets: release builds are not
yet signed with a real release key (they currently fall back to the Android debug key), and only
attachments are encrypted at rest today — the SQLite database and its full-text search index are
stored unencrypted inside the app-private directory. See `docs/architecture.md` section 21 for
the full list of open gaps.

---

# Exhaustive Feature List

## 1. Security, Privacy & Data Protection (Sensitive Data Extension)
- **FLAG_SECURE Window Screen Protection**:
  - Full-window screenshot and screen recording prevention via Android `WindowManager.LayoutParams.FLAG_SECURE` enforced natively in `MainActivity.kt`.
  - Prevents system task switcher snapshot caching and unauthorized visual screen captures across all application views.
- **Flexible App Lock Modes**:
  - **Phone Lock (Default)**: Leverages Android system device credentials (PIN, pattern, password) and biometric authentication via `local_auth` (`biometric_authenticator.dart`).
  - **App PIN Lock**: Custom 6-digit PIN backed by Android Keystore hardware-bound key derivation and PBKDF2 hashing (`app_pin_keystore.dart`, `app_pin_service.dart`, MethodChannel `sreerajp.journal_vault/app_pin_lock`).
  - **Single Active Mode Enforcement**: Strict mutual exclusion ensuring either phone lock or app PIN lock is active at one time (`AppSecurity` table, `app_lock_controller.dart`).
  - **Lock Gate Screen**: Full-screen gate (`_LockGateScreen`) preventing app interaction until biometric or PIN re-authentication completes, clearing session-unlocked state on lock.
- **First-Launch Security Setup Onboarding**:
  - Guided onboarding screen (`_FirstLaunchSetupScreen`) presented on initial app launch to select preferred lock mode and initialize credentials.
- **Journal-Level Granular Encryption & Password Protection**:
  - Ability to password-protect individual sensitive journals with dedicated passphrases (`journal_password_service.dart`).
  - Cryptographic key derivation via Argon2/PBKDF2; per-journal Data Encryption Key (DEK) references stored securely via native Android Keystore method channels (`MethodChannelJournalSecretStore`, `JournalSecretStore`, MethodChannel `sreerajp.journal_vault/journal_lock`).
  - In-memory session-level unlocking state management (`_unlockedJournalIdsProvider`).
- **Hardware-Backed AES-256-GCM Attachment Encryption**:
  - All binary attachments (images, PDFs, audio recordings, documents, archives) stored outside the database are encrypted at rest with AES-256-GCM (`attachment_crypto_storage.dart`, `attachment_key_manager.dart` / `AttachmentKeyManager`).
  - Key wrapping managed via native Android Keystore channel (`sreerajp.journal_vault/attachment_keys`) with master key alias `sreerajp_journal_vault_attachment_wrap_v1`.
- **Attachment-Level Fine-Grained Locks**:
  - Per-attachment access control requiring re-authentication before decrypting or exporting specific confidential media files (`attachment_lock_service.dart`, `AttachmentLocks` table, `_LockedAttachmentsScreen`).
- **Auto-Lock Profiles & Inactivity Management**:
  - Custom inactivity timeout rules (immediate lock on background/minimize, 30s, 1m, 5m, 15m) driven by `AppLockController`.
  - Configurable scheduled cron-like lock policies (`AutoLockProfiles` table, `auto_lock_service.dart`, `auto_lock_profiles_screen.dart`).
- **Security Audit Logging & Tamper Alerts**:
  - Comprehensive audit logging of security-relevant events (failed authentication attempts, lock triggers, tamper alerts, lock mode changes, export attempts, attachment access) with severity classification (`info`, `warning`, `critical`) (`security_event_service.dart`, `SecurityEvents` table).
  - UI audit viewer for inspecting security event history and diagnostic logs (`security_events_screen.dart`).
- **Native Android Method Channels**:
  - `sreerajp.journal_vault/attachment_keys`: Native Keystore key wrapping for attachments.
  - `sreerajp.journal_vault/attachment_storage`: SAF tree picker and file operations.
  - `sreerajp.journal_vault/journal_lock`: Keystore-backed journal password secret store.
  - `sreerajp.journal_vault/app_pin_lock`: Keystore-backed PIN verifier storage.
  - `sreerajp.journal_vault/runtime_environment`: Query Android SDK version (`getAndroidSdkInt`).
  - `sreerajp.journal_vault/html_pdf`: Renders a self-contained local HTML page to PDF bytes in an off-screen, network-blocked WebView, for export (`JvHtmlToPdf.kt`).
- **Structured, Privacy-Safe Logging**:
  - `AppLogger` (`app_logger.dart`) is the app's only logging entry point, wrapping the `logger` package. Console output only — no log files, so logs are not an extra place for journal content to leak.
  - Prod builds emit info-level logs and above; dev builds also emit trace/debug, gated by `AppFlavorConfig.enableVerboseLogging`.
  - Hard rule: never log journal titles, entry text, attachment names or bytes, PINs, passwords, key material, or decrypted content. A `redact()` helper masks a value to just its length when a diagnostic needs to tell empty from non-empty without exposing content.
- **Zero-Telemetry Offline Security Guarantee**:
  - `INTERNET` permission explicitly stripped from production Android manifests for complete offline data isolation and prevention of external data leakage.
- **Disclosed Gaps (tracked in `docs/architecture.md` section 21)**:
  - No "Delete all data" action exists yet anywhere in the app.
  - The SQLite database and its FTS index are **not** encrypted at rest — only attachments carry AES-256-GCM encryption today.
  - The attachment crypto format does not yet carry a version byte.
  - No release keystore yet — release builds still fall back to the Android debug signing key.
  - No retention caps on entry revisions, security events, or sync logs — these tables grow unbounded.
  - `ACCESS_NETWORK_STATE` and `WAKE_LOCK` permissions arrive transitively and go unused; only `INTERNET` is stripped from production manifests today.
  - The Home tab has no error/retry state for failed loads.

## 2. Rich Text Authoring & Knowledge Management
- **Flutter Quill Rich Text Editor**:
  - Full rich text formatting toolbar: Bold, Italic, Underline, Strikethrough, Headings (H1, H2, H3), Bulleted & Numbered Lists, Blockquotes, Inline Code, Code Blocks, Font Colors, Background Colors, and Text Alignment (`entry_editor_screen.dart`, `editor_toolbar.dart`).
- **Custom Quill Embed Blocks**:
  - **Grid Tables Embed**: Interactive grid table insertion, row/column operations, and inline editing (`table_embed.dart`).
  - **Callout / Admonition Embed**: Styled callout boxes for notes, warnings, tips, and highlights with custom icons (`callout_embed.dart`).
  - **Voice Note Embed**: Embedded voice recordings inline within journal entries with playback controls.
- **Voice Recording & Live Speech-to-Text (STT)**:
  - In-app audio recording powered by `record` package (`voice_note_recorder.dart`).
  - Integrated live speech recognition via `speech_to_text` for auto-transcribing voice notes directly into editable entry text (`voice_note_service.dart`, `VoiceNotes` table).
  - AES-256-GCM encryption applied to all voice recording audio files.
- **Entry Version History & Snapshot Restoration**:
  - Automatic snapshot saving of entry title, Quill JSON document state, and plain text on every edit (`EntryRevisions` table, `entry_revision_service.dart`).
  - Revision history screen displaying chronological snapshot list with text diffing and non-destructive snapshot restoration (`version_history_screen.dart`).
- **Customizable Journal Templates & Chooser**:
  - Category-grouped template picker dialog (`_EntryTemplateChooserDialog`) with pre-packaged ready-to-use templates: Daily Journal / Reflection, Travel Log, Meeting Notes, Gratitude Journal, and Mood Tracker (`entry_templates.dart`).
- **1-5 Scale Entry Mood Rating Picker**:
  - Inline discrete mood rating row (`_MoodPickerRow`) with emoji indicators (😞 1, 🙁 2, 😐 3, 🙂 4, 😄 5) persisted to `EntryMoods` table.
- **Wiki-Style Backlinks & Knowledge Inter-connections**:
  - Double-bracket syntax support (`[[Entry Title]]` and `[[entry:N]]`) for creating inter-linked knowledge nodes (`vault_backlink_parser.dart`, `vault_backlinks.dart`, `Backlinks` table).
  - Automated backlink extraction allowing bidirectional navigation across entries.
- **Inbound "Linked From" References Panel**:
  - Interactive reference panel (`_LinkedFromPanel`) rendered at the bottom of the editor displaying all entries linking to the current entry, allowing 1-tap navigation.
- **Contextual Formatting Context Menu**:
  - Custom text selection context menu with formatting actions (Bold, Italic, Underline, Strikethrough) positioned dynamically to avoid overlapping the top editor toolbar (`_adjustedSelectionAnchors`).

## 3. Media Attachments & Secure Viewers
- **Wide Media & Document Format Support**:
  - Import and attachment handling for PDF files, Audio recordings (MP3, M4A, WAV, AAC, OGG), Images, Documents, and Archives (ZIP, 7z) (`Attachments` table).
  - Only PDF, audio, and `.zip` render in a built-in viewer. Images and other document types still open with one tap, same as `.7z`, but via the device's external app chooser rather than an in-app viewer. The in-app-vs-external-app decision is made by `attachment_open_router.dart` (`AttachmentOpenRouter`).
  - Attachment file selection is abstracted behind `attachment_picker_service.dart` (`AttachmentPickerService`), implemented by `file_picker_attachment_picker_service.dart`.
- **Entry Attachment Tray**:
  - Editor attachment tray (`_AttachmentTray`) listing attachments with size, type, preview icon, 1-tap open, and individual lock/unlock buttons.
  - Attachment import and open sessions are managed by `attachment_open_service.dart` (`AttachmentImportService`, `AttachmentOpenService`).
- **Built-in In-App Secure Viewers**:
  - **Shared Viewer Host Screen**: `attachment_viewer_screen.dart` decrypts the attachment to a temporary file, owns that file's lifecycle, and dispatches to the matching viewer body below. The decrypted plaintext is deleted as soon as the viewer is closed.
  - **PDF Viewer Screen**: Embedded Syncfusion PDF Viewer (`pdf_attachment_view.dart`) for viewing encrypted PDFs securely in-memory without dumping unencrypted files to public storage.
  - **Audio Player Screen**: Integrated audio player (`audio_attachment_view.dart`, `just_audio`) featuring play/pause, seek bar, duration timer, and waveform visualizer.
  - **Archive Browser Screen**: In-app tree browser for encrypted `.zip` archives (`archive_attachment_view.dart`); `.7z` archives are handed off to an external app rather than browsed in-app.
- **Secure Temporary File Management**:
  - Isolated temporary file cache with automatic cleanup upon viewer exit to prevent orphaned unencrypted files (`attachment_temp_file_manager.dart`).
- **Attachment Storage Location Migration Engine**:
  - Dynamic storage migration engine for transferring encrypted attachment directory between App-Private Internal Storage (`app_private`) and External Storage / SD Card (`sd_card`) via Storage Access Framework (SAF) (`attachment_storage_migration_service.dart`, `attachment_storage_picker.dart`, `AppSettings` table).
  - Real-time progress updates, `.migrating` temp document cleanup, integrity check verification, error recovery, and failure logging.
  - User-cancellable: the in-progress migration dialog can be cancelled mid-run.

## 4. Search, Smart Tags & Multi-Criteria Filtering
- **Combined Search Screen**:
  - Single search tab returning matching journals and matching entries side by side for one typed query, with an entries-only filter toggle (`_SearchTab`, `app.dart`).
  - Entries belonging to a still-locked journal are excluded from results unless that journal has been session-unlocked.
- **SQLite FTS5 Full-Text Search Engine**:
  - Dual FTS5 virtual tables (`entries_fts` and `attachment_text_fts`) with automatic database triggers (`AFTER INSERT`, `AFTER DELETE`, `AFTER UPDATE`) for real-time index synchronization (`app_database.dart`).
  - Indexed full-text search over entry titles, body text, and extracted attachment content.
  - FTS text extraction pipeline for plain text (`.txt`), PDF (`.pdf`), Markdown (`.md`), and CSV (`.csv`) files (`AttachmentTexts` table).
  - Sanitized token processing wrapping search queries in quotes for literal matching.
- **Search Presets & Saved Filters**:
  - Save complex search queries and filter configurations as reusable search presets (`SearchPresets` table, `search_providers.dart`).
- **Smart Tags & Tag Management**:
  - Tag creation, assignment, and management for journals (`JournalTags`) and individual entries (`EntryTags`, `Tags` tables).
  - Smart Tag Chip Bar providing quick tag filtering, live auto-completion based on editor content, and usage statistics (`smart_tag_chip_bar.dart`, `smart_tag_service.dart`).
  - Tag colours: each tag carries an optional ARGB colour (`Tags.colorArgb`). When none is set, a colour is derived from a stable hash of the tag name, so every tag looks distinct without any setup (`tag_colors.dart`).
  - Tag manager screen reached from the Home app bar — lists every tag, and renames, recolours or deletes one. Deleting also clears its journal and entry links (`tag_manager_screen.dart`).
- **Multi-Criteria Filtering & Sorting**:
  - Filter entries by text query, date range, journal, tag, 1-5 scale mood rating, lock status, and attachment presence.

## 5. Timeline, Calendar & Insights Platform
- **Chronological Timeline View**:
  - Streamlined timeline feed displaying entries ordered by date with month headers and quick jump controls (`timeline_screen.dart`).
- **Calendar Entry Navigator**:
  - Integrated `table_calendar` widget (`_Calendar`) for viewing entry density, writing activity heatmaps, and mood distribution on a monthly calendar grid.
- **Analytics & Insights Engine**:
  - Comprehensive dashboard calculating total word counts, writing consistency streaks, entry frequency analytics, mood trend charts, tag heatmaps, memories, and weekly reflections (`insights_screen.dart`, `insights_service.dart`).
- **"On This Day" Memory Resurfacing Engine**:
  - Card (`_MemoriesCard`) resurfacing entries written on the exact month and day in previous years (`MemoryEntry`), showing years-ago badges (`1y`, `2y`, etc.), title, and content snippet.
- **Weekly Reflection Summary**:
  - Automated weekly report card (`_WeeklyReflectionCard`) compiling weekly date range, total entry count, total word count written, average mood rating, top used tags, and active streak info (`WeeklyReflection`).
- **Interactive Mood Trends Chart**:
  - 30-day daily mood trend bar chart (`_MoodChart`) with color-coded sentiment visualization (Green for high, Orange for medium, Red for low), tooltips, and daily entry density indicators.
- **Tag Usage Heatmap**:
  - Heatmap card (`_TagHeatmapCard`) displaying tag usage frequency with intensity-based background shading (`TagFrequency`).
- **Writing Consistency Streak Counter**:
  - Card (`_StreakCard`) calculating current consecutive daily writing streak and historical longest streak (`StreakInfo`).

## 6. Document Import, Export & Backup Management
- **Multi-Format Document Import Adapters**:
  - Flexible import adapter system accepting external document files (`import_screen.dart`, `import_service.dart`), built on a shared `import_adapter.dart` base interface implemented by each concrete adapter:
    - **Markdown Import Adapter**: Parses frontmatter YAML metadata, headers, formatting, and body text (`markdown_import_adapter.dart`).
    - **Microsoft Word Import Adapter**: Extracts document text and structure from `.docx` files (`docx_import_adapter.dart`).
    - **Plain Text Import Adapter**: Direct `.txt` file import into journal entries (`plain_text_import_adapter.dart`).
  - Target journal picker and detailed per-file import result reporting (`ImportFileResult`).
- **Entry & Journal Export** (`export_screen.dart`, `export_service.dart`):
  - Four formats: **Markdown** (`.md`), **HTML** (`.html`), **Plain Text** (`.txt`), and **PDF** (`.pdf`).
  - Three scopes: a single entry, a whole journal, or a date range within a journal (both end days inclusive).
  - Reachable from three places: the entry editor app bar, the journal detail app bar, and Settings → Export Data.
  - Optional attachment export — decrypted copies of files and voice-note audio are placed in an `attachments/` folder inside the bundle.
  - Optional per-entry metadata header (date, tags, 1-5 mood rating with its note).
  - Output is a single file when only one file is produced, otherwise a `.zip` bundle laid out as `entries/`, `attachments/`, and a `README.txt` describing the export. Saved through the system save dialog, so no storage permission is requested and a Malayalam file name survives intact.
  - Custom Quill embeds are converted rather than dropped: **tables** become Markdown pipe tables / HTML `<table>` / aligned fixed-width text, and **callouts** become labelled blockquotes / styled `<div>` boxes. An embed type this build does not know is written out as a named placeholder, never silently lost.
  - Voice notes are listed after the entry body with their duration, and their **transcript is written out as text** whether or not the audio itself is included.
  - **PDF rendering** goes through a native on-window Android WebView (`JvHtmlToPdf.kt`, `html_pdf_service.dart`) fed a self-contained HTML page with **Noto Sans Malayalam embedded as base64 `@font-face` data URIs**. Malayalam therefore shapes correctly (chillu, conjuncts, reordered vowel signs) and the PDF text stays real and selectable. The page contains no URL and the WebView blocks network loads, so export is fully offline. Ported from `SreerajP_lyricchord`. PDF is Android-only; where the renderer is absent the option is shown disabled with a reason, and the other three formats still work.
  - **Security rules:** a locked journal is never offered in the Settings picker (it must be unlocked on its own screen first), and a **locked attachment is never decrypted or written out** — it is named in the export and reported to the user instead. Each decrypted temporary file is deleted immediately after it is copied. Every export writes an `export_attempt` row to `SecurityEvents` recording the scope, format, and entry count — never any entry content.
  - **Optional password protection** (`vault_envelope.dart`, `vault_payload.dart`): a "Protect with a password" switch, off by default, seals the finished file with the **same** envelope the backup archive uses — AES-256-GCM under an Argon2id key, random salt, cost settings written into the file. The real file name and format ride inside the sealed bytes in a `JVP1` payload header, and the file is offered as `journal_export_<date>.jvenc`, because a name like `Leaving my job.md.jvenc` would give away what the password hides. Minimum 8 characters, typed twice.
  - **Opening a sealed export again** (`open_encrypted_export_screen.dart`): Settings → "Open an encrypted export" picks the file, asks for the password, and saves what was inside under its original name. It only unwraps the file — it never writes anything back into the vault.
  - **Without that switch the exported file is not encrypted.** The screen says so in plain words before the user exports, and requires an explicit confirmation; `security.md` records it as an accepted, deliberate property of the feature.
- **Backup Scheduler & Backup Health Dashboard**:
  - Manual and background scheduled backup creation (`backup_scheduler.dart`, `backup_service.dart`).
  - Compression and archive generation covering database snapshots and encrypted attachments.
  - Backup retention policy automatically keeping up to 50 backup logs.
  - Backup health monitoring screen displaying past backup logs, execution status (`success`, `failed`, `in_progress`), trigger type (`manual`, `scheduled`), file size, entry/attachment counts, and diagnostic error logs (`backup_health_screen.dart`, `BackupLogs` table).
- **One-Tap Encrypted Backup Creation And Restore**:
  - Baseline encrypted database and media export for secure offline data backup.
  - **Restore from a backup** (built 2026-08-18, A4.1) — `restore_backup_screen.dart`, `backup_restore_service.dart`. The screen previews what an archive holds before anything is written, restores it as a **replace** or a **merge**, and can dry-run either. It sits behind the app PIN, or the device credential when no PIN is set.
  - Safety order on a restore: password → archive format and database schema version check (a newer archive is refused rather than half-read) → structure check → optional dry run → an automatic pre-restore backup before a replace → one database transaction → search index rebuild → `PRAGMA integrity_check`. A failed restore rolls back and leaves nothing behind.
  - Archive **format version 2** stores attachment and voice-note files as plain bytes inside the encrypted container and re-encrypts them with the receiving device's Keystore key on the way in, so a backup restores onto a **new phone**. Version 1 archives still open, and are still tied to the device that wrote them.
  - The archive itself is sealed by the same `VaultEnvelope` an encrypted export uses — AES-256-GCM under an Argon2id key, random salt, cost settings written into the file.

## 7. Multi-Device Encrypted Sync Engine & Conflict Resolution
> **Currently disabled.** The engine, encryption, and conflict-resolution logic below are built
> and tested, but the UI is hidden behind `AppFlavorConfig.enableSyncUi` (`false`) because
> `SyncProtocol` has no concrete transport yet — there is no way to actually push or pull data
> between devices today. See `docs/architecture.md` section 21, "Still open — sync has no
> transport".
- **Vector Clock Sync Engine**:
  - Offline-first sync metadata tracking with deterministic UUID v5 sync IDs and per-record version counters (`SyncMetadata` table, `sync_engine.dart`, `sync_id_generator.dart`).
- **End-to-End Sync Encryption**:
  - AES-GCM payload encryption for sync records before transport (`sync_encryption_service.dart`, `sync_protocol.dart`).
- **Visual Conflict Resolution UI**:
  - Side-by-side conflict comparison interface for user-driven resolution of concurrent local vs. remote edits (keep local, keep remote, merge) (`conflict_resolution_screen.dart`, `SyncConflicts` table, `conflict_resolution_service.dart`).
- **Sync Health & Status Dashboard**:
  - Live status indicator widget, sync health dashboard UI, and sync execution logging (`sync_health_dashboard.dart`, `sync_status_widget.dart`, `SyncLogs` table).

## 8. App Architecture, Navigation & User Experience
- **Material Design 3 App Shell & Navigation**:
  - Modern `NavigationBar` layout with bottom tabs (Home/Entries, Search, Timeline, Insights, Settings) and smooth page transitions (`app.dart`).
- **Journal Library & Management (Home Tab)**:
  - Grid of journal cards (`_HomeTab`, `_JournalCard`) showing a cover-color background, entry count, "last updated" relative-time label (Today / Yesterday / Nd ago / Nw ago / Nmo ago / Ny ago), and a lock badge for password-protected journals.
  - Create / edit journal dialog (`_JournalFormDialog`) with a title, description, comma-separated tags, and (on creation only) an option to lock the new journal behind a password.
  - Delete journal with confirmation, cascading removal of the journal's tags and entries.
  - Empty state prompting the user to create their first journal.
  - Journal detail screen (`_JournalDetailScreen`): chronological list of the journal's entries, a password unlock gate for locked journals (session-scoped unlock), and an "Add entry" FAB that opens the entry template chooser before creating a new entry.
- **Unified Settings Screen**:
  - Single Settings tab (`_SettingsTab`) organized into five sections: Security (lock mode, auto-lock timeout, attachment-level lock, security events, and two "Coming soon" placeholders for Tamper Alerts and — when sync UI is disabled — Sync Conflicts), Appearance (theme), Storage (attachment location, migration, backup health, import, and — when sync UI is disabled — a "Coming soon" Sync Health placeholder), Permissions, and About.
- **Light & Dark Theme System**:
  - Curated Light and Dark Material 3 color schemes with persistent state control (`theme_mode_controller.dart`, `_themeModeProvider`).
- **Permissions Management Center**:
  - Dedicated transparency screen for auditing and granting the storage-related runtime permissions the app actually uses today — attachment import and document picking (`AppPermissionId.attachmentImport`, `AppPermissionId.documentPicker`) — with clear rationale and status indicators (`permissions_screen.dart`, `app_permissions_service.dart` / `AppPermissionsService`, `permission_handler_app_permissions_service.dart`).
- **Production Standard About Screen**:
  - Standardized about interface loading metadata from bundled asset config (`assets/config/app_config.json`), presenting app name, version (`1.0.1+1`), author, AI development tools used, IDE, build timestamp, and license declarations (`about_screen.dart`, `about_metadata.dart`).
- **Dev/Prod Build Flavors**:
  - Android `productFlavors` (`dev`, `prod`) under the `env` flavor dimension (`android/app/build.gradle.kts`), each with a distinct app label ("sreerajp_journal_vault (dev)" vs. "sreerajp_journal_vault") so the two builds are never confused on-device.
  - `AppFlavorConfig` (`app_flavor_config.dart`) is the single compile-time source of truth for the resolved flavor, read from `--dart-define=APP_FLAVOR` or the framework's `FLUTTER_APP_FLAVOR`, defaulting to `prod`. It gates verbose logging today (`enableVerboseLogging`) and is also the switch point for `enableSyncUi` (Section 7).
- **Compile-Safe Architecture & DAOs**:
  - Built with Riverpod 2.x state management and Drift SQLite ORM featuring 20 specialized DAOs (`JournalsDao`, `EntriesDao`, `TagsDao`, `AttachmentsDao`, `AttachmentTextsDao`, `BacklinksDao`, `BackupLogsDao`, `SearchPresetsDao`, `AppSettingsDao`, `AppSecurityDao`, `JournalTagsDao`, `EntryRevisionsDao`, `VoiceNotesDao`, `SyncMetadataDao`, `SyncConflictsDao`, `SyncLogsDao`, `AutoLockProfilesDao`, `AttachmentLocksDao`, `SecurityEventsDao`, `EntryMoodsDao`).

