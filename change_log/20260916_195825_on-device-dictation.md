# On-device dictation (speech to text) in the entry editor

Plan: [`plans/20260916_194242_on-device-dictation.md`](../plans/20260916_194242_on-device-dictation.md)

## What changed

### New: dictation

- A **Dictate** button (keyboard-voice icon) in the editor toolbar opens a bottom sheet.
- Listening starts at once. Finished words show in normal text, the recogniser's current guess in
  italics. Android ends a session after a silence, so the service starts a new one until the user
  pauses or presses **Done**.
- **Done** makes the text editable. **Insert** puts it at the caret (adding a space if the caret
  sits right after a word) and marks the entry as changed. **Discard** throws it away. Nothing
  reaches the entry before Insert.
- A language chip lists the offline languages the phone has installed. The choice is remembered
  under the `dictation_language` preference.
- In the Sanskrit UI the sheet says that Sanskrit speech cannot be recognised offline and suggests
  English or Malayalam.

### The no-cloud guard

- `MainActivity.kt` has a new channel, `sreerajp.journal_vault/speech`, with one method,
  `onDeviceSpeechStatus`. It returns whether `SpeechRecognizer.isOnDeviceRecognitionAvailable`
  is true (Android 12+), and on Android 13+ the installed and supported offline languages.
- `DictationService` checks this **before** it touches the recogniser, and stops with a clear
  message when the answer is no. This matters because the `speech_to_text` plugin otherwise falls
  back to the default recogniser, which is usually online.
- `PluginSpeechEngine.listen` always sends `onDevice: true`.
- Network and server errors end dictation and are never retried.
- Recognised text is never logged. Only status and error codes are.

### Voice notes

- The voice-note recorder no longer runs speech recognition at the same time. It could not hear
  (the recorder holds the microphone), its result was always empty, and it did not ask for
  on-device mode. `VoiceNoteService` no longer imports `speech_to_text`.
- The `VoiceNotes.transcript` column is unchanged. Old transcripts still back up and export. No
  schema change.

### Android manifest

- `RECORD_AUDIO` is now declared in the app's own manifest (it used to arrive only through
  `record`).
- A `<queries>` entry for `android.speech.RecognitionService`, which Android 11+ needs so the app
  can see the recogniser.

## Files

- New: `lib/features/entries/services/speech_engine.dart`,
  `lib/features/entries/services/dictation_service.dart`,
  `lib/features/entries/providers/dictation_providers.dart`,
  `lib/features/entries/presentation/editor/dictation_sheet.dart`
- Changed: `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`,
  `android/app/src/main/AndroidManifest.xml`,
  `lib/features/entries/presentation/editor/editor_toolbar.dart`,
  `lib/features/entries/presentation/entry_editor_screen.dart`,
  `lib/features/entries/presentation/entry_editor_layout.dart`,
  `lib/features/entries/presentation/entry_editor_actions_3.dart`,
  `lib/features/entries/services/voice_note_service.dart`,
  `lib/features/entries/presentation/editor/voice_note_recorder.dart`
- Localization: `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` and the generated files — 16
  new keys, and the microphone line of `helpFaqA3` now mentions dictation.
- Tests (new): `test/helpers/fake_speech_engine.dart`,
  `test/features/entries/services/dictation_service_test.dart`,
  `test/features/entries/services/speech_engine_test.dart`,
  `test/features/entries/presentation/editor/dictation_sheet_test.dart`
- Docs: `docs/security.md`, `docs/dependencies.md`, `docs/features.md`,
  `docs/architecture.md`, `docs/implementation_progress.md`

## Verification

- `flutter gen-l10n` — done.
- `flutter analyze` — no issues.
- `flutter test` — 907 tests passing, including translation parity and label length.
- `sh tool/check_sanskrit_markers.sh` — passing.
- `dart format lib test integration_test` — clean.
- `flutter build apk --flavor dev --debug` — builds, so the new Kotlin code compiles.
- `tool/check_no_internet_permission.sh` and `tool/check_absolute_paths.sh --all` — passing.
- Still to do by hand on a phone:
  1. Turn on airplane mode, dictate in English and in Malayalam, and insert the text.
  2. On a phone without offline speech recognition, check that the "not available" message
     shows.
  3. Check that a voice note still records and plays back.

## Needs native-reader review

Every new Malayalam and Sanskrit string needs a fluent reader's review:
`tooltipEditorDictate`, `titleDictation`, `labelDictationListening`, `labelDictationPaused`,
`tooltipDictationPause`, `tooltipDictationResume`, `tooltipDictationLanguage`,
`labelDictationDeviceDefault`, `labelDictationEditHint`, `actionDictationInsert`,
`emptyDictationSpeak`, `descDictationPrivacy`, `errorDictationOfflineUnavailable`,
`errorDictationLanguageUnavailable`, `errorDictationFailed`,
`helpDictationSanskritUnsupported`, and the changed `helpFaqA3`. Sanskrit terms to check first:
वाग्लेखनम् (dictation), वाक्परिचयः (speech recognition), जालं विना (offline).
