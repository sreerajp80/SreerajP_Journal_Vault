# Change log — Screenshot blocking: AirQR no longer changes it, and pairing screens no longer save over it

**Plan:** `plans/20260927_133428_airqr-screenshot-setting.md` (approved 2026-09-27)

## Problem 1 — Received AirQR settings could turn blocking off

- `lib/features/airqr/providers/airqr_providers.dart`:
  - `applySettings` no longer reads or applies `isScreenSecurityEnabled`. A payload from an older
    app version that still has the key is accepted, and the key is ignored.
  - `exportCurrentSettings` no longer reads the setting or sends it.
- `lib/features/airqr/domain/airqr_payload.dart`: `AirqrPayload.settings(...)` lost the
  `isScreenSecurityEnabled` parameter and no longer writes the key.

## Problem 2 — Pairing screens saved "blocking on" over the user's choice

- `android/.../MainActivity.kt`: new channel method `applyScreenSecurity` on
  `sreerajp.journal_vault/screen_security`. It sets or clears `FLAG_SECURE` on the live window
  and saves nothing. `onCreate` still applies the saved choice on every app start.
- `lib/core/security/screen_security_controller.dart`:
  - `ScreenSecurityStore.apply({enabled})` changes the live window only. The method-channel store
    calls the new native method. `InMemoryScreenSecurityStore` now tracks `liveEnabled` apart
    from the saved `enabled`.
  - `ScreenSecurityController.holdOn()` / `releaseHold()` use a hold count. The first hold turns
    the live window on; when the last hold is released, the window goes back to the saved
    choice. Neither saves anything, and neither throws (a failure is logged, type only).
  - `setEnabled(false)` during a hold saves "off", and the window stays on until the hold ends.
- `lib/features/airqr/presentation/airqr_send_screen.dart` and
  `lib/features/sync/presentation/sync_host_screen.dart`: `holdOn()` in `initState`,
  `releaseHold()` in `dispose`, instead of `setEnabled(true)`. The controller is read in
  `initState`, because `ref` may not be used in `dispose`.
- Also in `sync_host_screen.dart`, a small adjacent fix: `dispose` used `ref.read(...)` to stop
  the host, which Riverpod 3 does not allow in `dispose`. The host notifier is now read in
  `initState` too.

## Tests

- `test/core/security/screen_security_controller_test.dart`, 6 new tests: a hold with the saved
  choice off, then release; two holds; saved choice on (nothing saved); `setEnabled(false)`
  during a hold; release without a hold; a failing live update never throws. The two fake stores
  gained `apply`.
- `test/features/airqr/airqr_settings_service_test.dart`: a received
  `isScreenSecurityEnabled: false` is ignored; exported settings carry no such key.
- New `test/features/airqr/airqr_send_screen_security_test.dart`: with the saved choice off,
  opening the send screen turns the window on without saving, and closing it restores off. With
  the old `setEnabled(true)` put back, this test fails.
- `airqr_payload_test.dart`, `airqr_codec_test.dart`, `airqr_sender_test.dart`: only the removed
  argument was dropped. None of them checked it.
- **No widget test for the Wi-Fi Sync host screen.** It starts a real network socket as soon as it
  is shown. The controller tests cover the hold logic it uses.

## Docs

- `docs/security.md`: two new rules (only the Settings switch changes the saved choice; screens
  showing a secret hold protection on only while open), and a new release-checklist item.
- `docs/architecture.md` §21: "Closed on 2026-09-27 — screenshot setting and AirQR".

## Checks

- `dart format lib test integration_test`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 1,180 tests pass (1,171 before).
- `flutter build apk --flavor dev --debug`: built, so the Kotlin change compiles. It was **not**
  installed on any phone. The build also refreshed the generated `lib/core/constants/build_date.g.dart`
  to 2026-09-27, as every build does.
- `sh tool/check_absolute_paths.sh --all`: passes.

## Manual check for the user, on a phone

1. In Settings, turn "Block Screenshots" off.
2. Open AirQR Send. Try a screenshot: it is blocked.
3. Go back. Try a screenshot: it works. Settings still shows the switch off.
4. Send settings by AirQR from a phone with blocking off to a phone with blocking on. The
   receiving phone keeps blocking on.
