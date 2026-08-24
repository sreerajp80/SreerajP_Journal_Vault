# Settings — Appearance, Features, and Help Cards

**Status:** completed

## The issue

The user asked to analyze `SreerajPContactSphere` (`L:\Android\SreerajPContactSphere` <!-- allow-abs-path -->) and, based on its **Appearance**, **Features**, and **Help** cards under Settings, build equivalent, high-quality Appearance, Features, and Help cards and dedicated screens for **SreerajP Journal Vault** under Settings.

Currently in SreerajP Journal Vault:
- **Appearance**: The card under Settings opens a minimal page with only Light / Dark choice chips. In ContactSphere, Appearance is a dedicated hub offering Theme Mode (Light / Dark / System segmented options with explainer), Accent Color (live preview, curated presets, HSV custom color wheel, contrast handling, reset), and Typography (font options and text scaling).
- **Features**: There is no Features card under Settings. In ContactSphere, a dedicated Features screen groups every feature into visual categories with icons, descriptive paragraphs, and highlight badge tags.
- **Help**: There is no Help card under Settings. In ContactSphere, a dedicated Help & User Guides screen groups all topic guides into sections, with in-depth help screens for each topic using structured sections (`_Intro`, `_Section`, `_Bullet`, `_Footer`).

## The plan

### 1. Settings tab enhancements (`lib/app/app.dart`)

Update `_SettingsTab` to include the complete set of cards with refined subtitles and modern styling matching the ContactSphere layout:
1. **Security**: `Icons.lock_outline` — "App lock, auto-lock timeout, screenshot guard, and audit log"
2. **Appearance**: `Icons.palette_outlined` — "Theme mode and accent color" -> opens `AppearanceScreen`
3. **Storage & Data**: `Icons.folder_outlined` — "Attachment location, usage, backup, and multi-format export"
4. **Features**: `Icons.stars_outlined` — "Explore all features of SreerajP Journal Vault" -> opens `FeaturesScreen`
5. **Permissions**: `Icons.verified_user_outlined` — "What the app can access and why"
6. **Help**: `Icons.help_outline` — "Guides, encryption details, and FAQs" -> opens `HelpHomeScreen`
7. **About**: `Icons.info_outline` — "Version, author, and build details"

### 2. Feature 1: Appearance Screen & Settings (`lib/features/appearance/`)

Create modular appearance settings:
- `lib/features/appearance/presentation/appearance_screen.dart`:
  - Card 1: **Theme Mode** (`Icons.brightness_6_outlined`) -> `ThemeModeSettingsScreen`
  - Card 2: **Accent Color** (`Icons.color_lens_outlined`) -> `AccentColorSettingsScreen`
- `lib/features/appearance/presentation/theme_mode_settings_screen.dart`:
  - Segmented button for Light / Dark / System mode
  - Info card explaining how System mode tracks the device dark mode
- `lib/features/appearance/presentation/accent_color_settings_screen.dart`:
  - Live preview chip with sample text and badge
  - Curated preset color swatches (e.g. Leather Amber, Warm Terracotta, Forest Emerald, Deep Sapphire, Regal Violet, Velvet Rose, Ocean Teal, Slate)
  - Custom HSV hue wheel + brightness slider with real-time contrast calculation
  - "Reset to default" button
- Persist user accent color preference cleanly in `SharedPreferences` / theme store.

### 3. Feature 2: Features Screen (`lib/features/features_catalog/`)

Create `lib/features/features_catalog/presentation/features_screen.dart`:
- Rich header card with gradient background and star badge: "SreerajP Journal Vault Features — Explore every encryption safeguard, journaling tool, and private capability designed for you."
- 4 Feature Categories:
  1. **Journaling & Rich Text Editor** (`Icons.edit_note_outlined`):
     - Rich Text Formatting (Quill editor with headings, lists, bold/italic, blockquotes)
     - Structured Entry Templates (Daily Reflection, Gratitude, Dream, Meeting, Habit, Freeform)
     - Encrypted Attachments & OCR Text Scanner (On-device image text recognition, photo, audio, file attachments)
     - Color-Coded Tags & Tag Manager (Categorize entries, custom colors, tag manager)
     - Multiple Separate Journals (Dedicated private journals for personal, work, ideas)
  2. **Privacy, Encryption & Vault Security** (`Icons.shield_outlined`):
     - SQLCipher AES-256-GCM Encryption (Database encrypted at rest on disk; keys in Android Keystore)
     - Biometric & App PIN Protection (Fingerprint / Face unlock or custom 4+ digit PIN)
     - Per-Journal Password Protection (Individual journal locks with PBKDF2 credential derivation)
     - Attachment-Level Locks (Isolate and lock sensitive files individually)
     - Screenshot Guard (`FLAG_SECURE` screen capture and app-switcher defense)
     - Tamper-Evident Security Audit Log (Immutable record of unlock and export events)
     - Auto-Lock Inactivity Profiles (Immediate, 30s, 1m, 5m, 10m customizable timeouts)
  3. **Search, Timeline & Insights** (`Icons.insights_outlined`):
     - Lightning SQLite FTS Search (Full-text search across all entries and tags in milliseconds)
     - Saved Search Presets (Quick filter shortcuts and custom search bookmarks)
     - Interactive Calendar & Timeline Explorer (Visual monthly calendar and chronological timeline)
     - Writing Streaks & Productivity Insights (Streak tracking, word count trends, mood analysis)
  4. **Storage, Backups & Multi-Format Export** (`Icons.inventory_2_outlined`):
     - 100% Offline Architecture (Zero internet permissions, zero telemetry, zero trackers)
     - Storage Migration (Seamlessly move encrypted attachments between App-Private storage and SD Card)
     - Encrypted Vault Backups (`.jvbk` / `.vault` encrypted backup files with health verification)
     - Multi-Format Export (Export to formatted PDF with photos, Markdown zip, or JSON)
     - Standalone Encrypted Reader (Read encrypted `.jvbk` export archives securely within the app)

