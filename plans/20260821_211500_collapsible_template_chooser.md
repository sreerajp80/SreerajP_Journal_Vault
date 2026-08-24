# Expandable and Collapsible Entry Template Chooser

**Status:** completed

## The issue

The app has over 40 structured entry templates organized across 10 categories. In the new-entry template chooser dialog, all categories and templates are displayed at once in one long scrolling dialog. This makes it difficult for users to scan, find, and pick their preferred template without scrolling through a long list.

Users need the ability to:
1. Expand and collapse each category group individually.
2. Quickly expand all or collapse all groups with a single tap.

## The plan

### 1. Extract and Refactor `EntryTemplateChooserDialog`

Create a dedicated widget in `lib/features/entries/presentation/entry_template_chooser_dialog.dart` that replaces the static SimpleDialog list with a clean, collapsible list:
- Maintain an active expansion state (`Set<EntryTemplateCategory> _expandedCategories`).
- Start with the first/primary category (`general` / 'Start fresh') expanded by default, keeping the dialog compact and immediately showing basic choices while reducing vertical clutter.
- Render each category with a header showing the category label, template count badge, and expand/collapse indicator chevron.
- Tapping a category header toggles its expansion.
- In the dialog header or action bar, provide an "Expand all" / "Collapse all" toggle button (or quick action buttons) allowing users to expand or collapse all categories at once.
- Tapping any template returns the chosen `EntryTemplate` via `Navigator.pop(context, template)`.

### 2. Localization

Add localization strings to `lib/l10n/app_en.arb`:
- `templateExpandAll`: "Expand all"
- `templateCollapseAll`: "Collapse all"

Run `flutter gen-l10n` to regenerate `AppLocalizations`.

### 3. Update `lib/app/app.dart`

- Import `package:sreerajp_journal_vault/features/entries/presentation/entry_template_chooser_dialog.dart`.
- Update `_openEntryScreen` to use the new `EntryTemplateChooserDialog`.
- Remove the old private `_EntryTemplateChooserDialog`.

### 4. Tests

Create `test/features/entries/presentation/entry_template_chooser_dialog_test.dart`:
- Verify dialog renders category headers and initial default expansion.
- Verify tapping a category expands and collapses its templates.
- Verify tapping "Expand all" expands all category groups.
- Verify tapping "Collapse all" collapses all category groups.
- Verify tapping a template selects and returns it.
- Run all existing widget and unit tests to ensure no regressions.

## Files to change

| File | Change |
|---|---|
| `lib/l10n/app_en.arb` | Add `templateExpandAll` and `templateCollapseAll` localization keys |
| `lib/features/entries/presentation/entry_template_chooser_dialog.dart` | [NEW] Implement interactive, collapsible template chooser dialog |
| `lib/app/app.dart` | Use `EntryTemplateChooserDialog` from `features/entries` |
| `test/features/entries/presentation/entry_template_chooser_dialog_test.dart` | [NEW] Add widget tests for expand/collapse and selection |

## Out of scope
- Changing the predefined templates themselves or their content.
- Database schema changes.

## Checks before done
- `flutter gen-l10n` executed
- `flutter analyze` clean (0 warnings / errors)
- `flutter test` green (all tests passing)
- `dart format lib test integration_test` formatted
- Write change log to `change_log/`
