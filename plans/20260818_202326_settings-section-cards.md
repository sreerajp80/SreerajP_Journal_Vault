# Settings screen — section cards that open their own pages

**Status:** completed

## The issue

The Settings tab is one long `ListView`. Every section (Security, Appearance,
Storage, Permissions, About) is a small text header followed by all of its rows,
stacked one after another. Problems with this:

- The user must scroll a long way to reach Storage, Permissions or About.
- Section headers are thin and easy to miss, so the screen reads as one flat
  list of unrelated switches and rows.
- Unrelated controls (a screenshot switch, a theme chooser, a storage migration
  button) sit next to each other with nothing to separate them.

The user wants each section shown as a **card**. Tapping a card opens a page
that holds only that section's rows.

## The plan

### 1. Settings tab becomes a menu of cards

`_SettingsTab` stops rendering section content. It renders one `Card` per
section, each with an icon, the section name, a one-line description and a
chevron. Tapping pushes that section's own screen with `Navigator.push`
(Navigator 1.0, same as the rest of the app).

Cards, in the current order:

| Card | Icon | Opens |
|---|---|---|
| Security | `Icons.lock_outline` | `_SecuritySettingsScreen` (new) |
| Appearance | `Icons.palette_outlined` | `_AppearanceSettingsScreen` (new) |
| Storage | `Icons.folder_outlined` | `_StorageSettingsScreen` (new) |
| Permissions | `Icons.verified_user_outlined` | `_PermissionsSettingsScreen` (new) |
| About | `Icons.info_outline` | `AboutScreen` (already exists, reused) |

### 2. Four new section screens

Each is a `Scaffold` with an `AppBar` titled with the section name, and a
`ListView` holding exactly the rows that section has today — moved, not
rewritten:

- **Security** — App Lock Mode, Phone Lock, Separate App Lock, Auto-Lock
  Timeout, Attachment-Level Lock, Block Screenshots (`_ScreenSecurityTile`),
  Tamper Alerts, Sync Conflicts, Security Events.
- **Appearance** — Theme title/subtitle and the Light/Dark choice chips.
- **Storage** — the existing `_StorageSection` widget, unchanged.
- **Permissions** — the existing `_PermissionsSection` widget, unchanged.

Behaviour, wording, widget keys and helper methods (`_switchLock`,
`_switchTheme`, `_PinSetupDialog`, `_ScreenSecurityTile`) all stay the same.
`_switchLock` and `_switchTheme` move from `_SettingsTab` onto the Security and
Appearance screens.

### 3. Where the new code lives

The new screens go in `lib/app/app.dart`, next to `_SettingsTab`, as private
widgets. Reason: `_StorageSection`, `_PermissionsSection`, `_ScreenSecurityTile`
and `_LockedAttachmentsScreen` are already private classes in that file. Moving
them into a new `lib/features/settings/` folder would mean making all of them
public and rewriting their imports — a much bigger diff than this task asks for.
If you would rather I split Settings into its own feature folder, say so and I
will write that as a separate plan.

### 4. New text (all through ARB, no literals)

New keys in `lib/l10n/app_en.arb`, each with its `@key` description, then
`flutter gen-l10n`:

- `settingsSectionSecuritySubtitle` — "Lock mode, auto-lock, screenshots and
  security events"
- `settingsSectionAppearanceSubtitle` — "Theme and how the app looks"
- `settingsSectionStorageSubtitle` — "Attachment location, usage, backup and
  import"
- `settingsSectionPermissionsSubtitle` — "What the app is allowed to use"
- `settingsSectionAboutSubtitle` — "Version, licences and app details"

Existing `settingsSection*` keys are reused as the card titles and the new page
titles.

### 5. Accessibility

Each card is a `Semantics` button labelled with its section name, as required
for custom interactive widgets.

### 6. Tests

- `test/features/settings/settings_tab_test.dart` — rewritten navigation flow:
  the "all five sections" test now checks the five cards and their order, and
  every row test first taps the card that owns the row. Row-level assertions
  and keys stay the same.
- `test/app/settings_screen_security_test.dart` — tap the Security card before
  looking for `settings-screen-security`.
- `test/widget_test.dart` — tap the Appearance card before the theme chip, and
  the Security card before the PIN setup flow.
- `integration_test/lock_gate_test.dart` — checked and updated only if it walks
  into Settings rows.
- New card keys for tests: `settings-card-security`, `settings-card-appearance`,
  `settings-card-storage`, `settings-card-permissions`, `settings-card-about`.

Because sections are now separate pages, the tall 800x1800 surface size the
tests use can stay as is — it simply gives each page room.

### 7. Docs

- `docs/architecture.md` — update the Settings screen description to say it is a
  card menu with one page per section.
- `docs/features.md` — same, where the Settings screen is described.

## Files to change

| File | Change |
|---|---|
| `lib/app/app.dart` | `_SettingsTab` becomes a card menu; four new section screens; `_switchLock` / `_switchTheme` move |
| `lib/l10n/app_en.arb` | five new subtitle keys + `@key` descriptions |
| `lib/l10n/app_localizations.dart` | regenerated |
| `lib/l10n/app_localizations_en.dart` | regenerated |
| `test/features/settings/settings_tab_test.dart` | navigate through cards |
| `test/app/settings_screen_security_test.dart` | navigate through Security card |
| `test/widget_test.dart` | navigate through Appearance / Security cards |
| `integration_test/lock_gate_test.dart` | only if it touches Settings rows |
| `docs/architecture.md` | describe the new Settings structure |
| `docs/features.md` | describe the new Settings structure |

## Out of scope

- No change to any setting's behaviour, storage, or security rules.
- No new settings, no removed settings.
- No move of Settings into its own feature folder (see section 3).

## Checks before done

- `flutter analyze` clean
- `flutter test` green
- `dart format lib test integration_test`
- change log written to `change_log/`
