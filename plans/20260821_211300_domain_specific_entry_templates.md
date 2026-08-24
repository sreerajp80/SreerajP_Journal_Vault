# Domain-Specific and Detailed Topic Entry Templates

**Status:** completed

## The issue

Users need structured, domain-specific templates to quickly draft comprehensive, organized notes on specialized topics such as System Administration, Sanathana Dharma & Spiritual Study, DIY & Maker Projects, Home & Appliance Maintenance, Kitchen & Cooking Recipes, and general In-depth Topic Study.

Currently, the app only provides generic or high-level templates (e.g., Blank, My Thoughts, Daily Reflection, Book Notes, Meeting Notes), requiring users to manually construct structured sections for specialized topics.

## The plan

### 1. Add New Domain-Specific Templates to `entry_templates.dart`

Add the following new enum values to `EntryTemplateId`:
1. `sysadminRunbook` — System administration, server configs, CLI commands, and maintenance runbooks.
2. `sanathanaDharmaStudy` — Scripture, shloka/mantra, tatva/meaning, commentary, and sadhana reflection.
3. `diyProject` — DIY and maker projects, materials, tools, steps, and safety precautions.
4. `homeMaintenance` — Home repairs, appliance upkeep, service history, and warranties.
5. `kitchenRecipe` — Recipes, prep/cook times, ingredients, instructions, and chef tips.
6. `topicDeepDive` — Comprehensive research notes, core concepts, analysis, and takeaways.

### 2. Define Template Structures & Default JSON Deltas

Each template will have clear, structured sections with bold headers and spacing for easy note taking:
- **System Administration**: System/Service, Objective, Configuration & Commands, Verification & Health Checks, Troubleshooting.
- **Sanathana Dharma Study**: Topic/Scripture, Shloka/Mantra, Meaning & Word Breakdown, Philosophical Insights (Tatva), Sadhana & Practical Application.
- **DIY & Maker Project**: Goal/Scope, Tools & Materials, Step-by-Step Procedure, Safety & Precautions, Results & Improvements.
- **Home & Maintenance**: Item/Appliance, Issue/Task, Service & Cost Details, Warranty/Vendor Info, Next Maintenance Date.
- **Kitchen & Recipe**: Dish Name & Cuisine, Prep & Cook Time, Ingredients & Quantities, Step-by-Step Method, Chef Notes & Variations.
- **Topic Deep Dive**: Topic & Core Concept, Key Principles, Detailed Analysis, Key Takeaways & References, Open Questions.

### 3. Update Tests

- Update `test/features/entries/entry_templates_test.dart` to verify all new template IDs are properly registered, grouped, have valid Quill JSON deltas, and can be resolved by `templateFor(id)`.
- Ensure all existing tests pass with zero regressions.

## Files to change

| File | Change |
|---|---|
| `lib/features/entries/templates/entry_templates.dart` | Add new enum values, template metadata, and JSON deltas |
| `test/features/entries/entry_templates_test.dart` | Update unit tests to verify new templates |

## Out of scope
- Dynamic user-created custom templates (this change focuses on built-in predefined templates).
- Modifying database schemas or tables.

## Checks before done
- `flutter analyze` clean (0 warnings / errors)
- `flutter test` green (all tests passing)
- `dart format lib test integration_test` formatted
- Write change log to `change_log/`
