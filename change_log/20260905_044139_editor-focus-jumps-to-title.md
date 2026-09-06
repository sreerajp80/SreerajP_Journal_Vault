# Change log — body editor keeps its focus while typing

Implements: `plans/20260905_043613_editor-focus-jumps-to-title.md`

## The problem

Pressing backspace in the body of an entry deleted one character and then moved the
keyboard focus to the title field.

`QuillEditor.basic` in `flutter_quill` 11.5.x creates a **new `FocusNode` and a new
`ScrollController` on every build** when it is not given them. The entry editor rebuilds
on nearly every edit (the live word/character counter calls `setState`), so the body
editor got a fresh, unfocused node each time. Focus then fell back to the first focusable
widget on the screen — the title field. Each keystroke also leaked a `FocusNode` and a
`ScrollController`.

## What changed

### `lib/features/entries/presentation/entry_editor_screen.dart`

- Added two long-lived state fields, `_editorFocusNode` and `_editorScrollController`.
- Passed both into `QuillEditor.basic(...)` for the body editor.
- Disposed both in `dispose()`.

### `lib/features/entries/presentation/template_editor_screen.dart`

- Same fix for the template body editor: `_bodyFocusNode` and `_bodyScrollController`,
  passed in and disposed.

### `lib/features/entries/presentation/version_history_screen.dart`

- Same fix for the read-only revision preview: `_previewFocusNode` and
  `_previewScrollController`. This screen is read-only, so it had no focus jump, but it
  leaked a pair of objects per rebuild and could lose its scroll position.

### `test/features/entries/presentation/entry_editor_focus_test.dart` (new)

- A widget test that opens the entry editor, focuses the body, types text, deletes one
  character, and then asserts the editor still holds the same `FocusNode` and
  `ScrollController` and still has focus.
- Checked against the old code: the test fails without the fix and passes with it.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 782 tests pass, including the new one.
- No behaviour changed beyond focus and scroll ownership. Saving, auto-save, Markdown
  shortcuts, embeds and layout are untouched.
