# Update the `docs/guidelines` submodule to the latest guidelines

**Status:** completed

## Files to be changed

- `.gitmodules` — no change expected (only read).
- `docs/guidelines` — the submodule pointer moves from `d014cc8` to `aed1261`.
  This is recorded in the parent repo as a one-line gitlink change.

No source code, no `lib/`, no `docs/` file of this app is touched.

## What the issue is

The submodule `docs/guidelines` is pinned at `d014cc8` ("First Commit").
The shared guidelines repo (<https://github.com/sreerajp80/Flutter_Guidelines>)
has moved on by two commits:

- `4b7e85a` — "Changes"
- `aed1261` — "Features"

So this app is working against out-of-date shared rules. The incoming diff adds
three new guideline documents and edits several existing ones:

- New: `AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`
- Edited: `GUIDELINES_MANIFEST.md`, `README.md`, `guideline.md`,
  `flutter_project_engineering_standard.md`, `flutter_build_flavors_guide.md`,
  and two explainer READMEs under `docs/`
- Plus the guideline repo's own `plans/` and `change_log/` entries

Total: 23 files, ~1374 lines added.

## Plan for the fix

1. Confirm the submodule working tree is clean (it is — nothing modified inside it).
2. Move the submodule to the remote tip:
   `git submodule update --remote docs/guidelines`
3. Confirm the submodule now sits on `aed1261` and that no files inside it were
   edited locally.
4. Stage only the submodule pointer: `git add docs/guidelines`.
   The parent repo has many other uncommitted changes — those are left alone.
5. Commit only that pointer with a message saying which commit it moved to.
6. Read the three new guideline documents and the edited manifest, then report
   in plain English what new rules now apply to this app. No app files are changed
   as part of this plan; if the new rules require app changes, that becomes a
   separate plan.

## Risks

- Low. The change is a pointer move; it can be undone with
  `git checkout -- docs/guidelines` before commit, or by reverting the commit after.
- The new shared rules may conflict with this app's local overrides in `docs/`.
  Per `CLAUDE.md`, the local copy wins, so nothing breaks automatically — but any
  conflicts will be reported.
