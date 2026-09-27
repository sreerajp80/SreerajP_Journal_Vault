# Stop buttons and text from hiding under the Android navigation bar

**Status:** completed
**Change log:** `change_log/20260919_124408_fix-content-under-nav-bar.md`

Approved 2026-09-19 by the user ("I approve both slices").

## Issue

On the phone, the dictation sheet's bottom row ("Discard changes", the pause button, "Done")
sits **under** the Android navigation bar (back / home / recents). The buttons can't be tapped,
and the user reports that many screens look like this.

### Why it happens

- Flutter 3.44 targets Android SDK 36. On Android 15 and later, apps are always drawn
  **edge-to-edge**: the app draws behind the status bar and the navigation bar. The app itself
  has to leave room for them. Flutter reports that room as `MediaQuery` padding (the "safe
  area").
- `showDictationSheet` passes `useSafeArea: true`. That flag only protects the **top** of a
  bottom sheet, not the bottom. The sheet adds room for the keyboard
  (`MediaQuery.viewInsetsOf(context).bottom`) but none for the navigation bar.
- The voice-note recorder sheet (`voice_note_recorder.dart`) has the same gap: a fixed
  `EdgeInsets.all(24)` and no `SafeArea`.
- The other four bottom sheets (Air-QR journal picker, mood picker, scan-source picker, OCR text
  preview) already wrap their content in `SafeArea`, so they are fine.
- **Why "every screen" looks wrong:** a `ListView` or `SingleChildScrollView` adds the
  navigation-bar room by itself **only when no `padding:` is given**. Once a screen sets its own
  padding (for example `EdgeInsets.all(16)`), Flutter adds nothing. The last item then stops
  under the navigation bar and can't be scrolled any higher. 43 screens do this (list below).
  Tab screens inside the main `NavigationBar` shell are not affected, because the shell's bottom
  bar already takes that space.

## Fix

### Slice 1 — the two broken sheets (fixes the screenshot)

1. `lib/features/entries/presentation/editor/dictation_sheet.dart` — make the bottom padding
   `16 + viewInsets.bottom + MediaQuery.paddingOf(context).bottom`. When the keyboard is open,
   Flutter already sets `padding.bottom` to 0 (the keyboard covers the navigation bar), so this
   never adds the gap twice.
2. `lib/features/entries/presentation/editor/voice_note_recorder.dart` — wrap the sheet content
   in `SafeArea(top: false)`.

**Acceptance:** with 3-button navigation and with gesture navigation, every button on both sheets
sits fully above the navigation bar, in portrait and landscape, in en / ml / sa. With the
keyboard open (dictation "edit text" step), the text field and the Insert button sit right above
the keyboard with no extra gap.

### Slice 2 — one shared helper, applied to every affected screen

1. New `lib/core/utils/safe_insets.dart` (layer: core, UI helper, no business logic) — a small
   extension:
   `EdgeInsets.withSafeBottom(BuildContext context)` returns the same padding with
   `MediaQuery.paddingOf(context).bottom` added to the bottom. Inside the main tab shell that
   value is 0, so the helper is safe to use everywhere.
2. Change the scroll view `padding:` in each file below to
   `const EdgeInsets.all(16).withSafeBottom(context)` (keeping each file's current numbers).
   Content still scrolls behind the navigation bar, but the last item can now be scrolled clear
   of it.

   - `lib/app/app_lock_setup_screens.dart`, `lib/app/vault_unavailable_app.dart`
   - `lib/features/about/presentation/about_screen.dart`
   - `lib/features/airqr/presentation/` — `airqr_landing_screen.dart`,
     `airqr_receive_views.dart`, `airqr_send_screen.dart`
   - `lib/features/appearance/presentation/` — `accent_color_settings_screen.dart`,
     `appearance_screen.dart`, `language_settings_screen.dart`,
     `theme_mode_settings_screen.dart`, `typography_settings_screen.dart`
   - `lib/features/backup/presentation/backup_health_screen.dart`
   - `lib/features/entries/presentation/` — `entry_template_chooser_dialog.dart` (check only; a
     dialog is already inset, likely no change), `template_editor_screen.dart`,
     `template_manager_screen.dart`, `time_capsule_sealed_screen.dart`
   - `lib/features/export/presentation/` — `export_screen.dart`,
     `open_encrypted_export_screen.dart`
   - `lib/features/features_catalog/presentation/features_screen.dart`
   - `lib/features/help/presentation/` — all 14 help screens
   - `lib/features/insights/presentation/insights_screen.dart`
   - `lib/features/ritual/presentation/` — `create_ritual_card_screen.dart`,
     `ritual_deck_screen.dart`, `ritual_screen.dart`
   - `lib/features/security/presentation/` — `security_events_screen.dart`,
     `tamper_alerts_screen.dart`
   - `lib/features/sync/presentation/` — `conflict_resolution_screen.dart`,
     `sync_host_screen.dart`, `sync_landing_screen.dart`
   - `lib/features/timeline/presentation/timeline_screen.dart` (check whether it is a tab
     first; if it is, no change)
3. While going through each file, also check for buttons pinned to the bottom of a `Column`
   outside the scroll view (for example restore, import, export). Wrap those in
   `SafeArea(top: false)`.

**Acceptance:** on each screen above, scroll to the end: the last item and any bottom button are
fully visible above the navigation bar.

### Tests

- `test/core/utils/safe_insets_test.dart` — the helper adds the bottom padding, and adds 0 when
  `MediaQuery` padding is 0.
- `test/features/entries/presentation/editor/dictation_sheet_test.dart` — new case: with
  `MediaQuery` bottom padding of 48, the "Done" button's bottom edge is above
  `screenHeight - 48`.
- The same check for the voice-note recorder in its existing test file.
- Run `flutter analyze`, `flutter test`, `dart format lib test integration_test`.

## Not in scope

- No layout redesign, colour or text changes. No new strings, so no ARB changes.
- Not turning edge-to-edge off. Android 16 (SDK 36) no longer lets apps opt out.

## Risk

Low. Each change only adds bottom space equal to the navigation bar height, and adds nothing
where there is no navigation bar or where the keyboard is open.
