# Change log — Housekeeping from the 2026-09-27 project review (items 9–13)

**Plan:** `plans/20260927_120343_housekeeping-review-items.md`

## What changed

### Item 9 — Plan status lines

- 22 plans now have one allowed status value on their `**Status:**` line. 21 are `completed`.
  `20260924_081200_fix-dictation-repeated-lines.md` is `dropped`, because in-app dictation was
  removed on 2026-09-24.
- Change-log links and notes that were on the status line moved to their own
  `**Change log:**` or `**Note:**` line right below it. Missing change-log links were added for
  the three About-screen plans, the three table/OCR plans marked "Approved", Markdown paste, the
  toolbar plan, and the no-relock plan. Each change log was opened first to confirm it names that
  plan.
- 19 older plans that already said `completed` had a trailing space (or were being read with a
  stray `\r`). The space was trimmed. Git shows a diff only for the 7 files with a real trailing
  space; for the others the text is unchanged.
- Every plan in `plans/` now uses `completed`, `dropped`, `partial_completion` or `in_progress`.

### Item 10 — `CHANGELOG.md`

The `[Unreleased]` section was rewritten from the 94 change logs written since 2026-08-18. It now
lists, in user terms: Malayalam and Sanskrit, OCR, voice notes, drawings, tables, rich and Markdown
paste, templates, Wi-Fi Sync, AirQR, time capsules, ritual mode, reading themes, encrypted export,
backup restore, the new lock screen and Settings layout, the database encryption, keyboard
privacy, and temporary-file clean-up. The earlier items were kept. In-app dictation is not listed,
because it was added and removed before any release. A "Known issues" note warns that Wi-Fi Sync
does not yet handle attachments and journal links correctly.

### Item 11 — Junk files

Deleted two empty (0-byte) files at the project root, after checking they were still empty:

- `libfeaturesbackupservicesbackup_restore_steps.dart.tmp`
- `libfeaturesentriespresentationocr_camera_controls.dart.tmp`

### Item 12 — Imported template name

- `AirqrSettingsService.applySettings` (`lib/features/airqr/providers/airqr_providers.dart`) has a
  new required named parameter, `fallbackTemplateName`. It replaces the English literal
  `'Custom Template'`. A name that is only spaces is treated as missing too.
- `lib/features/airqr/presentation/airqr_receive_views.dart` passes
  `l10n.labelImportedTemplateName`.
- New ARB key `labelImportedTemplateName` in all three files, with an `@` description in
  `app_en.arb`:
  - en: `Imported template`
  - ml: `ഇറക്കുമതി ചെയ്ത മാതൃക` — **needs native-reader review**
  - sa: `आनीतं प्रारूपम्` — **needs native-reader review**
- `flutter gen-l10n` was run.
- New test `test/features/airqr/airqr_settings_service_test.dart`. It checks that a template with
  no name, and one with a blank name, get the name passed in, and a named one keeps its name.

### Item 13 — `docs/architecture.md`

The "Keyboard learns journal text" row moved out of the "Closed on 2026-07-25" table into a new
sub-section, "Closed on 2026-09-24 — keyboard privacy", after the 2026-09-19 sub-section. Its text
is unchanged.

## Checks

- `dart format`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 1,108 tests pass (one more than before: the new AirQR test).
- `sh tool/check_sanskrit_markers.sh`: passed.
- `sh tool/check_absolute_paths.sh --all`: passed.
