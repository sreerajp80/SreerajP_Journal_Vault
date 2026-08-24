# Plan: A1.5 Editor Quality of Life

**Status:** Implemented

## Overview
Implement the A1.5 editor quality-of-life bundle for the entry editor:
1. **Word and character count**: Live word and character count indicator in the editor.
2. **Distraction-free full-screen writing mode**: A dedicated writing mode that hides peripheral panels, toolbars, and app chrome for pure focus.
3. **Focus paragraph dim**: A toggleable mode that visually emphasizes the active paragraph while dimming surrounding context.
4. **Auto-save indicator with timestamp**: Debounced background auto-save that updates a timestamped status badge without interrupting typing.
5. **Markdown-style shortcuts while typing**: Automatic expansion of Markdown prefixes (`# `, `## `, `### `, `- `, `* `, `+ `, `1. `, `[] `, `> `, ```` ``` ````) into Quill rich-text block formats.

---

## Files to Create & Modify

### New Files
- `lib/features/entries/presentation/editor/editor_markdown_shortcuts.dart`: Handles live conversion of Markdown shorthand prefixes into rich-text block formatting.
- `lib/features/entries/presentation/editor/editor_stats_bar.dart`: Compact status and stats bar showing word count, character count, and auto-save state.
- `test/features/entries/editor/editor_markdown_shortcuts_test.dart`: Unit tests for all Markdown shortcut conversions and edge cases.
- `test/features/entries/editor/editor_stats_bar_test.dart`: Unit tests for word/character calculations and status indicators.

### Modified Files
- `lib/l10n/app_en.arb`: Add localized strings for word counts, character counts, auto-save states, distraction-free mode, and focus paragraph mode.
- `lib/features/entries/presentation/entry_editor_screen.dart`:
  - Integrate Markdown shortcut listener.
  - Add debounced auto-save timer and status tracking (`saved`, `saving`, `unsaved`).
  - Add word and character count calculation.
  - Implement full-screen distraction-free mode toggle.
  - Implement focus paragraph dim mode toggle.
- `lib/features/entries/presentation/editor/editor_toolbar.dart`: Add quick toggle buttons for distraction-free mode and focus paragraph mode.
- `docs/enhancement_ideas.md`: Mark A1.5 as completed.

---

## Step-by-Step Implementation Details

### 1. Markdown Shortcut Handler (`editor_markdown_shortcuts.dart`)
- Listens to document changes (`DocChange` where `change.source == ChangeSource.local`).
- Checks if the current line before the cursor matches a Markdown shortcut prefix:
  - `# ` -> Level 1 Header (`Attribute.h1`)
  - `## ` -> Level 2 Header (`Attribute.h2`)
  - `### ` -> Level 3 Header (`Attribute.h3`)
  - `#### ` -> Level 4 Header (`Attribute.h4`)
  - `##### ` -> Level 5 Header (`Attribute.h5`)
  - `###### ` -> Level 6 Header (`Attribute.h6`)
  - `- `, `* `, `+ ` -> Bullet List (`Attribute.ul`)
  - `1. `, `1) ` -> Numbered List (`Attribute.ol`)
  - `[] `, `[ ] ` -> Checklist (`Attribute.unchecked`)
  - `> ` -> Blockquote (`Attribute.blockQuote`)
  - ```` ``` ```` -> Code Block (`Attribute.codeBlock`)
- Replaces the trigger characters and applies the block format to the line cleanly, with re-entrancy protection.

### 2. Auto-Save with Timestamp Indicator
- Tracks editor save state:
  - `idle / saved`: Shows timestamp e.g. "Saved at 10:45 AM" or "Saved just now".
  - `unsaved / dirty`: Shows "Unsaved changes" and schedules debounced save.
  - `saving`: Shows "Saving…".
- Implements a debounced auto-save timer (2.5 seconds after the user stops typing while dirty).
- Updates smoothly on manual save or auto-save without showing disruptive snackbars on auto-saves.

### 3. Word and Character Count (`editor_stats_bar.dart`)
- Calculates words and characters from `controller.document.toPlainText()`.
- Word count: counts non-empty whitespace-separated tokens.
- Character count: counts document characters excluding the trailing newline.
- Formats cleanly: e.g. "124 words • 780 characters".

### 4. Distraction-Free Full-Screen Mode
- Toggleable via AppBar action and toolbar button.
- When enabled:
  - Hides AppBar, attachment tray, linked-from backlinks, mood picker, smart tags, and bottom action bar.
  - Renders a clean minimalist header bar with Back/Exit button, live word count, save indicator, and focus paragraph toggle.
  - Provides a distraction-free typing area.

### 5. Focus Paragraph Dim Mode
- Toggleable via action/toolbar button.
- When enabled, highlights the active paragraph / line while dimming the surrounding container and unfocused sections with a subtle focus vignette and contrast effect.

---

## Verification Plan

### Automated Tests
- Run `flutter test test/features/entries/editor/editor_markdown_shortcuts_test.dart`
- Run `flutter test test/features/entries/editor/editor_stats_bar_test.dart`
- Run all existing tests: `flutter test`
- Run static analysis: `flutter analyze`
- Run l10n generation: `flutter gen-l10n`

### Manual Verification
- Test typing Markdown shortcuts (`# `, `## `, `- `, `1. `, `[] `, `> `) in the entry editor and verify instant block formatting.
- Verify word and character counts update in real-time as text is added or deleted.
- Verify debounced auto-save triggers after 2.5 seconds and updates the timestamp badge.
- Toggle distraction-free mode and verify all peripheral widgets hide smoothly and exit returns properly.
- Toggle focus paragraph dim mode and verify active focus styling.
