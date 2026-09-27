# Plan — Housekeeping from the 2026-09-27 project review (items 9–13)

**Status:** completed
**Change log:** `change_log/20260927_121331_housekeeping-review-items.md`

## Background

A review of the project on 2026-09-27 found five small housekeeping problems. None of them changes
how the app behaves for a user, except item 12, which fixes one English word that shows in
Malayalam and Sanskrit.

---

## Item 9 — Plan status lines are stale or use the wrong words

### Issue

The workflow rules allow only these status values: `draft`, `approval_pending`, `in_progress`,
`completed`, `dropped`, `partial_completion`. 22 plans use other words ("Implemented",
"Approved", "Awaiting approval", "planned"), often with a change-log link on the same line.
Several of them were finished long ago, but the status line still says they are waiting.

### Fix

Set the `**Status:**` line to one allowed value. When the old line had a change-log link or a
note, move it to a new line right under the status: `**Change log:** <path>` or `**Note:** <text>`.
No other part of any plan changes.

| Plan | Old status | New status | Reason |
|---|---|---|---|
| `20260918_043618_about-author-transliteration.md` | Awaiting approval | `completed` | `change_log/20260918_044900_about-author-transliteration.md` exists |
| `20260918_045400_localize-app-name.md` | Awaiting approval | `completed` | `change_log/20260918_050600_localize-app-name.md` exists |
| `20260918_050147_localize-about-ai-ide-rows.md` | Awaiting approval | `completed` | `change_log/20260918_050453_localize-about-ai-ide-rows.md` exists |
| `20260918_061500_scan-source-two-rows.md` | Implemented — see … | `completed` | link moved to `**Change log:**` |
| `20260918_070527_ocr-accuracy-image-cleanup.md` | Implemented — see … | `completed` | same |
| `20260918_074147_ocr-noise-regression-fix.md` | Implemented — see … | `completed` | same |
| `20260918_201309_ocr-keep-short-key-column.md` | Implemented (revised version) — see … | `completed` | link and "revised version" note moved |
| `20260918_215329_ocr-edit-enlarge-sharpen-screen-filter.md` | Implemented — see … | `completed` | link moved |
| `20260919_122638_fix-content-under-nav-bar.md` | completed — see … | `completed` | link moved |
| `20260919_195847_dictation-direct-insert-and-cleanup.md` | completed (real-phone check pending) | `completed` | note moved; dictation was later removed, so the check no longer applies — say so in the note |
| `20260922_071800_fix_table_embed_usability.md` | Approved | `completed` | `change_log/20260922_072600_fix_table_embed_usability.md` exists |
| `20260922_194000_table-remove-buttons-add-resize.md` | Approved | `completed` | `change_log/20260922_195500_table-remove-buttons-add-resize.md` exists |
| `20260922_203000_ocr_crop_first_fast_export_mlkit.md` | Approved | `completed` | `change_log/20260922_204500_ocr-crop-first-fast-export-mlkit.md` exists |
| `20260924_081200_fix-dictation-repeated-lines.md` | planned | `dropped` | in-app dictation was removed on 2026-09-24 |
| `20260924_205927_dictation_accuracy.md` | Implemented 2026-09-24 — see … | `completed` | link moved |
| `20260924_212832_keyboard_incognito.md` | Implemented 2026-09-24 — see … | `completed` | link moved |
| `20260924_220102_markdown_paste.md` | Implemented (approved 2026-09-24) | `completed` | add `**Change log:** change_log/20260924_222720_markdown_paste.md` |
| `20260924_220251_remove-dictation-keyboard-privacy-setting.md` | Implemented 2026-09-24 — see … | `completed` | link moved |
| `20260924_223116_rich_html_paste.md` | Implemented 2026-09-25 — see … | `completed` | link moved |
| `20260925_212538_journal-screen-import-button.md` | Implemented 2026-09-25 — see … | `completed` | link moved |
| `20260925_213657_editor-toolbar-order-and-select-all-menu.md` | Implemented (approved with option C) | `completed` | note moved; add change-log link `20260925_214308_…` |
| `20260925_215533_no-relock-during-system-screens.md` | Implemented (2-minute limit accepted) | `completed` | note moved; add change-log link `20260925_215533_…` |

Seven older plans (2026-08-23 to 2026-09-12) already say `completed` but have a trailing space.
Trim that space.

Before each edit, open the matching change log and confirm it really implements that plan. If one
does not, do not mark the plan `completed`. Report it instead.

---

## Item 10 — `CHANGELOG.md` is out of date

### Issue

`CHANGELOG.md` was last updated on 2026-08-18. Since then, 94 change logs have been written. The
`[Unreleased]` section does not mention Malayalam and Sanskrit, the encrypted database, OCR, voice
notes, Wi-Fi Sync, AirQR, and many other changes a user would notice.

### Fix

Rewrite the `[Unreleased]` section only. Read every file in `change_log/` dated after 2026-08-18.
Add one short, user-facing line per feature, not one line per change log, under the Keep a
Changelog headings (Added / Changed / Fixed / Removed / Security). Leave out internal-only work:
CI, guidelines updates, doc edits, refactors.

