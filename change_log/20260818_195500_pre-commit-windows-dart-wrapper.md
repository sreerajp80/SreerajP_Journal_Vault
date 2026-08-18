# Pre-commit hook now finds a runnable dart and flutter on Windows

Implements `plans/20260818_195500_pre-commit-windows-dart-wrapper.md`.

## Why

A commit from GitHub Desktop failed with `/usr/bin/env: 'bash': No such file or directory`,
followed by "formatting check failed". The formatting was clean. On Windows the `dart` and
`flutter` files on PATH are POSIX shell scripts that need bash, and that Git client runs hooks
with a slim PATH that has none. The hook's `command -v flutter` test still passed, so it ran
the script, the script died, and the hook reported the wrong cause.

## What changed

`.githooks/pre-commit` only.

- Added a `resolve_tool` helper. It finds the tool with `command -v`, prefers the `.bat`
  wrapper beside it when that one answers `--version`, and otherwise uses the plain command if
  that answers. The `.bat` wrapper is native to Windows and needs no bash.
- The old `command -v flutter` guard is replaced by a check that both resolved commands exist.
  When either cannot run, the hook prints
  `no runnable dart/flutter here, skipping format and analyze` and exits 0, the same way it
  used to skip on a docs-only clone.
- The format and analyze steps now call the resolved commands instead of bare `dart` and
  `flutter`.
- Updated the header comment to match.

The absolute-path check is unchanged. It is pure shell, always runs, and still stops the commit
on its own.

## Verification

Ran the hook by hand in four states:

| State | Result |
|---|---|
| Normal | Format clean (193 files, 0 changed), analyzer clean, exit 0 |
| One file badly formatted | Fails with the real reason and the fix command, exit 1 |
| That file restored | Back to a clean pass |
| PATH without the Dart SDK | Prints the skip message, exit 0 |

No app source was changed, so no test run was needed.
