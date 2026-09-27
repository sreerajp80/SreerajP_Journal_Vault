# Make OCR capture, image clean-up and text reading robust

**Status:** completed

Approved 2026-09-19. Camera decision: **keep as is** — the phone's camera app stays the default
for "Take photo"; the in-app camera stays an opt-in in Settings. So section A below is not done,
and `helpOcrPhoneCamera` is not changed.

## Goal

A scan-text module that works every time:

1. The phone's camera hardware takes the photo, at the highest resolution it offers.
2. The photo is never saved to the gallery. It lives only in the app's private cache and is
   deleted as soon as the text is read (or the scan is cancelled).
3. The image clean-up tools (rotate, crop, filters, brightness, contrast, enlarge, sharpen) give
   the result the user sees, every time, with no hidden double-processing.
4. Text reading never hangs, never crashes the app on a very large photo, and always tells the
   user when something went wrong.

## What is already good (kept as is)

- The in-app camera asks CameraX for the highest resolution (`ResolutionPreset.max`, which the
  plugin maps to "highest available, prefer resolution over frame rate"). The photo is written to
  the app's private cache folder, not the gallery.
- A 50 MP photo is shrunk once, natively, to a 4000 px working copy, so Dart never decodes the full
  photo. EXIF rotation is applied once.
- Tesseract runs on one background thread, with cancel support, several reading passes and a
  blur warning. The 83 OCR tests that compile today all pass.

## Issues found

### A. The photo can end up in the gallery

1. **"Take photo" opens the phone's camera app by default.** The app hands that camera app a
   private file to write into, but several phone makers' camera apps also save their own copy to
   the gallery anyway. The app cannot stop that and cannot delete that copy. Only the in-app
   camera guarantees no gallery copy. The in-app camera is currently an opt-in switch in Settings.
2. Leaving the app for the phone camera app also lets Android kill the app in the background on
   low-memory phones, which loses the photo and forces an unlock.

### B. Private photos are left behind in the cache (not encrypted)

A photo of a journal page is private content. Today these plain (unencrypted) files are never
deleted:

1. The in-app camera's photo (`CAP…jpg`) after the scan finishes or is cancelled.
2. The copy of a gallery photo that the picker makes, in both the editor and the camera screen.
3. Leftovers from a crash or a force-close in the middle of a scan.

### C. Clean-up tool bugs

1. **Crop applies the filters twice.** The crop tool is given the already-filtered, already
   sharpened, already enlarged image, and afterwards every setting is applied again on top. So
   Document B/W gets doubled, sharpening gets doubled, and ×2 enlarge becomes ×4 (up to the cap).
   The picture the user sees after cropping is not what the sliders say.
2. **A failed clean-up is silent.** If a filter run fails, the screen just stops the spinner and
   keeps the old picture. The user thinks the change was applied.
3. **The default size cap undoes the high-resolution capture.** The working copy is 4000 px, but
   with enlarge at ×1 the output is shrunk again to 3000 px (about 250 dpi for a full page). This
   throws away detail that the camera captured, against the "use full resolution" rule.
4. **A very large photo can crash the app.** If native shrinking fails (rare, but possible with an
   odd file), the full 50 MP photo goes to the Dart image library, which needs about 200 MB per
   copy and can kill the app.

### D. Text reading can hang or crash

1. **Native out-of-memory hangs the screen forever.** The native side decodes the image with no
   size limit and only catches `Exception`. An `OutOfMemoryError` is not an `Exception`, so the
   worker thread dies without replying, and the "Reading text…" spinner never stops.
2. **No time limit on the Dart side.** If the native side never answers, the user waits forever.
3. **Sideways photo on a fallback path.** Native decoding ignores EXIF rotation. On the fallback
   path (when the working copy could not be made) a portrait photo is read sideways, which gives
   junk text.
4. **Closing the app during a read can crash natively.** `onDestroy` frees the Tesseract engine on
   the main thread while the OCR thread may still be using it.
5. **A half-copied language model is never repaired.** The model files (15 MB and 12 MB) are copied
   straight to their final name. If the copy fails part way, a broken file stays and the version
   marker can still be written, so Tesseract stays broken until the app is reinstalled.

### E. In-app camera fallback is too low

If full resolution will not start twice, the camera drops straight to 1920×1080, which is too low
for small print. There should be a 4K (3840×2160) step in between.

## Plan

### A. Camera and gallery — dropped (user chose to keep the phone camera app as default)

- **Recommended:** make the in-app camera the default for "Take photo". Change
  `OcrCameraSourceStore.defaultUseInAppCamera` from `false` to `true`. Users who already set the
  switch keep their choice; everyone else gets the in-app camera. The phone camera app stays
  available as an opt-in in Settings, with the existing warning that some camera apps keep a
  gallery copy.
- Update the help text `helpOcrPhoneCamera` (en, ml, sa) to describe the new default.

### B. Delete every temporary photo

- New service `OcrTempFileSweeper` (layer: service, `lib/features/entries/services/`).
  - `deleteNow(path)` — deletes one temp file, and its parent folder when it is an empty picker
    folder inside the cache.
  - `sweepStale()` — deletes leftover scan files in the app cache folder only, matched by the
    known name prefixes (`CAP`, `image_picker`, `image_cropper`, `ocr_cap_`, `ocr_enh_`,
    `ocr_prep_`, `ocr_rot_`) and older than 60 seconds. Never touches anything outside the cache.
    Never logs file names or paths.
  - Provider `ocrTempFileSweeperProvider`.
- Call `sweepStale()` when a scan starts (catches crash leftovers).
- Delete the in-app camera photo after the enhance screen closes (text inserted or cancelled).
- Delete the gallery copy after the enhance screen closes, in both the editor and the camera
  screen.
