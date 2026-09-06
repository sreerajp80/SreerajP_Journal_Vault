# Line Start / End entries in the editor selection menu

**Status:** completed

## Issue

On the phone, the journal editor runs right up to the edge of the screen. The
phone cover gets in the way, so it is hard to tap exactly at the first
character of a line to place the cursor there. The same problem happens at the
end of a line.

There is no keyboard or menu way to jump the cursor to the start or the end of
the current line.

## Fix

Add two new items to the text selection popup menu that already appears in the
entry editor (the one that shows Bold / Italic / Underline / Strike plus the
system Copy / Paste items).

- **⇤** — moves the caret to the first character of the current line.
- **⇥** — moves the caret to the last character of the current line.

Labels are the single arrow glyphs the user asked for: ⇤ and ⇥.

Details:

- The two items are always added, whether the selection is a word (double tap)
  or just a caret. They are added before the format items so they are the first
  things in the popup.
- "Current line" means the text between the previous newline and the next
  newline around `selection.baseOffset` in the document plain text. A soft
  wrapped visual line is not used — the whole logical line (paragraph) is used,
  because that is what the user is trying to reach.
- Pressing an item sets a collapsed selection at that offset, keeps the
  keyboard open, and closes the popup with `ContextMenuController.removeAny()`.
- Both labels come from `lib/l10n/app_en.arb` through `AppLocalizations`, as
  the localization rule requires. New keys: `editorGotoLineStart` and
  `editorGotoLineEnd`, each with an `@` description.

Scope is the entry editor only. The template editor does not use a custom
context menu, so it is left alone.

## Files to change

- `lib/l10n/app_en.arb` — add the two keys and their descriptions.
- `lib/features/entries/presentation/entry_editor_screen.dart` — build the two
  menu items in `_buildSelectionContextMenu`, add a small helper that works out
  the line start and end offsets and moves the caret.
- `test/features/entries/presentation/entry_editor_line_jump_test.dart` — new
  unit test for the line start / end offset maths (first line, middle line,
  last line, empty line, caret already at an edge).

Generated file `lib/l10n/app_localizations*.dart` is refreshed by
`flutter gen-l10n`; it is not hand edited.

## Checks after the change

- `flutter gen-l10n`
- `flutter analyze` (must be clean)
- `flutter test`
