# Change log — Revert the "keep space before a dot" helper

**Plan:** `plans/20260916_202828_editor-typing-and-selection-fixes.md` (Problem 1 only)
**Reverts part of:** `change_log/20260916_203226_editor-typing-and-selection-fixes.md`

## Why

The user decided the fix for Problem 1 (the keyboard removing the space before
a dot) is not needed and asked for it to be removed.

## What changed

- Deleted `lib/features/entries/presentation/editor/editor_space_keeper.dart`.
- Deleted `test/features/entries/editor/editor_space_keeper_test.dart`.
- `lib/features/entries/presentation/entry_editor_screen.dart`: removed the
  import and the `_spaceKeeper` field.
- `lib/features/entries/presentation/entry_editor_actions.dart`: removed the
  helper call from the document-change listener.

Typing a dot after a space now behaves as the keyboard decides again, the same
as before the earlier change.

## Kept

The selection fixes stay in place in the entry and template editors: 16 px side
padding and the selection magnifier.
