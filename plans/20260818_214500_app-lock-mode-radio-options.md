# App Lock Mode options do not look selectable

**Status:** completed

## Issue

On the Settings > Security screen, the "App Lock Mode" choice is drawn as three plain
`ListTile`s:

- a bare `ListTile` holding the text "App Lock Mode" (it looks like a normal row, not a
  group heading),
- one `ListTile` per mode ("Phone Lock", "Separate App Lock").

Problems:

1. No radio button or any other control is shown, so the two modes do not look like
   options a user can pick.
2. The active mode uses `selected: true`, which only tints its text. On the light theme
   that tint reads as "disabled" rather than "chosen".
3. The active mode has `onTap: null`, so it is genuinely not tappable — that reinforces
   the "greyed out" look.
4. The helper hints (`lockModePhoneHint`, `lockModeAppHint`) are not shown here, even
   though the first-launch setup screen shows them.

The first-launch lock setup screen already renders the same choice correctly with a
`RadioGroup` + two `RadioListTile`s. Settings should match it.

## Files to change

- `lib/app/app.dart` — `_SecuritySettingsScreen.build`: replace the three `ListTile`s
  with a section heading plus a `RadioGroup<AppLockMode>` holding two `RadioListTile`s.
- `test/widget_test.dart` — check the existing "switch lock mode" test still passes;
  adjust the tap target if needed.
- `test/app/settings_screen_security_test.dart` — add a test that both modes render as
  radio options and that the current mode is the selected one.

No new strings are needed. `settingsAppLockMode`, `lockModePhone`, `lockModePhoneHint`,
`lockModeApp` and `lockModeAppHint` all already exist in `lib/l10n/app_en.arb`.

## The fix

1. Draw "App Lock Mode" as a real group heading: a `Padding` + `Text` styled with
   `theme.textTheme.titleSmall` and `colorScheme.primary`, matching how other grouped
   settings headings are styled, instead of a `ListTile`.
2. Wrap the two modes in `RadioGroup<AppLockMode>`:
   - `groupValue` = `AppLockMode.appLock` when the current mode is app lock, else
     `AppLockMode.phoneLock`.
   - `onChanged` calls the existing `_switchLock(context, ref, mode)` only when the
     picked value differs from the current mode, so tapping the already-active option
     does nothing and does not pop the confirm dialog.
3. Each `RadioListTile<AppLockMode>` gets:
   - `value`, `title` (existing label), `subtitle` (the existing hint string),
   - a stable `Key` (`settings-lock-mode-phone`, `settings-lock-mode-app`) for tests.
4. Drop the `selected:`/`onTap: null` pattern — the radio button now carries the state,
   so nothing looks disabled.

Behaviour of the switch itself (confirm dialog, PIN setup when moving to app lock,
snackbar) is unchanged.

## Checks after the change

- `flutter analyze` clean.
- `flutter test` green (in particular `test/widget_test.dart` lock-mode switch test and
  `test/app/settings_screen_security_test.dart`).
- `dart format lib test integration_test`.
