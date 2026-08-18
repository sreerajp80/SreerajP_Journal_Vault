# Add a pre-commit guard that blocks absolute local paths

**Status:** completed

## What is the issue

[`change_log/20260816_134500_strip-absolute-paths.md`](../change_log/20260816_134500_strip-absolute-paths.md)
cleaned the absolute local paths out of `plans/` and `change_log/`. Nothing stops the next plan
or change log from adding one again. The check was manual, so it will drift.

The repository has no hooks and no CI today:

- `core.hooksPath` is not set, and `.git/hooks/` holds only Git's own `.sample` files.
- There is no `.github/`, no `lefthook.yml`, no `.pre-commit-config.yaml`.

So this is a from-scratch addition, not a change to an existing setup.

## The approach

A small shell script that scans files for absolute local paths, wired in two ways:

1. As a **pre-commit hook**, checking only the files staged for that commit. Fast, and it fails
   the commit before the leak is recorded in history.
2. As a **manual audit command**, checking every tracked file at once. Useful before a release
   or before making the repository public.

Hooks in `.git/hooks/` are not tracked by Git, so the hook would not survive a fresh clone. The
fix is to keep the hook in a tracked `.githooks/` folder and point Git at it with
`git config core.hooksPath .githooks`. That config is per-clone, so it needs one setup command
after cloning — which will be documented.

Written as POSIX `sh`. Git for Windows ships its own Bash and runs hooks with it, so this works
on this machine with no extra install, and works unchanged on Linux and macOS.

## What counts as a violation

| Pattern | Example it catches |
|---|---|
| A single drive letter followed by `\` or `/` | a path starting with a drive letter |
| `file:///` | a local file URI <!-- allow-abs-path --> |
| `/Users/<name>` or `/home/<name>` at a path boundary | a macOS or Linux home folder |
| `%USERPROFILE%`, `%HOMEPATH%`, `%APPDATA%` | a Windows environment path <!-- allow-abs-path --> |

Two details matter for avoiding false alarms:

- The drive-letter rule requires the letter to stand alone. Without that, the `s:/` inside <!-- allow-abs-path -->
  `https://` would match every URL in the docs.
- The `/Users/` and `/home/` rules only fire at a real path boundary. Without that,
  `lib/features/home/presentation/...` would match on every mention of the home feature.

## Which files get checked

Checked:

- `plans/` and `change_log/` — every file.
- `docs/` — every file, **except** `docs/guidelines/`.
- Markdown files at the repository root (`README.md`, `CLAUDE.md`, `AGENTS.md`).

Not checked, and why:

- `docs/guidelines/` — a separate Git submodule. Project rules say do not edit it, and its own
  text names drive-letter paths as bad examples inside the rule.
- Dart, Gradle, Xcode, CMake and web files — `attachment_storage_migration_service_test.dart`
  legitimately uses invented Windows-style fixture paths as test data. Scanning source would
  make the hook cry wolf on the first commit.

If a checked file ever has a genuine reason to show an absolute path, putting
`allow-abs-path` in a comment on that line skips it. This keeps the guard from becoming
something people routinely bypass wholesale.

## Files to be changed

| File | Change |
|---|---|
| `tool/check_absolute_paths.sh` | New. The scanner. Takes a list of files, or `--all` to scan everything tracked. Exits non-zero and prints file, line number and the offending text when it finds something. |
| `.githooks/pre-commit` | New. Runs the scanner over the staged files only. |
| `README.md` | New short "Repository setup" section: run `git submodule update --init --recursive` and `git config core.hooksPath .githooks` after cloning. |
| `CLAUDE.md` | Add a line to the project rules stating that plans, change logs and docs use relative repository paths only, and naming the guard and the `--all` audit command. |
| `plans/20260816_134319_absolute-path-guard-hook.md` | This plan. Status kept current. |

## Plan for the fix

1. Write `tool/check_absolute_paths.sh` with the patterns and file scope above.
2. Write `.githooks/pre-commit` to call it with the staged file list.
3. Enable it locally: `git config core.hooksPath .githooks`.
4. Test it properly, and report the real output:
   - Run `--all` against the repository as it stands now. It must pass, since the paths were
     just cleaned.
   - Stage a scratch file containing a fake absolute path and confirm the commit is blocked and
     the message is clear. Then unstage and delete the scratch file.
   - Confirm a normal commit with clean files is not blocked.
   - Confirm the `allow-abs-path` marker works.
   - Confirm a file under `docs/guidelines/` and a Dart test file are not flagged.
5. Update `README.md` and `CLAUDE.md`.
6. Write the change log.

## Things you should know

- **The hook is local, not enforced.** Anyone can skip it with `git commit --no-verify`, and a
  fresh clone has it off until `core.hooksPath` is set. A hook is a helpful reminder, not a
  security control. Real enforcement needs CI.
- **No CI exists yet**, so I am not adding a CI job in this plan. The scanner is written so a CI
  step can call it later with one line. Tell me if you want the CI job planned too.
- **No source code is touched**, so `flutter analyze` and `flutter test` results will not change.
