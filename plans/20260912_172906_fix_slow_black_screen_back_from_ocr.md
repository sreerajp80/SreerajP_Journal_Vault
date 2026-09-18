# Fix: long black loading screen when going back from the OCR enhance screen

**Status:** completed

## The problem

Steps that show it:

1. Entry editor -> OCR -> camera screen (`OcrCameraScreen`).
2. Take a photo -> the enhance screen (`OcrEnhanceScreen`) opens on top.
3. On the enhance screen, use the **crop** tool.
4. Press **back** on the enhance screen.
5. A full black screen with a spinner appears for a long time. Another back press
   is needed to reach the entry editor.

## Why it happens

The black screen with the white spinner is the camera screen's own loading state
(`_buildBody` in `lib/features/entries/presentation/ocr_camera_screen.dart`,
shown when `_isInitializing`, `_controller == null`, or the controller is not
initialized).

Three things add up:

1. **The crop tool is a separate Android screen.** `image_cropper` (uCrop) opens a
   native activity, so the app goes `inactive`/`paused`. The camera screen is still
   alive underneath the enhance screen, so its `didChangeAppLifecycleState` runs,
   disposes the camera controller and sets `_controller = null`.
2. **The camera is re-created at the wrong moment.** On `resumed` the camera screen
   calls `_initCamera` straight away, even though it is not the screen the user is
   looking at. CameraX start-up at `ResolutionPreset.veryHigh` is slow, and at that
   exact moment the enhance screen is re-running image enhancement plus Tesseract
   OCR, so the phone is busy. If that start-up stalls there is no timeout and no
   retry, so the screen can sit on the spinner.
3. **Old OCR work keeps running after the enhance screen is closed.** The native
   handler (`MainActivity.kt`) runs every `extractText` call on one single-thread
   executor with no cancellation. Every rotate, filter or slider change queues
   another full Tesseract run. Leaving the screen does not drop them, so they keep
   using the CPU while the camera is trying to start.

## The fix

**A. Do not rebuild the camera while the camera screen is hidden**
(`lib/features/entries/presentation/ocr_camera_screen.dart`)

- Track whether the camera route is the visible one (`ModalRoute.of(context)?.isCurrent`,
  plus a simple `_childRouteOpen` flag set around the `Navigator.push` calls in
  `_capturePhoto` and `_pickFromGallery`).
- On `paused`/`inactive`: dispose as now, but remember with a `_needsReinit` flag.
- On `resumed`: re-create the camera only when the camera screen is the visible
  route. Otherwise just keep `_needsReinit = true`.
- When the enhance screen (or the gallery picker) returns, if `_needsReinit` is set
  or the controller is gone, start `_initCamera` right then. The device is idle at
  that point, so the wait is short.

**B. Never let camera start-up hang**
(same file)

- Add a generation counter so a late `_initCamera` result cannot overwrite a newer one.
- Put a timeout (8 seconds) on `controller.initialize()`, with one retry, then show
  the existing error view with a "Retry" action instead of an endless spinner.
- Set `_isInitializing = true` at the start of `_initCamera` too, so the state is honest.

**C. Drop OCR work that nobody is waiting for any more**
(`lib/features/entries/presentation/ocr_enhance_screen.dart`,
`lib/features/entries/services/ocr_service.dart`,
`android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`)

- Give each `extractText` call a request id. The native side keeps the set of
  cancelled ids and skips a queued job whose id was cancelled before it started.
- Add a `cancelOcr` method on the same channel. The enhance screen calls it in
  `dispose()` and before starting a new recognition run, so only the newest request
  survives.
- On the Dart side ignore results from a stale request id.

**D. Small correctness touch**

- The enhance screen's `dispose()` deletes its temp files one by one on the UI
  thread. Move that to a fire-and-forget async delete so closing the screen is
  instant.

## Files to change

- `lib/features/entries/presentation/ocr_camera_screen.dart` (A, B)
- `lib/features/entries/presentation/ocr_enhance_screen.dart` (C, D)
- `lib/features/entries/services/ocr_service.dart` (C)
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` (C)
- `test/features/entries/services/ocr_service_test.dart` (new cancel test)
- New: `test/features/entries/presentation/ocr_camera_screen_lifecycle_test.dart`

## What stays the same

- No new dependency, no network, no change to capture quality
  (`ResolutionPreset.veryHigh` is kept).
- No change to how recognized text is returned to the entry editor.
- No change to storage, crypto, or the database.

## Checks after the change

- `flutter analyze` clean.
- `flutter test` green.
- Manual: camera -> capture -> enhance -> crop -> back. Expect the camera preview
  back in about a second, and back again reaches the entry editor at once.
