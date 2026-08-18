# App Lock Mode now shows as real radio options

Implements `plans/20260818_214500_app-lock-mode-radio-options.md`.

## What was wrong

On Settings > Security, "App Lock Mode" and its two choices were plain `ListTile`s. The
choices had no radio button, the active one was only tinted (which looked disabled) and
had `onTap: null`, and the helper hints were missing. Users could not tell these were
options.

## What changed

`lib/app/app.dart` — `_SecuritySettingsScreen`:

- "App Lock Mode" is now a group heading (small title text in the primary colour), not a
  `ListTile`.
- The two modes are a `RadioGroup<AppLockMode>` with two `RadioListTile`s, matching the
  first-launch lock setup screen. Keys: `settings-lock-mode-phone`,
  `settings-lock-mode-app`.
- Each option now shows its hint as a subtitle (`lockModePhoneHint`, `lockModeAppHint`).
- Picking the mode that is already active does nothing — no confirm dialog.
- A `Divider` separates the mode group from the rest of the security list.

`test/app/settings_screen_security_test.dart`:

- New test: both modes render as radio options with their hints, the group value matches
  the stored lock mode, and tapping the active mode raises no dialog.
- Added the `app_lock_controller.dart` import for `AppLockMode`.

## Not changed

The switch flow itself — confirm dialog, PIN setup when moving to app lock, and the
success snackbar — is untouched. No new localization strings were needed.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 604 tests, all passed.
- `dart format` applied to the touched files.
