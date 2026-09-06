# Editor: Tab button, and steady bottom bars while typing

Implements `plans/20260905_051500_editor-tab-key-and-bottom-bars.md`.

## What was wrong

* **No Tab in the body.** `flutter_quill` types a tab only from a hardware Tab
  key, and Android soft keyboards have none. The toolbar had no button for it,
  so on a phone a tab could not be typed at all.
* **The bottom bars jumped and covered the last line.** Everything after the
  editor's `Expanded` took height from the editor. `SmartTagChipBar` re-reads
  the live text on every keystroke and resolves a moment after typing pauses —
  the same moment the 2.5s auto-save fires, which is why it looked like an
  auto-save message. It grew from 0 to 48 px and shrank back again, resizing the
  editor each time. The mood row sat there permanently as well.

## What changed

### Tab

* `lib/features/entries/presentation/editor/editor_toolbar.dart` — new optional
  `onInsertTab` callback and a Tab `IconButton` (`Key('editor-insert-tab')`,
  `Icons.keyboard_tab`) next to the indent / outdent buttons.
* `lib/features/entries/presentation/entry_editor_screen.dart` — new
  `_insertTab()` replaces the selection with `'\t'` and moves the caret one
  place on. Wired into both toolbars (normal and distraction-free). A comment on
  `QuillEditorConfig` records that `enableAlwaysIndentOnTab` is left false on
  purpose, so a hardware Tab types a real tab rather than re-indenting. The
  value is not passed explicitly, because `avoid_redundant_argument_values`
  rejects restating a default.

### Steady bottom while typing

* `lib/features/entries/presentation/entry_editor_screen.dart`
  * A listener on `_editorFocusNode` rebuilds the screen on focus change, and
    `_isTyping` reports whether the caret is in the body. The listener is
    removed in `dispose`.
  * While `_isTyping`, `SmartTagChipBar`, `_LinkedFromPanel` and
    `_AttachmentTray` are not built. They come back as soon as the caret leaves
    the body. Nothing under the editor can change height mid-keystroke now, so
    the jumping and the hidden last line are both gone.
  * `EditorStatsBar` stays on screen but is now `compact: true` here too. It has
    a fixed height, so it cannot cover anything, and compact gives the editor a
    little more room.
  * The mood row is out of the column. `_showMoodPicker()` opens it in a modal
    bottom sheet from a new mood button in `_BottomActionBar`
    (`Key('entry-mood-button')`), which shows the chosen face or
    `Icons.mood_outlined` when none is set. The choice is applied in the
    callback rather than through the sheet's return value, because clearing a
    mood and swiping the sheet away would both return null.
  * `_MoodPickerRow` gained a `faceFor(level)` helper so the button can show the
    same emoji as the chips. Its widget keys are unchanged.

### Strings

* `lib/l10n/app_en.arb` — `editorInsertTab` ("Insert tab") and
  `entryMoodTooltip` ("Set mood"), each with its `@` description.
  `lib/l10n/app_localizations*.dart` regenerated with `flutter gen-l10n`.

### Tests

* New `test/features/entries/presentation/entry_editor_bottom_bars_test.dart`:
  the Tab button inserts `\t` at the caret and moves the caret; the smart-tag
  bar is absent while the body has focus and present when it does not; the mood
  picker is not on screen until its button is tapped, and picking a level closes
  the sheet and marks the entry unsaved.

## Checks

`flutter analyze` — no issues. `flutter test` — 796 tests, all pass.
`dart format lib test integration_test` clean.
