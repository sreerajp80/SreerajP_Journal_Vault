# Dictation: type straight into the entry, bottom button, noise clean-up

**Plan:** `plans/20260919_195847_dictation-direct-insert-and-cleanup.md`

## What was wrong

- While speaking, the dictation sheet showed only the phrase being spoken. After **Done** the
  edit box was empty, so nothing reached the entry.
- **Cause:** many on-device recognisers send each phrase's "final" result **empty**, because
  they already sent the words as partial results. `DictationService._handleResult` added the
  empty text and cleared the partial, so every phrase was lost. The empty final result sent
  when **Done** stopped listening wiped the last phrase too.

## What changed

### Words are no longer lost

- `lib/features/entries/services/dictation_service.dart`: a new `_commit` step. When a final
  result is empty, the last partial result is kept as the phrase. The same step runs when a
  session ends without a final result, on `finish()`, and before an error, so words heard are
  never dropped.
- New `phrases` stream: each finished phrase, cleaned, sent exactly once. It is synchronous, so
  the last phrase arrives before `finish()` returns.

### Speech goes straight into the entry

- The pop-up sheet (`dictation_sheet.dart`) is removed. A new slim bar,
  `lib/features/entries/presentation/editor/dictation_bar.dart`, sits in the editor above the
  bottom action bar (and at the bottom in distraction-free mode).
- The bar starts listening at once in the language used last time. The first time, it shows the
  language list, which moved to `dictation_language_sheet.dart`.
- Each finished phrase is inserted at the cursor as it is spoken, as a normal edit, so Undo and
  auto-save work. A space is added before and after where needed. Tapping elsewhere in the text
  moves where the next phrase goes.
- The words still being spoken show in the bar as a grey preview. The bar has a language chip,
  pause / resume, and stop. Stop puts in the last words, then closes the bar. Listening stops
  when the app goes to the background.
- The keyboard is put away when dictation starts so it does not cover the bar.

### Button at the bottom too

- `entry_editor_widgets.dart`: a dictate button next to OCR in the bottom action bar. Both the
  top and bottom buttons show as "on" while dictating, and tapping either one stops dictation.

### Noise clean-up

- New `lib/features/entries/services/dictation_text_cleaner.dart` (`cleanDictatedPhrase`).
  It removes filler sounds ("um", "uh", "hmm", ...) said on their own, and keeps a word said
  twice in a row only once. It drops phrases with no letters or digits, and drops one- or
  two-word phrases the recogniser scored below 0.3. A missing or zero score never drops
  anything.
- The doubled-word rule stays on, as approved. It can also shorten correct English such as
  "had had".
- `speech_engine.dart` / `OnDeviceDictation.kt`: final results now carry the recogniser's
  confidence score when the phone gives one. No words or audio are logged.
- The audio itself is not cleaned: the phone's recogniser owns the microphone.

### Strings

- New keys in all three ARB files: `tooltipDictationStop`, `helpDictationCursor`.
- Removed keys that only the old sheet used: `labelDictationEditHint`, `actionDictationInsert`,
  `emptyDictationSpeak`, `bodyDictationDiscardConfirm`.
- **Needs native-reader review:**
  - Malayalam: `tooltipDictationStop` "പറഞ്ഞെഴുത്ത് നിർത്തുക", `helpDictationCursor`
    "വാക്കുകൾ കഴ്സർ ഉള്ളിടത്ത് ചേർക്കും. മാറ്റാൻ ടെക്സ്റ്റിൽ തൊടുക."
  - Sanskrit: `tooltipDictationStop` "वाग्लेखनं स्थगय", `helpDictationCursor`
    "शब्दाः सूचकस्य स्थाने निवेश्यन्ते। तत् चालयितुं पाठं स्पृश।"

### Docs

- `docs/architecture.md`, `docs/features.md`, `docs/implementation_progress.md`,
  `docs/security.md` describe the new flow.

## Tests

- New: `test/features/entries/services/dictation_text_cleaner_test.dart` (15),
  `test/features/entries/presentation/editor/dictation_bar_test.dart` (9),
  `test/features/entries/presentation/entry_editor_dictation_test.dart` (4: both buttons exist,
  phrases land at the cursor, stop inserts the last words, undo).
- `dictation_service_test.dart`: empty final results, and the phrase stream (9 new tests).
- `speech_engine_test.dart`: the confidence value is passed through.
- Removed `dictation_sheet_test.dart` along with the sheet.
- `flutter analyze`: no issues. `flutter test`: all 1056 tests passed.
  `dart format`: clean. `tool/check_sanskrit_markers.sh`: passed.

## Device check

- Built and installed the dev debug APK on an emulator. The vault there is locked with a PIN,
  and the emulator has no on-device speech service, so real dictation was not checked on it.
- **Still to do:** check dictation on a real phone. Speak several phrases, move the cursor
  between them, press Stop, and use Undo.
