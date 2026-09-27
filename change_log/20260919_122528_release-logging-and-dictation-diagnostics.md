# Release builds log again; dictation logs why it fails

Implements `plans/20260919_121616_release-logging-and-dictation-diagnostics.md`.

## What changed

- `lib/core/logging/app_logger.dart`: the `Logger` now uses `ProductionFilter`. Before, it used
  the `logger` package's default `DevelopmentFilter`, which drops every line outside debug
  builds, so prod builds logged nothing although the code said "info and above".
- Same file: in prod (verbose off), `warning`, `error` and `fatal` log only the error's type,
  never its text, because an exception's text can hold a file name or path. Dev builds keep the
  full error. `debugOverrideLogger` gained a `fullErrors` flag for tests.
- `lib/features/entries/services/speech_engine.dart`: when the `speech_to_text` plugin fails to
  initialise or listen, the plugin's error code or type is logged (fixed plugin strings only).
- `lib/features/entries/services/dictation_service.dart`: logs each recogniser status word
  (`listening`, `notListening`, `done`).
- `test/core/logging/app_logger_test.dart`: 3 new tests (filter honours the level; prod logs the
  error type only; dev logs the full error).
- `docs/security.md` section 9 updated.

## Verification

- `flutter analyze` clean; logging, speech engine and dictation service tests pass (30).
- Prod release APK built and installed over the existing app with `adb install -r` (data kept).
- On the phone the log now shows the cause of the dictation failure:
  - First dictation after app start works (status `listening`, results arrive, restarts after
    silence).
  - Every later dictation fails at once with **`error_server_disconnected`**. The app's language
    check (`reportOnDeviceSpeechStatus`) ends with the phone's speech service shutting down
    (`RecognitionService#onDestroy`), and the plugin re-uses its earlier recogniser, whose
    connection is now dead. No listening request reaches the speech service.
- The fix for this is `plans/20260919_121359_fix-dictation-on-device-listening.md`, which waits
  for approval.
