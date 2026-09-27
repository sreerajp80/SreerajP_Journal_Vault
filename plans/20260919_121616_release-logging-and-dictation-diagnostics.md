# Make release builds log, and log why dictation fails

**Status:** completed

Approved 2026-09-19 by the user ("First let us fix this"), as the first step of
`plans/20260919_121359_fix-dictation-on-device-listening.md` (item 4 there), plus the
diagnostics needed to find the dictation failure. The rest of that plan waits for the result.

## Issue

- `AppLogger` builds a `Logger` without a filter. The `logger` package's default is
  `DevelopmentFilter`, which drops **every** message outside debug builds. So the prod build
  prints nothing, although the code says "Prod ships info and above". The dictation failure on
  the phone could not be diagnosed because of this.
- When listening fails inside the `speech_to_text` plugin, `PluginSpeechEngine` swallows the
  exception and the service logs only "listen did not start", without the reason.

## Fix

1. `lib/core/logging/app_logger.dart`: use `ProductionFilter`, so the configured level (info in
   prod, trace in dev) is honoured in every build.
2. Same file — **safety for release logs**: when verbose logging is off (prod), `warning`,
   `error` and `fatal` log only the error's **type**, never its text. An exception's text can hold
   a file name or path (for example `FileSystemException`), and existing call sites have not all
   been audited. Dev builds keep the full error. Stack traces stay (no user content).
3. `lib/features/entries/services/speech_engine.dart`: log the plugin's failure reason when
   `initialize` or `listen` fails — the exception type and, for `PlatformException` /
   `ListenFailedException`, the plugin's error code. These are fixed plugin strings such as
   `recognizerNotAvailable`, never speech or user content.

## Files

- `lib/core/logging/app_logger.dart`
- `lib/features/entries/services/speech_engine.dart`
- `test/core/logging/app_logger_test.dart`
- `docs/security.md` (logging section), change log

## Verify

- Tests: release-style logger passes info and drops debug; prod mode logs the error type, not
  its text. `flutter analyze`, `flutter test`.
- Build the prod release APK, install it over the current one with `adb install -r` (keeps the
  data; it refuses rather than wipes if the signature differs), try dictation, and read
  `adb logcat -s flutter` for the reason.
