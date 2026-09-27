# Editor toolbar order, and the missing menu after "Select all"

**Status:** completed
**Change log:** `change_log/20260925_214308_editor-toolbar-order-and-select-all-menu.md`
**Note:** Approved with option C.

## The two problems

1. **The formatting toolbar is long and out of order.** It is one long strip that scrolls
   sideways. Undo and Redo are the very last buttons, so you must scroll to the far end to use
   them. The first things you see are three wide drop-downs (Normal, Font, Font size), which are
   used less than Bold or Undo. The strip also repeats two buttons that are already in the app
   bar (Focus paragraph and Distraction-free).
2. **After "Select all", the selection menu vanishes.** The text is selected, but no
   Copy / Cut / Bold menu shows.

## Why the menu vanishes

The popup menu is placed using two anchor points: the top of the selection and the bottom of
the selection. Our own code (`_adjustedSelectionAnchors` in
`lib/features/entries/presentation/entry_editor_actions_2.dart`) says: "if the top anchor is too
close to the formatting toolbar, show the menu under the bottom anchor instead."

After "Select all", the top of the selection is the first line, right under the toolbar, so the
code switches to the bottom anchor. But the bottom anchor is the **last line of the whole
entry**, far below the screen. The menu is drawn there, off-screen, so you never see it. The
same happens for any long selection whose end is off-screen.

## The fix

### A. Keep the selection menu on screen

File: `lib/features/entries/presentation/entry_editor_actions_2.dart`

In `_adjustedSelectionAnchors`, work out the visible band of the editor: from the bottom of the
formatting toolbar down to the bottom of the screen, minus the keyboard. Then:

- Clamp both anchors into that band, so neither can point off-screen.
- If the top anchor has no room above it (the current rule), use the bottom anchor, but clamped
  so the menu still fits above the bottom edge.

Result: after "Select all" (or any long selection) the menu shows inside the visible text area.
Short selections behave exactly as now.

### B. Re-order the toolbar

File: `lib/features/entries/presentation/editor/editor_toolbar.dart`

- **Undo and Redo pinned at the left**, outside the sideways-scrolling part, so they are always
  visible. A thin divider separates them from the rest.
- New order of the scrolling part, most-used first, grouped:
  1. Bold, Italic, Underline, Strikethrough
  2. Text colour, Highlight, Clear formatting
  3. Heading style (Normal), Font, Font size
  4. Bullet list, Numbered list, Checklist, Outdent, Indent, Tab
  5. Align left, centre, right, justify
  6. Link, Inline code, Code block, Quote, Subscript, Superscript
  7. Insert: Table, Callout, Image, Drawing, Scan text
- **Remove** the Focus-paragraph and Distraction-free buttons from the toolbar. They are already
  in the app bar, and the distraction-free screen has its own exit and focus buttons at the top,
  so nothing is lost. No test uses the toolbar copies.
- Table-cell behaviour is unchanged: buttons that do not work inside a table cell stay greyed
  out, and Undo/Redo still act on the cell.

No button is added, and no new text is needed, so no ARB change for part B.

### C. (Optional — please say yes or no) Translate the menu's format labels

The selection menu shows **Bold, Italic, Underline, Strike** as raw English strings in code
(`_formatContextMenuItem('Bold', ...)`), even in Malayalam and Sanskrit. This breaks the
localization rule. The fix adds four short `action…` keys to all three ARB files. The Malayalam
and Sanskrit words would be marked "needs native-reader review".

## Files to change

- `lib/features/entries/presentation/entry_editor_actions_2.dart` (A, and C if approved)
- `lib/features/entries/presentation/editor/editor_toolbar.dart` (B)
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (only if C is approved)
- A widget test for the toolbar order (Undo/Redo visible without scrolling), and a unit test for
  the anchor clamping.

## Acceptance checks

- Undo and Redo are visible on the toolbar without scrolling, on a phone in portrait.
- Select all in a long entry: the menu with Copy / Cut / Bold etc. is visible on screen.
- A short selection in the middle of the text: the menu shows above it, as before.
- A selection on the first line: the menu shows below it and does not cover the toolbar.
- Inside a table cell, the same buttons as before are greyed out.
- `flutter analyze` is clean and `flutter test` passes.
