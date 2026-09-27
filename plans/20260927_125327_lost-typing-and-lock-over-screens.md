# Plan — Lost typing in the entry editor, and open screens staying visible over the lock screen

**Status:** completed
**Change log:** `change_log/20260927_131058_lost-typing-and-lock-over-screens.md`
**Note:** Approved 2026-09-27, Parts A and B together.

## Background

The 2026-09-27 review found that the editor can lose the last few seconds of typing. While
checking how the editor is closed when the app locks, a second, more serious problem turned up:
locking does not close open screens at all. The two are tied together, because the right fix for
the second one closes the editor, and closing the editor is exactly where typing gets lost.

- **Part A** fixes the lost typing.
- **Part B** fixes the lock bypass.

They can be approved together (recommended) or separately.

---

## Part A — The editor loses the last few seconds of typing

### Issue

The editor saves 2.5 seconds after the last keystroke:

- `_markDirty` in `lib/features/entries/presentation/entry_editor_actions.dart` (around line 280)
  restarts a 2.5-second timer on each change, and the timer calls `_saveContent(isAutoSave: true)`.
- `dispose` in `lib/features/entries/presentation/entry_editor_screen.dart` (around line 240)
  **cancels** that timer.
- Nothing saves when the screen closes. There is no `PopScope` or save-on-leave.

So text typed in the last 2.5 seconds is lost when the user:

1. presses Back (the app bar arrow or the system Back gesture);
2. leaves the app, and Android later kills it in the background before the timer fires (the timer
   does not run while the app is suspended);
3. has the editor closed by Part B when the app locks.

A related weakness: `_saveContent` reads `ref.read(insightsServiceProvider)` **after** several
awaits. If the screen closes while a save is running, that `ref` call happens after the widget is
gone. Riverpod then throws, and the mood is not saved.

### Fix

1. **Services are read once, in `initState`.** Add `late final` fields for
   `EntryEditorService` and `InsightsService`, next to the existing `_deletionService`.
   `_saveContent` uses these fields instead of `ref.read(...)`, so a save that is still running
   when the screen closes finishes safely.
2. **Save on close.** In `dispose`, before the controllers are disposed: if the entry is dirty
   (`_isDirty`) and has an ID, read the title, the delta JSON, the plain text and the mood
   **synchronously**. Then start one save with those values, without awaiting it: the same
   `EntryEditorService.saveContent` plus the mood save. The widget state is never touched again.
   The replaced-drawing clean-up from the last plan runs **after** this save finishes (chained on
   its future), so it reads the text that was just saved.
3. **Save when the app goes to the background.** The editor state mixes in
   `WidgetsBindingObserver`. On `AppLifecycleState.paused` or `hidden`, if the entry is dirty, it
   cancels the timer and saves at once. `_saveContent` reads the document before its first await,
   so the save holds what was on screen at that moment.
4. The shared snapshot code (title, JSON, plain text, mood) moves into one small helper used by
   `_saveContent` and by the close path. The two cannot drift apart.
5. No change to the 2.5-second autosave itself, to the manual Save button, or to how revisions are
   made.

### Tests

New `test/features/entries/presentation/entry_editor_unsaved_edits_test.dart`, pumping the real
`EntryEditorScreen` the way the existing editor tests do:

- Type text, close the screen **before** 2.5 seconds, then the database holds the new text.
- Type text, send `AppLifecycleState.paused`, then the text is saved without waiting.
- Closing a screen with no changes writes nothing (no new revision).
- Closing while an autosave is still running throws no error, and both saves land.

### Files

- `lib/features/entries/presentation/entry_editor_screen.dart`
- `lib/features/entries/presentation/entry_editor_actions.dart`
- `test/features/entries/presentation/entry_editor_unsaved_edits_test.dart` (new)

---

## Part B — Open screens stay visible on top of the lock screen

### Issue

When the app locks, `lib/app/app.dart` swaps `MaterialApp.home` from `_MainShell` to
`_LockGateScreen` (around line 172). But every other screen is opened with `Navigator.push` on the
same, single navigator: journal detail, the entry editor, settings pages, dialogs. The app has no
inner navigators. Swapping `home` changes only the **bottom** route. The pushed routes stay on top.

This was checked with a small throwaway Flutter test (not in the project): after the swap, the
pushed screen was still visible and hit-testable, and the lock screen underneath was not.

So:

1. The user opens an entry, or a password-locked journal they unlocked this session.
2. They press Home. The app locks on pause, as designed.
3. They, or anyone holding the phone, come back. The entry or journal is **still on screen and
   usable**. The lock screen sits hidden underneath.

This bypasses the app lock and the per-journal lock (the unlocked-journal list is cleared, but
the open screen is not). It breaks the Sensitive Data profile.

### Fix

1. Give `MaterialApp` a `navigatorKey`, owned by `_JournalVaultAppState`.
2. In `_JournalVaultAppState.build`, `ref.listen(appLockProvider, ...)`. When `isLocked` changes
   from false to true, call `navigatorKey.currentState?.popUntil((route) => route.isFirst)`. This
   closes every pushed screen, dialog and bottom sheet, so only the lock gate is left.
3. Closing the editor this way runs its `dispose`, which saves the unsaved text (Part A, step 2).
   That is why Part A must land with, or before, Part B.
4. Nothing changes for system screens the app opened on purpose (file picker, camera): the lock
   does not fire during those (the `ExternalHandoffGuard` rule), so nothing is popped.
5. After unlocking, the user starts again from the home screen, not from where they were. This is
   the usual, safe behaviour for a locked vault app.

### Tests

New `test/app/lock_closes_open_screens_test.dart`:

- With the app unlocked, push a screen (for example journal detail), lock the app, then the pushed
  screen is gone and the lock gate is the only visible screen.
- An open dialog is closed by the lock too.
- Unlocking shows the home shell, with nothing left over.

Plus one case in the Part A test file: the editor open with unsaved text, lock the app, then the
editor closes **and** the text is saved.

### Files

- `lib/app/app.dart`
- `test/app/lock_closes_open_screens_test.dart` (new)
- `docs/security.md` (the lock rule: locking closes every open screen)
- `docs/architecture.md` §6 App Lifecycle Behavior (save on background and on close; lock closes
  screens), and §21 (record both fixes)

---

## Checks after the change

- `dart format lib test integration_test`: clean.
- `flutter analyze`: zero issues.
- `flutter test`: all pass, including the new tests and the existing lock gate tests.
- `integration_test/` lock gate test still passes, if a device or emulator is available. If not,
  say so in the change log.
- `sh tool/check_absolute_paths.sh --all`: passes.
- A manual check on a phone, described in the change log for the user to run: type, press Back
  at once, reopen, and the text is there. Open an entry, press Home, return, and the lock screen
  shows, not the entry.

## Out of scope

- Review items 1–4 (commit `third_party/`, the Wi-Fi Sync bugs, AirQR turning off screenshot
  blocking).
- The two small findings from the last change log (the English "Entry #" text, and AirQR entries
  on a phone with no journals).
