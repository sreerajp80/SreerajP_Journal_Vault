# Change Log: Custom Entry Templates with Date Tokens (A1.7)

**Date:** 2026-08-23
**Plan reference:** [`plans/20260823_150200_a1-7-custom-entry-templates.md`](../plans/20260823_150200_a1-7-custom-entry-templates.md)

---

## What was changed

### 1. Database Schema Upgrade (v8 -> v9)
- Added `UserTemplates` Drift table and `UserTemplatesDao` in `lib/core/database/app_database.dart` with support for custom template names, optional descriptions, optional default titles, Quill Delta JSON starter content, and created/updated timestamps.
- Added database providers `allUserTemplatesProvider` and `userTemplatesStreamProvider` in `lib/core/database/database_providers.dart`.
- Implemented clean schema migration to create `user_templates` when upgrading to version 9 in `onUpgrade`.
- Updated schema migration tests in `test/core/database/migration_test.dart`.

### 2. Token Engine & Dynamic Substitution
- Created `TemplateTokenEngine` in `lib/features/entries/templates/template_token_engine.dart` to support tokens:
  - `{{today}}` -> YYYY-MM-DD
  - `{{weekday}}` -> Full weekday name (e.g., Monday)
  - `{{date}}` -> Locale/ISO date
  - `{{time}}` -> HH:mm 24-hour time
  - `{{year}}` -> YYYY
  - `{{month}}` -> MM (01-12)
  - `{{day}}` -> DD (01-31)
- Implemented safe JSON delta traversal so tokens inside Quill Delta operations are cleanly substituted on entry creation without corrupting formatting.

### 3. Template Management and Creation UI
- Created `TemplateManagerScreen` in `lib/features/entries/presentation/template_manager_screen.dart` to list, preview, edit, and delete custom templates.
- Created `TemplateEditorScreen` in `lib/features/entries/presentation/template_editor_screen.dart` with form validation, one-tap token insertion chips into title/content fields, and full rich text editing capabilities.
- Added "Save as template" action to the entry editor app bar in `lib/features/entries/presentation/entry_editor_screen.dart`.
- Added custom template category and entries into the collapsible `EntryTemplateChooserDialog` in `lib/features/entries/presentation/entry_template_chooser_dialog.dart`.
- Added template management shortcut to the home journal app bar and integrated template resolution in `lib/app/app.dart`.

### 4. Localization
- Added full localization strings for template management, editor, tokens, and dialogs in `lib/l10n/app_en.arb`.

### 5. Automated Tests
- Added unit tests for token replacement in `test/features/entries/template_token_engine_test.dart`.
- Added DAO CRUD and stream tests in `test/features/entries/user_templates_dao_test.dart`.
- Added widget tests for template manager in `test/features/entries/presentation/template_manager_screen_test.dart`.
- Added widget tests for template editor in `test/features/entries/presentation/template_editor_screen_test.dart`.
- Updated template chooser and registry tests in `test/features/entries/presentation/entry_template_chooser_dialog_test.dart` and `test/features/entries/entry_templates_test.dart`.

---

## Verification

- `flutter analyze` completed with 0 errors and 0 warnings.
- `flutter test` passed all 686 automated tests.
- Code formatted with `dart format lib test integration_test`.
