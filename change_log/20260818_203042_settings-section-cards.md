# Settings screen — section cards that open their own pages

Implements plan `plans/20260818_202326_settings-section-cards.md`.

## What changed

The Settings tab was one long list: five thin text headers with all their rows
stacked underneath. It is now a menu of five cards. Each card has an icon, the
section name, a one-line description and a chevron, and opens a page holding
only that section's rows.

| Card | Opens |
|---|---|
| Security | `_SecuritySettingsScreen` (new) |
| Appearance | `_AppearanceSettingsScreen` (new) |
| Storage | `_StorageSettingsScreen` (new) |
| Permissions | `_PermissionsSettingsScreen` (new) |
| About | `AboutScreen` (already existed, reused) |

Rows, wording, widget keys and behaviour were moved as they were. No setting was
added, removed, or changed.

## Files changed

- `lib/app/app.dart`
  - `_SettingsTab` is now a `StatelessWidget` that builds five
    `_SettingsSectionCard` widgets. Each card is wrapped in `Semantics(button:
    true)` and carries a key: `settings-card-security`,
    `settings-card-appearance`, `settings-card-storage`,
    `settings-card-permissions`, `settings-card-about`.
  - Added `_SecuritySettingsScreen`, `_AppearanceSettingsScreen`,
    `_StorageSettingsScreen`, `_PermissionsSettingsScreen`. The storage and
    permissions pages reuse the existing `_StorageSection` and
    `_PermissionsSection` widgets untouched.
  - `_switchLock` moved onto the Security page, `_switchTheme` onto the
    Appearance page.
  - Deleted `_SectionHeader`, which no longer had a caller.
- `lib/l10n/app_en.arb` — five new card subtitle keys, each with its `@key`
  description: `settingsSectionSecuritySubtitle`,
  `settingsSectionAppearanceSubtitle`, `settingsSectionStorageSubtitle`,
  `settingsSectionPermissionsSubtitle`, `settingsSectionAboutSubtitle`.
- `lib/l10n/app_localizations.dart`, `lib/l10n/app_localizations_en.dart` —
  regenerated with `flutter gen-l10n`.
- `test/features/settings/settings_tab_test.dart` — the one big "renders all
  five sections" test is split into a card-order test plus one test per section
  page. Added an `openSection` helper that taps a card. The migrate-storage test
  now reloads the Storage page with `pageBack()` + reopen instead of switching
  tabs.
- `test/app/settings_screen_security_test.dart` — `openSettings` now also taps
  the Security card.
- `test/widget_test.dart` — theme, About and lock-mode tests tap their card
  instead of scrolling the old long list.
- `docs/architecture.md` — navigation section records the card menu.
- `docs/features.md` — Settings screen description rewritten per page.

## One behaviour fix found while testing

Switching lock mode locks the app straight away. Because the switch now lives on
a pushed page, that page would have stayed on top of the lock gate. `_switchLock`
now pops itself after a successful switch, so the lock gate is what the user
sees. The snackbar is taken from the root `ScaffoldMessenger` before the pop, so
it still shows.

Note: other pushed settings screens (auto-lock profiles, security events, and so
on) still stay on top if the app auto-locks while they are open. That is
pre-existing behaviour and was not changed here.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 603 tests, all passed.
- `dart format lib test integration_test` — clean.
