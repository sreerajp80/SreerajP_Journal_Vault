# Plan: A6.2 Receive Shared Text and Images from Other Apps

**Status:** completed
**Date:** 2026-08-23
**Feature:** A6.2 Inbound Share Intents & Quick Capture

---

## 1. Overview & Problem Statement

Currently, the only way to get content into SreerajP Journal Vault is to open the app manually and create or import an entry. Most journal moments (reading an article, seeing a photo, receiving a quote or link in a chat) originate in other apps.

This change adds Android intent filters and a lightweight Inbound Share & Quick Capture pipeline so that:
1. When a user shares text, URLs, or images from any Android app, "SreerajP Journal Vault" appears in the Android Share Sheet.
2. When the user taps the app in the share sheet, the app safely receives the shared payload.
3. If the app is locked with a PIN or biometric lock, the lock gate is required first before any journal content or capture UI is displayed.
4. After unlock (or immediately if unlocked), a Quick Capture dialog/screen lets the user:
   - Select the destination journal.
   - Edit the title and shared text.
   - Review and attach shared images.
   - Either quick-save directly into the journal or open the full Entry Editor.
5. In addition, `.jvenc` and `.jvbk` files can be opened via the Android VIEW intent filter directly into the encrypted export viewer.

---

## 2. Architecture & Design

Following Tier 2 feature-first architecture:

### A. Android Native Layer (`android/`)
- Update `android/app/src/main/AndroidManifest.xml`:
  - Add `<intent-filter>` for `android.intent.action.SEND` with `text/plain`, `image/*`, and `*/*`.
  - Add `<intent-filter>` for `android.intent.action.SEND_MULTIPLE` with `image/*` and `*/*`.
  - Add `<intent-filter>` for `android.intent.action.VIEW` for `.jvenc` and `.jvbk` scheme `content` and `file`.
- Update `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`:
  - Add `MethodChannel` `sreerajp.journal_vault/share_intent`.
  - In `onCreate` and `onNewIntent`, safely parse incoming intent data:
    - Extract text / subject strings.
    - Extract `content://` or `file://` stream Uris, reading metadata (file name, MIME type) and byte contents safely without network access.
  - Expose `getInitialShare`, `clearPendingShare`, and push `onShareReceived` events to Flutter.

### B. Flutter Feature Layer (`lib/features/share_receiver/`)
- `domain/shared_intent_payload.dart`:
  - `SharedPayloadType` enum (`text`, `media`, `sealedFile`).
  - `SharedMediaItem` model (file name, mime type, bytes).
  - `SharedIntentPayload` model.
- `services/share_intent_service.dart`:
  - Abstract interface `ShareIntentService` and `MethodChannelShareIntentService`.
- `providers/share_receiver_providers.dart`:
  - `shareIntentServiceProvider` and `pendingSharePayloadProvider`.
- `presentation/quick_capture_share_dialog.dart`:
  - Dialog / Sheet for journal selection, title editing, text editing, attachment preview, and saving.

### C. App Shell Wiring (`lib/app/app.dart`)
- Listen to `pendingSharePayloadProvider` when unlocked.
- If a pending share is present, show `QuickCaptureShareDialog` (or open viewer for `.jvenc` files).
- Ensure locked state never exposes capture dialog until authenticated.

### D. Localization (`lib/l10n/app_en.arb`)
- Add user-facing strings for share receiver and quick capture with descriptions.

---

## 3. Files to Change

### Native Android
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`

### New Feature Files
- `lib/features/share_receiver/domain/shared_intent_payload.dart`
- `lib/features/share_receiver/services/share_intent_service.dart`
- `lib/features/share_receiver/services/method_channel_share_intent_service.dart`
- `lib/features/share_receiver/providers/share_receiver_providers.dart`
- `lib/features/share_receiver/presentation/quick_capture_share_dialog.dart`

### Existing Files Modified
- `lib/app/app.dart`
- `lib/l10n/app_en.arb`
- `lib/features/entries/presentation/entry_editor_screen.dart` (support initial plain text and initial attachments if opened from Quick Capture)

### Tests
- `test/features/share_receiver/shared_intent_payload_test.dart`
- `test/features/share_receiver/share_intent_service_test.dart`
- `test/features/share_receiver/quick_capture_share_dialog_test.dart`

---

## 4. Verification Plan

1. Run `flutter gen-l10n` to verify localization code generation.
2. Run `flutter analyze` to ensure zero static analysis issues.
3. Run `flutter test` to verify all unit and widget tests pass.
4. Run `dart format lib test` to ensure clean code formatting.
