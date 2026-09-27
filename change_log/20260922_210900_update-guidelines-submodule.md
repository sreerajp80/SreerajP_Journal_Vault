# Update Guidelines Submodule

**Plan:** `plans/20260922_210900_update-guidelines-submodule.md`

## What changed

- Updated the `docs/guidelines` Git submodule pointer to commit `eb4b4629e4e0c849d5e60176daa8bb3f1509a6cd` on remote branch `master`.
- The update pulls in:
  - Updates to `guideline.md` clarifying that display fields (`appName`, `author`, `aiUsed`, and `ideUsed`) in `app_config.json` must provide localized maps with script transliterations.
  - Updates to `AppConfig` code example in `guideline.md` reflecting `LocalizedText` for `appName`.
  - Checklist item in `AGENTS_MD_GUIDELINE.md` and `CLAUDE_MD_GUIDELINE.md` stating that localization rules must explicitly specify English, Malayalam, and Sanskrit.

## Verification

- Ran `git submodule update --remote docs/guidelines` which completed with exit code 0.
- Ran `git submodule status` and `git diff docs/guidelines` confirming the submodule commit advanced from `7ed5a36` to `eb4b462`.
