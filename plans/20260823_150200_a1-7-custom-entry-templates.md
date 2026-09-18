# Plan: A1.7 Templates the user can create

**Status:** completed
**Date:** 2026-08-23
**Feature:** A1.7 Templates the user can create

---

## 1. Context & Motivation

Diaries and journal habits are personal. While the built-in templates offer useful standard layouts, users need the ability to define their own custom templates tailored to their personal routines (such as daily standups, specialized logs, or custom reflection prompts).

Additionally, templates need dynamic date tokens (like `{{today}}` and `{{weekday}}`) so that when a new entry is started from a template, the title and content are automatically populated with the current date, day of the week, and formatted timestamps.

All template data must remain strictly local, private, and encrypted within the SQLCipher database.

---

## 2. Scope of Changes

### A. Database Schema & Migration (v8 -> v9)
- `lib/core/database/app_database.dart`:
  - Add `UserTemplates` table with columns: `id`, `name`, `description`, `defaultTitle`, `contentJson`, `createdAt`, `updatedAt`.
  - Bump `schemaVersion` from `8` to `9`.
  - Add migration in `migration.onUpgrade`: `if (from < 9) { await m.createTable(userTemplates); }`.
  - Add `UserTemplatesDao` with CRUD methods: `getAllUserTemplates()`, `getUserTemplateById(int id)`, `createUserTemplate(UserTemplatesCompanion companion)`, `updateUserTemplate(UserTemplate template)`, `deleteUserTemplate(int id)`.
  - Expose `UserTemplatesDao` in `AppDatabase`.
- `lib/core/database/database_providers.dart`:
  - Add `allUserTemplatesProvider` Stream/Future provider.

### B. Template Token Engine & Domain Models
- `lib/features/entries/templates/template_token_engine.dart`:
  - Create token resolver supporting `{{today}}`, `{{weekday}}`, `{{date}}`, `{{time}}`, `{{year}}`, `{{month}}`, `{{day}}`.
  - Safely resolve tokens in plain strings and inside Quill Delta JSON document structures without corrupting JSON formatting.
  - Expose token descriptors for UI helper chips and tooltips.
- `lib/features/entries/templates/entry_templates.dart`:
  - Add `EntryTemplateCategory.custom` ("My templates").
  - Extend `EntryTemplate` to support custom user-defined templates (storing optional `customId`, `isCustom`).
  - Add factory constructor `EntryTemplate.fromUserTemplate(UserTemplate ut)`.

### C. Presentation & UI
- `lib/features/entries/presentation/template_manager_screen.dart`:
  - Screen listing all custom templates with Create, Edit, Delete, and Preview options.
- `lib/features/entries/presentation/template_editor_screen.dart` (or dialog):
  - Form to create/edit custom templates with Name, Description, Default Title, Quill content editor, and quick-tap token insertion chips (`+ {{today}}`, `+ {{weekday}}`).
- `lib/features/entries/presentation/entry_template_chooser_dialog.dart`:
  - Display custom user templates under the "My templates" category group alongside built-in categories.
  - Add action button to navigate directly to template creation / manager.
- `lib/features/entries/presentation/entry_editor_screen.dart`:
  - Support passing custom `EntryTemplate` and resolving tokens on entry creation.
  - Add "Save as template" option in the editor overflow menu to easily convert any entry into a reusable custom template.
- `lib/app/app.dart`:
  - Wire custom template selection to entry creation.
  - Add navigation entry point to `TemplateManagerScreen` from home app bar / actions.

### D. Localization
- `lib/l10n/app_en.arb`:
  - Add all UI labels, tooltips, dialog titles, error messages, and token descriptions.
  - Run `flutter gen-l10n`.

### E. Tests
- `test/core/database/migration_test.dart`:
  - Add tests for v1 -> v9 and v8 -> v9 migration creating the `user_templates` table.
- `test/features/entries/template_token_engine_test.dart`:
  - Unit tests for token parsing and substitution in titles, plain text, and Quill delta JSON.
- `test/features/entries/user_templates_dao_test.dart`:
  - Unit tests for template CRUD operations in Drift.
- `test/features/entries/presentation/entry_template_chooser_dialog_test.dart`:
  - Widget tests for displaying and selecting custom templates.
- `test/features/entries/presentation/template_manager_screen_test.dart`:
  - Widget tests for template management screen (create, edit, delete).

---

## 3. Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis errors.
- Run `flutter test test/core/database/migration_test.dart`.
- Run `flutter test test/features/entries/`.
- Run `flutter test` across the full test suite.
