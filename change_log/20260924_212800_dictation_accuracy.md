# Change log: Dictation puts only the recogniser's final words into the entry

**Plan:** `plans/20260924_205927_dictation_accuracy.md`
**Date:** 2026-09-24
**Undoes part of:** `change_log/20260924_194900_direct-live-dictation-at-cursor.md` (live
typing) and the pause timers from `change_log/20260922_210800_voice-dictation-accuracy-and-pauses.md`

## Why

Dictated text was much worse than what the phone's recogniser could give. The app wrote
the recogniser's rough first guess into the entry (after a 1.3-second pause, 0.6 seconds
after the end of speech, or when the first word changed), then dropped or partly
repeated the better final answer. Example: "Learn Claude Code. Prompt Claude to write
code." came out as "Land cloud from cloud to, right?". The user also did not want the
words shown in the dictation bar, and chose to see nothing until the final answer.

## What changed

- `lib/features/entries/services/dictation_service.dart`
  - Removed the 1.3-second pause timer (`pauseCommitDelay`) and the 0.6-second timer
    after `end_of_speech`.
  - Replaced `_isNewUtterance` with `_startsOver`, a much narrower check. It commits the
    earlier guess only when the new guess is less than half as long and starts with
    another word, which means the recogniser started over without a final result. A
    correction ("land cloud" → "learn Claude code") never triggers it.
  - A phrase is now committed on the final result, or when the session ends, pauses,
    finishes or fails. An empty final result still uses the last guess.
- `android/.../OnDeviceDictation.kt` — partial results no longer add the recogniser's
  `UNSTABLE_TEXT` (its least sure words).
- `lib/features/entries/presentation/editor/dictation_bar.dart` — no preview line and no
  `onLivePartial`. While listening or paused the bar shows only its status row.
- `lib/features/entries/presentation/entry_editor_actions_3.dart`,
  `entry_editor_layout.dart`, `entry_editor_screen.dart` — removed live typing of guesses
  into the entry (`_onDictationLivePartial`, `_dictationCaretOffset`,
  `_dictationLiveLength`). `_insertDictatedPhrase` inserts at the current cursor.
- `docs/features.md`, `docs/security.md` — dictation wording updated.

## Tests

- `test/features/entries/services/dictation_service_test.dart` — timer tests replaced:
  a guess is never sent while speaking (even after `end_of_speech`); a corrected guess
  sends only the final words once; final words replace the last guess; an earlier
  sentence is kept when the recogniser starts over; cumulative guesses send the phrase
  once; a final that repeats committed words sends only the new ones.
- `test/helpers/fake_speech_engine.dart` — added `endOfSpeech()`.
- `test/features/entries/presentation/editor/dictation_bar_test.dart` — the guess is
  never shown in the bar.
- `test/features/entries/presentation/entry_editor_dictation_test.dart` — guesses stay
  out of the entry until the final words.

Results: `flutter analyze` — no issues. `flutter test` — all 1079 tests pass. Kotlin
`OnDeviceDictation` unit tests pass.

## Not yet checked

- On a real phone. Please read the sample text again in English (en-IN). Words will
  appear a few seconds after you pause. "Claude" may still become "cloud"; that is the
  phone's offline model.
- The `_startsOver` limits (half as long, 3 or more words) are a judgement, not measured
  on a phone.

No new strings, so no Malayalam or Sanskrit text needs review.
