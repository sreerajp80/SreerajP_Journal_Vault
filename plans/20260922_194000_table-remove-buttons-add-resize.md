# Remove External Table Buttons and Add Column Resize

**Status:** completed
**Change log:** `change_log/20260922_195500_table-remove-buttons-add-resize.md`

## Issue

Two changes requested for the table embed:

1. The external `+ Row` (below) and `+ Column` (right side) buttons are redundant since the
   long-press context menu already offers Add Row, Add Column, Delete Row, Delete Column, and
   Delete Table. The external buttons waste space and clutter the UI.

2. There is no way to resize column widths. All columns share equal width, which is limiting
   when one column holds short labels and another holds longer text.

## Fix

### Part 1 — Remove external `+ Row` and `+ Column` buttons

**File:** `lib/features/entries/presentation/editor/table_embed.dart`

- In `_TableBlockState.build()`, remove the `_AddButton` widget for "+ Row" (lines 450–458)
  and simplify the editable body so the `Column` only contains the `tableWidget`.
- Remove the outer `Row` wrapper that places the "+ Column" button to the right (lines 464–481).
  The editable body becomes the `GestureDetector > Container > tableWidget` directly.
- Delete the entire `_AddButton` class (lines 560–612) since it is no longer used anywhere.
- The `tooltipTableAddRow` and `tooltipTableAddColumn` l10n keys become unused but can be kept
  for now — they do no harm and removing ARB keys is a separate cleanup task.

No other files reference `_AddButton`.

### Part 2 — Drag-to-resize columns

**File:** `lib/features/entries/presentation/editor/table_embed.dart`

**Data format change:** The embed currently stores a plain JSON 2D array of strings:
`[["a","b"],["c","d"]]`. To persist column widths, wrap the data in an object:

```json
{
  "rows": [["a","b"],["c","d"]],
  "colWidths": [120.0, 200.0]
}
```

When `colWidths` is absent (all existing tables), every column gets an equal flexible share
(the current behaviour), so this is backwards compatible — no migration needed.

**Widget changes:**

1. Add a `List<double>?` field `_colWidths` to `_TableBlockState`. Initialise from the embed
   data if the `colWidths` key is present; otherwise leave null (equal-width mode).

2. Replace the `Table` widget with a `SingleChildScrollView(scrollDirection: Axis.horizontal)`
   wrapping a `Row` of sized columns, OR keep `Table` and supply `columnWidths:` using
   `FixedColumnWidth` values from `_colWidths`. The `Table` approach is simpler; use
   `defaultColumnWidth: const FlexColumnWidth()` as fallback when `_colWidths` is null.

3. Add thin `GestureDetector` drag handles (4–6 px hit area) on the right border of each
   column header cell. On horizontal drag, update `_colWidths[col]` in `setState`, clamping
   to a minimum of 48 px. On drag end, commit the new widths to the embed data via `onCommit`.

4. Update `_commitIfChanged()` and `_currentData()` to produce the new JSON envelope when
   `_colWidths` is not null.

5. Update `TableEmbed.rows` getter and `TableEmbed.fromRows` to handle both the old flat
   format and the new envelope format. Add a `colWidths` getter and a
   `TableEmbed.fromRowsAndWidths(rows, widths)` factory.

**Row height:** Row height does not need a resize handle — `TextField(maxLines: null)` already
grows rows to fit content. This is sufficient.

**L10n:** No new user-visible strings needed. The drag handle is a visual affordance, not a
labelled control. A `Semantics(label: ...)` is added for accessibility using an existing
or new key.

**New l10n keys (all three ARB files):**

- `tooltipTableResizeColumn` — "Resize column" / "നിരയുടെ വലുപ്പം മാറ്റുക" / "स्तम्भविस्तारं परिवर्तय"

### Files to change

| File | Change |
|------|--------|
| `lib/features/entries/presentation/editor/table_embed.dart` | Remove buttons, add resize handles, update data format |
| `lib/l10n/app_en.arb` | Add `tooltipTableResizeColumn` |
| `lib/l10n/app_ml.arb` | Add `tooltipTableResizeColumn` |
| `lib/l10n/app_sa.arb` | Add `tooltipTableResizeColumn` |

### Verification

- `flutter analyze` — zero issues.
- `flutter gen-l10n` — regenerates without error.
- Manual test: create a table, verify no external buttons visible, long-press shows context
  menu with add/delete row/column, drag column border to resize, close and reopen the entry
  to confirm widths are persisted.
- Existing tables (old flat-array format) still render correctly with equal-width columns.
