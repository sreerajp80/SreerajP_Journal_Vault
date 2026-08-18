# Fixed false positives from the absolute-path guard

Implements `plans/20260818_194110_fix-abs-path-guard-false-positives.md`.

## Why

The pre-commit hook blocked a commit with 8 hits from `tool/check_absolute_paths.sh`.
None was a real local path. All 8 sit in the plans and change logs that describe the guard
itself, so they quote the patterns it looks for. Those four documents were written before
the guard existed, so they never carried its escape marker.

## What changed

Added the `<!-- allow-abs-path -->` marker to the 8 lines below. An HTML comment is
invisible in rendered markdown, so no document reads differently.

| File | Lines |
|---|---|
| `change_log/20260816_134500_strip-absolute-paths.md` | 39, 40 |
| `change_log/20260816_134815_absolute-path-guard-hook.md` | 24, 29 |
| `plans/20260816_133907_strip-absolute-paths.md` | 15 |
| `plans/20260816_134319_absolute-path-guard-hook.md` | 40, 42, 46 |

On the two table rows the marker went inside the last cell, before the closing `|`, so the
table still parses as a table.

## What did not change

The guard script and its pattern are untouched, so the rule is as strict as before. No
source code was touched, so no test run was needed.

## Verification

`sh tool/check_absolute_paths.sh --all` exits clean. The two new files added by this change
were also scanned by name and are clean.
