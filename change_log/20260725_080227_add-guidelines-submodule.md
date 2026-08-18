# Change log — Add Flutter Guidelines as a Git submodule

**Date:** 2026-07-25 08:02 (local time)
**Implements:** [`plans/20260725_080036_add-guidelines-submodule.md`](../plans/20260725_080036_add-guidelines-submodule.md)

## Why

`SreerajP_Journal_Vault/docs/GUIDELINES_MANIFEST.md` pointed at guideline documents under
`docs/guidelines/`, but that folder did not exist, so every path in the manifest was broken.
Nothing in the workspace was under Git either, so the submodule could not be added until a
repository existed.

## What was done

1. **Checked `.gitignore`.** Confirmed `SreerajP_Journal_Vault/.gitignore` does not exclude
   `docs/` or `docs/guidelines/`. Safe to proceed.
2. **Created the Git repository.** Ran `git init` in `SreerajP_Journal_Vault/`. The Flutter app
   folder is the repository root. The parent folder above it stays outside Git.
   Default branch is `master`.
3. **Made a baseline commit** (`5fc1dbc`, "Initial commit of SreerajP Journal Vault") — 272 files,
   47,022 lines. This was needed because `git submodule add` requires a working index.
4. **Added the submodule.**
   ```
   git submodule add https://github.com/sreerajp80/Flutter_Guidelines docs/guidelines
   ```
   The clone succeeded. Submodule is pinned at commit `d014cc8` on branch `master`.
5. **Verified all manifest paths.** All 12 paths listed in the manifest exist in the cloned repo —
   the 7 core documents and the 5 plain-English explainers. Nothing was missing.
6. **Created `SreerajP_Journal_Vault/CLAUDE.md`.** This was step 3 of the manifest's own
   instructions and had never been done. It points at the manifest, states the "local copy wins"
   rule, and records the submodule commands (`git submodule update --init --recursive` after a
   fresh clone, `git submodule update --remote docs/guidelines` to pull newer guidelines).
7. **Committed** the submodule pointer, `.gitmodules`, and `CLAUDE.md` (`9f6f49c`). The working
   tree is clean.

## Files added

| File | Note |
|---|---|
| `SreerajP_Journal_Vault/.git/` | New local repository. |
| `SreerajP_Journal_Vault/.gitmodules` | Records `docs/guidelines` → the GitHub URL. |
| `SreerajP_Journal_Vault/docs/guidelines/` | Submodule content, pinned at `d014cc8`. |
| `SreerajP_Journal_Vault/CLAUDE.md` | Project rules pointing at the manifest. |

No existing project file was edited or deleted.

## Things worth knowing

- **Nothing was pushed.** No remote is configured on the new repository. Both commits are local
  only. Adding a remote and pushing is a separate decision.
- **Line endings.** Git printed many "LF will be replaced by CRLF" warnings during the first
  commit. That is normal on Windows with `core.autocrlf=true`. Files are stored with LF in Git and
  checked out with CRLF. If mixed line endings become annoying later, add a `.gitattributes`.
- **The two manifest copies are identical.** `docs/GUIDELINES_MANIFEST.md` and
  `docs/guidelines/GUIDELINES_MANIFEST.md` have the same content today, so the "local copy wins"
  rule makes no practical difference right now.
- **Still open — the applicability profile.** The manifest asks which profile this app is in
  (`Core Baseline`, `Production App Extension`, `Sensitive Data Extension`). This was declared out
  of scope in the plan and has not been decided. Given the app has encrypted attachments, a PIN
  and biometric lock, and a keystore, it likely falls in all three, but that needs a real decision.
