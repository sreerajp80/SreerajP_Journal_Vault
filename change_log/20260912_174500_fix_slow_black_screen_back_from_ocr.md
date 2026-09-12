# Change log: long black loading screen when going back from the OCR enhance screen

**Plan:** `plans/20260912_172906_fix_slow_black_screen_back_from_ocr.md`
**Date:** 2026-09-12

## What was wrong

Going back from the OCR enhance screen showed a black screen with a spinner for a
long time before the entry editor could be reached.

The black screen was the camera screen's own loading state. Three things caused it:

1. The crop tool is a separate Android screen. Opening it puts the app in the
   background, so the camera screen — still alive under the enhance screen — threw
   its camera away.
2. On resume it rebuilt the camera straight away, even though the user was still
   looking at the enhance screen. Camera start-up is slow, and at that moment the
   enhance screen was re-running image enhancement and text recognition, so the
   device was busy. There was no timeout and no retry, so the spinner could stay.
3. Every rotate, filter or slider change queued another full recognition run on the
   single native recognition queue, with no way to cancel. Closing the enhance
   screen did not stop them, so they kept the processor busy.

## What changed

### `lib/features/entries/presentation/ocr_camera_screen.dart`

- Added `_childRouteOpen`, `_needsReinit` and `_isScreenVisible`. The camera is now
  rebuilt only when this screen is the one on top. While the enhance screen, the
  crop tool or the gallery picker is in front, the camera stays released.
- `build` brings the camera back the moment the screen is visible again, and the
  enhance / gallery paths call `_resumeCameraAfterChildRoute()` when they return.
- `_initCamera` now has a generation counter, so a slow attempt can never overwrite
  a newer one; an 8 second timeout with one retry; it no longer waits for the old
  camera to be released; and it sets the loading state honestly.
- The error view gained a **Retry** button (existing `commonRetry` string), so a
  failed start-up is recoverable instead of a dead end.
- New optional `controllerFactory` parameter, used only by tests to supply a stand-in
  camera controller. Production behaviour and capture quality are unchanged
  (`ResolutionPreset.veryHigh`).

### `lib/features/entries/services/ocr_service.dart`

- `extractTextFromImage` takes an optional `requestId`.
- New `cancelRequests(List<int>)` asks the platform to drop recognition work that
  nobody is waiting for. `NativeOcrService` sends it over the method channel;
  `MlKitOcrService` has nothing queued, so its version does nothing.

### `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

- `extractText` now reads a `requestId` and skips a queued job whose id was
  cancelled before it started.
- New `cancelOcr` method records cancelled ids.

### `lib/features/entries/presentation/ocr_enhance_screen.dart`

- Each recognition run gets an id. Starting a new run cancels the older ones, and a
  late answer from an out-of-date run is ignored.
- `dispose()` cancels everything still in flight, and deletes its temporary preview
  files in the background instead of one by one on the UI thread, so closing the
  screen is instant.

## Tests

- New `test/features/entries/presentation/ocr_camera_screen_lifecycle_test.dart`:
  the camera is not rebuilt while another screen is on top, and is rebuilt when that
  screen closes; a resume while the camera screen is visible does rebuild it.
- New case in `test/features/entries/presentation/ocr_enhance_screen_test.dart`:
  closing the screen cancels recognition that is still running.
- New cases in `test/features/entries/services/ocr_service_test.dart`: the request id
  is sent, `cancelOcr` is sent with the ids, and an empty cancel sends nothing.
- Existing OCR test fakes updated for the new method signature.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 832 tests pass.
- `./gradlew :app:compileProdDebugKotlin` — builds.

## Notes

No new dependency, no network use, no change to storage, crypto or the database.
