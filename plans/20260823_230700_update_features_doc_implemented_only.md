# Implementation Plan: Update features.md to List Only Implemented Features

**Status:** completed  
**Date:** 2026-08-23  

## Issue

`docs/features.md` contains outdated statements, lists features that are not usable/implemented (such as multi-device sync which lacks a transport mechanism and is disabled), and is missing several features that have been implemented recently. Specifically:

1. **Unimplemented / Disabled Features Listed**:
   - Section 7 describes the Multi-Device Sync Engine as a feature, even though it has no transport and its UI is disabled.
   - References in Settings to sync placeholders that have been removed.

2. **Outdated Statements**:
   - States that the SQLite database and FTS5 index are stored unencrypted at rest (SQLCipher database encryption was implemented in A5.1).
   - States that Tamper Alerts is a disabled "Coming soon" placeholder (Tamper alerts and on-demand vault integrity verification was implemented in `TamperAlertsScreen`).

3. **Missing Recently Implemented Features**:
   - **SQLCipher at-rest database encryption** with Keystore-held keys (A5.1).
   - **Drawing and handwriting canvas embed** (`DrawingEmbed`, interactive drawing canvas with Pen, Highlighter, Eraser, color palette, grid paper backgrounds, encrypted PNG storage, and vector data) (A1.3).
   - **Inline images in the editor body** (`ImageEmbed` with encrypted attachment backing) (A1.2).
   - **On-device OCR scanner with image crop & rotate** (`ocr_scan_service.dart`, ML Kit).
   - **Custom entry templates & template manager** with dynamic date tokens (`{{today}}`, `{{weekday}}`, etc.) and save-entry-as-template (A1.7).
   - **Editor quality-of-life enhancements** (word/character count stats bar, auto-save status indicator, real-time Markdown shortcut expansions, full-screen distraction-free mode, focus paragraph dimming) (A1.5).
   - **Android Share Intent Receiver & Quick Capture** for incoming text, images, and `.jvenc`/`.jvbk` files (A6.2).
   - **Bilingual Localization (English & Malayalam)** across all screens via `AppLocalizations` (A6.4).
   - **Vault integrity verification & live tamper status screen** (`TamperAlertsScreen`) (A5.6).

## Proposed Fix

Update `docs/features.md` so it accurately and cleanly documents **only implemented and user-reachable features**:
1. Update the overview and introduction to reflect all current features and remove references to unencrypted databases or disabled sync.
2. Remove Section 7 (Multi-Device Sync) from the implemented feature catalog.
3. Update Section 1 (Security) to describe SQLCipher database encryption at rest and the dedicated Tamper Alerts screen, updating the disclosed gaps section accordingly.
4. Update Section 2 (Editor & Authoring) to include Drawing/Handwriting embeds, Inline image embeds, On-device OCR text scanning, Editor quality-of-life features, and Custom user templates.
5. Update Section 6 & 8 to include Share intent receiver / Quick capture, and full English/Malayalam localization.
6. Ensure no absolute paths or private system details are added.

## Files to Change

- `docs/features.md`

## Verification

- Audit `docs/features.md` against the active codebase and `change_log/` to ensure every item described is implemented and accessible in the UI.
- Run `sh tool/check_absolute_paths.sh` or ensure no absolute paths are present.
