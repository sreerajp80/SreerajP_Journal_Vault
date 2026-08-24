# Change Log: Replace Syncfusion PDF Viewer with pdfrx (B6)

**Date:** 2026-08-23
**Plan:** [`plans/20260823_232600_replace_syncfusion_with_pdfrx.md`](../plans/20260823_232600_replace_syncfusion_with_pdfrx.md)

## Summary
Replaced the proprietary `syncfusion_flutter_pdfviewer` dependency with the open-source (PDFium, BSD/MIT) `pdfrx` package. This aligns the repository with the family rule forbidding proprietary/commercial PDF SDKs, eliminates commercial license constraints, and unties dependency version constraints.

## Changes Made
1. **Dependencies (`pubspec.yaml`):**
   - Removed `syncfusion_flutter_pdfviewer: ^33.2.13` and its transitive Syncfusion packages.
   - Added `pdfrx: ^2.4.7`.
   - Cleaned up dependency comments regarding win32 pins.

2. **Attachment Viewer UI (`lib/features/attachments/presentation/pdf_attachment_view.dart`):**
   - Replaced Syncfusion imports and widgets with `pdfrx`'s `PdfViewer.file`.
   - Added error banner builder preserving localized failure display.
   - Preserved missing file handling and widget keys.

3. **Tests (`test/features/attachments/pdf_attachment_view_test.dart`):**
   - Added widget tests for `PdfAttachmentView` covering missing-file and existing-file rendering scenarios.

4. **Documentation:**
   - Updated `docs/dependencies.md`, `docs/architecture.md`, `docs/features.md`, `docs/release_process.md`, `docs/security.md`, `docs/journal_vault_plan.md`, and `android/app/proguard-rules.pro`.
   - Marked item B6 as completed in `docs/enhancement_ideas.md`.

## Verification
- Ran `flutter pub get` (clean resolution without Syncfusion).
- Ran `dart format lib test integration_test` (clean).
- Ran `flutter analyze` (0 issues).
- Ran `flutter test` (all 710 tests passing).
