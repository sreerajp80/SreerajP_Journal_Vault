# App Description: SreerajP Journal Vault (`sreerajp_journal_vault`)

`SreerajP_Journal_Vault` is a production-grade, security-hardened, privacy-first offline personal journal, diary, and knowledge vault application built with Flutter (3.44.8) and Dart (3.12.2) for Android (minimum API 28 / Android 9.0+). It is governed by three strict engineering profiles: **Core Baseline**, **Production App Extension**, and **Sensitive Data Extension**.

The application features a journal library home screen for creating, editing, and deleting journals (with tagging and optional password protection at creation time), full database-at-rest encryption via SQLCipher with keys held in the Android Keystore, window-wide `FLAG_SECURE` screen protection (blocking system screenshots, screen recording, and task switcher preview thumbnails, on by default and switchable off from Settings), hardware Keystore-backed AES-256-GCM attachment encryption, multi-mode app locking (Device Credential / Biometric lock vs. custom Keystore-hashed 6-digit PIN lock), granular journal-level password encryption (Argon2/PBKDF2 key derivation with Android Keystore native secret storage), fine-grained per-attachment security locks, rich text authoring with Flutter Quill, custom interactive Quill embeds (grid tables, callout admonitions, inline voice recordings, inline encrypted images, and interactive handwriting/drawing canvas blocks), on-device OCR text scanning with image crop and rotation, on-device speech-to-text dictation, entry version history snapshot restoration, built-in and user-created custom entry templates with dynamic date tokens and a dedicated template manager, a combined journal-and-entry search screen backed by a SQLite FTS5 full-text search engine indexing entries and extracted attachment content (.txt, .pdf, .md, .csv), saveable search presets and multi-criteria filtering (date range, journal, tag, mood, lock status, attachment presence), smart tag management with color coding and a dedicated tag manager screen, wiki-style double-bracket (`[[Entry Title]]`) backlinks with inbound "Linked From" reference discovery, multi-format document import adapters (Markdown with frontmatter parsing, Microsoft Word DOCX, Plain Text), entry and journal export to Markdown, HTML, plain text, and PDF (with Malayalam-correct, selectable PDF text rendered through a native offline WebView, optional decrypted attachment bundling, and an optional password that seals the exported file with the same versioned envelope the backup archive uses), incoming Android share intent integration with Quick Capture, background backup scheduler & health monitoring dashboard, restore from an encrypted backup archive with preview, replace-or-merge and dry-run modes, a user-cancellable attachment storage location migration engine (App-Private Storage <-> SD Card / External Storage via Storage Access Framework), a chronological timeline feed with a calendar entry navigator showing writing-activity and mood heatmaps, dynamic analytics & insight engine (word counts, writing streaks, 1-5 scale mood trends chart, tag heatmaps, "On This Day" memory resurfacing, automated weekly reflection summaries), a Daily Journaling Ritual flow with card flip animations and contemplation timer, built-in Sanathana Dharma thought prompt decks (localized in English and Malayalam) and custom prompt card creation, Time Capsules / future-dated sealed entries with countdown gates, local peer-to-peer Wi-Fi sync with ephemeral X25519 and AES-256-GCM end-to-end encryption, optical air-gapped AirQR synchronization using animated QR streams, integrated in-app secure viewers (PDF viewer, audio player with waveform visualizer, ZIP archive browser), auto-lock profiles with cron schedules and minimize locking, security audit event logging with a dedicated Tamper Alerts and vault integrity verification screen, full English and Malayalam bilingual localization, a unified modular Settings hub, built-in permissions transparency center, asset-configured About metadata, dev/prod build flavors with flavor-gated verbose logging, a console-only structured logger that redacts sensitive content by policy, and an offline-first architecture with zero telemetry and no network permission requirement in production.

---

# Implemented Features

