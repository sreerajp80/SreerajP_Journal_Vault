# Voice Dictation: Fix Overwritten Phrases, Auto-Commit on Pause, and Boost Accuracy

**Date:** 2026-09-22  
**Plan:** `plans/20260922_205900_voice-dictation-accuracy-and-pauses.md`

## Summary of changes

1. **Auto-commit on pauses (`DictationService`):**
   - Added an inactivity pause commit timer (`pauseCommitDelay`, 1300ms). When the user pauses speaking, the spoken phrase is automatically committed and inserted into the journal entry.
   - Users no longer need to press the Stop button just to see their words in the journal.

2. **Utterance boundary preservation (`DictationService`):**
   - Added `_isNewUtterance` check. When Android delivers a new speech segment that does not extend the earlier partial preview, the existing preview text is committed immediately to the entry.
   - Prior sentences are never overwritten or lost when starting a new sentence after a pause.

3. **Android on-device formatting & end of speech (`OnDeviceDictation.kt`):**
   - Added `RecognizerIntent.EXTRA_ENABLE_FORMATTING` with `FORMATTING_OPTIMIZE_QUALITY` for Android 13+ (API 33+).
   - Added `onEndOfSpeech()` callback event (`status: end_of_speech`) to prompt fast phrase commit upon natural silence.
   - Integrated unstable text bundle support for low-latency live preview.

4. **Spoken punctuation & formatting (`dictation_text_cleaner.dart`):**
   - Added `convertSpokenPunctuation`: converts spoken commands ("period", "full stop", "comma", "question mark", "exclamation mark", "colon", "semicolon", "new line") to punctuation marks and newlines.
   - Preserves ordinary uses of words (e.g. "a period of time" is not converted).
   - Automatically capitalizes sentences following sentence-ending punctuation (`.`, `?`, `!`, `\n`, `।`).

5. **Editor insertion polishing (`entry_editor_actions_3.dart`):**
   - Improved `_withSpacesForCaret`: ensures no leading space is inserted before punctuation symbols or newlines.

6. **Automated tests:**
   - Added unit tests in `test/features/entries/services/dictation_service_test.dart` for pause auto-commit, utterance boundary preservation, and silence error safety.
   - Added unit tests in `test/features/entries/services/dictation_text_cleaner_test.dart` for spoken punctuation and sentence capitalization.
   - Added widget tests in `test/features/entries/presentation/entry_editor_dictation_test.dart` for spoken punctuation symbol conversion directly into the entry.

## Verification

- `flutter test test/features/entries/services/dictation_service_test.dart` (33/33 passed)
- `flutter test test/features/entries/services/dictation_text_cleaner_test.dart` (18/18 passed)
- `flutter test test/features/entries/presentation/entry_editor_dictation_test.dart` (5/5 passed)
- `flutter analyze` (clean, 0 issues)
- `dart format lib test` (clean)
