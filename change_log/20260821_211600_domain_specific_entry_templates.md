# Change Log — Domain-Specific & Topic Entry Templates

**Date:** 2026-08-21
**Plan:** `plans/20260821_211300_domain_specific_entry_templates.md`

## Summary of changes

Added 6 domain-specific and detailed topic predefined templates to give users structured starting points for specialized note-taking.

### Added Templates:
1. **Topic Deep Dive** (`EntryTemplateId.topicDeepDive`, Category: `learning`):
   - Structured sections for topic concept, key principles, analysis, takeaways, and open questions.
2. **System Administration** (`EntryTemplateId.sysadminRunbook`, Category: `specialty`):
   - Structured sections for system/service, architecture, configuration & commands, health checks, and rollback/troubleshooting.
3. **Sanathana Dharma Study** (`EntryTemplateId.sanathanaDharmaStudy`, Category: `specialty`):
   - Structured sections for scripture reference, shloka/mantra, word breakdown & meaning, tatva (philosophical insights), and daily sadhana reflection.
4. **DIY & Maker Project** (`EntryTemplateId.diyProject`, Category: `specialty`):
   - Structured sections for project goal & scope, tools & materials required, step-by-step procedure, safety & precautions, and testing & lessons learned.
5. **Home & Maintenance** (`EntryTemplateId.homeMaintenance`, Category: `specialty`):
   - Structured sections for area/item, issue/task, service history & costs, warranty & vendor info, and next scheduled check.
6. **Kitchen & Recipe** (`EntryTemplateId.kitchenRecipe`, Category: `specialty`):
   - Structured sections for dish name, cuisine, prep/cook time, ingredients & quantities, step-by-step method, and chef notes.

### Files modified:
- `lib/features/entries/templates/entry_templates.dart` — Registered new template IDs and added rich JSON deltas.
- `test/features/entries/entry_templates_test.dart` — Added test assertions verifying template availability, default titles, and delta formatting.

## Verification
- `flutter analyze` passed with 0 issues.
- `flutter test` passed with all 619 tests green.
- `dart format` applied.
