# Buttons and text no longer hide under the Android navigation bar

Implements `plans/20260919_122638_fix-content-under-nav-bar.md`.

## Why

On Android 15 and later the app is always drawn behind the system navigation bar. Several
places did not leave room for that bar, so buttons and the last lines of text sat under it and
could not be tapped or read. The user's screenshot showed this on the dictation sheet.

## What changed

### Slice 1 — the dictation and voice-note sheets

Already fixed by the parallel dictation work (item 5 of
`plans/20260919_121359_fix-dictation-on-device-listening.md`) before this plan was approved.
Both sheets now add the navigation bar height, or the keyboard height when the keyboard is open,
to their bottom padding. This change did not touch those two files, to avoid overwriting that
work.

### Slice 2 — one shared helper, used across the app

- New `lib/core/utils/safe_insets.dart` (core, UI helper): `EdgeInsets.withSafeBottom(context)`
  adds `MediaQuery.paddingOf(context).bottom` to a padding's bottom. It adds 0 inside the main
  tab shell and while the keyboard is open.
- Scroll views that set their own padding now use it, so the last item can scroll clear of the
  bar:
  - `lib/app/app_lock_setup_screens.dart`, `lib/app/vault_unavailable_app.dart`
  - `lib/features/about/presentation/about_screen.dart`
  - `lib/features/airqr/presentation/airqr_landing_screen.dart`, `airqr_receive_views.dart`,
    `airqr_send_screen.dart`
  - `lib/features/appearance/presentation/` — accent colour, appearance, language, theme mode,
    typography screens
  - `lib/features/backup/presentation/backup_health_screen.dart`,
    `restore_backup_screen.dart` (last sliver)
  - `lib/features/entries/presentation/template_editor_screen.dart`,
    `template_manager_screen.dart`, `time_capsule_sealed_screen.dart`,
    `time_capsules_list_screen.dart` (end spacer), `version_history_screen.dart` (version
    preview)
  - `lib/features/export/presentation/export_screen.dart`, `open_encrypted_export_screen.dart`
  - `lib/features/features_catalog/presentation/features_screen.dart`
  - all 14 screens in `lib/features/help/presentation/`
  - `lib/features/insights/presentation/insights_screen.dart`
  - `lib/features/ritual/presentation/create_ritual_card_screen.dart`,
    `ritual_deck_screen.dart`, `ritual_screen.dart`
  - `lib/features/security/presentation/security_events_screen.dart`,
    `tamper_alerts_screen.dart`
  - `lib/features/sync/presentation/conflict_resolution_screen.dart`, `sync_host_screen.dart`,
    `sync_landing_screen.dart`
- **Entry editor bottom bar** (attach, voice note, scan, mood) in
  `lib/features/entries/presentation/entry_editor_widgets.dart`: found during the audit. It had
  only 8 px of padding and sat under the navigation bar. It now clears the bar.
- `import` lines added to `lib/app/app.dart`, `airqr_receive_screen.dart` and
  `entry_editor_screen.dart` for their `part` files.

### Checked and left alone

- Tab screens (Home, Search, Timeline, Settings): the shell's `NavigationBar` already takes the
  space.
- Plain `ListView`s with no `padding:`: Flutter adds the room by itself.
- Dialogs (template chooser, conflict details, event details, journal card, ritual settings):
  dialogs are already inset from the screen edges.
- Import screen, attachment viewers, the drawing canvas and the distraction-free editor: already
  safe, or short centred content.

No text, colour or layout changes, and no ARB changes, so nothing needs native-reader review.

## Tests

- New `test/core/utils/safe_insets_test.dart`: the helper adds the bar height to the bottom only,
  adds 0 when there is no bar, and the Tags help screen's list ends 40 + 48 px from the bottom
  with a 48 px bar.
- `flutter analyze`: no issues. `dart format lib test integration_test`: clean.
- `flutter test`: 1,032 passed, 1 failed —
  `entry_editor_bottom_bars_test.dart` "toolbar tab button types a tab character at the caret".
  It passes when that file is run alone (2 of 2 runs). It tests the top formatting toolbar, not
  the bottom bar changed here, and the full run was slowed by a second session working in the
  same repository at the same time. Treat it as a probable timing flake, and re-run the full
  suite once the other work settles.

## Still to do

- Check on a phone with 3-button navigation and with gesture navigation, portrait and
  landscape.
