# Replace Syncfusion PDF Viewer with pdfrx (B6)

**Status:** Completed

## Overview
Replace the proprietary `syncfusion_flutter_pdfviewer` dependency with the open-source (MIT/BSD-style, PDFium-based) `pdfrx` package across the project. This aligns the app with the cross-app architectural rule forbidding proprietary/commercial PDF SDKs, eliminates Syncfusion licensing constraints, and unties dependency version pins.

## Files to Change
- `pubspec.yaml`
- `lib/features/attachments/presentation/pdf_attachment_view.dart`
- `docs/dependencies.md`
- `docs/architecture.md`
- `docs/features.md`
- `docs/release_process.md`
- `docs/security.md`
- `docs/enhancement_ideas.md`

## Implementation Steps
1. **Update `pubspec.yaml`:**
   - Remove `syncfusion_flutter_pdfviewer: ^33.2.13`.
   - Add `pdfrx: ^2.4.7`.
   - Update dependency comments regarding the resolution of the Syncfusion-induced pin constraints.
   - Run `flutter pub get`.

2. **Update `lib/features/attachments/presentation/pdf_attachment_view.dart`:**
   - Import `package:pdfrx/pdfrx.dart` instead of Syncfusion.
   - Replace `SfPdfViewer.file(...)` with `PdfViewer.file(...)`.
   - Configure error handling using `PdfViewerParams(onError: ...)`.
   - Preserve existing missing file check (`l10n.attachmentPdfMissing`) and key semantics (`Key('pdf-attachment-viewer')`).

3. **Update Documentation:**
   - Update `docs/dependencies.md` (table entry & notes).
   - Update `docs/architecture.md`, `docs/features.md`, `docs/release_process.md`, `docs/security.md`, and mark item B6 in `docs/enhancement_ideas.md`.

4. **Verification:**
   - Run `flutter analyze` to ensure zero errors/warnings.
   - Run `flutter test` to ensure all unit and widget tests pass.
