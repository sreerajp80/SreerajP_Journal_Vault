# Change log — Two small findings: English "Entry #" text, and AirQR entries on a phone with no journals

**Plan:** `plans/20260927_135129_small-review-findings.md` (approved 2026-09-27, Option A)

No ARB change. Both fixes reuse strings that already exist in English, Malayalam and Sanskrit, so
nothing needs a native-reader review.

## Finding 1 — "Linked from" showed English text

- `lib/features/entries/presentation/entry_editor_widgets.dart`, `_LinkedFromRow`: an untitled
  entry that links here is shown with `descCommonUntitled` ("Untitled" /
  "തലക്കെട്ടില്ലാത്തത്" / "अनामिकम्") instead of the raw English `Entry #<row id>`.
- New `test/features/entries/presentation/entry_editor_linked_from_test.dart`: the row shows
  "Untitled", and no "Entry #" text appears. With the old line put back, the test fails.

## Finding 2 — An AirQR entry failed on a phone with no journals

- `lib/features/share_receiver/services/incoming_entry_service.dart`: `importReceivedEntry` has
  a new required `fallbackJournalTitle`. With no journals, it first creates one with that name,
  then puts the entry in it. The hard-coded journal ID `1` is gone. With journals, the entry still
  goes into the first one.
- `lib/features/airqr/presentation/airqr_receive_views.dart` passes
  `l10n.descAirqrImportedJournalTitle` ("Imported journal"). The journal import already uses this
  name.
- `test/features/share_receiver/incoming_entry_service_test.dart`: a new test for "no journals,
  one is made"; the existing tests pass the new argument, and one now also checks that no journal
  is created when journals exist.

## Checks

- `dart format lib test integration_test`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 1,182 tests pass (1,180 before).
- `sh tool/check_absolute_paths.sh --all`: passes.
