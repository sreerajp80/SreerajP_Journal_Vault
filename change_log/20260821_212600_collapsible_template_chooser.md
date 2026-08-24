# Expandable and Collapsible Entry Template Chooser

**Plan:** `plans/20260821_211500_collapsible_template_chooser.md`

## Summary of Changes

Implemented interactive expandable/collapsible category sections and an **Expand all** / **Collapse all** button in the entry template chooser dialog.

1. **`lib/features/entries/presentation/entry_template_chooser_dialog.dart`**:
   - Created `EntryTemplateChooserDialog` with state tracking for expanded category groups.
   - Initialized the dialog with the "Start fresh" category expanded by default and others collapsed to keep the dialog compact and scannable.
   - Added category headers displaying category icon, title, item count badge, and animated chevron.
   - Added top header with an **Expand all** / **Collapse all** toggle button.
   - Added footer with a Cancel button.

2. **`lib/app/app.dart`**:
   - Replaced the previous monolithic `_EntryTemplateChooserDialog` with `EntryTemplateChooserDialog` from `features/entries`.

3. **`lib/l10n/app_en.arb`**:
   - Added `templateExpandAll` ("Expand all") and `templateCollapseAll` ("Collapse all") localization keys.

4. **`test/features/entries/presentation/entry_template_chooser_dialog_test.dart`**:
   - Added comprehensive widget tests verifying initial expansion, individual category expansion/collapse, expand/collapse all functionality, template selection, and cancellation.

## Verification

- `flutter gen-l10n` regenerated localizations.
- `flutter test` passed all 624 tests across unit and widget suites.
- `flutter analyze` completed with 0 errors/warnings.
- `dart format` applied across the project.
