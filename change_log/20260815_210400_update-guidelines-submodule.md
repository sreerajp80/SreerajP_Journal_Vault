# Change log — update the `docs/guidelines` submodule

Implements `plans/20260815_205723_update-guidelines-submodule.md`.

## What was changed

- `docs/guidelines` submodule pointer moved from `d014cc8` ("First Commit") to
  `aed1261` ("Features"), picking up two upstream commits.
- Committed as `563ef08`, one file changed (the gitlink only). All other
  uncommitted work in the tree was left untouched.

Nothing else was modified. No app source, no `lib/`, no local `docs/` file.

## What the update brings in

Three new shared documents:

- `AGENTS_MD_GUIDELINE.md` — how to write the project-root `AGENTS.md` (MUST).
- `CLAUDE_MD_GUIDELINE.md` — how to write the project-root `CLAUDE.md` (MUST).
- `DOCS_FOLDER_GUIDELINE.md` — how to create files in a project's `docs/` folder.

Rule changes in the existing documents:

- Root `CLAUDE.md` and root `AGENTS.md` are now **Core Baseline MUSTs**, not just
  "recommended". They moved out of the recommended list in the engineering standard.
- `plans/` and `change_log/` are now **required** documents in the engineering
  standard's project layout, and must use **relative repository paths only** and
  hold **no sensitive data** (keys, passwords, local absolute paths, internal IPs).
- Writing a plan and getting explicit user approval before changing files is now
  written into the engineering standard itself (section 22.1).
- The Definition of Done gained an item: plans and change logs must be safe to
  share publicly.
- The flavors guide moved its baseline from Flutter 3.41 / Dart 3.11 to
  Flutter 3.44 / Dart 3.12.
- `assets/config/`, `plans/`, `change_log/` and `CLAUDE.md` were added to the
  reference project tree.

## Gaps this opens for this app (not fixed here)

1. The local `docs/GUIDELINES_MANIFEST.md` is an older copy and does not list the
   three new documents. Because the local copy wins for this app, the new
   documents are effectively invisible until the local manifest is refreshed.
2. Three existing files under `plans/` and `change_log/` contain absolute local
   paths, which the new rule forbids:
   - `plans/20260725_085907_close-profile-gaps.md`
   - `plans/20260725_080036_add-guidelines-submodule.md`
   - `change_log/20260725_080227_add-guidelines-submodule.md`
3. Root `CLAUDE.md` and `AGENTS.md` both exist, but have not been checked against
   the new `CLAUDE_MD_GUIDELINE.md` / `AGENTS_MD_GUIDELINE.md` rules.

Each of these needs its own plan.
