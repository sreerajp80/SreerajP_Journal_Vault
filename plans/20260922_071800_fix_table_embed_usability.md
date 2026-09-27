# Fix Table Embed Usability Issues

**Status:** completed
**Change log:** `change_log/20260922_072600_fix_table_embed_usability.md`

## Issue

Four usability problems with the table embed in the journal editor:

1. No text-to-table conversion from selected text
2. No way to extend a table (add rows/columns after creation)
3. Double-tap needed to edit a cell (big cursor on first tap)
4. Column/row resizing not possible (deferred — not feasible with current `Table` widget)

## Fix

### Files to change

- `lib/features/entries/presentation/editor/table_embed.dart` — main widget fixes
- `lib/features/entries/presentation/entry_editor_actions_2.dart` — text-to-table context menu
- `lib/l10n/app_en.arb` — new English keys
- `lib/l10n/app_ml.arb` — new Malayalam keys
- `lib/l10n/app_sa.arb` — new Sanskrit keys

### Approach

1. **Single-tap cell focus:** wrap the table in a `GestureDetector` with
   `HitTestBehavior.opaque` to intercept the first tap and focus the cell directly,
   preventing the Quill editor from claiming the tap as block-level selection.

2. **Extend table:** Tab in the last cell adds a new row. Visible `+ Row` and `+ Column`
   buttons below and beside the table. Long-press context menu with add/delete row/column
   and delete table.

3. **Text-to-table:** context menu item "Convert to table" when the selection contains
   tab-separated or pipe-separated text.