## 1. Security, Privacy & Data Protection (Sensitive Data Extension)
- **Database Encrypted at Rest with SQLCipher**:
  - Full-database encryption at rest using SQLCipher via native build hooks (`package:sqlite3`), securing all journal titles, entry text, metadata, revisions, moods, ritual cards, time capsules, and FTS5 full-text search indexes (`app_database.dart`).
  - Database encryption key generated from 32 `SecureRandom` bytes stored directly in the Android Keystore and passed as a raw key to SQLCipher.
- **FLAG_SECURE Window Screen Protection**:
  - Full-window screenshot and screen recording prevention via Android `WindowManager.LayoutParams.FLAG_SECURE` enforced natively in `MainActivity.kt`.
  - Prevents system task switcher snapshot caching and unauthorized visual screen captures across all application views.
  - **User-controlled "Block Screenshots" switch** in Settings → Security, on by default. Turning it off shows a warning dialog first, applies to the live window at once, survives a restart (native `screen_security` SharedPreferences read in `onCreate`), and is recorded in the security event log as `screen_security_changed`.
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
  - All binary attachments (images, PDFs, audio recordings, documents, archives, drawings) stored outside the database are encrypted at rest with AES-256-GCM (`attachment_crypto_storage.dart`, `attachment_key_manager.dart` / `AttachmentKeyManager`).
  - Key wrapping managed via native Android Keystore channel (`sreerajp.journal_vault/attachment_keys`) with master key alias `sreerajp_journal_vault_attachment_wrap_v1`.
- **Attachment-Level Fine-Grained Locks**:
  - Per-attachment access control requiring re-authentication before decrypting or exporting specific confidential media files (`attachment_lock_service.dart`, `AttachmentLocks` table, `_LockedAttachmentsScreen`).
- **Auto-Lock Profiles & Inactivity Management**:
  - Custom inactivity timeout rules (immediate lock on background/minimize, 30s, 1m, 5m, 15m) driven by `AppLockController`.
  - Configurable scheduled cron-like lock policies (`AutoLockProfiles` table, `auto_lock_service.dart`, `auto_lock_profiles_screen.dart`).
- **Security Audit Logging & Tamper Alerts**:
  - Comprehensive audit logging of security-relevant events (failed authentication attempts, lock triggers, tamper alerts, lock mode changes, export attempts, attachment access) with severity classification (`info`, `warning`, `critical`) (`security_event_service.dart`, `SecurityEvents` table).
  - UI audit viewer for inspecting security event history and diagnostic logs (`security_events_screen.dart`).
  - **Tamper Alerts & Vault Integrity Screen (`TamperAlertsScreen`)**: Dedicated screen under Settings → Security showing live vault integrity status, on-demand integrity verification across all journals and entries, educational explanation of security boundaries, and logged tamper events.
- **Native Android Method Channels**:
  - `sreerajp.journal_vault/attachment_keys`: Native Keystore key wrapping for attachments.
  - `sreerajp.journal_vault/attachment_storage`: SAF tree picker and file operations.
  - `sreerajp.journal_vault/journal_lock`: Keystore-backed journal password secret store.
  - `sreerajp.journal_vault/app_pin_lock`: Keystore-backed PIN verifier storage.
  - `sreerajp.journal_vault/runtime_environment`: Query Android SDK version (`getAndroidSdkInt`).
  - `sreerajp.journal_vault/html_pdf`: Renders a self-contained local HTML page to PDF bytes in an off-screen, network-blocked WebView, for export (`JvHtmlToPdf.kt`).
  - `sreerajp.journal_vault/share_intent`: Receives inbound shared text, files, and encrypted archives from the Android system share sheet.
- **Structured, Privacy-Safe Logging**:
  - `AppLogger` (`app_logger.dart`) is the app's only logging entry point, wrapping the `logger` package. Console output only — no log files, so logs are not an extra place for journal content to leak.
  - Prod builds emit info-level logs and above; dev builds also emit trace/debug, gated by `AppFlavorConfig.enableVerboseLogging`.
  - Hard rule: never log journal titles, entry text, attachment names or bytes, PINs, passwords, key material, or decrypted content. A `redact()` helper masks a value to just its length when a diagnostic needs to tell empty from non-empty without exposing content.
