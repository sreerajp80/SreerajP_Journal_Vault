# Change Log: Update README.md with Complete App Details

**Date:** 2026-09-12  
**Plan:** `plans/20260912_180600_update_readme_app_details.md`

## Summary of Changes

Updated `README.md` to serve as a comprehensive, attractive, and informative GitHub repository home page for SreerajP Journal Vault.

### Changes Details

- **Header & Badges**: Added platform, Flutter version, security architecture, offline/zero-telemetry, and MIT license badges.
- **App Overview**: Highlighted that the app is an encrypted, privacy-first, offline personal journal and knowledge vault governed by the Core Baseline, Production App Extension, and Sensitive Data Extension profiles.
- **Key Highlights**: Summarized zero-cloud privacy, SQLCipher database encryption at rest, Keystore-backed AES-256-GCM attachments, `FLAG_SECURE` window protection, rich text editing with custom Quill embeds, on-device OCR for English and Malayalam, knowledge backlinks, insights, mindful rituals, local Wi-Fi and optical AirQR sync, and multi-format exports.
- **Detailed Feature Tour**:
  - Security & Privacy Architecture (SQLCipher, Keystore, App Lock, per-journal passwords, attachment locks, auto-lock, tamper alerts).
  - Rich Text & Multimedia Writing (tables, callout admonitions, drawing canvas, inline images, voice notes with live speech-to-text, version history).
  - Knowledge Management & Search (backlinks, FTS5 full-text search across entries and attachments, smart tags, dynamic date token templates).
  - Timeline, Calendar & Insights (chronological feed, calendar heatmap, streaks, mood trend charts, "On This Day" memories).
  - Mindful Rituals & Philosophy Cards (routine timer, 3D card flip, bilingual Sanathana Dharma thought decks, custom decks, time capsules).
  - Offline Sync & Data Portability (P2P Wi-Fi Sync with X25519 and AES-256-GCM, optical air-gapped AirQR, Markdown/HTML/Text/PDF export with Malayalam support, password-sealed `.jvenc` files, encrypted backups).
  - Appearance & Viewers (Light, Paper/Sepia, Dark, OLED True Black surfaces, typography, secure in-app PDF/Audio/ZIP viewers, bilingual English & Malayalam).
- **Technical Architecture & Specifications**: Added directory layout, component responsibilities, and technology summary table.
- **Developer Guide**: Preserved and streamlined setup from clean clone, run commands, testing instructions, code generation, and release build steps.
- **Documentation Map & License**: Added links to architecture, security, features, release process, and MIT license.

## Verification

- Ran path audit check (`tool/check_absolute_paths.sh`) on `README.md`, the plan, and this change log to ensure no absolute paths or machine details exist.
- Verified all markdown links use relative repository paths.
