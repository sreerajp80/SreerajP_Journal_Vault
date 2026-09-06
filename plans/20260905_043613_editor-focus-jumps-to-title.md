# Fix: backspace in the body deletes one character, then focus jumps to the title

**Status:** completed

## Files to be changed

- `lib/features/entries/presentation/entry_editor_screen.dart`
- `lib/features/entries/presentation/template_editor_screen.dart`
- `lib/features/entries/presentation/version_history_screen.dart`
- `test/features/entries/presentation/entry_editor_focus_test.dart` (new)

## What the issue is

While writing in the body of an entry, pressing backspace deletes one character and
then the keyboard focus moves to the title field. The user has to tap back into the
body for every deletion.

The cause is in how the body editor is built. In
[entry_editor_screen.dart:895](lib/features/entries/presentation/entry_editor_screen.dart#L895)
the body is created with `QuillEditor.basic(...)` and no `focusNode` or
`scrollController`.

In `flutter_quill` 11.5.x, `QuillEditor.basic` is a factory that fills the gaps like this:

```dart
focusNode: focusNode ?? FocusNode(),
scrollController: scrollController ?? ScrollController(),
```

So **every time `build()` runs, the editor gets a brand new `FocusNode` and a brand new
`ScrollController`.**

The screen rebuilds on almost every edit:

- `_updateStats()` calls `setState` whenever the word or character count changes.
- `_markDirty()` calls `setState` when the entry first becomes dirty.

When the rebuild swaps in a fresh, unfocused `FocusNode`, the body editor loses focus.
The focus scope then falls back to the first focusable widget in the `Column`, which is
the title `TextField` — so the caret visibly jumps to the title. The old `FocusNode` and
`ScrollController` are also never disposed, so each keystroke leaks two objects.

The same `QuillEditor.basic` pattern is used in the template editor
(`template_editor_screen.dart:377`) and in the read-only version preview
(`version_history_screen.dart:289`), so both carry the same defect. The template editor
can show the same focus jump; the version preview is read-only, so there it is only a
leak.

## The plan for the fix

1. **`entry_editor_screen.dart`**
   - Add two long-lived fields to the state class:
     `final FocusNode _editorFocusNode = FocusNode(debugLabel: 'EntryBodyEditor');`
     and `final ScrollController _editorScrollController = ScrollController();`
   - Pass both into `QuillEditor.basic(...)` so the editor keeps one stable focus node
     and one stable scroll position for the life of the screen.
   - Dispose both in `dispose()`.

2. **`template_editor_screen.dart`** — the same three steps for its body editor.

3. **`version_history_screen.dart`** — the same three steps for the preview editor. It
   is read-only, but the stable node and controller stop the per-build leak and keep the
   scroll position steady across rebuilds.

4. **Test** — add a widget test that opens the entry editor, taps into the body, types a
   character, presses backspace, and asserts that the body editor's focus node still has
   focus (and the title field does not). This locks the behaviour in.

Nothing else changes: no change to save, auto-save, Markdown shortcuts, embeds, or
layout. This is a scoped fix to focus and scroll ownership.

## How it will be verified

- `flutter analyze` clean.
- `flutter test` passes, including the new test.
- Manual check on a device: type in the body, press backspace several times, and confirm
  the caret stays in the body and the keyboard stays up.