### 4. Feature 3: Help Center & User Guides (`lib/features/help/`)

Create `lib/features/help/presentation/help_home_screen.dart` and dedicated topic screens:
- Header banner card with gradient styling and help center badge: "Help Center & Knowledge Base — Browse in-depth guides and solutions for all features of SreerajP Journal Vault."
- Grouped sections:
  1. **Writing & Journal Management**:
     - Journal Organization & Templates (`JournalOrganizationHelpScreen`)
     - Attachments, Media & OCR Scanner (`AttachmentsOcrHelpScreen`)
     - Tags & Color Coding (`TagsHelpScreen`)
  2. **Security & Encryption**:
     - Encryption & Keystore Architecture (`EncryptionSecurityHelpScreen`)
     - Biometrics & App PIN Lock (`BiometricsPinHelpScreen`)
     - Per-Journal & Attachment Locks (`JournalLocksHelpScreen`)
     - Screenshot Guard & Audit Trail (`ScreenshotAuditHelpScreen`)
  3. **Search, Timeline & Insights**:
     - Full-Text Search & Presets (`SearchTimelineHelpScreen`)
     - Writing Insights & Trends (`InsightsHelpScreen`)
  4. **Storage, Backups & Export**:
     - Storage Locations & SD Card Migration (`StorageMigrationHelpScreen`)
     - Encrypted Backups & Restore (`BackupRestoreHelpScreen`)
     - Exporting to PDF, Markdown & Standalone Reader (`ExportFormatsHelpScreen`)
  5. **Frequently Asked Questions**:
     - FAQs & Troubleshooting Guide (`FaqTroubleshootingHelpScreen`)

### 5. Localization (`lib/l10n/app_en.arb`)

Add all UI strings to `lib/l10n/app_en.arb` with descriptive `@key` entries and regenerate localizations via `flutter gen-l10n`.

### 6. Tests

- Update `test/features/settings/settings_tab_test.dart` to verify all 7 cards (Security, Appearance, Storage, Features, Permissions, Help, About) are rendered and navigable.
- Add tests for:
  - `AppearanceScreen`, `ThemeModeSettingsScreen`, and `AccentColorSettingsScreen`
  - `FeaturesScreen` (verifying categories, headers, and tiles)
  - `HelpHomeScreen` and topic help screens
- Verify existing tests in `test/widget_test.dart` and `test/app/settings_screen_security_test.dart` pass.

## Files to change

| File | Change |
|---|---|
| `lib/app/app.dart` | Wire AppearanceScreen, FeaturesScreen, and HelpHomeScreen into `_SettingsTab` |
| `lib/features/appearance/presentation/appearance_screen.dart` | [NEW] Appearance hub screen |
| `lib/features/appearance/presentation/theme_mode_settings_screen.dart` | [NEW] Theme mode configuration screen |
| `lib/features/appearance/presentation/accent_color_settings_screen.dart` | [NEW] Accent color picker & presets screen |
| `lib/features/features_catalog/presentation/features_screen.dart` | [NEW] Categorized Features catalog screen |
| `lib/features/help/presentation/help_home_screen.dart` | [NEW] Help Center home screen |
| `lib/features/help/presentation/journal_organization_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/tags_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/encryption_security_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/biometrics_pin_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/journal_locks_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/screenshot_audit_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/search_timeline_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/insights_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/storage_migration_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/backup_restore_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/export_formats_help_screen.dart` | [NEW] Topic guide |
| `lib/features/help/presentation/faq_troubleshooting_help_screen.dart` | [NEW] Topic guide |
| `lib/l10n/app_en.arb` | Add localized strings for Appearance, Features, and Help screens |
| `test/features/settings/settings_tab_test.dart` | Update settings tab test for the 7 cards |
| `test/features/appearance/appearance_screen_test.dart` | [NEW] Appearance screen tests |
| `test/features/features_catalog/features_screen_test.dart` | [NEW] Features screen tests |
| `test/features/help/help_screens_test.dart` | [NEW] Help screens tests |
| `docs/features.md` | Document the new Appearance, Features, and Help sections |

## Checks before done

- `flutter gen-l10n` runs without issues
- `flutter analyze` clean (0 issues)
- `flutter test` green
- `dart format lib test integration_test`
- `sh tool/check_absolute_paths.sh --all` clean
- Change log written to `change_log/`
