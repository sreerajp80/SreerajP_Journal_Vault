# Editor toolbar order, and the missing menu after "Select all"

**Plan:** `plans/20260925_213657_editor-toolbar-order-and-select-all-menu.md` (approved, with the
optional translation fix)

## What changed

### Selection menu no longer vanishes after "Select all"

- New file `lib/features/entries/presentation/editor/selection_menu_anchors.dart` with
  `clampSelectionMenuAnchors`. It keeps the popup inside the visible band between the formatting
  toolbar and the keyboard.
- `_adjustedSelectionAnchors` in `lib/features/entries/presentation/entry_editor_actions_2.dart`
  now uses it. Before, when the selection started right under the toolbar, the menu was moved
  under the selection's end, which for "Select all" was far below the screen. Now, if that end
  is out of view, the menu shows just under the toolbar. Short selections behave as before.

### Toolbar re-ordered

`lib/features/entries/presentation/editor/editor_toolbar.dart`:

- Undo and Redo are pinned at the left, outside the sideways-scrolling part, so they are always
  visible.
- The scrolling part is now grouped, most-used first: Bold/Italic/Underline/Strike → colours and
  clear formatting → heading, font, font size → lists, indent, tab → alignment →
  link, code, quote, sub/superscript → insert buttons (table, callout, image, drawing, scan).
- The Focus-paragraph and Distraction-free buttons were removed from the toolbar, with their
  constructor parameters. Both are still in the app bar, and the distraction-free screen keeps its
  own exit and focus buttons. Callers in `entry_editor_screen.dart` and
  `entry_editor_layout.dart` were updated.
- Table-cell behaviour is unchanged.

### Selection menu labels translated

The Bold / Italic / Underline / Strike items in the selection menu were raw English strings.
They now use four new keys in all three ARB files:

| Key | en | ml | sa |
|---|---|---|---|
| `actionEditorBold` | Bold | ബോൾഡ് | स्थूलम् |
| `actionEditorItalic` | Italic | ഇറ്റാലിക് | तिर्यक् |
| `actionEditorUnderline` | Underline | അടിവര | अधोरेखा |
| `actionEditorStrike` | Strike | വെട്ടുക | छेदरेखा |

**Needs native-reader review:** all four Malayalam and all four Sanskrit terms.

## Tests

- New `test/features/entries/presentation/editor/editor_toolbar_test.dart`: Undo/Redo are on
  screen at 360 px wide without scrolling, sit before the other buttons, and are outside the
  scroll view; the removed toggles are gone and the insert buttons remain.
- New `test/features/entries/presentation/editor/selection_menu_anchors_test.dart`: covers a
  middle selection, a selection under the toolbar, "Select all" with the end off-screen, and
  selections that start above the screen.
- `flutter analyze`: no issues. `flutter test`: all pass except
  `sync_engine_wifi_test.dart`, which failed once in the full run and passes when run on its
  own; it is timing-sensitive and not touched by this change.
- `tool/check_sanskrit_markers.sh` and `tool/check_keyboard_incognito.sh` pass.
