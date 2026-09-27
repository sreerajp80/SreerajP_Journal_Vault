# Dictation: type straight into the entry, add a bottom button, clean up noise

**Status:** completed
**Note:** The real-phone check was still pending when in-app dictation was removed on 2026-09-24, so it no longer applies.

## What the user reported

1. The dictation sheet shows only one line — the latest phrase — while speaking. After pressing
   **Done**, the edit box is empty, so nothing reaches the journal entry.
2. The user wants the spoken words to go straight into the entry, at the place where they put
   the cursor, with no separate text box.
3. The dictation button is only in the top formatting toolbar. OCR (scan text) is in both the top
   toolbar and the bottom action bar. Dictation should be in both places too.
4. Background noise gets picked up. It should be thrown away, so only clean text goes in.

## Why issue 1 happens (root cause)

The code in `lib/features/entries/services/dictation_service.dart` keeps two pieces of text:

- `partialText` — the recogniser's current guess for the phrase being spoken;
- `committedText` — phrases the recogniser has finished.

When a phrase ends, the phone sends a "final" result. The on-device recogniser on many phones
sends that final result **empty** — it has already sent the words as partial results.
`_handleResult` then does:

- `committedText = committedText + ''` — nothing is added;
- `partialText = ''` — the words already heard are wiped.

So each phrase is shown for a moment (as the partial guess) and then lost. The box only ever
shows the phrase being spoken right now ("the last line"). Pressing **Done** calls
`_engine.stop()`, the phone sends one more empty final result, the last phrase is wiped too, and
the edit box opens blank.

The native side (`OnDeviceDictation.kt`, `onResults`) sends the final result even when it is
empty, so Dart must handle it.

## The fix

### Part A — never lose heard words (fixes issue 1)

In `DictationService._handleResult`: when a final result is empty (or only spaces), commit the
current `partialText` instead of dropping it. A final result that has words still replaces the
guess, as now. Add service tests:

- partial "hello world", then empty final → committed text is "hello world";
- two phrases each ending in an empty final → both phrases are kept, in order;
- `finish()` while a partial is showing and the final comes back empty → the text is returned.

### Part B — speak straight into the entry (issue 2)

Replace the modal dictation sheet with a small **dictation bar** that sits inside the editor,
just above the bottom action bar. The entry stays visible and editable behind it.

How it works:

- Tapping the dictation button (top or bottom) opens the bar and starts listening at once in the
  language picked last time. The first time ever (no saved language), a short language list opens
  first, as today.
- While the user speaks, the words being guessed show in the bar in grey italics (a preview).
- As soon as the recogniser finishes a phrase, the cleaned text (Part D) is **inserted into the
  entry at the cursor**, and the cursor moves to the end of the new text. So the next phrase goes
  right after it. A space is added before it when needed (the existing `_withLeadingSpace` rule).
- If the user taps somewhere else in the entry, the next phrase goes there instead.
- If text was selected, the first phrase replaces the selection, the same as typing would.
- The bar has: a language chip (change language), pause / resume, and **Stop** (close the bar).
  Stop waits briefly for the last phrase and inserts it before the bar closes.
- Each inserted phrase is a normal edit, so **Undo** removes it and auto-save picks it up.
- Errors (no on-device recogniser, microphone refused, language not installed) show in the bar
  with the same messages as today.
- Leaving the editor, or the app going to the background, stops listening. Text already
  inserted stays in the entry.
- The keyboard is hidden while the bar is listening, so it does not cover the bar. Tapping the
  entry text still moves the cursor.

Layers:

- `DictationService` (services) keeps all the listening logic. It gets one new thing: a stream of
  finished phrases (`phrases`) so the bar can insert each phrase once, as soon as it is final. It
  still never logs what was said.
- New widget `DictationBar` (presentation) in `lib/features/entries/presentation/editor/`. It
  owns a `DictationService` for as long as it is open, shows state, and calls back
  `onPhrase(String text)`.
- The editor screen (presentation) inserts each phrase at the cursor with the existing
  `_insertExtractedText`. No SQL, file paths or platform channels in widgets.
- The language list moves out of `dictation_sheet.dart` into its own small sheet widget
  (`dictation_language_sheet.dart`) so the bar can reuse it. `dictation_sheet.dart` is then
  removed, along with its now-unused text-box strings.

### Part C — dictation button at the bottom too (issue 3)

Add a dictation button to `_BottomActionBar` in
`lib/features/entries/presentation/entry_editor_widgets.dart`, next to the OCR button. It uses
the same icon as the top toolbar (`Icons.keyboard_voice_outlined`) — different from the
voice-note microphone (`Icons.mic_outlined`), which records audio as an attachment. It uses the
existing localized tooltip `tooltipEditorDictate`. The top toolbar button stays. While the bar is
open, both buttons show as "on" and tapping either one stops dictation.

### Part D — clean out noise (issue 4)

An honest limit first: the app cannot clean the **audio** itself. The phone's own recogniser owns
the microphone during dictation, and it already does its own noise handling. What the app can do
is clean the **text** before it goes into the entry. New pure function
`cleanDictatedPhrase(String text, {String? languageTag})` in
`lib/features/entries/services/dictation_text_cleaner.dart` (services layer, no Flutter imports):

