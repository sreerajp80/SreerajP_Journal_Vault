# Plan — Two rows in the scan-text sheet, camera choice moves to Settings

**Status:** completed
**Change log:** `change_log/20260918_062800_scan-source-two-rows.md`

## Issue

The "Scan text from photo" sheet in the entry editor shows three rows:

1. Take photo (opens the phone's own camera app)
2. In-app camera
3. Choose from gallery

Three rows is one choice too many for a routine action. The fallback the user
expected already exists: if the phone camera app cannot be opened,
`_scanWithPhoneCamera` already shows a message and opens the in-app camera by
itself.

The in-app camera row is not a fallback. It exists for privacy — some phone
camera apps keep their own copy of the photo in the device gallery, outside the
vault and unencrypted. The in-app camera never lets the picture leave the app.
That control must stay, so it moves to Settings instead of being dropped.

## Decision

- The sheet shows two rows: **Take photo** and **Choose from gallery**.
- A new Settings switch decides what "Take photo" does:
  - off (default) — the phone's own camera app, best picture quality, best OCR
  - on — the in-app camera, nothing leaves the app
- The existing automatic fallback is unchanged.

## Layer notes

- `OcrCameraSourceStore` — **service** layer, same shape as
  `OcrLanguageStore` (abstract + SharedPreferences + in-memory for tests).
- `ocrCameraSourceStoreProvider` / `ocrInAppCameraProvider` — **providers**.
- Switch tile and sheet — **presentation**.

No schema change, no new dependency, no new permission, no network use.

## Files to change

| File | Change |
|---|---|
| `lib/features/entries/services/ocr_camera_source_store.dart` | **New.** `OcrCameraSourceStore` with `prefKey = 'ocr_use_in_app_camera'`, default `false`. SharedPreferences and in-memory implementations, mirroring `ocr_language_store.dart` |
| `lib/features/entries/providers/ocr_providers.dart` | New `ocrCameraSourceStoreProvider`, plus an `ocrInAppCameraProvider` `AsyncNotifier`-style provider that reads the value and writes it back |
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | Sheet drops the `entry-ocr-source-in-app-camera` row. `_ScanSource` keeps `phoneCamera` and `gallery`. When the setting is on, "Take photo" pushes `OcrCameraScreen` directly; otherwise it calls `_scanWithPhoneCamera` as now. Test injection path (`widget.imagePicker`) unchanged |
| `lib/features/settings/presentation/security_settings_screen.dart` | New `ScanCameraTile` switch, placed under `ScreenSecurityTile` — it is a privacy control, so it belongs with the other privacy rows. `Semantics` label like the existing tile |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | `helpOcrPhoneCamera` bullet rewritten to describe the Settings switch instead of a third row |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | Add `labelSettingsScanInAppCamera` and `descSettingsScanInAppCamera`. Reword `helpOcrPhoneCamera`. Keep `actionOcrInAppCamera` — it is still the in-app camera screen's own title. All three files, real translations, `@key` descriptions in the template |
| `test/features/entries/presentation/entry_editor_ocr_test.dart` | The case at line 176 that taps `entry-ocr-source-in-app-camera` changes to set the preference and tap "Take photo" instead |
| `test/features/entries/services/ocr_camera_source_store_test.dart` | **New.** Default is phone camera; saved value is read back; a read failure falls back to the default |
| `change_log/<timestamp>_scan-source-two-rows.md` | Written after the change |

## Acceptance criteria

1. The scan sheet shows exactly two rows in all three languages.
2. With the switch off, "Take photo" opens the phone camera app; if that fails,
   the message shows and the in-app camera opens — unchanged behaviour.
3. With the switch on, "Take photo" opens the in-app camera and never calls
   `image_picker`.
4. The setting survives an app restart.
5. `flutter analyze` clean, `flutter test` green, `dart format` clean.
6. `test/l10n/translation_parity_test.dart` and `label_length_test.dart` pass;
   `sh tool/check_sanskrit_markers.sh` passes.

## Needs native-reader review

Malayalam and Sanskrit text of `labelSettingsScanInAppCamera`,
`descSettingsScanInAppCamera` and the reworded `helpOcrPhoneCamera`.

## Not in scope

No change to OCR accuracy, capture resolution, the enhance screen, or the
in-app camera screen itself.
