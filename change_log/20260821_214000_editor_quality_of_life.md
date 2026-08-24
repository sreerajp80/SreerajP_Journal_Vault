# Change Log: A1.5 Editor Quality of Life

**Plan:** `plans/20260821_212800_editor_quality_of_life.md`  
**Date:** 2026-08-21  

---

## Summary of Changes

Implemented the A1.5 editor quality-of-life bundle for the entry editor:

1. **Word and Character Count**:
   - Added live word and character counters in the editor bottom stats bar (`EditorStatsBar`).
   - Counts update automatically and accurately as the user writes or edits text.

2. **Auto-Save Indicator with Timestamp**:
   - Added automatic 2.5-second debounced background saving for pending changes.
   - Displayed live auto-save state badges ("Saving…", "Saved at 10:45 AM", "Unsaved changes") in `EditorStatsBar`.

3. **Markdown Shortcuts While Typing**:
   - Created `EditorMarkdownShortcuts` to automatically expand Markdown prefixes at line starts into Quill rich-text block formats:
     - `# `, `## `, `### `, `#### `, `##### `, `###### ` -> Headings 1 to 6
     - `- `, `* `, `+ ` -> Bullet list
     - `1. `, `1) ` -> Numbered list
     - `[] `, `[ ] ` -> Checklist
     - `> ` -> Blockquote
     - ```` ``` ```` -> Code block

4. **Distraction-Free Full-Screen Writing Mode**:
   - Added full-screen distraction-free mode toggle in the AppBar and toolbar.
   - Hides peripheral panels and app bars, providing an immersive, serene writing canvas.

5. **Focus Paragraph Dim Mode**:
   - Added toggleable focus paragraph mode in the AppBar and toolbar.
   - Visually highlights the active writing area with subtle accent border and background focus styling.

6. **Tests & Localization**:
   - Added comprehensive unit tests in `test/features/entries/editor/editor_markdown_shortcuts_test.dart` and `test/features/entries/editor/editor_stats_bar_test.dart`.
   - Added all necessary user-facing strings to `lib/l10n/app_en.arb`.

---

## Files Added and Modified

- `lib/features/entries/presentation/editor/editor_markdown_shortcuts.dart` (New)
- `lib/features/entries/presentation/editor/editor_stats_bar.dart` (New)
- `lib/features/entries/presentation/editor/editor_toolbar.dart` (Modified)
- `lib/features/entries/presentation/entry_editor_screen.dart` (Modified)
- `lib/l10n/app_en.arb` (Modified)
- `docs/enhancement_ideas.md` (Modified)
- `test/features/entries/editor/editor_markdown_shortcuts_test.dart` (New)
- `test/features/entries/editor/editor_stats_bar_test.dart` (New)
- `plans/20260821_082000_editor_quality_of_life.md` (Modified)

---

## Verification

- `flutter gen-l10n`: Regenerated localizations without errors.
- `flutter test`: 641 tests passed including all 17 new editor tests.
- `flutter analyze`: Static analysis clean with 0 issues.
- `dart format lib test`: Code formatted.