- **Zero-Telemetry Offline Security Guarantee**:
  - `INTERNET`, `ACCESS_NETWORK_STATE`, and `WAKE_LOCK` permissions explicitly stripped from production Android manifests using `tools:node="remove"` for complete offline data isolation, guarded by automated unit tests and CI checks.
- **Disclosed Gaps (tracked in `docs/architecture.md` section 21)**:
  - No "Delete all data" action exists yet anywhere in the app.
  - The attachment crypto format does not yet carry a version byte.
  - No release keystore yet — release builds still fall back to the Android debug signing key.
  - No retention caps on entry revisions or security events — these tables grow unbounded.
  - The Home tab has no error/retry state for failed loads.

## 2. Rich Text Authoring & Knowledge Management
- **Flutter Quill Rich Text Editor**:
  - Full rich text formatting toolbar: Bold, Italic, Underline, Strikethrough, Headings (H1, H2, H3), Bulleted & Numbered Lists, Blockquotes, Inline Code, Code Blocks, Font Colors, Background Colors, and Text Alignment (`entry_editor_screen.dart`, `editor_toolbar.dart`).
- **Custom Quill Embed Blocks**:
  - **Grid Tables Embed**: Interactive grid table insertion, row/column operations, and inline editing (`table_embed.dart`).
  - **Callout / Admonition Embed**: Styled callout boxes for notes, warnings, tips, and highlights with custom icons (`callout_embed.dart`).
  - **Voice Note Embed**: Embedded voice recordings inline within journal entries with playback controls.
  - **Inline Images Embed**: Embedded images inside the rich text flow with small / medium / full-width sizing options and tap-to-open full-screen preview (`image_embed.dart`, `inline_image_store.dart`). Backed by encrypted attachments.
  - **Drawing & Handwriting Canvas Embed**: Embedded interactive sketches and handwritten notes (`drawing_embed.dart`). Interactive drawing canvas featuring Pen, Highlighter (semi-transparent blending), Eraser, 10-color palette, 4 stroke widths (Fine, Normal, Thick, Bold), and 4 paper background patterns (Blank, Ruled lines, Square grid, Dot grid). Rendered image is stored as an AES-256-GCM encrypted PNG attachment with vector stroke data preserved for lossless in-place re-editing (`drawing_canvas.dart`).
- **On-Device OCR Text Scanner & Document Capture**:
  - In-editor camera capture and gallery photo picker with integrated image cropping and 90-degree rotation tools (`ocr_crop_rotate_screen.dart`).
  - On-device text recognition powered by Google ML Kit (`ocr_scan_service.dart`), extracting text directly into the active editor position with zero network telemetry.
- **Image Editing & Annotation Pipeline**:
  - Image crop, 90-degree rotation, and aspect ratio adjustment before inserting captured or picked photos into journal entries (`image_edit_service.dart`, `ocr_crop_rotate_screen.dart`).
