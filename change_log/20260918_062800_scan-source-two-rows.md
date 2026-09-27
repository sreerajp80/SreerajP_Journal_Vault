# Change log — Two rows in the scan-text sheet, camera choice moved to Settings

**Plan:** `plans/20260918_061500_scan-source-two-rows.md`
**Date:** 2026-09-18

## Why

The "Scan text from photo" sheet in the entry editor had three rows: "Take
photo", "In-app camera" and "Choose from gallery". Three rows is one choice too
many for a routine action.

The in-app camera row was never a fallback — the app already falls back to it
by itself when the phone's camera app cannot be opened. It was there for
privacy: a few phone camera apps keep their own copy of the shot in the device
gallery, outside the vault and unencrypted, and the in-app camera never lets
the picture leave the app.

So the choice was kept, but moved out of the sheet.

## What changed

The sheet now shows two rows: **Take photo** and **Choose from gallery**.

A new switch in Settings → Security, **In-app camera**, decides what "Take
photo" does:

- off (the default) — the phone's own camera app, best picture and best text
- on — the camera built into this app, so nothing reaches the gallery

The automatic fallback is unchanged: if the phone camera app cannot be opened,
the message still shows and the in-app camera still opens.

## Files

| File | Change |
|---|---|
| `lib/features/entries/services/ocr_camera_source_store.dart` | **New** service. `OcrCameraSourceStore` with pref key `ocr_use_in_app_camera`, default `false`. SharedPreferences and in-memory implementations, built like `ocr_language_store.dart`. Stores one true/false flag, never content |
| `lib/features/entries/providers/ocr_providers.dart` | New `ocrCameraSourceStoreProvider` and `ocrInAppCameraProvider` (`AsyncNotifier`), which reads the flag and writes it back |
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | `_ScanSource.inAppCamera` removed; the enum is now `phoneCamera` and `gallery`. The in-app camera row is gone from the sheet. "Take photo" reads the setting and pushes `OcrCameraScreen` when it is on. The injected-picker test path short-circuits before the read, so tests never touch SharedPreferences |
| `lib/features/settings/presentation/security_settings_screen.dart` | New `ScanCameraTile` switch (`settings-scan-in-app-camera`), placed right under `ScreenSecurityTile` because it is a privacy control. Has a `Semantics` label like the tile above it |
| `lib/features/help/presentation/attachments_ocr_help_screen.dart` | No code change — the bullet it shows (`helpOcrPhoneCamera`) was reworded in the ARB files |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | New `labelSettingsScanInAppCamera` and `descSettingsScanInAppCamera`. `helpOcrPhoneCamera` reworded to point at the Settings switch instead of a third row. `actionOcrInAppCamera` kept — it is still used elsewhere |
| `test/features/entries/services/ocr_camera_source_store_test.dart` | **New.** Default is the phone camera; the choice saves, reads back, and turns off again; the in-memory store behaves the same |
| `test/features/entries/presentation/entry_editor_ocr_test.dart` | The sheet assertion now expects no in-app camera row |

No schema change, no new dependency, no new permission, no network use, no
change to OCR accuracy or capture resolution.

## Checks

- `flutter analyze` — no issues
- `flutter test` — 926 tests, all passing, including translation parity and
  label length
- `dart format lib test integration_test` — clean
- `sh tool/check_sanskrit_markers.sh` — passed

## Needs native-reader review

The Malayalam and Sanskrit text of `labelSettingsScanInAppCamera`,
`descSettingsScanInAppCamera`, and the reworded `helpOcrPhoneCamera`.
