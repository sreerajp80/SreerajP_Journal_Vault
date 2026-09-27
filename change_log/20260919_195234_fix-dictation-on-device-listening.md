# Dictation works every time: own on-device listener

Implements `plans/20260919_121359_fix-dictation-on-device-listening.md` (approved 2026-09-19).
Item 4 of that plan (release logging) was done first, in
`change_log/20260919_122528_release-logging-and-dictation-diagnostics.md`.

## Cause (confirmed on a Motorola phone, Android 17)

Only the first dictation after the app started worked. Every later one failed at once with
`error_server_disconnected`: the app's language check ends with the phone's speech service
shutting down, and the `speech_to_text` plugin re-used its old recogniser, whose connection had
died with the service.

## What changed

- New `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OnDeviceDictation.kt`:
  the app's own listener. A fresh recogniser from `SpeechRecognizer.createOnDeviceSpeechRecognizer`
  for every listening session, destroyed when the session ends. It never creates the online
  recogniser, and refuses to start when on-device recognition is missing. Sends `listening`,
  partial and final results, error names and `done` to Dart over the new event channel
  `sreerajp.journal_vault/speech_events`. Logs nothing that was said. `speechErrorName` keeps the
  error names the plugin used, so the Dart handling is unchanged.
- `MainActivity.kt`: `startListening`, `stopListening`, `cancelListening` on the existing
  `sreerajp.journal_vault/speech` channel; the listener is released in `onDestroy`.
- `lib/features/entries/services/speech_engine.dart`: `NativeSpeechEngine` replaces
  `PluginSpeechEngine`. It asks for the microphone through `permission_handler` (the plugin used
  to do this), and logs failure codes only.
- `lib/features/entries/providers/dictation_providers.dart`: uses it, and disposes it.
- `pubspec.yaml` / `pubspec.lock`: **`speech_to_text` removed**, with its own dependencies.
- `lib/features/entries/services/dictation_service.dart`: `error_server_disconnected` is retried
  with a fresh session; `DictationState.errorCode` keeps the recogniser's code.
- `dictation_sheet.dart`: a small "Code: …" line under a failure; the bottom padding clears the
  navigation bar (or the keyboard, whichever is taller). `voice_note_recorder.dart`: the same
  bottom clearance.
- New key `labelDictationErrorCode` in all three ARB files.
- Docs: `dependencies.md` (removal note), `security.md` (dictation note, R8 list),
  `architecture.md` (platform channels), `release_process.md` (smoke test: dictation twice in a
  row).

**Needs native-reader review:** `labelDictationErrorCode` — ml `കോഡ്: {code}`, sa `सङ्केतः: {code}`.

## Different from the plan

- The plan said a lost connection is retried **once**. It now shares the existing retry limit
  for passing errors (busy, client, lost connection): up to 3 fresh sessions in a row. A fresh
  session is cheap, and one more try is not always enough if the service is still restarting.
- Unknown recogniser codes are named `error_unknown_<number>` (the plugin used
  `error_unknown (<number>)`), so the code shows cleanly on screen.
- Added a Kotlin unit test, `OnDeviceDictationTest.kt`, for the error names.

## Verification

- `flutter analyze`: no issues.
- Speech engine (8), dictation service (21) and dictation sheet (15) tests pass, including new
  ones: lost connection retried; code kept and shown; buttons above a 120 px bottom bar.
- `OnDeviceDictationTest` passes (`testProdDebugUnitTest`; the release variant's unit tests do not
  compile because of the dev-only `integration_test` plugin — unrelated to this change).
- Full `flutter test`: 1028 passed, 6 failed. The 5 time capsule tests failed because
  `build/native_assets/windows/sqlcipher.dll` was missing for part of the run (another session
  was building in the same folder at the time), and the Wi-Fi Sync test hit its 30-second limit
  under load. All 6 pass when run on their own.
- On the phone (prod release, installed with `adb install -r`, data kept): dictation in English
  (India) worked at 19:49:56 and again at 19:51:39 **in the same app process**, with the language
  check running in between — the exact case that failed before. The user reports a third success
  that fell in a gap in the log capture.
- Not yet confirmed by the user: that the Close and Discard buttons now sit above the navigation
  bar (covered by the widget test).
