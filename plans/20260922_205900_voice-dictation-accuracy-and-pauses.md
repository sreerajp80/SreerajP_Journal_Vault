# Voice Dictation: Fix Overwritten Phrases, Auto-Commit on Pause, and Boost Accuracy

**Status:** completed

## What the user reported

1. Dictation only inserts the last line. Spoken words before a pause disappear.
2. The user has to stop recording for the text to appear in the journal entry. Words do not appear live while speaking.
3. The user asked how to increase speech accuracy, and how background noise and disturbances are handled.

## Root cause analysis

1. **Android on-device recognizer behavior:**
   During continuous dictation, Android's on-device `SpeechRecognizer` does not emit an `onResults` (final result) callback between sentences. It only provides continuous `onPartialResults` (interim guesses).
2. **Buffer overwrite on pause:**
   When the user pauses and starts a new sentence, Android sends the new sentence as a new partial guess without repeating the prior sentence. In `DictationService._handleResult`, `partialText` was replaced directly by the new words, causing earlier words to be overwritten and lost.
3. **No insertion until stop:**
   `DictationService._commit` was only triggered when `isFinal == true` or when the user pressed **Stop** (`DictationService.finish`). Because `isFinal` was never true while speaking, nothing was emitted on the `phrases` stream until the user pressed Stop. At that point, only the last sentence left in `partialText` was committed.

## Proposed changes

### 1. Auto-commit on speech pauses (Silence / Inactivity Timer)
- In `DictationService`, add an auto-commit timer (e.g., 1.2 to 1.5 seconds of silence after the latest partial result).
- When the user pauses speaking, any non-empty `partialText` is automatically committed and emitted on `phrases`.
- The phrase is immediately inserted into the journal entry at the caret, securing it permanently.

### 2. Segment boundary preservation (Never overwrite pending words)
- In `DictationService._handleResult`:
  If a new partial result arrives and does not continue or match the current `partialText` (the recognizer started a new utterance after a brief pause), immediately commit the existing `partialText` before accepting the new text.
- This guarantees no words are ever lost, even during short conversational pauses.

### 3. Safety commit on Android events
- In `DictationService._handleError`: On silence errors (`error_speech_timeout`, `error_no_match`) or before restarting sessions, commit any pending `partialText` first.
- In `OnDeviceDictation.kt`: Ensure `onEndOfSpeech()` signals phrase finalization or triggers clean result delivery.

### 4. Enable Android 13+ text formatting (`EXTRA_ENABLE_FORMATTING`)
- In `OnDeviceDictation.kt`, add `RecognizerIntent.EXTRA_ENABLE_FORMATTING` set to `FORMATTING_OPTIMIZE_QUALITY` on Android 13+ (API 33+).
- This instructs the on-device engine to add automatic punctuation (commas, periods) and capitalize proper nouns.

### 5. Smart sentence capitalization & spoken punctuation
- In `dictation_text_cleaner.dart`:
  - Automatically capitalize the first letter of sentences.
  - Support spoken punctuation:
    - "period" / "full stop" -> `.`
    - "comma" -> `,`
    - "question mark" -> `?`
    - "exclamation mark" -> `!`
    - "colon" -> `:`
    - "new line" / "next line" -> `\n`

### 6. Editor live feedback
- Ensure `DictationBar` displays active listening vs paused state with clear visual feedback.
- Ensure `_insertDictatedPhrase` smoothly handles cursor positioning and newlines.

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OnDeviceDictation.kt`
- `lib/features/entries/services/dictation_service.dart`
- `lib/features/entries/services/dictation_text_cleaner.dart`
- `lib/features/entries/presentation/editor/dictation_bar.dart`
- `lib/features/entries/presentation/entry_editor_actions_3.dart`
- `test/features/entries/services/dictation_service_test.dart`
- `test/features/entries/services/dictation_text_cleaner_test.dart`
- `test/features/entries/presentation/entry_editor_dictation_test.dart`

## Verification plan

1. Automated unit tests:
   - Run `flutter test test/features/entries/services/dictation_service_test.dart`
   - Run `flutter test test/features/entries/services/dictation_text_cleaner_test.dart`
   - Run `flutter test test/features/entries/presentation/entry_editor_dictation_test.dart`
   - Run `flutter analyze`
2. Test scenarios:
   - Dictating sentence 1, pausing for 2 seconds, then dictating sentence 2: both sentences appear in the entry in order.
   - Pausing does not erase previous text.
   - Spoken punctuation like "comma" and "period" translates to punctuation marks.
   - Capitalization at the beginning of phrases.
