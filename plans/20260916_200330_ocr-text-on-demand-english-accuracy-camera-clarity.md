# Plan — OCR: text on demand, better English, clearer photos

**Status:** completed
**Status note:** See `change_log/20260916_202307_ocr-text-on-demand-english-accuracy-camera-clarity.md` (approved 2026-09-16)

## The three problems reported

1. The OCR edit screen reads text from the photo again after **every** action
   (rotate, crop, filter, brightness, contrast, reset, language change). The
   whole screen stays busy with that work, so the image tools feel slow and do
   not work properly. The user wants OCR to run only when asked, from a text
   preview icon.
2. English OCR misses or garbles some words.
3. The OCR camera does not take photos as clear as the phone's own camera app,
   so recognition suffers.

---

## Part 1 — Stop automatic OCR; read text only when the user asks

### What happens now

In `lib/features/entries/presentation/ocr_enhance_tools.dart`,
`_applyEnhancements` ends by calling `_runLiveOcr` every time. Every tool action
calls `_applyEnhancements`, and changing the language calls `_runLiveOcr`
directly. So each slider move or rotate starts a full Tesseract run: up to six
passes on a 3000 px image. It uses the CPU the image work also needs, and the
Insert button is disabled while it runs (`_isScanning`).

### The fix

- **No automatic OCR.** Remove the `_runLiveOcr` call from
  `_applyEnhancements` and from `_onLanguageChanged`. Image actions only change
  the image, so they run fast.
- **The photo stays the main view.** The always-visible "live text" card
  under the photo is removed. The photo gets that space.
- **New text preview icon** (`Icons.text_snippet_outlined`) in the app bar,
  beside "Insert text", with a localized tooltip. Tapping it:
  - opens a bottom sheet;
  - runs OCR **once** on the current edited image, with a progress spinner;
  - shows the language selector, word count and the recognised text
    (selectable, scrollable);
  - has an "Insert text" button in the sheet too;
  - changing the language in the sheet re-runs OCR once for that language.
- **The result is kept** for the current image and language. Opening the
  preview again without changing anything shows it straight away, with no new
  run.
- **Any image change clears the kept text** and cancels any OCR still running
  (the existing `cancelRequests` path), so old text never stays on a changed
  image.
- **Insert text** uses the kept text if it is up to date. If not, it runs OCR
  once with a small progress dialog, then inserts. The Insert button is no
  longer disabled by OCR work.
- The image tools are never blocked while OCR runs. If the user edits the
  image during a run, that run is cancelled.
- The chosen language is remembered (see Part 2).

### Files

