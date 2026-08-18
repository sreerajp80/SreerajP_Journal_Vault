# Removed absolute local paths from plans and change logs

Implements [`plans/20260816_133907_strip-absolute-paths.md`](../plans/20260816_133907_strip-absolute-paths.md).

## Why

Three older records named real folders on the development PC. If this repository is ever made
public, those lines would reveal the machine's drive letters and folder layout. The shared
guidelines already require `plans/` and `change_log/` entries to use relative repository paths
only.

## What was changed

| File | Change |
|---|---|
| `plans/20260725_080036_add-guidelines-submodule.md` | Two mentions of the local parent folder replaced with "the parent folder above the app / repository root". |
| `change_log/20260725_080227_add-guidelines-submodule.md` | Same replacement in the "What was done" step 2. |
| `plans/20260725_085907_close-profile-gaps.md` | The Flutter SDK and JDK install folders dropped. The line now just says both tools are on `PATH`. |
| `plans/20260816_133907_strip-absolute-paths.md` | The plan itself. Its "before" column originally quoted the offending paths, which repeated the leak, so it was rewritten to describe them instead of quoting them. |

Only the offending words were changed. These are historical records, so the surrounding text and
meaning were left as they were.

## What was checked and deliberately left alone

- `content://` — an Android URI scheme, not a local path.
- `win32` — a pub.dev package name in the dependency notes.
- `sreerajp_journal_vault`, `in.sreerajp...`, `SreerajP` — the app's own package name, bundle id
  and branding. Public by design.
- The public `Flutter_Guidelines` GitHub URL.
- `docs/guidelines/` — a separate Git submodule that project rules say not to edit. Its
  drive-letter mentions are bad-examples inside the rule text itself.
- `test/features/attachments/attachment_storage_migration_service_test.dart` — invented
  Windows-style fixture paths under a fake `vault` folder. Test data, not real folders.
- Source code, Gradle, Xcode, CMake and web files — no absolute local paths found.

## Verification

Re-ran a repository-wide search over all tracked files for drive-letter paths, `file:///`, <!-- allow-abs-path -->
`/Users/`, `/home/` and `%USERPROFILE%`. After the edits, no hits remain in `plans/`, <!-- allow-abs-path -->
`change_log/`, `docs/*.md` or the root markdown files.

No source code was touched, so no test run was needed.

## Still open

Nothing prevents a future plan or change log from adding an absolute path again. A pre-commit
hook or a small check script would enforce this automatically. Not done — awaiting a decision.
