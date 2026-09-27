# Do not lock the app while the user is using a system screen

**Status:** completed
**Change log:** `change_log/20260925_215533_no-relock-during-system-screens.md`
**Note:** The 2-minute limit was accepted.

## The problem

While editing a journal entry, the user saves and then presses a button such as Export (save to
file), Add photo or Open attachment. When they come back, the app is locked and asks for the PIN
again. The user did not leave the app — they were still working in it.

## Why it happens

`AppLockController.didChangeAppLifecycleState` in
`lib/features/lock_gate/app_lock_controller.dart` locks the app every time Android reports
`AppLifecycleState.paused`.

Android also reports `paused` when **our own app opens a system screen on top of itself**. These
screens belong to Android or to another app, so our screen goes to the background for a moment:

- the system "Save as" / "Open file" screen (`FilePicker.saveFile`, `FilePicker.pickFiles`) —
  used by export, import, backup, restore, attachments and encrypted-export files
- the folder picker for attachment storage (`pickStorageTree` in `MainActivity.kt`)
- the camera and the gallery (`ImagePicker.pickImage`) — editor photos and OCR
- opening an attachment in another app (`OpenFilex.open`)
- opening a link from a table cell (`launchUrl`)
- the fingerprint / device PIN prompt for locked attachments and restore (`local_auth`)

So the app sees "the user left", and locks. Saving itself does not lock — it is the system screen
opened after it.

## The fix

Tell the lock controller "we are opening a system screen on purpose — do not lock for this one
pause". It is still safe, because of two limits:

1. **It covers only that one hand-off.** The guard is switched on just before the system screen
   opens and switched off when it returns. Pressing Home or switching apps at any other time still
   locks at once, exactly as today.
2. **It has a time limit.** If the user stays away longer than **2 minutes** (for example, they
   open the file picker and put the phone down), the app locks when they come back. The 2-minute
   figure is a proposal — tell me if you want a different value.

### New class — core layer

`lib/core/security/external_handoff_guard.dart` — `ExternalHandoffGuard`

- `Future<T> run<T>(Future<T> Function() action)` — counts one hand-off as open, runs the action,
  and closes it in a `finally`, so an error cannot leave the guard stuck open.
- `bool get isActive` — true while at least one hand-off is open.
- A Riverpod provider `externalHandoffGuardProvider` in the same folder.
- It lives in `core/` because many features use it (entries, export, import, backup,
  attachments). It knows nothing about UI, SQL or navigation.

### Changed files

| File | Change |
|---|---|
| `lib/features/lock_gate/app_lock_controller.dart` | Takes the guard. On `paused`: if the guard is active, remember the time instead of locking. On `resumed`: if more than 2 minutes passed, lock. A plain `paused` with no guard still locks at once. |
| `lib/features/lock_gate/providers/lock_gate_providers.dart` | Pass the guard from its provider into `AppLockController`. |
| `lib/features/attachments/services/file_picker_attachment_picker_service.dart` | Wrap `FilePicker.pickFiles`. |
| `lib/features/attachments/domain/attachment_open_router.dart` (or its caller in `attachment_open_service.dart`) | Wrap `OpenFilex.open`. |
| `lib/features/attachments/services/attachment_storage_picker.dart` | Wrap `pickStorageTree`. |
| `lib/features/backup/services/backup_file_picker.dart` | Wrap `FilePicker.pickFiles`. |
| `lib/features/import/presentation/import_screen.dart` | Wrap `FilePicker.pickFiles`. |
| `lib/features/export/presentation/export_screen_actions.dart` | Wrap `FilePicker.saveFile`. |
| `lib/features/export/presentation/open_encrypted_export_screen.dart` | Wrap `pickFiles` and `saveFile`. |
| `lib/features/entries/presentation/entry_editor_actions_3.dart` | Wrap the camera and gallery `pickImage` calls. |
| `lib/features/entries/presentation/ocr_camera_controls.dart` | Wrap the gallery `pickImage` call. |
| `lib/features/entries/presentation/editor/table_cell_editor.dart` | Wrap `launchUrl`. |
| `lib/features/lock_gate/services/biometric_authenticator.dart` | Wrap `authenticate`, so a fingerprint prompt for a locked attachment never relocks the app. |

No database change, no new package, no new permission, no new text on screen, so no ARB change.

## Tests

`test/features/lock_gate/app_lock_controller_test.dart` (add to the existing file or create it):

1. `paused` with no hand-off → locks (today's behaviour is kept).
2. `paused` during a hand-off, then `resumed` within 2 minutes → stays unlocked.
3. `paused` during a hand-off, then `resumed` after more than 2 minutes → locks.
4. The hand-off ends, then a new plain `paused` → locks.
5. An action that throws still closes the hand-off.

The clock is injected so tests do not wait 2 minutes.

Then run `flutter analyze`, `flutter test`, and `dart format lib test integration_test`.

## Acceptance

- Edit an entry, save, tap Export → Save to file, come back: still unlocked.
- Add a photo from the camera or gallery: still unlocked.
- Open an attachment in another app and return within 2 minutes: still unlocked.
- Press Home at any time, then reopen: locked (unchanged).
- Open the file picker and wait more than 2 minutes: locked on return.

## Not in scope

The `AutoLockService` inactivity timer (auto-lock profiles) only writes a security log entry and
never actually locks the app. That is a separate issue and is not changed here.
