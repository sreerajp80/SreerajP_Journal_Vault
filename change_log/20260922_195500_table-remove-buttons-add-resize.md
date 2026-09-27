# Remove External Table Buttons and Add Column Resize

**Plan:** `plans/20260922_194000_table-remove-buttons-add-resize.md`

## What changed

### `lib/features/entries/presentation/editor/table_embed.dart`

**Part 1 — Removed external `+ Row` / `+ Column` buttons**

- Deleted the `_AddButton` widget class entirely.
- Simplified the `build()` method: removed the `Column` wrapper (which held `tableWidget` +
  `_AddButton` for row), removed the outer `Row` wrapper (which held the column `_AddButton`
  to the right). The editable body is now just `GestureDetector > Container > tableWidget`.
- The long-press context menu (which already had Add Row, Add Column, Delete Row, Delete
  Column, Delete Table) is the sole way to add/remove rows and columns.

**Part 2 — Drag-to-resize columns**

- **Data format:** `TableEmbed` now supports two JSON formats transparently:
  - Legacy: `[["a","b"],["c","d"]]` (existing tables, backward compatible).
  - Envelope: `{"rows":[...],"colWidths":[120.0,200.0]}` (written after first resize).
  Added `_parsed()`, `colWidths` getter, and `fromRowsAndWidths()` factory.

- **Widget changes:**
  - `_TableBlock` accepts an optional `colWidths` list. `onCommit` signature changed from
    `ValueChanged<List<List<String>>>` to
    `void Function(List<List<String>> rows, List<double>? colWidths)`.
  - `_TableBlockState` holds `_colWidths` and `_isDragging` state.
  - Header cells (row 0) wrapped in `_buildResizableHeaderCell()` which overlays a
    `_buildDragHandle()` on the right edge of each column except the last.
  - Resize uses a split-pane model: dragging the border between column N and N+1
    redistributes width between them, keeping the total constant. Min width is 48 px.
  - On first drag, `_colWidths` initialises from `maxWidth / colCount` (via `LayoutBuilder`).
  - `_addColumn` and `_deleteColumn` maintain `_colWidths` when columns change.
  - `didUpdateWidget` syncs `_colWidths` from the embed unless a drag is active.

### Localisation (`lib/l10n/`)

- Added `tooltipTableResizeColumn` to `app_en.arb`, `app_ml.arb`, `app_sa.arb`.
- Ran `flutter gen-l10n` — all three generated files updated.

## Verification

- `flutter gen-l10n` — success.
- `flutter analyze` — zero issues.
