# Update README.md with Complete App Details for GitHub

**Status:** completed

## The issue

The current `README.md` focuses mostly on developer prerequisites and command-line instructions. It does not properly present the app to visitors on the GitHub repository home page. It lacks descriptions of user-facing features, security and privacy architecture, offline sync mechanisms, rich text and multimedia authoring capabilities, and screenshots/feature highlights.

## The proposed fix

Update `README.md` to serve as a comprehensive, attractive, and informative repository home page:

1. **Header & Badges**:
   - Clear title, tagline, and project badges (Android API 28+, Flutter 3.44.8, 100% Offline / Zero Telemetry, SQLCipher + Keystore Encryption, MIT License).
2. **About the App**:
   - Introduction to SreerajP Journal Vault as a private, security-hardened, offline-first personal journal, knowledge vault, and diary.
3. **Key Features & Capabilities**:
   - **Privacy & Security**: Zero-cloud guarantee, full-database SQLCipher encryption at rest, hardware Android Keystore integration, AES-256-GCM attachment encryption, app lock (biometrics / custom PIN), per-journal password locks, window-wide screenshot blocking (`FLAG_SECURE`), and security audit logging with tamper alerts.
   - **Rich Text & Multimedia Writing**: Flutter Quill editor, custom embeds (tables, callout boxes, drawings/handwriting canvas, inline images, voice notes with live speech-to-text), on-device OCR scanner (English & Malayalam with rotation/crop).
   - **Knowledge Organization**: Wiki-style backlinks (`[[Entry Title]]`), smart tags with auto/custom colors, reusable entry templates with dynamic date tokens, full-text search (SQLite FTS5) indexing entries and attachments.
   - **Timeline, Calendar & Insights**: Monthly calendar heatmap, writing streaks, word counts, mood trend analytics (1-5 rating), and "On This Day" memory resurfacing.
   - **Mindful Rituals & Philosophy**: Daily journaling ritual with contemplation timer, 3D card-flip reveal, curated bilingual Sanathana Dharma thought card decks, and custom prompt decks.
   - **Offline Sync & Data Freedom**: Peer-to-peer Wi-Fi sync (direct device-to-device with X25519 & AES-256-GCM), optical air-gapped AirQR sync (animated QR codes), multi-format export (Markdown, HTML, Plain Text, PDF with Malayalam support), encrypted `.jvenc` exports, and automated encrypted backups.
   - **Themes & Localization**: Multiple reading surfaces (Light, Paper/Sepia, Dark, OLED True Black), customizable accent colors, typography sizing/fonts, and complete English & Malayalam bilingual support.
4. **Technical Architecture Overview**:
   - Summary of tech stack: Flutter, Riverpod, Drift ORM over SQLCipher, native Android Keystore channels, offline-first design.
5. **Getting Started & Developer Guide**:
   - Keep clear, concise developer instructions: prerequisites, setup, run commands, testing, code generation, database migrations, and release build steps.
6. **Documentation Map & License**:
   - Links to `docs/` (architecture, security, release process, features) and MIT License.

## Files to change

- `README.md` (modify)

## Verification plan

- Review `README.md` for clear formatting and simple English.
- Verify that relative paths and links are correct.
- Verify no absolute paths or machine details are introduced using `sh tool/check_absolute_paths.sh --all`.