- The enhance screen writes its files through `getTemporaryDirectory()` (today it uses
  `Directory.systemTemp`), so every file lands in one known folder that the sweeper covers.

### C. Clean-up tools

1. **Crop fix:** before opening the crop tool, make a copy of the working image with only the
   current rotation applied (no filter, no adjustments, no resize). Crop that. The cropped image
   becomes the new source with rotation reset to 0, and the filters and sliders are then applied
   once. Needs one new option on `OcrEnhanceParams`: `fitToOcrSize` (default `true`; `false` for the
   rotation-only copy).
2. **Visible failure:** when a clean-up run fails, show a message (new string
   `errorOcrEnhanceFailed`, "Could not apply this change. Try again.").
3. **Size cap:** raise `kOcrMaxOutputLongEdge` from 3000 to 4000, to match the working copy, so the
   captured detail reaches the reader. The enlarged cap stays at 4500.
4. **Size guard:** before decoding, `processOcrImageIsolate` reads only the image header. If the
   image is above 25 megapixels it stops with a clear error instead of running out of memory. The
   screen then shows a new message `errorOcrPhotoUnreadable` ("Could not open this photo. Try
   another one.").

### D. Text reading

1. **Native safe decode** (new small file `OcrImageLoading.kt`, pure functions, JVM-testable):
   - read the image size first, then decode with a sample size so the long edge is at most
     4500 px;
   - apply EXIF rotation when the file is a JPEG;
   - catch `Throwable` (including `OutOfMemoryError`) in the OCR worker so it always replies
     with an error instead of dying.
2. **Dart time limit:** `NativeOcrService` waits at most 3 minutes, then cancels the native job
   and throws a timeout. The enhance screen shows a new message `errorOcrTimedOut` ("Reading took
   too long. Crop to the text and try again.").
3. **Safe shutdown:** `onDestroy` frees the Tesseract engines on the OCR thread, after any running
   job, instead of on the main thread.
4. **Safe model copy:** copy each language model to a `.tmp` file, check its size matches the
   asset, then rename it into place. The version marker is written only when both models are
   complete.

### E. In-app camera

- Start-up attempts become: full resolution, full resolution, 4K (`ultraHigh`), 1080p. 1080p is now
  only the last resort.
- Log the captured width and height once (numbers only, no content), so a low-resolution device can
  be spotted in the logs.

## Files to change

| File | Change |
|---|---|
| `lib/features/entries/services/ocr_temp_file_sweeper.dart` | **New** — temp photo clean-up |
| `lib/features/entries/providers/ocr_providers.dart` | Sweeper provider |
| `lib/features/entries/services/ocr_enhancer.dart` | `fitToOcrSize`, 4000 px cap, 25 MP guard |
| `lib/features/entries/services/ocr_service.dart` | Time limit and cancel on timeout |
| `lib/features/entries/services/ocr_capture_downscaler.dart` | Log capture size (numbers only) |
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Temp folder, new fields |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | Crop fix, failure and timeout messages |
| `lib/features/entries/presentation/ocr_camera_screen.dart` | 4K fallback step |
| `lib/features/entries/presentation/ocr_camera_controls.dart` | Delete captured and gallery photos |
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | Sweep on scan start, delete gallery copy |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Safe decode, catch `Throwable`, safe shutdown, safe model copy |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OcrImageLoading.kt` | **New** — sample-size and EXIF helpers |
| `android/app/src/test/kotlin/in/sreerajp/sreerajp_journal_vault/OcrImageLoadingTest.kt` | **New** — JVM tests for the helpers |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (+ regenerated `app_localizations*.dart`) | 3 new error strings |
| `test/features/entries/services/ocr_temp_file_sweeper_test.dart` | **New** |
| `test/features/entries/services/ocr_enhancer_test.dart` | Cap, guard and `fitToOcrSize` tests |
| `test/features/entries/services/ocr_service_test.dart` | Timeout test |
| `test/features/entries/presentation/ocr_enhance_screen_test.dart` (+ fakes) | Crop-once, failure message, timeout message |
| `test/features/entries/presentation/ocr_camera_screen_test.dart` | Captured photo deleted, 4K step |
| `docs/architecture.md` | OCR section: temp clean-up, limits |
| `change_log/…_ocr-robust-capture-and-enhance.md` | **New** — change log |

No database change, no new package, no new permission, no network use.

## Blocker to note

The tree does not compile right now because of the unfinished dictation change
(`plans/20260918_223500_fix-dictation-and-voice-note.md`, status in progress):
`pickDictationLanguage` is missing. That stops `flutter analyze` from being clean and stops
`entry_editor_ocr_test.dart` from loading. This plan does **not** touch dictation. Full
verification of the editor OCR test needs that change finished first.

## How it will be verified

- `flutter gen-l10n`, `dart format lib test`, `sh tool/check_sanskrit_markers.sh`.
- `flutter analyze` — no new issues (the dictation errors above are pre-existing).
- All OCR tests, the l10n parity and label-length tests, and the new tests pass.
- `./gradlew :app:testDevDebugUnitTest` for the Kotlin helper tests (`OcrPassRulesTest`,
  `OcrImageLoadingTest`).
- On a real phone (manual, by the user): take a photo with the in-app camera, check the gallery has
  no new photo, crop after applying Document B/W and confirm it is applied once, read Malayalam and
  English text, and confirm the app cache holds no scan files afterwards.

## Needs native-reader review

The new and changed Malayalam and Sanskrit strings (`errorOcrEnhanceFailed`,
`errorOcrPhotoUnreadable`, `errorOcrTimedOut`).
