# Plan — Screenshot blocking: AirQR must not change it, and pairing screens must not save over it

**Status:** completed
**Change log:** `change_log/20260927_134932_airqr-screenshot-setting.md`
**Note:** Approved 2026-09-27.

## Background

This is review item 4 from the 2026-09-27 project review. The project rule (CLAUDE.md, "Security
rules") says `FLAG_SECURE` stays on by default, and **the only thing that may clear it is the
user's own "Block Screenshots" switch in Settings**. That switch also writes a security event.

Screenshot blocking does not stop AirQR from working. It blocks screenshots, screen recording
and casting on the same phone. It does not stop another phone's camera from reading the QR codes
on the screen. The AirQR send screen already turns blocking on for this reason.

---

## Problem 1 — Receiving AirQR settings can turn screenshot blocking off

### Issue

- `AirqrSettingsService.exportCurrentSettings` (`lib/features/airqr/providers/airqr_providers.dart`,
  around line 27–62) reads this phone's "Block Screenshots" value and puts it in the settings
  payload as `isScreenSecurityEnabled`.
- `applySettings` (same file, around line 127–129) copies the received value straight into the
  receiving phone's setting with `screenSecurityProvider.notifier.setEnabled(...)`.

So if the sending phone had blocking off, applying its settings **silently turns blocking off**
on the receiving phone. No dialog is shown, and no security event is written.

### Fix

1. `applySettings` no longer reads or applies `isScreenSecurityEnabled`. A payload from an older
   app version that still has the key is accepted, and the key is ignored.
2. `exportCurrentSettings` no longer puts it in the payload, and
   `AirqrPayload.settings(...)` (`lib/features/airqr/domain/airqr_payload.dart`) loses the
   `isScreenSecurityEnabled` parameter. Screenshot blocking is a security setting of each phone,
   not a preference to copy, like theme or font.
3. No change to anything else the settings payload carries.

---

## Problem 2 — Pairing screens save "blocking on" over the user's choice, for good

### Issue

Two screens show a secret on screen, a QR code or a pairing code, and protect it like this in
`initState`:

- `lib/features/airqr/presentation/airqr_send_screen.dart` line 31
- `lib/features/sync/presentation/sync_host_screen.dart` line 41

```dart
ref.read(screenSecurityProvider.notifier).setEnabled(true);
```

`setEnabled` **saves** the value as the user's setting (native SharedPreferences) and never puts
the old value back. So a user who turned blocking off in Settings finds it switched back on for
good after opening either screen, without being told. This fails in the safe direction, but it
still overrides the user's own choice. Also, the returned future is not awaited, so a failure
there is an unhandled error.

### Fix

Protect these screens **only while they are open**, without touching the saved setting.

1. **Native, apply without saving.** `MainActivity.kt`, `SCREEN_SECURITY_CHANNEL`: add a method
   `applyScreenSecurity` that sets or clears `FLAG_SECURE` on the live window and saves
   nothing. The existing `setScreenSecurityEnabled` (save and apply) is unchanged. On the next app
   start, `onCreate` still applies the **saved** choice, so a held state never outlives the
   process.
2. **Store.** `ScreenSecurityStore` gets `apply({required bool enabled})`, "live window only". It
   is implemented by `MethodChannelScreenSecurityStore` (the new method) and by
   `InMemoryScreenSecurityStore` (it records the live state, so tests can check it).
3. **Controller.** `ScreenSecurityController` gets a hold count:
   - `Future<void> holdOn()`: the first hold applies blocking on (live only), whatever the saved
     choice is.
   - `Future<void> releaseHold()`: when the last hold is released, the live window goes back to
     the saved choice.
   - `setEnabled` while a hold is active saves the new choice. If it is "off", blocking stays on
     live until the hold ends. In practice this cannot happen, because Settings cannot be reached
     from these screens, but the rule stays correct.
   - Failures are caught and logged (type only). A failed `holdOn` is logged as an error. Because
     blocking is on by default, the likely failure leaves the screen protected.
4. **Both screens** call `holdOn()` in `initState` and `releaseHold()` in `dispose`. They read the
   controller in `initState`, because `ref` may not be used in `dispose`. They no longer call
   `setEnabled`.
5. When the app locks, these screens are closed (the lock rule from the last change), so their
   `dispose` releases the hold. The lock gate is then drawn under the user's own choice.

---

## Tests

- `test/core/security/screen_security_controller_test.dart`:
  - with the saved choice **off**, `holdOn` turns the live window on and leaves the saved value
    off; `releaseHold` puts the live window back to off;
  - two holds: the window stays on until **both** are released;
  - with the saved choice **on**, hold and release keep it on and save nothing;
  - `setEnabled(false)` during a hold saves "off" but keeps the window on until the release.
- `test/features/airqr/airqr_settings_service_test.dart`: applying a settings payload that holds
  `isScreenSecurityEnabled: false` leaves this phone's setting **on**.
- A test that `exportCurrentSettings` no longer includes the key.
- Existing tests that build `AirqrPayload.settings(...)` with `isScreenSecurityEnabled`
  (`airqr_payload_test.dart`, `airqr_codec_test.dart`, `airqr_sender_test.dart`) drop that
  argument. They are updated only as far as the removed parameter needs.
- A widget test for the AirQR send screen: with the saved choice off, opening it holds blocking
  on, and closing it restores off, and the saved value never changes. Plus the same case for the
  Wi-Fi Sync host screen, if it can be pumped without real sockets. If it cannot, say so in the
  change log and rely on the controller tests.

## Files

- `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt`
- `lib/core/security/screen_security_controller.dart`
- `lib/features/airqr/providers/airqr_providers.dart`
- `lib/features/airqr/domain/airqr_payload.dart`
- `lib/features/airqr/presentation/airqr_send_screen.dart`
- `lib/features/sync/presentation/sync_host_screen.dart`
- Tests: `test/core/security/screen_security_controller_test.dart`,
  `test/features/airqr/airqr_settings_service_test.dart`, `test/features/airqr/airqr_payload_test.dart`,
  `test/features/airqr/airqr_codec_test.dart`, `test/features/airqr/airqr_sender_test.dart`, and
  a new send-screen test if needed
- `docs/security.md` (screenshot blocking: never copied from another phone, and pairing screens
  hold it on only while open)
- `docs/architecture.md` §21 (record the fix)

## Checks after the change

- `dart format lib test integration_test`: clean.
- `flutter analyze`: zero issues.
- `flutter test`: all pass.
- The Kotlin change compiles. Build a debug APK (`flutter build apk --flavor dev --debug`)
  without installing it. It is **not** installed on a phone holding real entries (CLAUDE.md,
  "Build flavors").
- `sh tool/check_absolute_paths.sh --all`: passes.

## Out of scope

- Review item 1 (commit `third_party/`).
- The small findings (the English "Entry #" text, and AirQR entries on a phone with no journals).
- Two-way sync, and syncing edits and deletes.