Expected content (to be checked against the logs while writing):

- **Added:** Malayalam and Sanskrit, with an in-app language picker. Scan text from a photo
  (OCR) for English and Malayalam, fully offline, with a camera screen, crop, rotate and enhance.
  Voice notes saved as encrypted attachments. Drawing and handwriting blocks. Tables in entries.
  Custom and topic-specific entry templates. Receiving text and images shared from other apps.
  Wi-Fi Sync between two of the user's own phones. AirQR transfer. Time capsules. Ritual mode and
  thought cards. Reading themes and typography settings. Pasting Markdown and formatted web text.
  Import button on the journal screen. Password-protected encrypted export. Restoring a backup.
- **Changed:** new lock screen design. Settings grouped into sections. Editor toolbar order and
  "Select all" menu. The app no longer locks while the user is in the file picker, the camera, or
  another app it opened, unless they stay away for more than 2 minutes.
- **Security:** the database itself is now encrypted (SQLCipher). Keyboard privacy: text boxes ask
  the keyboard not to learn what is typed (on by default). Screenshot blocking can be switched off
  in Settings, and the change is logged. Leftover decrypted and temporary files are cleaned up at
  start.
- **Known issue** (short note): Wi-Fi Sync does not yet transfer attachment files correctly.
  This will be fixed separately.

In-app dictation was added and removed again before any release, so it is not listed.

---

## Item 11 — Two empty junk files at the project root

### Issue

- `libfeaturesbackupservicesbackup_restore_steps.dart.tmp`
- `libfeaturesentriespresentationocr_camera_controls.dart.tmp`

Both are 0 bytes and date from 2026-09-16. They look like a Windows path whose `\` characters were
dropped by a shell. They are untracked and nothing refers to them.

### Fix

Delete both files. Check first that they are still 0 bytes.

---

## Item 12 — English fallback name for imported templates

### Issue

`lib/features/airqr/providers/airqr_providers.dart` line 153 names an imported template
`'Custom Template'` when the QR payload has no name. That English text is saved to the database and
then shown in all three languages. The CLAUDE.md rule says user-visible text must come from the ARB
files.

The service has no `BuildContext`, and services must not know UI strings. So the name must come in
from the screen.

### Fix

1. Add one ARB key to all three files, with an `@` description in `app_en.arb`:
   - `labelImportedTemplateName`
   - en: `Imported template`
   - ml: `ഇറക്കുമതി ചെയ്ത മാതൃക`
   - sa: `आनीतं प्रारूपम्`

   These use the same words for "template" that the app already uses (`മാതൃകകൾ`, `प्रारूपाणि`).
   The Malayalam and Sanskrit text is marked "needs native-reader review" in the change log.
2. `AirqrSettingsService.applySettings(payload)` gets a required named parameter
   `fallbackTemplateName` and uses it instead of `'Custom Template'`.
3. `lib/features/airqr/presentation/airqr_receive_views.dart` line 14 passes
   `l10n.labelImportedTemplateName`. `l10n` is already in scope there.
4. Run `flutter gen-l10n`.
5. Add a unit test: a settings payload with a template that has no name is imported with the name
   passed in. Put it in `test/features/airqr/` next to the existing AirQR tests. Create the file
   if needed.

---

## Item 13 — Keyboard privacy entry is in the wrong table in `docs/architecture.md`

### Issue

In section 21, the table "Closed on 2026-07-25" has a row "Keyboard learns journal text" that says
it was closed on 2026-09-24.

### Fix

Move that row out of the 2026-07-25 table into a new sub-section,
`### Closed on 2026-09-24 — keyboard privacy`, placed after the 2026-09-19 sub-section. Its text
stays the same. Nothing else in the document changes.

---

## Files to be changed

| File | Item |
|---|---|
| The 22 plans in the table above, plus 7 plans with a trailing space | 9 |
| `CHANGELOG.md` | 10 |
| `libfeaturesbackupservicesbackup_restore_steps.dart.tmp` (delete) | 11 |
| `libfeaturesentriespresentationocr_camera_controls.dart.tmp` (delete) | 11 |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb` | 12 |
| `lib/l10n/app_localizations*.dart` (generated by `flutter gen-l10n`, not edited by hand) | 12 |
| `lib/features/airqr/providers/airqr_providers.dart` | 12 |
| `lib/features/airqr/presentation/airqr_receive_views.dart` | 12 |
| A new or existing test in `test/features/airqr/` | 12 |
| `docs/architecture.md` | 13 |
| `change_log/<timestamp>_housekeeping-review-items.md` (new) | log |

## Checks after the change

- `flutter analyze`: zero issues.
- `flutter test`: all pass, including translation parity, label length, and the new AirQR test.
- `sh tool/check_sanskrit_markers.sh` and `sh tool/check_absolute_paths.sh --all` pass.
- Search `plans/` again: every `**Status:**` line holds exactly one allowed value.

## Out of scope

Review items 1–8 (sync, AirQR screenshot setting, drawing delete, DAO use in widgets, logging).
Each gets its own plan.