1. **Filler sounds removed** — stand-alone "um", "umm", "uh", "uhh", "uhm", "er", "erm", "ah",
   "hmm", "mm", "mhm" (English), matched as whole words, any case. Real words that merely contain
   these letters are never touched.
2. **Stutters removed** — the same word said twice in a row ("the the", "I I") becomes one.
   Only exact repeats of the same word, next to each other.
3. **Noise-only phrases dropped** — a phrase that is empty after steps 1–2, or is only
   punctuation or symbols, is not inserted at all.
4. **Low-confidence scraps dropped** — the native side also sends the recogniser's confidence
   score when the phone gives one. A phrase of one or two words with a reported confidence below
   0.3 is treated as noise and dropped. When the phone gives no score (many do not), nothing is
   dropped for this reason — losing real words is worse than keeping a stray one.
5. **Tidy spacing** — runs of spaces become one; no space before `, . ? !`.

Native change for step 4: `OnDeviceDictation.kt` adds a `confidence` value (or none) to each
`result` event from `SpeechRecognizer.CONFIDENCE_SCORES`. No audio, no words are logged.

Unit tests for every rule, including: Malayalam text passes through unchanged except spacing;
"umbrella" and "hummus" are untouched; "the the" becomes "the". Note that the stutter rule
would also shorten correct English such as "had had" or "that that". **Decision for the user:**
keep the stutter rule (cleaner text, rare loss of a real double word) or leave stutters alone.
The plan keeps it on.

## Localization

New keys, in `app_en.arb`, `app_ml.arb` and `app_sa.arb`, all with real translations and `@key`
descriptions:

- `tooltipDictationStop` — "Stop dictation" (short);
- `helpDictationCursor` — "Words go where the cursor is. Tap the text to move it." (long, shown
  once in the bar under the preview).

Existing keys reused: `tooltipEditorDictate`, `labelDictationListening`, `labelDictationPaused`,
`tooltipDictationPause`, `tooltipDictationResume`, `tooltipDictationLanguage`, all error keys.

Keys only the old text box used (`labelDictationEditHint`, `actionDictationInsert`,
`bodyDictationDiscardConfirm`, `emptyDictationSpeak` if unused) are removed from all three files.

The new Malayalam and Sanskrit strings are listed as **needs native-reader review** in the change
log. Run `flutter gen-l10n` and `sh tool/check_sanskrit_markers.sh`.

## Files to change

| File | Change |
|---|---|
| `lib/features/entries/services/dictation_service.dart` | Keep partial text on an empty final result; add `phrases` stream; pass confidence through |
| `lib/features/entries/services/speech_engine.dart` | `onResult` also gets an optional confidence |
| `lib/features/entries/services/dictation_text_cleaner.dart` | **New.** Text clean-up rules |
| `android/.../OnDeviceDictation.kt` | Send `confidence` with each result |
| `lib/features/entries/presentation/editor/dictation_bar.dart` | **New.** The in-editor dictation bar |
| `lib/features/entries/presentation/editor/dictation_language_sheet.dart` | **New.** Language list, moved out of the old sheet |
| `lib/features/entries/presentation/editor/dictation_sheet.dart` | **Removed** |
| `lib/features/entries/presentation/entry_editor_screen.dart` | Show the bar above the bottom bar; wire both buttons |
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | `_dictate` toggles the bar; phrase goes in through `_insertExtractedText` |
| `lib/features/entries/presentation/entry_editor_widgets.dart` | Dictation button in `_BottomActionBar` |
| `lib/features/entries/presentation/editor/editor_toolbar.dart` | Show the dictate button as "on" while listening |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ generated) | New keys, unused keys removed |
| `test/features/entries/services/dictation_service_test.dart` | Empty-final and phrase-stream tests |
| `test/features/entries/services/dictation_text_cleaner_test.dart` | **New** |
| `test/features/entries/presentation/editor/dictation_bar_test.dart` | **New**, replaces `dictation_sheet_test.dart` |
| `docs/implementation_progress.md`, `docs/architecture.md` | Describe the new dictation flow |

No database change, no new package, no new permission. Nothing leaves the device.

## Acceptance checks

- Speaking three phrases puts all three into the entry at the cursor, in order, each separated
  by a space. Nothing is lost when pressing Stop.
- Moving the cursor between phrases puts the next phrase at the new place.
- Undo removes the last inserted phrase.
- The dictation button is in both the top toolbar and the bottom bar, with a tooltip, in English,
  Malayalam and Sanskrit.
- "um so uh I I went" goes in as "so I went". A phrase that is only "hmm" is not inserted.
- Existing features still work: OCR insert, voice notes, auto-save, the lock gate.
- `flutter analyze` is clean, `flutter test` passes, `dart format` is clean.

## Testing on a device

Unit and widget tests use the existing fake speech engine. For a real check the app will be run
on emulator-5554. Emulators often have **no on-device speech model**; if so, the emulator can
only confirm the layout, the buttons and the error message, and real dictation must be checked on
a phone.
