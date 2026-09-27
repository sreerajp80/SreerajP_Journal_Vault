# Make OCR capture, image clean-up and text reading robust

Implements [`plans/20260919_091549_ocr-robust-capture-and-enhance.md`](../plans/20260919_091549_ocr-robust-capture-and-enhance.md).

## Decision from the user

"Take photo" keeps opening the phone's own camera app by default (plan section A was dropped).
The in-app camera stays an opt-in switch in Settings. Only the in-app camera guarantees that no
copy reaches the gallery: some phone makers' camera apps save their own extra copy, which this
app cannot stop or delete. The existing help text already says this.

## What changed

### Temporary photos are deleted (privacy)

- New service `OcrTempFileSweeper` / `CacheOcrTempFileSweeper`
  (`lib/features/entries/services/ocr_temp_file_sweeper.dart`) and `ocrTempFileSweeperProvider`.
  - `deleteNow` deletes one scan file, and the picker's empty folder, only inside the app cache.
  - `sweepStale` deletes scan files (`CAP`, `image_picker`, `image_cropper`, `ocr_cap_`,
    `ocr_enh_`, `ocr_prep_`, `ocr_rot_`) older than 60 seconds, only in the cache folder.
  - Never logs a file name or path.
- In-app camera: the captured photo is deleted when the enhance screen closes, whether the text
  was inserted or the user went back to retake. The gallery copy made by the picker is deleted
  too.
- Editor: each new scan sweeps old leftovers. The picker's copy of a gallery photo, and the phone
  camera photo, are deleted when the enhance screen closes.
- The enhance screen now writes its working files into the cache folder given by the sweeper
  (was `Directory.systemTemp`).

### Image clean-up tools

- **Crop fix:** crop now receives the unfiltered image with only the rotation applied (new
  `OcrEnhanceParams.fitToOcrSize: false` for that copy). Filters, sliders, sharpen and enlarge are
  then applied once, to the cropped image. Before, they were applied twice.
- A failed change now shows "Could not apply this change. Try again."; a photo that cannot be
  opened shows "Could not open this photo. Try another one."; a failed crop shows the existing
  crop error. Before, failures were silent.
- `kOcrMaxOutputLongEdge` raised from 3000 to 4000 px, matching the working copy, so the camera's
  detail is not shrunk away.
- The enhancer reads only the image header first and refuses images over 25 MP
  (`OcrImageTooLargeException`) instead of running out of memory.
- An edit made before the working copy is ready now waits for it, instead of starting on the
  full-size photo. The first preview of the photo is decoded at 2048 px wide, not full size.

### Text reading

- `NativeOcrService` gives up after 3 minutes (`kOcrRecognitionTimeout`) with
  `OcrTimeoutException`, and cancels the native job. The insert button and the text preview show
  "Reading the text took too long. Crop to just the text and try again."
- Recognition request ids now come from one counter for the whole app run, so a late cancel from
  a closed screen can never drop a read on the next screen.
- Native (`MainActivity.kt`, new `OcrImageLoading.kt`):
  - images are decoded with a sample size and resized so the long edge is at most 4500 px, and
    EXIF rotation is applied;
  - the OCR worker catches `Throwable`, so an out-of-memory error still answers the caller (and
    frees the engines so the next read starts clean);
  - `onDestroy` frees the Tesseract engines on the OCR thread, after any running read;
  - language models are copied to a `.part` file and renamed only when complete.

### In-app camera

- Start-up attempts are now full resolution, full resolution, 4K (`ultraHigh`), then 1080p.
  Before, the fallback went straight to 1080p.
- The capture's width and height are logged (numbers only).

### Strings (en, ml, sa)

New keys: `errorOcrEnhanceFailed`, `errorOcrPhotoUnreadable`, `errorOcrTimedOut`.

### Docs

`docs/architecture.md` OCR section updated with the limits, the crop behaviour and the
temp-file clean-up.

## Tests

- New: `test/features/entries/services/ocr_temp_file_sweeper_test.dart` (9 tests),
  `test/features/entries/services/ocr_enhancer_limits_test.dart` (4),
  `test/features/entries/presentation/ocr_enhance_screen_robustness_test.dart` (7),
  `android/app/src/test/kotlin/in/sreerajp/sreerajp_journal_vault/OcrImageLoadingTest.kt` (7).
- Changed: `ocr_service_test.dart` (2 timeout tests), `ocr_enhancer_test.dart` (size-limit test
  now expects 4000 px), `ocr_enhance_screen_test.dart` and `ocr_enhance_test_fakes.dart` (inject a
  fake sweeper; new fakes).
- Results: 125 Dart tests pass (all OCR service and screen tests, all entries service tests
  except dictation, and the l10n parity and label-length tests). Kotlin: `OcrImageLoadingTest`
  7/7 and `OcrPassRulesTest` 5/5 pass. `dart format` clean. Sanskrit marker check passes.

## Not done, and why

- **Section A (in-app camera as default):** dropped at the user's request.
- **`entry_editor_ocr_test.dart` could not run**, and `flutter analyze` still reports 5 errors.
  Both are caused by the unfinished dictation change
  (`plans/20260918_223500_fix-dictation-and-voice-note.md`): `pickDictationLanguage` is missing,
  so the editor library does not compile. This change adds no analyzer issue of its own. The
  Kotlin tests were run with the Flutter compile step skipped for the same reason.
- **No widget test for deleting the in-app camera photo.** The camera screen's test mode returns
  the photo path before the enhance screen opens, so the deletion path cannot be reached there.
  The sweeper itself is fully tested.
- **Gallery copies left by a crash are not swept.** The picker puts them in randomly named
  folders, which cannot be told apart from other cache folders safely. They are copies of photos
  already in the user's gallery, so no new private content is exposed.
- **Real-device check is still needed:** take a photo with each camera, crop after applying
  Document, read Malayalam and English, and confirm the app cache holds no scan files afterwards.

## Needs native-reader review

Malayalam and Sanskrit text of `errorOcrEnhanceFailed`, `errorOcrPhotoUnreadable` and
`errorOcrTimedOut`.
