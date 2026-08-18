# Added a pre-commit guard against absolute local paths

Implements [`plans/20260816_134319_absolute-path-guard-hook.md`](../plans/20260816_134319_absolute-path-guard-hook.md).

## Why

An earlier change cleaned absolute local paths out of `plans/` and `change_log/`, but nothing
stopped the next file from adding one. This adds an automatic check.

## What was added

| File | What it does |
|---|---|
| `tool/check_absolute_paths.sh` | The scanner. Takes a file list, or `--all` to scan every tracked file. Prints file, line number and the offending text. Exits 1 on a find, 2 on bad usage. |
| `.githooks/pre-commit` | Runs the scanner over the staged files only, so a bad commit is blocked before it reaches history. |
| `.gitattributes` | New. Forces LF line endings on `*.sh` and `.githooks/*`. |
| `README.md` | New "Repository setup" section: the submodule init command and `git config core.hooksPath .githooks`, plus the `--all` audit command. |
| `CLAUDE.md` | New "Relative paths only" section stating the rule and naming the guard. |

The hook was enabled locally with `git config core.hooksPath .githooks`.

### What the scanner flags

A lone drive letter followed by a separator; `file:///`; a `/Users/` or `/home/` folder at a path <!-- allow-abs-path -->
boundary; and Windows environment paths such as `%USERPROFILE%`. <!-- allow-abs-path -->

Two anchors in the pattern stop false alarms, both found by testing against the real repository:

- The drive-letter rule requires the letter to stand alone. Without it, the `s:/` inside <!-- allow-abs-path -->
  `https://` matched every URL in the docs.
- The home-folder rules only fire at a path boundary. Without it,
  `lib/features/home/presentation/...` matched every mention of the home feature.

### Scope

Covers `plans/`, `change_log/`, `docs/` (excluding the `docs/guidelines/` submodule) and root
markdown files. Source code is deliberately out of scope, because
`test/features/attachments/attachment_storage_migration_service_test.dart` uses invented
Windows-style fixture paths as test data.

Putting `allow-abs-path` in a comment on a line skips that line.

## Two things that came up during the work

1. **Line endings.** This machine has `core.autocrlf=true`, so Git was checking the shell scripts
   out with CRLF. A shell script with CRLF fails on Linux and macOS with a "bad interpreter"
   error, so the hook would have silently stopped working for anyone not on Windows. `.gitattributes`
   was added to pin LF. This file was not in the original plan; it was needed to make the hook
   actually portable. Confirmed with `git check-attr text eol`, which now reports `eol: lf` for
   both scripts, and the CRLF warning no longer appears when staging them.
2. **The guard flagged its own documentation.** The new `README.md` and `CLAUDE.md` sections spell
   out the forbidden patterns as examples, so the scanner matched them. Those three lines now
   carry the `allow-abs-path` marker — the intended escape hatch, used here for its intended case.

## Verification

All seven checks were run and passed:

| Check | Result |
|---|---|
| `--all` against the repository as it stands | Passed, exit 0. |
| Scratch file with six different bad patterns | All six caught, exit 1. |
| Six known-good lines in the same file (`https://`, `content://`, `lib/features/home/...`, `app.dart:945`, a relative path, and a bare `/docs`) | None flagged. |
| `allow-abs-path` marker on a bad line | Not flagged. |
| Committing the scratch file | Blocked. `git log` confirmed `HEAD` was unchanged at `563ef08`. |
| Out-of-scope files (the Dart migration test, a `docs/guidelines/` document) | Not flagged, exit 0. |
| Clean staged set, and clean in-scope files | Not blocked, exit 0. |

The scratch file was unstaged and deleted afterwards. A final `--all` run after the `README.md`
and `CLAUDE.md` edits exits 0.

No source code was touched, so `flutter analyze` and `flutter test` were not run.

## Limits you should know

- The hook is a local reminder, not enforcement. It can be skipped with `git commit --no-verify`,
  and it stays off in a fresh clone until `core.hooksPath` is set.
- There is still no CI in this repository. Real enforcement needs one. The scanner takes `--all`
  so a CI step can call it in a single line whenever a CI setup is added.
