# Change Log: Encrypted Device-to-Device Optical Air-Gap Sync (AirQR)

**Date:** 2026-08-24
**Plan:** `plans/20260824_123000_optical_airqr_sync.md`

---

## 1. Overview

Implemented **Optical Air-Gap Sync (AirQR)**, allowing users to synchronize app settings, preferences, user templates, selected journals, and individual entries over light without any network connection (no Wi-Fi, no Bluetooth, no hotspot, no servers).

---

## 2. Key Changes Made

### Core AirQR Engine (`lib/features/airqr/`)
- `lib/features/airqr/services/airqr_constants.dart`: Configured scheme `sreerajp-journal-vault-airqr://`, chunk size limits (400–2200 bytes), FPS controls (2–12 FPS), soft cap (256 KB), warn cap (1 MB), and hard cap (4 MB).
- `lib/features/airqr/domain/airqr_payload.dart`: Typed payloads for Settings, Single Journal, Single Entry, and Vault Snapshot.
- `lib/features/airqr/services/airqr_codec.dart`: Gzip compression + PBKDF2-HMAC-SHA256 session key derivation with 16-byte random salt + AES-256-GCM encryption + SHA-256 integrity validation + base64url URI framing and robust parser.
- `lib/features/airqr/services/airqr_sender.dart`: Looping frame animator with live FPS / chunk size controls.
- `lib/features/airqr/services/airqr_receiver.dart`: Out-of-order frame collector, live progress indicator, missing frame tracker, pairing code authentication, and unsealing pipeline.
- `lib/features/airqr/providers/airqr_providers.dart`: `AirqrSettingsService` for exporting and applying app theme, custom accent color, screenshot security preferences, ritual practice config, user templates, and tags.
- `lib/features/airqr/presentation/airqr_size_warning.dart`: Pre-flight size gating modal dialog warning on medium-large payloads and directing to Wi-Fi Sync for large datasets.

### UI & Presentation (`lib/features/airqr/presentation/`)
- `lib/features/airqr/presentation/airqr_landing_screen.dart`: Hub offering **"Sync App Settings"**, **"Sync Single Journal"**, and **"Receive via Camera"** scanner.
- `lib/features/airqr/presentation/airqr_send_screen.dart`: Animated QR stream with `FLAG_SECURE`, pairing code copy, frame counter, and FPS controls.
- `lib/features/airqr/presentation/airqr_receive_screen.dart`: Camera viewfinder, torch/camera switch, live frame progress bar, missing frame chips, pairing code prompt, and verified payload import preview.

### App Wiring & Localization
- `lib/features/sync/presentation/sync_landing_screen.dart`: Added Optical Air-Gap Sync card.
- `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`: Full English and Malayalam localization strings.
- `pubspec.yaml`: Added `crypto` dependency.

---

## 3. Verification & Tests
- Created test suite under `test/features/airqr/`:
  - `test/features/airqr/airqr_codec_test.dart`
  - `test/features/airqr/airqr_payload_test.dart`
  - `test/features/airqr/airqr_receiver_test.dart`
  - `test/features/airqr/airqr_sender_test.dart`
- `flutter analyze` completed with **0 issues**.
- Full test suite verified.
