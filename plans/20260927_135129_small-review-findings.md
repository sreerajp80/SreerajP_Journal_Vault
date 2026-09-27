# Plan — Two small findings: English "Entry #" text, and AirQR entries on a phone with no journals

**Status:** completed
**Change log:** `change_log/20260927_135558_small-review-findings.md`
**Note:** Approved 2026-09-27, Option A.

## Background

Two small problems were found while doing the 2026-09-27 review work, and were written down in
`change_log/20260927_125030_review-items-5-to-8.md`. Both fixes reuse strings that already exist
in all three languages, so no new translation is needed.

---

## Finding 1 — "Linked from" shows English text for an untitled entry

### Issue

`lib/features/entries/presentation/entry_editor_widgets.dart`, `_LinkedFromRow` (around line
149–151):

```dart
final title = entry?.title?.isNotEmpty == true
    ? entry!.title!
    : 'Entry #$sourceEntryId';
```

When an entry that links here has no title, the "Linked from" panel shows the raw English text
`Entry #12`, in Malayalam and Sanskrit too. That breaks the rule that all user-visible text comes
from the ARB files. It also shows an internal row number, which means nothing to the user.

A search of `lib/` for other English text built into widgets found no other case. The other
matches are numbers, token examples or tag names, not English words.

### Fix

Use the existing key `descCommonUntitled` ("Untitled" / "തലക്കെട്ടില്ലാത്തത്" / "अनामिकम्"),
the same word the time-capsule list already shows for an untitled entry.

---

## Finding 2 — An AirQR entry sent to a phone with no journals fails to import

### Issue

`IncomingEntryService.importReceivedEntry`
(`lib/features/share_receiver/services/incoming_entry_service.dart`) puts a received entry into
the first journal. When there is no journal at all, it falls back to journal ID `1`. That row does
not exist, and foreign keys are on, so the insert fails. The user sees only "Could not import the
data." (`errorAirqrImport`) and cannot tell why.

### Fix (Option A — recommended)

- When the phone has **no** journals, create one first, named with the existing key
  `descAirqrImportedJournalTitle` ("Imported journal" / "ഇറക്കുമതി ചെയ്ത ജേണൽ" /
  "आनीता दैनन्दिनी"). The received journal import already uses this name. Then put the entry in it.
- The name comes from the screen: `importReceivedEntry` gets a required
  `fallbackJournalTitle` parameter, and `airqr_receive_views.dart` passes
  `l10n.descAirqrImportedJournalTitle`. The service stays free of UI strings.
- The hard-coded `1` is removed.
- With one or more journals, nothing changes: the entry still goes into the first journal.

### Option B (not planned; say if you want it instead)

Ask the user which journal the entry should go into, with a list like the one Settings shows for
Import. It is more work and a new screen step. The "no journals" case would still need Option A.

---

## Tests

- `test/features/share_receiver/incoming_entry_service_test.dart`:
  - with no journals, `importReceivedEntry` creates one journal with the given title, and the
    entry is in it;
  - with journals, no new journal is created (the existing "first journal" test stays).
- A widget test for the "Linked from" row: an untitled entry that links to the open entry is
  shown as "Untitled", and no text containing "Entry #" appears. It goes next to the existing
  editor tests in `test/features/entries/presentation/`.

## Files

- `lib/features/entries/presentation/entry_editor_widgets.dart`
- `lib/features/share_receiver/services/incoming_entry_service.dart`
- `lib/features/airqr/presentation/airqr_receive_views.dart`
- `test/features/share_receiver/incoming_entry_service_test.dart`
- A new or existing editor widget test in `test/features/entries/presentation/`

No ARB change, so nothing needs a native-reader review.

## Checks after the change

- `dart format lib test integration_test`: clean.
- `flutter analyze`: zero issues.
- `flutter test`: all pass.
- `sh tool/check_absolute_paths.sh --all`: passes.

## Out of scope

- Review item 1 (commit `third_party/`).
- Two-way sync, and syncing edits and deletes.
