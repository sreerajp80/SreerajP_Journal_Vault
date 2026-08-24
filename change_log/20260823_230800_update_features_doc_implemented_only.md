# Change Log: Update features.md to List Only Implemented Features

**Date:** 2026-08-23  
**Plan:** [`plans/20260823_230700_update_features_doc_implemented_only.md`](../plans/20260823_230700_update_features_doc_implemented_only.md)  

## Summary of Changes

Updated `docs/features.md` to reflect only genuine, working, and user-reachable features of the application.

### Key Corrections Made:
1. **Removed Unimplemented / Disabled Features**:
   - Removed Section 7 (Multi-Device Sync Engine), as it lacks a transport mechanism and its UI is disabled.
   - Removed references to removed sync placeholders in Settings.

2. **Corrected Outdated Information**:
   - Updated database security to describe **SQLCipher database encryption at rest** with Keystore-held keys.
   - Updated Tamper Alerts to document the live `TamperAlertsScreen` and on-demand vault integrity verification.
   - Updated the Disclosed Gaps list to remove items that are now closed.

3. **Added Recently Implemented Capabilities**:
   - **Drawing and Handwriting Canvas Embed**: Interactive canvas (pen, highlighter, eraser, 10 colors, grid backgrounds, encrypted PNG storage, vector strokes).
   - **Inline Images Embed**: Embedded in rich text flow with encrypted attachment storage and full-screen viewer.
   - **On-Device OCR Scanner**: Photo-to-text with crop and rotate tools using ML Kit.
   - **Custom User Templates & Template Manager**: Dynamic date/time tokens (`{{today}}`, `{{weekday}}`, etc.), Template Manager screen, and save-entry-as-template.
   - **Editor Quality of Life**: Live stats bar (word/char count), auto-save indicator, real-time Markdown shortcut expansions, full-screen distraction-free mode, and focus paragraph dimming.
   - **Android Share Intent Receiver & Quick Capture**: Handles incoming text, images, and `.jvenc`/`.jvbk` archives.
   - **Bilingual Localization**: English and Malayalam localization across all screens via `AppLocalizations`.

## Files Changed

- `docs/features.md`
- `plans/20260823_230700_update_features_doc_implemented_only.md`
- `change_log/20260823_230800_update_features_doc_implemented_only.md`
