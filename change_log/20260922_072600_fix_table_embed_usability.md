# Fix Table Embed Usability

**Plan:** `plans/20260922_071800_fix_table_embed_usability.md`

## What changed

### `lib/features/entries/presentation/editor/table_embed.dart`

Rewrote the table embed widget to fix three usability issues:

1. **Single-tap cell focus.** Each cell is now wrapped in a `GestureDetector` with
   `HitTestBehavior.opaque` that calls `requestFocus()` on the cell's `FocusNode`. This
   prevents the Quill editor from claiming the first tap as a block-level embed selection
   (the "big cursor" problem). Users now get a text cursor inside the cell on the very
   first tap.

2. **Tab navigation and auto-extend.** Each cell is wrapped in a `KeyboardListener` that
   intercepts Tab and Shift+Tab key events. Tab moves focus to the next cell
   (left-to-right, top-to-bottom). If Tab is pressed in the last cell of the last row, a
   new empty row is added and focus moves to its first cell — matching the behaviour of
   office applications. Shift+Tab moves to the previous cell.

3. **Add Row / Add Column buttons.** A small "+ Row" button appears below the table and a
   "+ Column" button appears to its right. Each commits the current state, adds the row or
   column, and persists the change.

4. **Long-press context menu.** Long-pressing the table shows a popup menu with: Add row,
   Add column, Delete row, Delete column, and Delete table. Row/column delete options are
   shown only when a cell is focused (so the target row/column is known).

5. **`onDelete` callback.** The builder now passes an `onDelete` callback (same pattern as
   `CalloutEmbedBuilder`), enabling the "Delete table" menu item.

### `lib/features/entries/presentation/entry_editor_actions_2.dart`

Added a "Convert to table" item to the selection context menu. It appears when the selected
text contains tab or pipe characters and has at least two lines. The handler:

- Splits the text into rows (by newline) and columns (by tab or pipe).
- Pads shorter rows to equal column count.
- Bounds dimensions to the same 1–20 range as the insert-table dialog.
- Replaces the selection with a `TableEmbed.fromRows(...)`.

### `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`

Added eight new localization keys in all three languages:

- `actionTableAddRow`, `actionTableAddColumn`
- `actionTableDeleteRow`, `actionTableDeleteColumn`
- `actionTableDelete`
- `actionConvertToTable`
- `tooltipTableAddRow`, `tooltipTableAddColumn`

Malayalam and Sanskrit translations follow the existing vocabulary already used in
`labelEntryTableRows` / `labelEntryTableColumns`.

## What did not change

**Column/row resizing** is deferred. The `Table` widget distributes column widths evenly
and does not support user-draggable separators. A full drag-to-resize system would need a
custom layout widget with stored per-column widths.

## Verification

- `flutter analyze` — zero issues.
- `flutter test` — all tests pass.
- Manual verification required: insert table, single-tap cell, Tab through cells, Tab in
  last cell, + Row / + Column buttons, long-press menu, text-to-table conversion.
- Malayalam and Sanskrit translations flagged for native-reader review.
