# Plan — Editor: dot joining the word, and hard text selection

**Status:** completed
**Status note:** See `change_log/20260916_203226_editor-typing-and-selection-fixes.md` (approved 2026-09-16). Problem 1 fix later removed at the user's request — see `change_log/20260916_203501_revert-editor-space-keeper.md`

## The problems reported

1. Typing a word, then a space, then a dot: the dot jumps back and joins the
   word (`word .` becomes `word.`).
2. Selecting a word, or a few letters inside a word, is slow and fiddly.
3. Starting a selection at the very beginning of a line is almost impossible.
4. While dragging a selection handle, the finger hides the text, so you cannot
   see where the selection will end.

All four are in the entry body editor (`flutter_quill` 11.5.1), set up in
`lib/features/entries/presentation/entry_editor_screen.dart`.

---

## Problem 1 — Dot joins the previous word

### Cause

This is not our code. Android keyboards (Gboard, Samsung Keyboard) have a
"smart punctuation" habit: when a dot is typed right after a space, the keyboard
itself deletes the space and sends `word.` instead. The keyboard does this
because the editor asks for suggestions, and `flutter_quill` gives the app no
setting to turn that off (it hard-codes `enableSuggestions: true`).

### Fix

Add a small, testable helper next to the Markdown shortcuts:
`lib/features/entries/presentation/editor/editor_space_keeper.dart`
(presentation layer, editor helper — same kind of class as
`EditorMarkdownShortcuts`).

- It remembers when the user's last edit was typing **one space on its own**.
- If the very next edit removes that same space and puts a `.` (or `. `) in its
  place, the helper puts the space back, so the text reads `word .` and the
  cursor sits after the dot.
- It does **not** act when the keyboard adds its own space after you pick a word
  from the suggestion bar (that space arrives together with the word, not on its
  own). So the normal "pick a word, tap dot" flow still gives `word.`, which is
  what most people want there.
- It only reacts to local typing, never to undo/redo, paste, or code changes.

It is called from the existing document-change listener in
`lib/features/entries/presentation/entry_editor_actions.dart`
(`_subscribeToDocChanges`), next to the Markdown shortcut handler.

> Question for you: should this apply to other marks too (`, ? ! : ;`)? The
> plan covers only `.` unless you say otherwise.

---

## Problem 2 — Selecting words or letters is fiddly

### Cause

The editor has no side padding (the body sits in `Expanded` with 0 px left and
right in `entry_editor_layout.dart`). Handles near the edges are cramped, and
the magnifier (see Problem 4) is off, so fine adjustments are guesswork.

### Fix

Covered by the fixes for Problems 3 and 4 below: side padding plus the
magnifier make letter-by-letter handle dragging practical. Long-press still
selects a whole word, as on every Android text field.

---

## Problem 3 — Cannot start a selection at the start of a line

### Cause

Text starts at the very left edge of the screen (0 px padding). The start
handle hangs to the left of the first letter, so it is partly off-screen, and a
drag that starts at the screen edge is taken by Android's **back gesture**
instead of the editor.

### Fix

Give the editor inner side padding with `QuillEditorConfig.padding`
(`EdgeInsets.symmetric(horizontal: 16)`), in `entry_editor_screen.dart`. This
matches the 16 px used by the title field above it, so the body text also lines
up with the title. The same padding is applied in distraction-free mode, which
reuses the same editor widget.

---

## Problem 4 — The finger hides the selection end

### Cause

`flutter_quill` ships a magnifier but leaves it **off** by default
(`quillMagnifierBuilder` is null).

### Fix

Turn it on in `entry_editor_screen.dart`:
`quillMagnifierBuilder: defaultQuillMagnifierBuilder`. While a handle is
dragged, a zoomed bubble shows the text above the finger, so you can stop on
the exact word or letter.

The same two settings (padding and magnifier) are also added to the template
body editor in `lib/features/entries/presentation/template_editor_screen.dart`,
so both editors behave the same. The read-only version-history viewer is left
alone.

---

## Files to change

| File | Change |
|---|---|
| `lib/features/entries/presentation/entry_editor_screen.dart` | Add `padding` and `quillMagnifierBuilder` to `QuillEditorConfig` |
| `lib/features/entries/presentation/template_editor_screen.dart` | Same two settings |
| `lib/features/entries/presentation/editor/editor_space_keeper.dart` | New helper that restores the space before a dot |
| `lib/features/entries/presentation/entry_editor_actions.dart` | Call the helper from the document-change listener |
| `test/features/entries/presentation/editor/editor_space_keeper_test.dart` | New tests: typed space + dot keeps the space; suggestion space + dot is left alone; remote/undo changes ignored |

No database, ARB, permission or dependency changes. No new user-visible text.

## Checks after the change

- `flutter analyze` — zero issues
- `flutter test`
- `dart format lib test integration_test`
- Manual check on a phone with Gboard: type `word .`; select from the start of
  a line; drag a handle and confirm the magnifier shows the text.

## Risk

- Problem 1 fights the keyboard's own behaviour. Keyboards differ, so the
  helper is kept narrow (only a lone typed space followed by a dot). If a
  keyboard sends the change in an unexpected shape, the helper does nothing,
  which is the same as today.
- Padding moves body text 16 px inward on each side. Existing entries are not
  changed; only how they are shown.
