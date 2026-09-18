# Change log — OCR: text on demand, better English, clearer photos

**Plan:** `plans/20260916_200330_ocr-text-on-demand-english-accuracy-camera-clarity.md`
**Date:** 2026-09-16

## Summary

Three OCR problems were fixed:

1. The edit screen no longer reads text after every image change. Text is read
   only when the user asks for it.
2. English recognition was improved: a better model, and fewer real words thrown
   away.
3. "Take photo" now uses the phone's own camera app, and the in-app camera was
   improved.

## Part 1 — Text is read only on demand

**Before:** every rotate, crop, filter, invert, brightness or contrast change,
and every language change, started a full Tesseract run. The screen stayed busy
and the image tools lagged.

**Now:**

- Image tools only change the image. They never start recognition.
- The "Text found" card under the photo was removed, so the photo has more room.
- A new text preview icon in the app bar opens a bottom sheet. The sheet reads
  the text once and shows it, with the language picker, the word count and an
  insert button.
- The result is kept for the current image and language. Opening the preview
  again shows it with no new read.
- Any image change throws the kept text away and cancels a read still running.
- "Insert into Entry" uses the kept text when it is up to date. Otherwise it
  reads once (with a "Scanning text..." overlay), then inserts.
- Closing the sheet during a read cancels that read. A cancelled read answers
  with empty text on the native side; the screen now ignores such answers, so
  empty text is never kept or inserted by mistake.
- The last chosen OCR language is remembered under the `ocr_language`
  preference. It holds only a language code, never journal content.

| File | Change |
|---|---|
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Text card removed from layout; text preview icon; insert overlay; new state for kept text |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | Automatic OCR removed; `_readText` with kept text; waits for the image to be final; insert reads when needed; language saving |
| `lib/features/entries/presentation/ocr_enhance_tools_2.dart` | Language selector moved out (into the sheet) |
| `lib/features/entries/presentation/ocr_text_preview_sheet.dart` | **New.** Presentation layer. The text preview bottom sheet; calls no service |
| `lib/features/entries/services/ocr_language_store.dart` | **New.** Service layer. Saves and reads the OCR language |
| `lib/features/entries/providers/ocr_providers.dart` | `ocrLanguageStoreProvider` |

## Part 2 — English accuracy

| File | Change |
|---|---|
| `assets/tessdata/eng.traineddata` | Replaced the `tessdata_fast` model (4.1 MB) with `tessdata_best` (15.4 MB), from `github.com/tesseract-ocr/tessdata_best`, Apache 2.0. SHA-256 `8280aed0782fe27257a68ea10fe7ef324ca0f8d85bd2fd145d1c2b560bcb66ba`. APK grows by about 11 MB, approved by the owner |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | `TESSDATA_VERSION` bumped so existing installs copy the new model. English-only scans keep every word (no confidence filter). The strict "foreign word" floor applies only when at least 70% of readable words are Malayalam (`MALAYALAM_PAGE_SHARE`), not a simple majority. Early stop now needs score 2400 **and** mean confidence 85 (`CONFIDENT_MEAN`), instead of score 1600 alone |
| `docs/dependencies.md` | Model table updated |

## Part 3 — Camera

| File | Change |
|---|---|
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | "Take photo" opens the phone's own camera app (`image_picker`, no size limits), then the enhance screen. The temporary photo is deleted afterwards. If the camera app cannot be opened, a message is shown and the in-app camera opens instead. New "In-app camera" option in the source sheet |
| `lib/features/entries/presentation/ocr_camera_screen.dart` | Flash starts **off** (flash glare hides words on paper) |
| `lib/features/entries/presentation/ocr_camera_controls.dart` | Before each shot, focus is set on the last tap point (or the centre) and given 350 ms to settle. Skipped when the user has locked focus or the camera cannot focus on a point |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | New help bullet about the two cameras and the gallery-copy note |

**Privacy note:** a few phone camera apps also keep their own copy of the photo
in the gallery. This is explained in the help screen, and the in-app camera is
still offered for photos that must never leave the app. No new permission, no
new dependency, no network use.

## Localization

New keys in `app_en.arb`, `app_ml.arb` and `app_sa.arb`:
`tooltipOcrPreviewText`, `actionOcrInAppCamera`,
`errorOcrPhoneCameraUnavailable`, `helpOcrPhoneCamera`.

**Needs native-reader review:** the Malayalam and Sanskrit text of all four new
keys. In particular the Sanskrit `अन्तःस्थं छायायन्त्रम्` for "in-app camera" and
`छायायन्त्र-अनुप्रयोगः` for "camera app".

## Tests

- `test/features/entries/presentation/ocr_enhance_screen_test.dart` — rewritten:
  image tools never call OCR; the preview reads once and keeps the text; an
  image change clears the kept text; insert reads when nothing is kept; a
  language change re-reads once and is saved; the saved language is used;
  closing the preview during a read cancels it; closing the screen during a
  read cancels it; the capture is still shrunk before enhancement.
- `test/features/entries/services/ocr_language_store_test.dart` — **new**.
- `test/features/entries/presentation/ocr_camera_screen_test.dart` — flash now
  starts off.
- `test/features/entries/presentation/entry_editor_ocr_test.dart` — the source
  sheet shows "In-app camera".

## Checks run

- `flutter analyze` — no issues.
- `flutter test` — all 916 tests passed.
- `dart format lib test integration_test` — clean.
- `sh tool/check_sanskrit_markers.sh` — passed.
- Kotlin compiles (`:app:compileDevDebugKotlin`).

## Not tested here — needs a real device

- The native filter and early-stop changes have no Kotlin unit tests. Check with
  an English page, a Malayalam page and a mixed page.
- The phone camera app flow (opening, cancelling, returning a full-size photo),
  and whether the device's camera app keeps a gallery copy.
- Focus-before-capture sharpness on the in-app camera.
- The first launch after update copies the new English model once (about 15 MB).
