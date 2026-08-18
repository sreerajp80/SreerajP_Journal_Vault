# Modern app lock screen

Implements [`plans/20260818_201240_modern-lock-screen.md`](../plans/20260818_201240_modern-lock-screen.md).

## What changed

The lock gate — the first screen a user sees when the app is locked — was rebuilt.
Only the look changed. No unlock logic, lock mode rule, or security behaviour was
touched.

### `lib/app/app.dart`

- `_LockGateScreen` no longer has an `AppBar`. The page is now full bleed.
- Added a soft vertical gradient built from the active `ColorScheme`, so it follows
  the app seed colour in both light and dark mode.
- Added a large circular lock badge (`Icons.lock_rounded` on `primaryContainer`,
  inside a wider soft ring) as the focal point.
- Added a headline ("Your journal is locked"), a short subtitle, and a pill chip
  naming the active lock mode with a matching icon.
- The unlock controls now sit in a rounded, softly shadowed card, capped at 420 px
  wide so it still looks right on tablets and in landscape.
  - Phone lock: a full-width 54 px `FilledButton.icon` with a fingerprint icon.
  - App lock: a filled, rounded, centred PIN field with a number keyboard and a
    show/hide eye button, plus a full-width Unlock button below it.
  - While an unlock is running, the button shows a small progress ring instead of its
    icon and stays disabled (the existing `_busy` rule).
- Errors moved from hard-coded `Colors.red` text to a themed error pill
  (`errorContainer` / `onErrorContainer`) with a warning icon, faded in by an
  `AnimatedSwitcher`.
- Added a one-shot fade and rise when the screen appears. It is a
  `TweenAnimationBuilder`, not a repeating animation, so widget tests still settle.
- New private widgets: `_LockGateEntrance`, `_LockBadge`, `_LockModeChip`,
  `_LockCard`, `_LockActionButton`, `_LockErrorPill`.
- Added a `_pinVisible` field to the screen state for the show/hide toggle.
- `Semantics` labels on the badge and both unlock buttons.

### `lib/l10n/app_en.arb`

Added five keys, each with an `@` description: `lockGateHeadline`,
`lockGateSubtitle`, `lockGateShowPin`, `lockGateHidePin`, `lockGateBadgeSemantics`.
`lockGateTitle` was left in place, unused, since the app bar is gone.
`lib/l10n/app_localizations.dart` and `lib/l10n/app_localizations_en.dart` were
regenerated with `flutter gen-l10n`.

### Tests

- `test/app/lock_gate_screen_test.dart` — new. Checks the phone-lock layout, the
  app-lock PIN field and its show/hide toggle, and that a wrong PIN shows the error
  pill.
- `test/widget_test.dart` and `integration_test/lock_gate_test.dart` — the ten
  `find.text('App Lock Gate')` checks now look for `'Your journal is locked'`,
  because the app bar title is no longer on screen.

## Kept unchanged on purpose

- Widget keys `app-lock-pin-field`, `app-lock-unlock-button`,
  `phone-lock-unlock-button`.
- `_unlockPin` and `_unlockBiometric`, the `_busy` guard, and every error message.

## Notes

While writing the new test, calling `AppPinService.setPin` directly inside
`testWidgets` hung: the PBKDF2 work never finishes inside the fake-async zone. The
test now derives the credential inside `tester.runAsync`, which is the same class of
trap the testing rules already record for file I/O.

## Checks run

- `flutter gen-l10n` — done
- `flutter analyze` — no issues found
- `flutter test` — full suite green (the two failures seen on the first run were the
  fake-async hang described above, fixed and re-run green)
- `dart format lib test integration_test` — clean
