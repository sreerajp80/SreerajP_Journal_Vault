# Fix false positives from the absolute-path guard

**Status:** completed

## The issue

The pre-commit hook runs `tool/check_absolute_paths.sh`. The commit is blocked by 8 lines
in 4 files. None of them is a real local path. They are the plans and change logs that
*describe the guard itself*, so they quote the very patterns the guard looks for
(`file:///`, `/Users/`, `/home/`, `%USERPROFILE%`, and the `s:/` inside `https://`). <!-- allow-abs-path -->

The guard already has an escape for this: the text `allow-abs-path` in a comment on the
same line. `CLAUDE.md` already uses it for exactly this reason. These four files were
written before the guard existed, so they never got the marker.

## Files to change

| File | Lines |
|---|---|
| `change_log/20260816_134500_strip-absolute-paths.md` | 39, 40 |
| `change_log/20260816_134815_absolute-path-guard-hook.md` | 24, 29 |
| `plans/20260816_133907_strip-absolute-paths.md` | 15 |
| `plans/20260816_134319_absolute-path-guard-hook.md` | 40, 42, 46 |

## The fix

Append `<!-- allow-abs-path -->` to the end of each of those 8 lines. An HTML comment is
invisible when the markdown is rendered, so the documents read the same as before.

No wording is changed, no source code is touched, and the guard script itself is not
changed — the rule stays as strict as it is now.

## Verification

Run `sh tool/check_absolute_paths.sh --all` and expect a clean exit.

## Not doing

Weakening the pattern in `tool/check_absolute_paths.sh` (for example, ignoring paths
inside backticks). That would let a real leaked path slip through in a code span, which is
where a pasted path most often lands.
