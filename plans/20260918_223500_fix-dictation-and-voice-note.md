# Fix dictation language choice and voice note saving

**Status:** partial_completion

Approved 2026-09-18. Download button not included (no answer given; safer default). Old voice
notes are moved. Only the dictation service parts and the text keys were built here. The rest —
the dictation sheet, the voice note save, and the move of old voice notes — was finished by
`plans/20260919_094126_voice-dictation-and-stale-files.md`.

## Issues

### 1. Dictation fails with "Malayalam model is not installed"

- The phone's system language is Malayalam, and so is the app language.
- `DictationSheet._begin()` picks a language on its own and starts listening straight away.
  `pickDictationLanguage()` prefers the app language, and when the offline language list is empty,
  it passes `null`, so the recogniser uses the device language. Either way it picks Malayalam.
- The phone has no offline Malayalam model, so the recogniser returns
  `error_language_unavailable` and the sheet shows the error.
- On the error screen the language chip is hidden (`status != DictationStatus.error`), so the user
  cannot switch to English. The only button is Close. That is a dead end.

### 2. Voice note is not attached to the entry

- `_handleVoiceNoteComplete` saves the encrypted recording to the `voice_notes` table.
  No screen reads that table (`entryVoiceNotesProvider` and `watchVoiceNotesForEntry` are unused).
  So the note never shows in the entry's attachment tray and cannot be played.
- `VoiceNoteRecorder._stopRecording()` calls `onRecordingComplete` without waiting for it, then
  closes the sheet. If saving fails, the error is lost and the user sees nothing. If
  `_entryId` is null, it returns silently.
- The recorder has no "saving" state, and `stopRecording()` returning null (no file) is also silent.

## Fix

### Dictation (speech to text)

1. **Ask for the language first.** When the sheet opens, it prepares the recogniser and then shows
   a language list. It does **not** start listening on its own. The list:
   - installed offline languages first, each marked ready;
   - then supported-but-not-downloaded languages, marked "not downloaded";
   - if the platform gives no list (older Android, or the check fails), fall back to English
     (`en-IN`, `en-US`), Malayalam (`ml-IN`) and "Device default".
   - The last language the user used is pre-selected, if it is still offered.
   Tapping a language saves it and starts listening.
2. **Never a dead end on a language error.** On `languageUnavailable`, the error screen keeps a
   "Choose another language" button that goes back to the language list. The language chip also
   stays usable while listening or paused, as it is today.
3. `DictationService` gets a small `restart()` path so a new language can be tried after a
   language error, without closing the sheet. The other errors (permission, offline recogniser
   missing) keep their current messages.
4. `MainActivity.reportOnDeviceSpeechStatus` already returns `supportedLanguages`. No Kotlin
   change is needed for the list.

   Optional (asking you): on Android 13 and newer, add a "Download" button for a
   not-downloaded language. It calls `SpeechRecognizer.triggerModelDownload()`. That makes
   **Google's speech service** (not this app) download the model. This app still makes no network
   call, and speech still stays on the device. Without this button, the user is told to install
   the language in the phone's speech settings instead.

### Voice note

1. **Save as a normal attachment.** The recording is saved to the `attachments` table with MIME type
   `audio/mp4` and a readable name such as `Voice note 2026-09-18 22-35.m4a`, through the existing
   `AttachmentImportService` (AES-256-GCM, same as every other attachment). It then shows in the
   entry's attachment tray and plays in the existing in-app audio player. It is also covered by
   the existing attachment lock, export and backup paths.
2. **Show a clear result.** The recorder sheet waits for the save and shows a spinner. On
   success, it closes and shows "Voice note saved (N s)", and the attachment tray refreshes
   (`_attachmentRefreshToken++`). On failure (no file, entry not ready, or a crypto or database
   error), it shows "Could not save the voice note". The temp recording is always deleted.
3. The save logic moves out of the widget into a small service method
   (`VoiceNoteService` or a new `voice_note_saver.dart` in `services/`), so it can be unit tested.
   Layer: services.
4. **Old hidden voice notes.** Notes already in `voice_notes` are moved into `attachments` once, on
   startup (the same encrypted file, nonce and key reference, so nothing is decrypted). This is a
   data move, not a schema change: schema version stays 11, and the `voice_notes` table stays for
   backup compatibility. If you'd rather skip this, say so. If the table is empty on your phone,
   nothing happens.

### Text (all three ARB files, with real ml and sa translations)

New keys (names may change slightly):
`titleDictationChooseLanguage`, `labelDictationLanguageReady`, `labelDictationLanguageNotDownloaded`,
`actionDictationChooseLanguage`, `errorVoiceNoteSaveFailed`, `labelVoiceNoteSaving`,
`labelVoiceNoteFileName`. The new Malayalam and Sanskrit terms get flagged for native-reader review.

## Files to change

- `lib/features/entries/presentation/editor/dictation_sheet.dart` — language step, error recovery
- `lib/features/entries/services/dictation_service.dart` — allow restart after a language error; language list ordering helper
- `lib/features/entries/presentation/editor/voice_note_recorder.dart` — await save, saving/error states
- `lib/features/entries/presentation/entry_editor_actions_2.dart` — save through the attachment path, refresh tray
- `lib/features/entries/services/voice_note_service.dart` (or new `voice_note_saver.dart`) — save logic
- one-time move of old voice notes (new small service in `lib/features/entries/services/`, called from start-up wiring)
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ `flutter gen-l10n`)
- If the download button is approved: `MainActivity.kt` (new `downloadSpeechModel` method) and `speech_engine.dart`

## Tests

- `test/features/entries/services/dictation_service_test.dart` — restart after language error; language ordering
- new widget test for the dictation sheet: language list shows first; language error offers "Choose another language"
- new service test for the voice note save: creates an `audio/mp4` attachment, deletes the temp file, cleans up on DB failure
- test for the one-time voice note move
- run `flutter analyze`, `flutter test`, `sh tool/check_sanskrit_markers.sh`
- try both mics on the connected phone (dev flavor)

## Acceptance criteria

- Opening dictation shows a language list. Choosing English works on a Malayalam phone.
- A missing language model never traps the user. They can pick another language from the error screen.
- After recording a voice note, the user sees either "saved" or "could not save".
- A saved voice note appears in the entry's attachment tray and plays.
