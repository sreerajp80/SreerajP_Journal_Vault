# Do not lock the app while the user is using a system screen

**Plan:** `plans/20260925_215533_no-relock-during-system-screens.md`

## What was wrong

The app locked every time Android reported it as paused. Android also reports a pause when the
app itself opens a system screen: the Export "Save as" dialog, the file picker, the camera, the
gallery, the fingerprint / device-PIN prompt, a link, or another app showing an attachment. So the
user was asked for the PIN again while still working in the app, for example after saving an
entry and exporting it.

## What changed

- **New:** `lib/core/security/external_handoff_guard.dart` — `ExternalHandoffGuard` (core layer).
  `run(action)` marks one system-screen hand-off as open while the action runs, and always closes
  it, even on error. One app-wide instance, plus `externalHandoffGuardProvider`.
- `lib/features/lock_gate/app_lock_controller.dart`
  - A pause while a hand-off is open no longer locks; the time is remembered instead.
  - On resume, if more than `handoffGracePeriod` (2 minutes) passed, the app locks.
  - Any other pause still locks at once, as before.
  - `unlock()` clears a remembered pause, so it cannot relock right after an unlock.
  - The guard and a clock can be injected for tests.
- `lib/features/lock_gate/providers/lock_gate_providers.dart` — passes the guard in.
- Wrapped in `ExternalHandoffGuard.instance.run(...)`:
  - `lib/features/attachments/services/file_picker_attachment_picker_service.dart` — file picker
  - `lib/features/attachments/domain/attachment_open_router.dart` — open in another app
  - `lib/features/attachments/services/attachment_storage_picker.dart` — folder picker
  - `lib/features/backup/services/backup_file_picker.dart` — backup file picker
  - `lib/features/import/presentation/import_screen.dart` — import file picker
  - `lib/features/export/presentation/export_screen_actions.dart` — export save dialog
    (import added to `export_screen.dart`, its library file)
  - `lib/features/export/presentation/open_encrypted_export_screen.dart` — pick and save
  - `lib/features/entries/presentation/entry_editor_actions_3.dart` — camera and gallery
    (import added to `entry_editor_screen.dart`)
  - `lib/features/entries/presentation/ocr_camera_controls.dart` — gallery
    (import added to `ocr_camera_screen.dart`)
  - `lib/features/entries/presentation/editor/table_cell_editor.dart` — links
  - `lib/features/lock_gate/services/biometric_authenticator.dart` — device-credential prompt
- `docs/security.md` — documents the exception and the rule that new system-screen calls must be
  wrapped.

No database change, no new package, no new permission, no new on-screen text.

## Tests

Added a "system screen hand-off" group to `test/features/lock_gate/app_lock_controller_test.dart`:
a pause during a hand-off does not lock; returning after the grace period locks; the grace period
is checked even if the hand-off ended before resume; a plain pause after the hand-off still locks;
an action that throws still closes the hand-off; `unlock()` clears a pending pause.

- `flutter analyze` — no issues.
- `flutter test` — all 1107 tests pass.
- `dart format lib test integration_test` — clean.

Not yet checked on a real device.

## Not changed

The auto-lock profile inactivity timer in `AutoLockService` only writes a log entry and never
locks the app. That is a separate issue.
