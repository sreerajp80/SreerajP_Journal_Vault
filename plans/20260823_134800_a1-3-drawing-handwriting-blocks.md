# Plan: A1.3 Drawing and Handwriting Blocks

**Status:** completed
**Date:** 2026-08-23
**Feature:** A1.3 Drawing and Handwriting Blocks

---

## 1. Context & Motivation

Diaries and personal journals are not purely typed text. Quick doodles, mind maps, sketches, signatures, and handwritten notes or diagrams are common in paper journals. Adding a drawing/handwriting embed enables natural finger and stylus drawing directly inside entry documents while maintaining the vault's core security invariants:
1. Drawing images are AES-256-GCM encrypted and stored in the `Attachments` table/storage.
2. The Quill document delta stores only the embed metadata (`attachmentId`, `fileName`, `widthFactor`, `strokeJson`) and never plaintext image bytes.
3. Drawings participate seamlessly in backup/restore, sync, search, and Markdown/HTML/PDF/Plain text exports.
4. Drawings can be re-edited by reloading the saved vector stroke data into the canvas.

---

## 2. Scope of Changes

### A. Drawing Models & Canvas
- `lib/features/entries/presentation/editor/drawing/drawing_models.dart`:
  - `DrawingTool`: `pen`, `highlighter`, `eraser`.
  - `DrawingPoint`: `Offset point`, `double pressure`.
  - `DrawingStroke`: `List<DrawingPoint>`, `Color`, `strokeWidth`, `DrawingTool`, `isHighlighter`.
  - `DrawingBackgroundStyle`: `blank`, `ruled`, `grid`, `dots`.
  - `DrawingCanvasState`: full serialization and deserialization to/from JSON (`strokeJson`) with backwards/forwards tolerance.
- `lib/features/entries/presentation/editor/drawing/drawing_canvas.dart`:
  - `DrawingCanvas`: smooth pointer gesture listener supporting touch and stylus input.
  - `DrawingPainter`: high-performance `CustomPainter` rendering smooth bezier curves, semi-transparent highlighters, erasers, and background guide patterns (ruled lines, square grid, bullet dot grid, blank).
- `lib/features/entries/presentation/editor/drawing/drawing_canvas_screen.dart`:
  - Full-screen drawing interface with tool selector (Pen, Highlighter, Eraser), color palette, stroke width selector, background pattern chooser, Undo/Redo stack, Clear canvas, Discard confirmation dialog, and Save/Done exporting to PNG image bytes and stroke JSON.

### B. Quill Embed & Editor Integration
- `lib/features/entries/presentation/editor/drawing_embed.dart`:
  - `DrawingEmbedData`: parses and encodes `{attachmentId, fileName, widthFactor, strokeJson}`.
  - `DrawingEmbed`: `CustomBlockEmbed` with key `'drawing'`.
  - `DrawingEmbedBuilder`: `EmbedBuilder` rendering inline drawing using `InlineImageStore`. Displays controls: Edit Drawing button (reloads strokes in canvas screen), Size selector (Small, Medium, Full), Delete button, and tap for full-screen zoomable preview.
- `lib/features/entries/presentation/editor/editor_toolbar.dart`:
  - Add `onInsertDrawing` callback and button with `Icons.draw_outlined` icon and localized tooltip.
- `lib/features/entries/presentation/entry_editor_screen.dart`:
  - Add `DrawingEmbedBuilder` to `_embedBuilders`.
  - Add `_insertDrawing()` and `_editDrawing(DrawingEmbedData data, int offset)`.
  - On save: encrypt PNG bytes via `AttachmentImportService`, create `DrawingEmbed`, insert into document delta, refresh attachment tray, and mark dirty.
- `lib/features/entries/presentation/version_history_screen.dart`:
  - Add `DrawingEmbedBuilder` to `_embedBuilders` for read-only preview of drawing embeds in revisions.

### C. Export Integration
- `lib/features/export/services/delta_document.dart`:
  - Add `DrawingBlock` in `ExportBlock` hierarchy.
  - Recognize `'drawing'`, `'vault_drawing'`, and `'sketch'` in `_embedBlock()`.
- `lib/features/export/services/export_collector.dart`:
  - Collect attachment IDs from both `ImageBlock` and `DrawingBlock`.
- `lib/features/export/services/delta_to_markdown.dart`:
  - Render `DrawingBlock` as Markdown image link if linkable, or `_[Drawing: ...]_`.
- `lib/features/export/services/delta_to_html.dart`:
  - Render `DrawingBlock` as `<figure class="inline-drawing"><img src="..." alt="..."></figure>`.
- `lib/features/export/services/delta_to_plain_text.dart`:
  - Render `DrawingBlock` as `[Drawing: fileName]`.

### D. Localization
- `lib/l10n/app_en.arb`:
  - Add localized strings for drawing toolbar button, canvas screen titles, tool labels, background styles, dialogs, and embed controls.

---

## 3. Files to Create and Modify

### New Files
- `lib/features/entries/presentation/editor/drawing/drawing_models.dart`
- `lib/features/entries/presentation/editor/drawing/drawing_canvas.dart`
- `lib/features/entries/presentation/editor/drawing/drawing_canvas_screen.dart`
- `lib/features/entries/presentation/editor/drawing_embed.dart`
- `test/features/entries/drawing_embed_test.dart`
- `test/features/entries/drawing_models_test.dart`
- `test/features/entries/presentation/drawing_canvas_screen_test.dart`
- `test/features/export/drawing_export_test.dart`

### Modified Files
- `lib/features/entries/presentation/editor/editor_toolbar.dart`
- `lib/features/entries/presentation/entry_editor_screen.dart`
- `lib/features/entries/presentation/version_history_screen.dart`
- `lib/features/export/services/delta_document.dart`
- `lib/features/export/services/export_collector.dart`
- `lib/features/export/services/delta_to_markdown.dart`
- `lib/features/export/services/delta_to_html.dart`
- `lib/features/export/services/delta_to_plain_text.dart`
- `lib/l10n/app_en.arb`

---

## 4. Verification Plan

### Automated Tests
- Run `flutter test` across all new and existing test suites:
  - `test/features/entries/drawing_embed_test.dart`
  - `test/features/entries/drawing_models_test.dart`
  - `test/features/entries/presentation/drawing_canvas_screen_test.dart`
  - `test/features/export/drawing_export_test.dart`
  - `test/features/entries/embed_blocks_test.dart`
  - `test/features/export/delta_document_test.dart`
  - `test/features/export/delta_to_html_test.dart`
  - `test/features/export/delta_to_markdown_test.dart`
  - `test/features/export/delta_to_plain_text_test.dart`
- Run `flutter analyze` to ensure 0 lint or static analysis issues.
- Run `dart format --set-exit-if-changed lib test` to ensure clean formatting.
