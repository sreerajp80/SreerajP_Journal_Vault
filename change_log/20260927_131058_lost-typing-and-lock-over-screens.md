# Change log — Lost typing in the editor, and open screens over the lock screen

**Plan:** `plans/20260927_125327_lost-typing-and-lock-over-screens.md` (approved 2026-09-27,
Parts A and B together)

## Part A — The editor no longer loses the last few seconds of typing

`lib/features/entries/presentation/entry_editor_screen.dart`:

- The editor state now uses `WidgetsBindingObserver`. On `paused` or `hidden`, a dirty entry is
  saved at once (the 2.5-second timer does not run in the background).
- `dispose` saves a dirty entry. It takes a snapshot (title, delta JSON, search text, mood) before
  the controllers are disposed, and starts the save without awaiting it. The replaced-drawing
  clean-up from the last change now runs **after** that save, in a static helper
  (`_finishAfterClose`) that holds no widget state.
- `EntryEditorService` and `InsightsService` are read once in `initState` (`_editorService`,
  `_insightsService`). A save still running when the screen closes no longer calls `ref` after the
  widget is gone. Before, that threw and the mood was not saved.
- New `_editGeneration` counter. A save clears the dirty flag only if nothing changed while it
  ran, so a change typed during a save is not marked as saved.
- New private record type `_EditorSnapshot`.

`lib/features/entries/presentation/entry_editor_actions.dart`:

- `_snapshot()` reads everything a save writes, before any await.
- `_saveSnapshot(entryId, snapshot)` writes it using only the services read in `initState`.
  `_saveContent` and `dispose` both use it, so the two paths cannot drift apart.
- `_markDirty` bumps `_editGeneration`.

`lib/features/entries/presentation/entry_editor_actions_2.dart`: choosing a mood also bumps
`_editGeneration`.

New `test/features/entries/presentation/entry_editor_unsaved_edits_test.dart`:

- closing the screen 0.3 seconds after typing saves the text;
- going to the background saves at once;
- closing without changes writes nothing and makes no revision;
- text typed after an autosave is saved when the screen closes.

With the two new save paths switched off, three of these four tests fail. The fourth, "no
changes", is a guard against over-saving.

## Part B — Locking now closes every open screen

The bug was confirmed twice. First with a throwaway Flutter test outside the project. Then in the
real app: the three new tests below all fail when the fix is switched off.

`lib/app/app.dart`:

- `_JournalVaultAppState` owns a `GlobalKey<NavigatorState>`, passed to `MaterialApp`.
- `ref.listen(appLockProvider, ...)`: when `isLocked` goes from false to true,
  `popUntil((route) => route.isFirst)` closes every pushed screen, dialog and sheet. An open
  editor saves as it closes (Part A).

`lib/features/settings/presentation/security_settings_screen.dart`:

- This screen had its own one-off fix for the same problem: after switching lock mode, which
  locks at once, it popped itself. With Part B the app has already closed it, so that pop would
  have closed one route too many, and the confirmation was never shown.
- Now it takes the app-level `ScaffoldMessenger` before the switch, no longer pops itself, and
  shows "Lock mode updated…" over the lock gate. The existing test
  `test/widget_test.dart` ("Lock mode switch persists and relocks…") caught this, and it passes
  again unchanged.
- No other code locks the app and then closes its own screen.

Tests — new group "locking closes open screens" in `test/journal_flow_test.dart`:

- an open journal is closed when the app locks, and unlocking shows the home screen;
- an open dialog is closed when the app locks;
- an open editor with unsaved text closes **and** its text is saved when the app locks.

Change from the plan: these tests were added to `test/journal_flow_test.dart`, which already has
the helpers that pump the whole app and lock it, instead of a new
`test/app/lock_closes_open_screens_test.dart`. The existing relock test in that file presses Back
before locking, which is why it never caught the bug.

## Docs

- `docs/architecture.md` §6: save on background and on close; locking closes screens. §21: new
  "Closed on 2026-09-27 — lost typing, and screens over the lock gate".
- `docs/security.md`: new rule, "locking closes every open screen".

## Checks

- `dart format lib test integration_test`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 1,154 tests pass (1,147 before).
- `integration_test/`: **not run.** A phone was connected, but both flavors share one application
  ID. Installing a dev build over the real app destroys its journal data (CLAUDE.md, "Build
  flavors"), so it was not installed.

## Manual check for the user, on a phone

1. Open an entry, type a few words, and press Back at once. Reopen the entry: the words are there.
2. Open an entry, press Home, wait, and return. The lock screen shows, not the entry. After
   unlocking, the app starts on the home screen, and any text typed before pressing Home is saved.
3. Open a password-locked journal, unlock it, press Home, and return. The lock screen shows. After
   unlocking, the journal asks for its password again.
