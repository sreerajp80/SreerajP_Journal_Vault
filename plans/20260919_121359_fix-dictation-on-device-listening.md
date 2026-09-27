# Fix dictation failing as soon as listening starts

**Status:** completed

## What happens

On a Motorola phone (Android 17), English (India) is installed and shows as "Ready" in the
dictation language list. After picking it, the sheet at once shows "Speech recognition stopped
unexpectedly. Try again." (`errorDictationFailed`).

## What the phone's log shows

- Opening the sheet runs the app's own language check (`reportOnDeviceSpeechStatus` in
  `MainActivity.kt`) twice. Each check makes a short-lived on-device recogniser, asks for the
  language list, and destroys it. Each time, the phone's speech service
  (Android System Intelligence) is shut down afterwards (`RecognitionService#onDestroy`).
- After the language is picked, **no listening request reaches the speech service at all**. No
  new session, no `startListening`, no microphone use.
- The on-device service offers no Malayalam pack on this phone (English, Hindi and some others
  only). That is a phone limit, not an app bug.

## Confirmed cause (2026-09-19, after release logging was fixed)

The phone's log now shows it. The first dictation after the app starts works. Every later one
fails at once with **`error_server_disconnected`**:

1. Opening the sheet runs the app's language check twice. Each check ends with the phone's speech
   service shutting down (`RecognitionService#onDestroy`).
2. The `speech_to_text` plugin keeps its recogniser from the first use and re-uses it
   (`createRecognizer` returns early when one exists). That recogniser's connection died with the
   service.
3. So listening never reaches the speech service; the phone answers "disconnected" straight away.
   The app shows its general "stopped unexpectedly" message for this code.

The same could happen whenever the phone restarts its speech service for any other reason, so
avoiding the language check alone would not be enough.

## The fix

1. **Own on-device listener instead of the plugin.** Add a small native listener to
   `MainActivity.kt` (a new `OnDeviceDictation.kt` next to it), on the existing
   `sreerajp.journal_vault/speech` channel plus an event channel for results:
   - A **fresh** recogniser from `SpeechRecognizer.createOnDeviceSpeechRecognizer` for every
     listening session, destroyed when the session ends. No stale connection can survive.
   - **On-device only, always.** It never calls `createSpeechRecognizer`, so it cannot fall back
     to Google's online recogniser the way the plugin can (the plugin silently uses the default
     recogniser when on-device creation fails). This makes the privacy promise simpler.
   - Sends partial and final results, `done`, and the Android error code to Dart. Never logs
     what was said.
   - `lib/features/entries/services/speech_engine.dart` gets a `NativeSpeechEngine` that
     implements the existing `SpeechEngine` interface, so `DictationService` and the sheet do
     not change. The provider switches to it.
   - `speech_to_text` is then unused and is **removed** from `pubspec.yaml` (one dependency
     less; its `RECORD_AUDIO` need stays via `record`). `docs/dependencies.md` updated.
2. **Retry once on a lost connection.** `error_server_disconnected` and `error_client` start a
   fresh session once more before giving up (today: `error_client` 3 times, the other never).
3. **Show the error code.** The error screen adds a small line such as
   `Code: error_server_disconnected`. It is an Android code, never user content, and it makes the
   next problem diagnosable without a cable.
4. ~~Release logs work as documented.~~ Done separately first:
   `plans/20260919_121616_release-logging-and-dictation-diagnostics.md`.
5. **Sheets clear the navigation bar.** On Android 15+ the app draws behind the navigation bar,
   and in the screenshot the dictation sheet's "Close" button sits under it. The dictation sheet
   and the voice note sheet add the bottom system inset (`MediaQuery.viewPaddingOf`) to their
   bottom padding.

## Files to change

- new `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OnDeviceDictation.kt`
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` — channel wiring
- `lib/features/entries/services/speech_engine.dart` — `NativeSpeechEngine`, plugin engine removed
- `lib/features/entries/providers/dictation_providers.dart` — use it
- `lib/features/entries/services/dictation_service.dart` — one retry on lost connection; keep the code
- `lib/features/entries/presentation/editor/dictation_sheet.dart` — error code line, bottom inset
- `lib/features/entries/presentation/editor/voice_note_recorder.dart` — bottom inset
- `pubspec.yaml`, `docs/dependencies.md`, `docs/security.md` (dictation note), `docs/architecture.md`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` — one key, `labelDictationErrorCode`
  ("Code: {code}"), real translations
- tests (below)

## Tests

- `speech_engine_test.dart` rewritten for `NativeSpeechEngine` with a mocked channel: results,
  errors, done, and that `listen` always asks for on-device.
- `dictation_service_test.dart`: a lost connection is retried once, then reported with its code.
- `dictation_sheet_test.dart`: the error code shows; the sheet leaves room for the bottom inset.
- `flutter analyze`, `flutter test`, Sanskrit marker check.
- On the connected phone: build and install **prod** release (same as the one installed now),
  dictate in English (India), watch the log for the session reaching the speech service.

## Acceptance criteria

- On this phone, picking English (India) starts listening, and spoken words appear.
- If the recogniser fails, the screen shows which code it sent.
- Dictation can never use an online recogniser.
- The Close button and other controls sit above the navigation bar.