- **Editor Quality of Life**:
  - **Live Editor Stats Bar**: Real-time word and character counts in the editor toolbar, along with auto-save status indicators (`editor_stats_bar.dart`).
  - **Real-Time Markdown Shortcuts**: Instant Markdown prefix expansion while typing (`# `, `## `, `### ` for headings, `- `, `* `, `+ ` for bullet lists, `1. ` for numbered lists, `[] ` for checklists, `> ` for blockquotes, ```` ``` ```` for code blocks) (`editor_markdown_shortcuts.dart`).
  - **Distraction-Free Full-Screen Mode**: Toggle to hide toolbars and system UI for focused writing.
  - **Focus Paragraph Dimming**: Option to dim surrounding paragraphs, highlighting only the current active block of prose.
- **Voice Recording & On-Device Dictation (Speech to Text)**:
  - In-app audio recording powered by `record` package (`voice_note_recorder.dart`). Voice notes are audio only; older notes keep any transcript they already have.
  - Dictation button in the editor toolbar opens a sheet (`dictation_sheet.dart`) that turns speech into text at the caret. It keeps listening through pauses, shows the recogniser's live guess, can be paused, and lets the user edit the text before inserting it.
  - Recognition runs **on the device only** (`dictation_service.dart`, `speech_engine.dart`). If the phone has no on-device recogniser, dictation explains that and does nothing. No dictation audio is stored.
  - Language picker lists the offline languages the phone has installed, and remembers the choice. English and Malayalam work where the offline packs exist; Android has no offline Sanskrit recogniser.
  - AES-256-GCM encryption applied to all voice recording audio files.
- **Entry Version History & Snapshot Restoration**:
  - Automatic snapshot saving of entry title, Quill JSON document state, and plain text on every edit (`EntryRevisions` table, `entry_revision_service.dart`).
  - Revision history screen displaying chronological snapshot list with text diffing and non-destructive snapshot restoration (`version_history_screen.dart`).
- **Customizable Entry Templates & Template Manager**:
  - **Built-in General & Domain Templates**: Daily Journal, Travel Log, Meeting Notes, Gratitude Journal, Mood Tracker, Dream Journal, Book/Movie Review, Project Post-Mortem, and Habit Tracker (`entry_templates.dart`).
  - **Collapsible Template Chooser Dialog**: Organized category-based template picker modal (`entry_template_chooser_dialog.dart`).
  - **Custom User Templates**: Create, edit, and delete custom reusable templates with starter rich text content and default titles (`UserTemplates` table, `user_templates_dao.dart`, `template_editor_screen.dart`).
  - **Dynamic Date/Time Tokens**: Automatic token substitution when applying templates: `{{today}}`, `{{weekday}}`, `{{date}}`, `{{time}}`, `{{year}}`, `{{month}}`, `{{day}}` (`template_token_engine.dart`).
  - **Template Management Screen**: Dedicated management interface (`template_manager_screen.dart`) accessible from Settings and the template chooser dialog.
  - **Save Entry as Template**: Save any existing journal entry directly as a new custom template from the editor app bar menu.
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
  - Built-in in-app viewers for PDF, audio, and `.zip` archives. Images, `.7z`, and other documents open securely via external app chooser (`attachment_open_router.dart`).
  - Attachment file selection abstracted behind `attachment_picker_service.dart` (`AttachmentPickerService`).
- **Entry Attachment Tray**:
  - Editor attachment tray (`_AttachmentTray`) listing attachments with size, type, preview icon, 1-tap open, and individual lock/unlock buttons.
  - Attachment import and open sessions managed by `attachment_open_service.dart` (`AttachmentImportService`, `AttachmentOpenService`).
- **Built-in In-App Secure Viewers**:
  - **Shared Viewer Host Screen**: `attachment_viewer_screen.dart` decrypts the attachment to a temporary file, owns that file's lifecycle, and dispatches to the matching viewer body below. The decrypted plaintext is deleted as soon as the viewer is closed.
  - **PDF Viewer Screen**: Embedded PDF Viewer (`pdf_attachment_view.dart`, `pdfrx`) for viewing encrypted PDFs securely without dumping unencrypted files to public storage.
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
  - Dual FTS5 virtual tables (`entries_fts` and `attachment_text_fts`) with automatic database triggers (`AFTER INSERT`, `AFTER DELETE`, `AFTER UPDATE`) for real-time index synchronization (`app_database.dart`). Encrypted at rest under SQLCipher.
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

## 6. Document Import, Export, Share & Backup Management
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
  - Optional attachment export — decrypted copies of files, drawings, and voice-note audio are placed in an `attachments/` folder inside the bundle.
  - Optional per-entry metadata header (date, tags, 1-5 mood rating with its note).
  - Output is a single file when only one file is produced, otherwise a `.zip` bundle laid out as `entries/`, `attachments/`, and a `README.txt` describing the export. Saved through the system save dialog, so no storage permission is requested and a Malayalam file name survives intact.
  - Custom Quill embeds are converted rather than dropped: **tables** become Markdown pipe tables / HTML `<table>` / aligned fixed-width text, **callouts** become labelled blockquotes / styled `<div>` boxes, **inline images and drawings** are embedded as HTML `<img>` / Markdown image links / text labels. An unknown embed is written out as a named placeholder, never silently lost.
  - Voice notes are listed after the entry body with their duration, and their **transcript is written out as text** whether or not the audio itself is included.
  - **PDF rendering** goes through a native on-window Android WebView (`JvHtmlToPdf.kt`, `html_pdf_service.dart`) fed a self-contained HTML page with **Noto Sans Malayalam embedded as base64 `@font-face` data URIs**. Malayalam therefore shapes correctly (chillu, conjuncts, reordered vowel signs) and the PDF text stays real and selectable. The page contains no URL and the WebView blocks network loads, so export is fully offline. Ported from `SreerajP_lyricchord`. PDF is Android-only; where the renderer is absent the option is shown disabled with a reason, and the other three formats still work.
  - **Security rules:** a locked journal is never offered in the Settings picker (it must be unlocked on its own screen first), and a **locked attachment is never decrypted or written out** — it is named in the export and reported to the user instead. Each decrypted temporary file is deleted immediately after it is copied. Every export writes an `export_attempt` row to `SecurityEvents` recording the scope, format, and entry count — never any entry content.
  - **Optional password protection** (`vault_envelope.dart`, `vault_payload.dart`): a "Protect with a password" switch, off by default, seals the finished file with the **same** envelope the backup archive uses — AES-256-GCM under an Argon2id key, random salt, cost settings written into the file. The real file name and format ride inside the sealed bytes in a `JVP1` payload header, and the file is offered as `journal_export_<date>.jvenc`, because a name like `Leaving my job.md.jvenc` would give away what the password hides. Minimum 8 characters, typed twice.
  - **Opening a sealed export again** (`open_encrypted_export_screen.dart`): Settings → "Open an encrypted export" picks the file, asks for the password, and saves what was inside under its original name. It only unwraps the file — it never writes anything back into the vault.
  - **Without that switch the exported file is not encrypted.** The screen says so in plain words before the user exports, and requires an explicit confirmation; `security.md` records it as an accepted, deliberate property of the feature.
- **Inbound Share Intent & Quick Capture Integration**:
  - Intent filters configured for `ACTION_SEND` (plain text, images, generic files), `ACTION_SEND_MULTIPLE` (multiple images and attachments), and `ACTION_VIEW` (`.jvenc` and `.jvbk` encrypted archives) (`MainActivity.kt`, `share_intent_receiver.dart`).
  - **Quick Capture Dialog**: Interactive modal presented on inbound share allowing journal destination selection, title and body editing, attachment thumbnail preview, and immediate saving to the vault or routing to the full rich-text editor.
  - Standalone `.jvenc` encrypted exports and `.jvbk` backup archives shared into the app route directly to their respective decryption and viewer screens.
- **Backup Scheduler & Backup Health Dashboard**:
  - Manual and background scheduled backup creation (`backup_scheduler.dart`, `backup_service.dart`).
  - Compression and archive generation covering database snapshots and encrypted attachments.
  - Backup retention policy automatically keeping up to 50 backup logs.
  - Backup health monitoring screen displaying past backup logs, execution status (`success`, `failed`, `in_progress`), trigger type (`manual`, `scheduled`), file size, entry/attachment counts, and diagnostic error logs (`backup_health_screen.dart`, `BackupLogs` table).
- **One-Tap Encrypted Backup Creation And Restore**:
  - Baseline encrypted database and media export for secure offline data backup.
  - **Restore from a backup** (`restore_backup_screen.dart`, `backup_restore_service.dart`): Previews what an archive holds before anything is written, restores it as a **replace** or a **merge**, and can dry-run either. Gated behind the app PIN, or the device credential when no PIN is set.
  - Safety order on a restore: password → archive format and database schema version check (a newer archive is refused rather than half-read) → structure check → optional dry run → an automatic pre-restore backup before a replace → one database transaction → search index rebuild → `PRAGMA integrity_check`. A failed restore rolls back and leaves nothing behind.
  - Archive **format version 2** stores attachment and voice-note files as plain bytes inside the encrypted container and re-encrypts them with the receiving device's Keystore key on the way in, so a backup restores onto a **new phone**. Version 1 archives still open, and are still tied to the device that wrote them.
  - The archive itself is sealed by the same `VaultEnvelope` an encrypted export uses — AES-256-GCM under an Argon2id key, random salt, cost settings written into the file.

## 7. Daily Journaling Ritual & Thought Prompt Cards (C9 Ritual Mode)
- **Mindful Journaling Ritual Flow**:
  - Dedicated daily ritual experience (`ritual_screen.dart`) accessible from the Home app bar and Settings.
  - Multi-step guided routine:
    1. **Atmosphere Selection & Mindful Breathing**: Calming visual environment with a dedicated contemplation timer.
    2. **Daily Thought Card Reveal**: Interactive 3D card flip animation revealing a daily philosophical or introspective prompt.
    3. **Start Journaling from Prompt**: One-tap action to create a new entry with the selected prompt, theme, and context pre-filled into the rich-text editor.
- **Curated Sanathana Dharma Thought Cards Deck**:
  - Built-in prompt deck rooted in classical Indian philosophy, Vedic wisdom, Upanishads, Bhagavad Gita, and universal ethical reflections (`sanathana_dharma_cards.dart`).
  - **Bilingual Translations**: Fully localized prompts and descriptions in both English and Malayalam, matching the device language.
- **Custom Ritual Cards & Deck Manager**:
  - Deck browser (`ritual_deck_screen.dart`) displaying built-in and user-created prompt cards organized by category (Mindfulness, Wisdom, Gratitude, Self-Inquiry, Philosophy).
  - Custom card creator and editor (`create_ritual_card_screen.dart`, `UserRitualCards` table, `user_ritual_cards_dao.dart`) allowing users to compose personal prompt cards with custom questions, descriptions, categories, and card accent colors.

## 8. Encrypted Local Peer-to-Peer Wi-Fi Sync & Optical AirQR
- **Local Network Peer-to-Peer Wi-Fi Sync**:
  - Direct device-to-device synchronization over local Wi-Fi / LAN without cloud servers, external accounts, or Internet connectivity (`sync_landing_screen.dart`, `sync_host_screen.dart`, `sync_client_screen.dart`, `wifi_sync_transport.dart`).
  - **End-to-End Encryption**:
    - Ephemeral X25519 key exchange establishes a shared session secret for every sync handshake (`wifi_sync_crypto.dart`).
    - AES-256-GCM encrypted message protocol (`wifi_sync_protocol.dart`) guaranteeing forward secrecy and tampering protection across the local network transport.
  - **Interactive Conflict Resolution**:
    - UI screen (`conflict_resolution_screen.dart`) presenting side-by-side title, date, word count, and text previews for conflicting entry edits, with options to Keep Local, Keep Remote, or Keep Both.
  - **Sync Health & Diagnostic Monitoring**:
    - Sync health screen (`sync_health_dashboard.dart`, `SyncLogs` and `SyncMetadata` tables) reporting sync device history, timestamp records, transferred payload sizes, and diagnostic status logs.
- **Optical Air-Gapped AirQR Sync**:
  - Completely air-gapped data transfer using high-density animated QR code streams, requiring only screen display and camera capture (`airqr_landing_screen.dart`, `airqr_send_screen.dart`, `airqr_receive_screen.dart`).
  - 100% offline and optical — operates with zero radio emissions (Wi-Fi, Bluetooth, or cellular disabled).
  - Optical payload streaming with chunked frame serialization and progress tracking for transferring app settings, custom templates, ritual card decks, and selected journal entries.
  - Integrated payload size warnings and transmission safety estimates (`airqr_size_warning.dart`).

## 9. Time Capsules & Sealed Journal Entries
- **Time-Locked Future Journal Entries**:
  - Ability to seal any journal entry into a Time Capsule until a specified future date and time (`time_capsule_seal_dialog.dart`, `TimeCapsules` table, `time_capsules_dao.dart`, `time_capsule_service.dart`).
  - Locked entries are strictly sealed against viewing and editing until the target unlock timestamp is reached.
- **Sealed Entry Lock Gate**:
  - Dedicated sealed screen (`time_capsule_sealed_screen.dart`) displaying the entry title, creation date, unlock date, and a live countdown timer showing remaining days, hours, and minutes.
- **Time Capsules Hub Screen**:
  - Comprehensive view (`time_capsules_list_screen.dart`) accessible from Home and Settings listing all Sealed, Ready to Open, and Unlocked time capsules.
- **Platform Unlock Reminders**:
  - Local system notification triggers (`platform_notification_service.dart`) that notify the user when a sealed time capsule becomes ready to open.

## 10. App Architecture, Navigation & User Experience
- **Material Design 3 App Shell & Navigation**:
  - Modern `NavigationBar` layout with bottom tabs (Home/Entries, Search, Timeline, Insights, Settings) and smooth page transitions (`app.dart`).
- **Journal Library & Management (Home Tab)**:
  - Grid of journal cards (`_HomeTab`, `_JournalCard`) showing a cover-color background, entry count, "last updated" relative-time label (Today / Yesterday / Nd ago / Nw ago / Nmo ago / Ny ago), and a lock badge for password-protected journals.
  - Create / edit journal dialog (`_JournalFormDialog`) with a title, description, comma-separated tags, and (on creation only) an option to lock the new journal behind a password.
  - Delete journal with confirmation, cascading removal of the journal's tags and entries.
  - Empty state prompting the user to create their first journal.
  - Journal detail screen (`_JournalDetailScreen`): chronological list of the journal's entries, a password unlock gate for locked journals (session-scoped unlock), and an "Add entry" FAB that opens the entry template chooser before creating a new entry.
- **Unified Settings Screen**:
  - The Settings tab (`settings_tab.dart`) is organized into clean, modular cards — Security, Appearance, Storage, Features, Permissions, Help, and About.
  - Security page (`security_settings_screen.dart`): lock mode, auto-lock timeout, attachment-level lock, screenshot blocking, tamper alerts (`TamperAlertsScreen`), and security events.
  - **Appearance Hub (`appearance_screen.dart`)**:
    - **Theme Mode & Reading Surfaces (`theme_mode_settings_screen.dart`)**: Five distinct reading surfaces with live visual cards and instant persistence: Light (clean daylight paper), Paper / Sepia (warm parchment `#F8F3E6` background and espresso `#2C221E` ink), Dark (soft charcoal dark mode), OLED / True Black (pitch black `#000000` surface for AMOLED power savings), and System mode (`theme_mode_controller.dart`, `appThemeModeProvider`, `themeModeProvider`).
    - **Accent Color Picker (`accent_color_settings_screen.dart`)**: Real-time theme re-coloring with curated presets (Classic Amber, Terracotta Rust, Forest Emerald, Deep Sapphire, Regal Violet, Velvet Rose, Ocean Teal, Classic Slate), custom HSV color wheel, opacity/value slider, interactive live UI preview card, and one-tap reset to default (`accent_color_controller.dart`, `accentColorProvider`).
    - **Reading Typography (`typography_settings_screen.dart`)**: Custom body typography with font family selection (Sans-Serif / Modern, Book Serif / Literary, Monospace / Typewriter), font size slider and presets (12pt–24pt), live interactive journal preview card, and QuillEditor integration (`typography_controller.dart`, `typographyProvider`).
  - Storage page (`storage_settings_screen.dart`): attachment location, migration, storage usage, backup health, Wi-Fi P2P sync, AirQR optical sync, and document import.
  - **Features Catalog (`features_screen.dart`)**:
    - Categorized showcase of all capabilities across *Journaling & Rich Text Editor*, *Privacy, Encryption & Vault Security*, *Search, Timeline & Insights*, and *Storage, Backups & Multi-Format Export*.
  - Permissions page (`permissions_settings_screen.dart`): permissions status rows and direct system settings link.
  - **Help Center & Knowledge Base (`help_home_screen.dart`)**:
    - Comprehensive guide with 13 dedicated topic screens organized into 5 categories (*Writing & Journal Management*, *Security, Lock & Encryption*, *Search, Timeline & Insights*, *Storage, Backups & Export*, *Frequently Asked Questions & Troubleshooting*).
    - Modular guide architecture with `HelpIntro`, `HelpSection`, `HelpBullet`, and `HelpFooter` components (`help_components.dart`).
  - The About card opens the standardized `AboutScreen` directly.
- **Bilingual Localization (English & Malayalam)**:
  - Complete internationalization and localization using standard `flutter_localizations` and `intl` with ARB files (`lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`).
  - Over 800 synchronized translation keys covering all UI views, buttons, dialogs, error messages, features catalog, ritual cards, and all 13 help topic screens.
  - Seamlessly follows the system device language.
- **Enhanced Reading Themes & Typography System**:
  - Curated Light, Paper/Sepia, Dark, and OLED True Black Material 3 color schemes and body typography controls with persistent state control (`theme_mode_controller.dart`, `typography_controller.dart`).
- **Permissions Management Center**:
  - Dedicated transparency screen for auditing and granting runtime permissions used by the app — attachment import, document picking, camera (OCR/AirQR), and notifications (`AppPermissionsService`, `permissions_screen.dart`).
- **Production Standard About Screen**:
  - Standardized about interface loading metadata from bundled asset config (`assets/config/app_config.json`), presenting app name, version (`1.0.1+1`), author, AI development tools used, IDE, build timestamp, and license declarations (`about_screen.dart`, `about_metadata.dart`).
- **Dev/Prod Build Flavors**:
  - Android `productFlavors` (`dev`, `prod`) under the `env` flavor dimension (`android/app/build.gradle.kts`), each with a distinct app label ("sreerajp_journal_vault (dev)" vs. "sreerajp_journal_vault") so the two builds are never confused on-device.
  - `AppFlavorConfig` (`app_flavor_config.dart`) is the single compile-time source of truth for the resolved flavor, read from `--dart-define=APP_FLAVOR` or the framework's `FLUTTER_APP_FLAVOR`, defaulting to `prod`. It gates verbose logging today (`enableVerboseLogging`).
- **Compile-Safe Architecture & DAOs**:
  - Built with Riverpod 2.x state management and Drift SQLite ORM featuring 23 specialized DAOs (`JournalsDao`, `EntriesDao`, `TagsDao`, `AttachmentsDao`, `AttachmentTextsDao`, `BacklinksDao`, `BackupLogsDao`, `SearchPresetsDao`, `AppSettingsDao`, `AppSecurityDao`, `JournalTagsDao`, `EntryRevisionsDao`, `VoiceNotesDao`, `SyncMetadataDao`, `SyncConflictsDao`, `SyncLogsDao`, `AutoLockProfilesDao`, `AttachmentLocksDao`, `SecurityEventsDao`, `EntryMoodsDao`, `UserTemplatesDao`, `UserRitualCardsDao`, `TimeCapsulesDao`).
