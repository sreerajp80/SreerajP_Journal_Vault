# Settings toggle for screenshot blocking (FLAG_SECURE)

**Status:** completed

## The issue

The app blocks screenshots, screen recording and the task-switcher preview everywhere.
This is done once, natively, in `MainActivity.onCreate`:

```kotlin
window.setFlags(FLAG_SECURE, FLAG_SECURE)
```

There is no way for the user to turn it off. Settings has a Security section
(`lib/app/app.dart`, `_SettingsTab`) with lock mode, auto-lock, attachment locks and the
security event log, but no screen-protection row. The user has asked for one.

## Important warning before you approve

`FLAG_SECURE` is a **documented hard rule** of this project, not an accident:

- `CLAUDE.md` and `AGENTS.md` — "`FLAG_SECURE` must stay set in `MainActivity.onCreate`".
- `docs/security.md` — it is the stated mitigation for the "shoulder surfing and screen
  capture" threat, and part of the OWASP M8 "verified" line.
- `docs/release_process.md` and the security checklist both have a manual release check
  "try to take a screenshot and confirm it fails".
- The Sensitive Data Extension profile is in force for this app.

Adding an off switch weakens that control by choice. If the user turns it off:

- screenshots and screen recorders can capture journal text and attachments;
- the recent-apps thumbnail shows the last screen, readable by anyone holding the phone;
- other apps with a screen-capture service (including accessibility-style recorders) can
  read the screen.

The plan therefore treats the switch as an explicit, informed user choice: default **on**,
a plain warning in the confirm dialog, and an entry in the security event log every time it
changes. The docs and the release checks are updated so they stop claiming the flag is
always on. If the user would rather keep the rule as is, this plan should be marked
`dropped` instead.

## The plan

### 1. Store the choice natively (so it applies before the first frame)

The flag has to be right at `onCreate`, before any Flutter code runs. So the value is kept
in the app's own native `SharedPreferences` file, written through a method channel — the
same shape the app already uses for Keystore-backed values.

- New channel `sreerajp.journal_vault/screen_security` in `MainActivity.kt`:
  - `isScreenSecurityEnabled` → `Boolean` (default `true`)
  - `setScreenSecurityEnabled(enabled: Boolean)` → saves the value **and** applies or
    clears `FLAG_SECURE` on the live window straight away, on the UI thread.
- `onCreate` reads the saved value and sets `FLAG_SECURE` only when it is `true`.
  Missing value means `true`, so a fresh install and any read failure stay protected.

### 2. Dart service + provider (core layer)

New `lib/core/security/screen_security_controller.dart`:

- `abstract class ScreenSecurityStore { Future<bool> read(); Future<void> write(bool); }`
- `MethodChannelScreenSecurityStore` — the real one, talking to the channel above.
- `screenSecurityStoreProvider` — a `Provider` overridden in `main.dart`, with an
  in-memory default so widget tests and non-Android hosts keep working.
- `ScreenSecurityController` (`AsyncNotifier<bool>`): reads on build, `setEnabled(bool)`
  writes and rolls back on failure. It never touches `BuildContext`.

### 3. Settings row

In `_SettingsTab` (`lib/app/app.dart`), in the Security section under the attachment lock
row, add a `SwitchListTile` with `key: Key('settings-screen-security')`:

- title "Block screenshots", subtitle explaining what it covers;
- turning it **off** opens a confirm dialog spelling out the risk; turning it back **on**
  needs no dialog;
- a `SnackBar` confirms, and a `Semantics` label is set as the code style rules require;
- on failure the switch snaps back and shows the failure message.

Every string goes in `lib/l10n/app_en.arb` with an `@` description, then `flutter gen-l10n`:
`settingsScreenSecurity`, `settingsScreenSecuritySubtitle`, `settingsScreenSecurityOffTitle`,
`settingsScreenSecurityOffBody`, `settingsScreenSecurityOffAction`,
`settingsScreenSecurityUpdatedOn`, `settingsScreenSecurityUpdatedOff`,
`settingsScreenSecuritySaveFailed`.

### 4. Security event log

Add `logScreenSecurityChanged({required bool enabled})` to `SecurityEventService`
(`eventType: 'screen_security_changed'`, severity `warning` when turned off, `info` when
turned on). The controller calls it after a successful write. No journal content is logged.

### 5. Wiring

`main.dart` overrides `screenSecurityStoreProvider` with the method-channel store. It stays
thin — one more override in the existing list.

### 6. Tests

- `test/core/security/screen_security_controller_test.dart` — default on, toggle off/on,
  write failure rolls back, event logged.
- A widget test for the Settings row: switch shows, dialog appears on turn-off, cancel
  leaves it on.
- Existing tests that pump `_SettingsTab` get the in-memory store default, so they keep
  passing.

### 7. Docs

Update the places that state the flag is always on:

- `CLAUDE.md` / `AGENTS.md` — reword the hard rule: `FLAG_SECURE` is applied in
  `MainActivity.onCreate` **by default** and may only be cleared by the user's explicit
  Settings choice; nothing else may clear it.
- `docs/security.md` — threat model line, the M8 row, and the security checklist item.
- `docs/architecture.md` — the screenshot-protection line in the gap table.
- `docs/release_process.md` — the manual check becomes "with the setting on, a screenshot
  fails; with it off, it succeeds".
- `docs/features.md` — describe the toggle.

## Files to change

| File | Change |
|---|---|
| `android/app/src/main/kotlin/.../MainActivity.kt` | Read the saved value in `onCreate`; new screen-security method channel |
| `lib/core/security/screen_security_controller.dart` | New — store, provider, controller |
| `lib/app/app.dart` | New `SwitchListTile` in the Security section + confirm dialog helper |
| `lib/l10n/app_en.arb` | Eight new strings with descriptions |
| `lib/l10n/app_localizations*.dart` | Regenerated by `flutter gen-l10n` |
| `lib/features/security/services/security_event_service.dart` | `logScreenSecurityChanged` |
| `lib/main.dart` | Override `screenSecurityStoreProvider` |
| `test/core/security/screen_security_controller_test.dart` | New unit tests |
| `test/app/settings_screen_security_test.dart` | New widget test |
| `CLAUDE.md`, `AGENTS.md`, `docs/security.md`, `docs/architecture.md`, `docs/release_process.md`, `docs/features.md` | Reword the always-on claims |

## Not in scope

- No database schema change, so no migration.
- No per-screen granularity (for example "block only in the editor"). One app-wide switch.
- Backup and export behaviour is untouched.

## Checks after implementing

- `flutter analyze` clean, `dart format lib test integration_test`, `flutter test` green.
- Manual on device: toggle off → a screenshot works and the recents thumbnail is visible;
  toggle on → both blocked; kill and relaunch the app → the choice survives.
- Write the change log to `change_log/`.
