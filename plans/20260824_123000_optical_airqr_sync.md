# Plan: Encrypted Device-to-Device Optical Air-Gap Sync (AirQR)

**Status:** Planned — Awaiting Approval
**Date:** 2026-08-24
**Issue:** Add optical air-gap device-to-device synchronization (animated QR frame stream + camera scanner) for settings, small journals, and individual entries with size gating warnings and 100% offline security.

---

## 1. Objective

Implement **Optical Air-Gap Sync (AirQR)**, enabling two devices to synchronize settings, selected journals, and lightweight entries over light using an animated QR frame stream on one screen and a camera scanner on the other. This requires zero network connections (no Wi-Fi, no Bluetooth, no hotspot, no servers), ensuring 100% offline air-gapped security with size gating warnings.

---

## 2. Architecture & Design

### Optical Link & Size Gating
Optical transmission moves ~10–20 KB/second. To ensure honest expectations:
- **< 256 KB:** Starts immediately without warning (ideal for settings, preferences, and small journals).
- **256 KB – 1 MB:** Shows an estimated transfer time and warns user.
- **1 MB – 4 MB:** Shows an explicit warning with estimated duration and offers Local Wi-Fi Sync instead.
- **> 4 MB:** Blocks optical transmission and directs user to Local Wi-Fi Sync.

### Settings Sync via AirQR
AirQR provides a first-class **"Sync Settings"** capability:
- Packages app appearance (theme mode, custom accent color), screenshot security preferences, auto-lock profile presets, ritual preferences (startup launch, breath technique & cycles), and custom entry templates into a lightweight `AirqrPayload.settings(...)` (~1–5 KB).
- Takes less than 1 second to stream over 1–2 QR frames.
- Allows instant synchronization of all user preferences from one phone/tablet to another without typing them all over again or needing network connections.

### Protocol & Cryptography
- URI Scheme: `sreerajp-journal-vault-airqr://m?...` (manifest) and `sreerajp-journal-vault-airqr://f?...` (frames).
- Envelope: JSON payload containing journal records, tags, metadata, or settings.
- Compression: gzip `gzip.encode(...)`.
- Crypto: PBKDF2-HMAC-SHA256 session key (derived from a 16-character out-of-band pairing code shown on sender) + AES-256-GCM authenticated cipher with SHA-256 integrity verification.
- Frame Assembly: Receiver supports out-of-order frame capture, missing frame detection, real-time completion progress bar (e.g. `[=====     ] 45% (9/20 frames)`), and automatic re-assembly once all frames are received.

---

## 3. Files to Create / Modify

### Core AirQR Engine (`lib/features/airqr/`)
- `lib/features/airqr/services/airqr_constants.dart`: Frame sizes, FPS, caps, and protocol constants.
- `lib/features/airqr/domain/airqr_payload.dart`: Typed payloads for Settings, Single Journal, Single Entry, and Snapshot.
- `lib/features/airqr/services/airqr_codec.dart`: Gzip, PBKDF2/AES-GCM encryption, chunking, and framing.
- `lib/features/airqr/services/airqr_sender.dart` & `lib/features/airqr/services/airqr_receiver.dart`: Sender loop and receiver assembly.
- `lib/features/airqr/presentation/airqr_size_warning.dart`: Size gating warning dialog.

### Presentation (`lib/features/airqr/presentation/`)
- `lib/features/airqr/presentation/airqr_landing_screen.dart`: Optical Sync hub.
- `lib/features/airqr/presentation/airqr_send_screen.dart`: Animated QR stream with `FLAG_SECURE`.
- `lib/features/airqr/presentation/airqr_receive_screen.dart`: Camera scanner with frame progress and DB merge.

### App Wiring & Localization
- `lib/features/sync/presentation/sync_landing_screen.dart`: Add Optical Air-Gap Sync option.
- `lib/l10n/app_en.arb` & `lib/l10n/app_ml.arb`: Full localized strings.

### Tests (`test/features/airqr/`)
- `test/features/airqr/airqr_codec_test.dart`
- `test/features/airqr/airqr_payload_test.dart`
- `test/features/airqr/airqr_receiver_test.dart`
- `test/features/airqr/airqr_sender_test.dart`

---

## 4. Acceptance Criteria

1. Optical AirQR sync can encode and stream settings, entries, and small journals over animated QR codes.
2. Scanned frames can arrive out of order and reassemble accurately with live progress feedback.
3. Cryptographic integrity and privacy are maintained with PBKDF2 + AES-256-GCM and SHA-256 verification.
4. Payloads exceeding 1 MB trigger optical duration warnings offering Wi-Fi Sync; payloads exceeding 4 MB are blocked.
5. All new tests pass and `flutter analyze` has zero issues.
