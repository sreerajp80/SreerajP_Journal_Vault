# Settings switch for screenshot blocking

Implements [`plans/20260818_195414_screenshot-blocking-toggle.md`](../plans/20260818_195414_screenshot-blocking-toggle.md).

## What changed

Screenshot blocking (`FLAG_SECURE`) was hard-wired on. The user can now turn it off from
Settings → Security. It stays **on** by default, and turning it off asks for confirmation
first.

### Native (`android/app/src/main/kotlin/.../MainActivity.kt`)

- `onCreate` no longer sets `FLAG_SECURE` unconditionally. It reads the saved choice and
  calls the new `applyScreenSecurity(enabled)`, which sets or clears the flag.
- The choice lives in the app's own `SharedPreferences` file `screen_security`, key
  `enabled`. A missing value, or any read failure, means **protected** — a broken read can
  never leave the window open.
- New MethodChannel `sreerajp.journal_vault/screen_security`:
  - `isScreenSecurityEnabled` → `Boolean`
  - `setScreenSecurityEnabled(enabled)` → saves the value and applies the flag to the live
    window on the UI thread, so the switch works without a restart.

### Dart

- New `lib/core/security/screen_security_controller.dart`:
  `ScreenSecurityStore` (interface), `MethodChannelScreenSecurityStore` (the real one),
  `InMemoryScreenSecurityStore` (tests and non-Android hosts),
  `screenSecurityStoreProvider`, and `ScreenSecurityController` — an `AsyncNotifier<bool>`
  whose `setEnabled` writes through and rolls the value back if the write fails. It never
  touches `BuildContext`.
- `lib/app/app.dart`: new `_ScreenSecurityTile`, a `SwitchListTile`
  (`Key('settings-screen-security')`) in the Security section, under the attachment lock
  row. Turning it off opens a warning dialog; turning it on does not. A snackbar confirms,
  a failure snaps the switch back with an error message, and the tile carries a `Semantics`
  label.
- `lib/features/security/services/security_event_service.dart`: new
  `logScreenSecurityChanged({required bool enabled})` — event type
  `screen_security_changed`, severity `warning` when turned off, `info` when turned on. A
  logging failure is swallowed so it cannot block the setting itself.
- `lib/main.dart`: overrides `screenSecurityStoreProvider` with the method-channel store.
- `lib/l10n/app_en.arb`: eight new strings, each with a description; localizations
  regenerated with `flutter gen-l10n`.

No database schema change, so no migration.

### Tests

- New `test/core/security/screen_security_controller_test.dart` — default protected, reads
  a stored off value, writes through both ways, no write when the value is unchanged, and
  a failed write rolls back and throws.
- New `test/app/settings_screen_security_test.dart` — the switch renders on by default,
  cancelling the warning dialog keeps it on, confirming turns it off, and turning it back
  on needs no dialog.
- `test/features/settings/settings_tab_test.dart` — test surface raised from 1600 to 1800
  px tall. The Security section grew a row, which pushed the About header out of the laid
  out area and failed the section-order test. Behaviour unchanged.

### Docs

`CLAUDE.md`, `AGENTS.md`, `docs/security.md`, `docs/architecture.md`,
`docs/release_process.md` and `docs/features.md` no longer say the flag is always on. The
hard rule now reads: `FLAG_SECURE` is applied by default and only the user's own Settings
switch may clear it. The threat model, the OWASP M8 row, and both release checks were
reworded to cover the on and off cases.

## Security note

This deliberately weakens a control. With the switch off, screenshots, screen recorders and
the recent-apps thumbnail can capture journal content. The design keeps it an informed
choice: protected by default, a plain warning before it is turned off, and an audit entry
for every change.

## Verification

- `flutter analyze` — no issues.
- `dart format lib test integration_test` — clean.
- `flutter test` — 596 tests, all passing.
- `flutter build apk --flavor dev --debug` — builds, so the Kotlin change compiles.
- Still to do on a real device: confirm a screenshot fails with the switch on, succeeds
  with it off, and that the choice survives a restart.
