# Update docs/guidelines submodule to latest

**Status:** completed

## Files to be changed

- `docs/guidelines` (submodule pointer only, `aed1261` -> `2b381be`)

No source files change. No file inside the submodule is edited (it is a separate repo).

## What the issue is

The `docs/guidelines` submodule is pinned to `aed1261`. Upstream
(`sreerajp80/Flutter_Guidelines`) has moved on by one commit, `2b381be` ("Update").
That commit adds two new mandatory rules and touches 8 files:

- `AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`
- `flutter_project_engineering_standard.md` and its README
- `guideline.md`
- two new rule docs about mandatory ARB string externalization (l10n) and about
  keeping local system details out of plans and change logs

Until we move the pointer, this app is working against stale guidelines.

## The plan for the fix

1. `git submodule update --remote docs/guidelines` to move the checkout to `2b381be`.
2. Confirm the submodule is clean and sits on the new commit.
3. Stage and commit the changed submodule pointer on its own, with a message naming the
   new commit. Nothing else gets staged — the working tree has many unrelated edits.

## Follow-up noted, not done here

The new upstream rules (mandatory ARB string externalization, and no local system details
in plans/change logs) may need work in this app. That is a separate plan, not part of this
pointer bump.
