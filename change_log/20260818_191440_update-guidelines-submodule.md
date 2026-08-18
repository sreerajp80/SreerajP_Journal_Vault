# Change log — update docs/guidelines submodule to latest

Implements `plans/20260818_190630_update-guidelines-submodule.md`.

## What changed

- `docs/guidelines` submodule pointer moved from `aed1261` to `2b381be` ("Update").
- Committed as `58c3834` on `master`. Only the submodule pointer was staged; the many
  unrelated working-tree edits were left untouched.

## What the new upstream commit brings

Eight files changed upstream (369 insertions, 34 deletions):

- `AGENTS_MD_GUIDELINE.md`
- `CLAUDE_MD_GUIDELINE.md`
- `DOCS_FOLDER_GUIDELINE.md`
- `flutter_project_engineering_standard.md` and its README
- `guideline.md`
- two new rule documents:
  - mandatory ARB string externalization (all user-facing strings go through l10n)
  - no local system details in plans and change logs

## Verification

- Submodule working tree is clean and sits on `2b381be`.
- `git diff --cached --name-only` before the commit listed only `docs/guidelines`.

## Follow-up still open

The two new mandatory rules have not been applied to this app yet. Checking this app
against the ARB string externalization rule needs its own plan and its own change log.
