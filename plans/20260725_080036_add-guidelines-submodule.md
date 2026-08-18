# Add Flutter Guidelines as a Git submodule

**Status:** completed

## What is the issue

The app folder `SreerajP_Journal_Vault/` already has `docs/GUIDELINES_MANIFEST.md`. That manifest
says the shared guideline documents must live at `docs/guidelines/`, added as a Git submodule.

Right now:

- `docs/guidelines/` does not exist, so every path in the manifest is broken.
- Nothing in this workspace is a Git repository. `git init` has never been run in the parent
  folder above the app, nor in the app folder `SreerajP_Journal_Vault/` itself.
  So `git submodule add` cannot run at all.
- There is no `CLAUDE.md` in the app folder, so step 3 of the manifest ("reference it from the
  app's CLAUDE.md") is also not done.

Submodule URL to use: `https://github.com/sreerajp80/Flutter_Guidelines`

## Decision already made

The user chose: **`git init` first, then add the submodule.** The repository root will be the
Flutter app folder `SreerajP_Journal_Vault/` (it already has its own `.gitignore` and
`pubspec.yaml`, so it is the natural repo root). The parent folder above the repository root
stays outside Git.

## Files to be changed

| File | Change |
|---|---|
| `SreerajP_Journal_Vault/.git/` | New. Created by `git init`. |
| `SreerajP_Journal_Vault/.gitmodules` | New. Records the submodule path and URL. |
| `SreerajP_Journal_Vault/docs/guidelines/` | New. The submodule content, cloned from GitHub. |
| `SreerajP_Journal_Vault/CLAUDE.md` | New. Points at `docs/GUIDELINES_MANIFEST.md`. |
| `SreerajP_Journal_Vault/.gitignore` | Read only — checked to be sure it does not exclude `docs/`. |
| `plans/20260725_080036_add-guidelines-submodule.md` | This plan. |
| `change_log/20260725_<time>_add-guidelines-submodule.md` | New. Written after the work is done. |

No existing project file is edited or deleted.

## The plan

1. **Check `.gitignore`.** Read `SreerajP_Journal_Vault/.gitignore` and confirm it does not
   ignore `docs/` or `docs/guidelines/`. If it does, report it and stop before step 3.
2. **Initialise the repository.**
   ```
   git init SreerajP_Journal_Vault
   ```
   Default branch will be whatever the local Git config gives. No remote is added — this plan
   does not push anything anywhere.
3. **Make one first commit.** `git submodule add` needs a working index. Stage the existing app
   files and commit them as the starting point. This is a purely local commit.
4. **Add the submodule.**
   ```
   git submodule add https://github.com/sreerajp80/Flutter_Guidelines docs/guidelines
   ```
   This clones the repo into `docs/guidelines/` and writes `.gitmodules`.
5. **Verify the manifest paths resolve.** Check that these files now exist:
   - `docs/guidelines/guideline.md`
   - `docs/guidelines/flutter_project_engineering_standard.md`
   - `docs/guidelines/architecture.md`
   - `docs/guidelines/flutter_build_flavors_guide.md`
   - `docs/guidelines/release_process.md`
   - `docs/guidelines/security.md`
   - `docs/guidelines/README.md`
   - the five explainers under `docs/guidelines/docs/`

   Report any path in the manifest that does not exist in the real repo.
6. **Create `CLAUDE.md`** at the app root with a short rule: follow the guidelines listed in
   `docs/GUIDELINES_MANIFEST.md`, and prefer a local copy in `docs/` over the submodule copy
   when both exist (that is the manifest's own "local copy wins" rule).
7. **Commit the submodule and `CLAUDE.md`** locally.
8. **Write the change log** to `change_log/` and set this plan's status to `completed`.

## Things to be aware of

- **Network.** Steps 4 needs internet access to GitHub. If the clone fails, nothing else in the
  plan can finish; I will report the error rather than work around it.
- **Nothing is pushed.** All commits stay on this machine. No remote is configured, so there is
  no risk of publishing anything.
- **The applicability profile is not decided here.** The manifest asks which profile the app is
  in (`Core Baseline` / `Production App Extension` / `Sensitive Data Extension`). A journal app
  with a local encrypted store would likely be all three, but that is a separate decision and is
  out of scope for this plan.

## Do you approve this plan?
