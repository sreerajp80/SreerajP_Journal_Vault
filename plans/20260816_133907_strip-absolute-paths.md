# Remove absolute local paths from plans, change logs and docs

**Status:** completed

## What is the issue

Some plan and change log files still name real folders on the local PC. If this repository is
ever pushed to a public host, those lines tell the reader which drives and folders exist on the
machine. The shared guidelines already forbid this — see
`docs/guidelines/DOCS_FOLDER_GUIDELINE.md` line 56 and
`docs/guidelines/flutter_project_engineering_standard.md` line 2186: `plans/` and `change_log/`
entries must use **relative repository paths only**.

I searched the whole repository for absolute paths (any drive letter followed by a separator,
plus `/Users/`, `/home/`, `file:///`, `%USERPROFILE%`, `$HOME`). Only four lines in three files <!-- allow-abs-path -->
are real problems:

(The offending text is described, not quoted, so this plan does not repeat the leak.)

| File | Line | What was wrong |
|---|---|---|
| `plans/20260725_080036_add-guidelines-submodule.md` | 14 | Named the local drive letter and parent folder holding the app. |
| `plans/20260725_080036_add-guidelines-submodule.md` | 26 | Named the same local parent folder again. |
| `change_log/20260725_080227_add-guidelines-submodule.md` | 18 | Named the same local parent folder. |
| `plans/20260725_085907_close-profile-gaps.md` | 63 | Named the local install folders for the Flutter SDK and the JDK. |

### What I checked and am leaving alone

These matched my search but are **not** local machine details, so they stay as they are:

- `content://` — an Android URI scheme used all over the attachment code and docs.
- `win32` — the name of a pub.dev package in the dependency notes.
- `sreerajp_journal_vault`, `in.sreerajp...`, `SreerajP` — the app's own package name, bundle id
  and product branding. These are meant to be public.
- `https://github.com/sreerajp80/Flutter_Guidelines` — a public repository URL.
- Everything under `docs/guidelines/` — that is a separate Git submodule. Project rules say do
  not edit files there. Its own text only mentions drive-letter paths as bad examples inside the
  rule itself, which is fine.
- `test/features/attachments/attachment_storage_migration_service_test.dart` — uses made-up
  Windows-style fixture paths under a fake `vault` folder. These are invented test data, not
  folders on this PC.
- Files outside `plans/`, `change_log/` and `docs/` (source code, Gradle, Xcode, CMake) had no
  absolute local paths.

## Files to be changed

| File | Change |
|---|---|
| `plans/20260725_080036_add-guidelines-submodule.md` | Replace the two local-folder mentions with a neutral description ("the parent folder above the repository root"). |
| `change_log/20260725_080227_add-guidelines-submodule.md` | Same replacement on line 18. |
| `plans/20260725_085907_close-profile-gaps.md` | Drop the Flutter SDK and JDK install paths; just say both tools are on `PATH`. |
| `plans/20260816_133907_strip-absolute-paths.md` | This plan. Status updated as work moves on. |

## Plan for the fix

1. Edit the three files listed above. Keep the meaning of each sentence; only remove the drive
   letters and folder names.
2. Re-run the search for absolute paths across the whole repository and confirm the only
   remaining hits are the allowed ones listed above.
3. Write the change log to `change_log/`.

These are historical records, so I will not rewrite them beyond the offending words.

## Not in scope (flagging for your call)

Nothing stops a future plan or change log from adding an absolute path again. A pre-commit hook
or a small check script could block it. Say the word and I will plan that separately.