| File | Change |
|---|---|
| `lib/features/entries/presentation/ocr_enhance_screen.dart` | Remove text card from layout; add text preview icon; Insert no longer waits on `_isScanning` |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` | Remove auto OCR; keep-result logic (text + language + image version); on-demand OCR; clear and cancel on image change; Insert runs OCR if needed |
| `lib/features/entries/presentation/ocr_enhance_tools_2.dart` | Language selector moved into the sheet |
| `lib/features/entries/presentation/ocr_text_preview_sheet.dart` (new) | The bottom sheet widget. Presentation layer. Gets text, state and callbacks from the screen; calls no services itself |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | New keys such as `tooltipOcrPreviewText`, `titleOcrTextPreview`, `bodyOcrReadingText` — real translations in all three |

## Part 2 — English words missed

I found three causes in the native Tesseract code
(`android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`)
and the shipped models.

### Cause A — English uses the low-precision "fast" model

`assets/tessdata/eng.traineddata` is the `tessdata_fast` build (4.1 MB, rounded
weights). Malayalam already uses `tessdata_best`. `docs/dependencies.md` records
the choice as "English is already reliable at this build" — the user report
shows it is not, on phone photos.

**Fix:** replace it with `eng.traineddata` from `tessdata_best` (about 15 MB,
Apache 2.0, same source repo). Bump `TESSDATA_VERSION` so existing installs copy
the new file. APK grows by about 11 MB.

The model file must be downloaded once from
`github.com/tesseract-ocr/tessdata_best` by a developer and committed. The app
itself never downloads anything.

### Cause B — the confidence filter throws English words away

`collectConfidentText` drops any word under confidence 30. On a photo, real
English words often score 20–40, so correct words vanish. Worse, in the default
bilingual mode (`eng+mal`), some English words get misread as Malayalam
shapes. If those win the page "vote", the page is treated as Malayalam and
**every English word under 60 is dropped**.

**Fix:**
- When the language is English only (`eng`), skip the word filter completely
  and keep every word Tesseract reports. The filter exists to remove ornaments
  on Malayalam newsprint; it has no job on an English-only scan.
- In bilingual mode, only apply the high "foreign word" floor when the page is
  clearly Malayalam (at least 70% Malayalam words, instead of a simple
  majority). A mixed page keeps its English words.

### Cause C — the scan stops after the first "good enough" pass

After the first page segmentation mode scores `>= 1600` (for example 20 words at
confidence 80), the other modes are skipped. On a page with columns or a
separate heading, the first mode can read the main block well and still miss
words elsewhere.

**Fix:** only stop early when the first pass is both confident **and** clearly
complete — raise `CONFIDENT_SCORE` and also require mean confidence of at least
85. Otherwise try all three modes and keep the best, as the code already does.
This costs a little more time only on hard pages.

### Also: default language

The screen starts in `eng+mal`. Running two models on a pure English page
lowers English accuracy. **Fix:** remember the last language the user picked in
the OCR screen (a plain preference, `ocr_language`, not journal content), so an
English user picks English once and keeps it. First-time default stays
`eng+mal`.

### Files

| File | Change |
|---|---|
| `assets/tessdata/eng.traineddata` | Replace fast model with best model |
| `MainActivity.kt` | Bump `TESSDATA_VERSION`; skip word filter for `eng`; 70% rule for the Malayalam page vote; stricter early stop |
| `lib/features/entries/presentation/ocr_enhance_tools.dart` / `_2.dart` | Load and save the last chosen language through a provider |
| `lib/features/entries/providers/ocr_providers.dart` | Provider for the saved OCR language, using the app's existing preferences service |
| `docs/dependencies.md` | Update the model table and the reason |

---

## Part 3 — Clearer photos from the camera

### What happens now

`OcrCameraScreen` uses the Flutter `camera` plugin at `ResolutionPreset.max`.
That plugin talks to the raw camera hardware. It does **not** get the phone
maker's own photo processing — multi-frame noise reduction, HDR, sharpening,
stabilisation, and on many phones the full 50 MP mode. That is why the phone's
own camera app looks much sharper. No setting in the plugin can unlock this.

Two more things make it worse:
- **Flash starts on `auto`.** On paper, flash makes a bright glare spot that
  wipes out the words under it.
- **No focus before the shot.** The shutter fires straight away, so a photo
  taken while the lens is still hunting comes out soft.

### The fix

**3a. The main shutter uses the phone's own camera app (user decision).**
The editor's scan button already shows a small sheet with **Camera** and
**Gallery** (`entry_editor_actions_3.dart`). **Camera** will now open the phone's
own camera app through
`image_picker` with `ImageSource.camera` (already a dependency — no new
package). The photo comes back at the full quality the phone's camera app
gives, and goes into the same enhance screen as before. No resize limits are
set on the picker, so nothing is lost (matches the full-resolution rule).

**Privacy note, please read:** the photo is taken by another app. With the
normal Android capture request the photo is written only to the file this app
provides, but a few camera apps (some vendor builds) also keep their own copy in
the gallery. The in-app camera never does this. So the in-app camera stays
available as a third option in that sheet, **In-app camera**, and the OCR help
screen will say this plainly.

If no camera app is available, or the user cancels, nothing breaks: cancelling
returns to the editor quietly, and if the phone camera app cannot be opened the
app shows a message and opens the in-app camera instead.

**3b. Improve the in-app camera.**
- Default flash to **off** instead of auto.
- Before `takePicture`, lock focus and exposure on the centre (or the last
  tap point), wait briefly for focus to settle, take the shot, then return to
  auto focus. Uses `setFocusMode(FocusMode.locked)` / `setFocusPoint`, which the
  screen already calls for tap-to-focus. Ignored safely on devices that do not
  support it.

### Files

| File | Change |
|---|---|
| `lib/features/entries/presentation/ocr_camera_screen.dart` | Flash default off |
| `lib/features/entries/presentation/ocr_camera_controls.dart` | Focus-before-capture |
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | Sheet option "Camera" opens the phone camera app, then the enhance screen; new option "In-app camera" opens `OcrCameraScreen` |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | Explain the two cameras and the gallery-copy note |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | `actionOcrInAppCamera`, `helpOcrPhoneCamera` |

---

## Tests

| Test | Covers |
|---|---|
| `test/features/entries/presentation/ocr_enhance_screen_test.dart` | Rotate, filter, adjust and crop do **not** call the OCR service; the text preview icon runs OCR once and shows the text; opening it again does not run OCR again; an image change clears the kept text; Insert runs OCR when nothing is kept and returns the text; a language change in the sheet re-runs once |
| `test/features/entries/presentation/ocr_camera_screen_test.dart` | Flash starts off |
| `test/features/entries/presentation/entry_editor_ocr_test.dart` | "Camera" calls the picker with `ImageSource.camera` and opens the enhance screen; "In-app camera" opens `OcrCameraScreen`; cancel returns to the editor quietly |
| `test/features/entries/services/ocr_service_test.dart` | Language value still passed through unchanged |
| `test/l10n/*` | Parity and label-length tests pass for the new keys |

The native filter and early-stop changes in `MainActivity.kt` have no Kotlin
unit test harness in this project. They need a check on a real device with an
English page, a Malayalam page and a mixed page, before and after.

## Rules check

- No new dependency. No network use. Model is shipped in the APK.
- Nothing new is logged except existing length counts. No recognised text in logs.
- No schema change, so no migration.
- The OCR language preference is not journal content.
- New Malayalam and Sanskrit strings are marked "needs native-reader review" in
  the change log.
- `flutter analyze`, `flutter test`, `dart format`, and
  `tool/check_sanskrit_markers.sh` run after the change.

## Decisions from the user

- Part 1: OCR must not run on every image action; text only on demand from a
  preview icon. (Revised above.)
- Part 2: The 11 MB larger APK for the best English model is accepted.
- Part 3: The phone's own camera app is the main shutter.
