# Caret jump to line start / end in the editor selection menu

Implements `plans/20260905_045500_line-start-end-context-menu.md`.

## Why

On the phone the journal editor reaches the screen edge, and the phone cover
makes it hard to tap exactly on the first or last character of a line. There
was no other way to put the caret there.

## What changed

**`lib/features/entries/presentation/entry_editor_screen.dart`**

- `_buildSelectionContextMenu` now puts two new items at the front of the text
  selection popup: `⇤` (go to line start) and `⇥` (go to line end). They show
  for a caret as well as for a word picked by a double tap, and sit before the
  Bold / Italic / Underline / Strike items.
- New `_lineJumpContextMenuItem` builds each item. Tapping one collapses the
  selection onto the target offset with `ChangeSource.local` and closes the
  popup with `ContextMenuController.removeAny()`.
- New top-level helpers `lineStartOffset` and `lineEndOffset` work out the
  offsets from the document plain text. They use the logical line (the text
  between two newlines), not a soft-wrapped visual row, and clamp the incoming
  offset into the text.

**`lib/l10n/app_en.arb`**

- Added `editorGotoLineStart` (`⇤`) and `editorGotoLineEnd` (`⇥`), each with an
  `@` description saying what the glyph means. `flutter gen-l10n` was run, so
  `lib/l10n/app_localizations*.dart` were regenerated.

**`test/features/entries/presentation/entry_editor_line_jump_test.dart`** (new)

- 11 unit tests over the two helpers: first line, middle line, empty line, last
  line, text with no trailing newline, and out-of-range offsets.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 793 tests, all pass.
- `dart format` — clean.

## Note

Scope stayed on the entry editor. The template editor does not install a custom
context menu, so it was left as it was.
