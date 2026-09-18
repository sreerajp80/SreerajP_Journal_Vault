# Change log — Editor: dot joining the word, and hard text selection

**Plan:** `plans/20260916_202828_editor-typing-and-selection-fixes.md` (approved 2026-09-16)

## What changed

### 1. The space before a dot is kept

New helper `lib/features/entries/presentation/editor/editor_space_keeper.dart`
(presentation layer, editor helper, like `EditorMarkdownShortcuts`).

Android keyboards delete a space typed before a dot. The helper notices when
the user typed one space on its own, and the next edit swapped that space for
`.` or `. `. It then puts the space back, so the text reads `word .` and the
cursor sits after the dot.

- It does nothing when the space came together with a word (a picked
  suggestion), so "pick a word, tap dot" still gives `word.`.
- It does nothing if the user deleted the space themselves first.
- It ignores changes that are not local typing.
- Quill sends change events after the whole edit is applied, so the helper
  checks the final text and cursor instead of reading each step.

It is called from `_subscribeToDocChanges` in
`lib/features/entries/presentation/entry_editor_actions.dart`, before the
Markdown shortcut handler. Only the dot is covered, as the plan said.

### 2. Easier selection

In `lib/features/entries/presentation/entry_editor_screen.dart` and
`lib/features/entries/presentation/template_editor_screen.dart`, the body
`QuillEditorConfig` now sets:

- `padding: EdgeInsets.symmetric(horizontal: 16)` — line starts are no longer
  at the screen edge, where the handle was cut off and Android's back gesture
  took the drag. The body now lines up with the title field.
- `quillMagnifierBuilder: defaultQuillMagnifierBuilder` — a zoomed bubble shows
  the text under the finger while a selection handle is dragged.

The read-only version history viewer is unchanged.

### 3. Tests

New `test/features/entries/editor/editor_space_keeper_test.dart`, placed next
to the existing `editor_markdown_shortcuts_test.dart` (the plan named a
slightly different folder; this one matches the existing editor tests). It
covers: space swapped for `.`, space moved after the dot, delete and dot sent
as two edits, a normal dot after a space, a suggestion space, a user-deleted
space, and non-local changes.

## Checks

- `flutter analyze` — no issues.
- `dart format` — clean.
- `flutter test test/features/entries/editor` — all pass.

## Known limits

- If the user types a whole word and then taps that same word in the suggestion
  bar, some keyboards add the space as a separate edit. That space then looks
  typed, so a dot after it keeps the space.
- Keyboards differ. If one sends the change in another shape, the helper does
  nothing, which is the same as before.
- Needs a manual check on a phone: typing `word .`, selecting from a line start,
  and the magnifier while dragging.

No database, ARB, permission or dependency changes. No new Malayalam or
Sanskrit text.
