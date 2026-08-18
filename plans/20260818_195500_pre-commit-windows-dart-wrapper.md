# Make the pre-commit hook find a runnable dart and flutter on Windows

**Status:** completed

## The issue

A commit made from GitHub Desktop fails with:

```
pre-commit: checking formatting...
/usr/bin/env: 'bash': No such file or directory
pre-commit: formatting check failed.
```

The formatting is not actually dirty. On Windows the `dart` and `flutter` files on PATH are
POSIX shell scripts whose first line is `#!/usr/bin/env bash`. GitHub Desktop runs hooks with
its own bundled Git and a slim PATH that has no `bash`, so the script cannot start.

The hook's `command -v flutter` test still succeeds, so it does not take the "flutter is not
installed" skip. It runs the script, the script dies, and the hook reads that non-zero exit as
"formatting check failed". So the hook reports the wrong thing and blocks a clean commit.

The same SDK folder also ships `dart.bat` and `flutter.bat`. Those are native Windows wrappers
and need no bash. `dart.bat --version` was confirmed working in this repository.

## Files to change

| File | Change |
|---|---|
| `.githooks/pre-commit` | Resolve a runnable `dart` and `flutter` before using them |

No source code, no docs, no other script.

## The fix

Add a small resolver to the hook:

1. Find the tool with `command -v`, as now.
2. If a `.bat` file sits next to it, use that instead. It is the native wrapper and runs in
   every Windows Git client, with or without bash.
3. Check the chosen command really runs (`--version`). If it does not, print a clear warning
   and skip the format and analyze steps, the same way the hook already skips them when
   Flutter is not installed at all.

Step 3 matters: a hook that fails for a reason the developer cannot act on is a hook people
turn off. CI stays the real gate — `.github/workflows/ci.yml` runs format, analyze and test on
every push and pull request.

The absolute-path check is untouched. It is pure shell, it always runs, and it still stops the
commit on its own.

## Verification

- Run `sh .githooks/pre-commit` by hand from Git Bash and see format and analyze run and pass.
- Make one file badly formatted, run the hook again, and see it fail with the real reason.
  Then restore the file.
- Commit from GitHub Desktop and see the hook pass.

## Not doing

Removing the format and analyze steps from the hook, or hard-coding an SDK location. The first
loses a useful local check; the second breaks on any other machine.
