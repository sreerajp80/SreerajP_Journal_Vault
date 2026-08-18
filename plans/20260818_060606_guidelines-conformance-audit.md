# Guidelines Conformance — Structure, Code and Docs

**Status:** completed

**Date:** 2026-08-18

**Scope:** Audit the whole repository against the guideline documents in `docs/guidelines/`
(as indexed by [`docs/GUIDELINES_MANIFEST.md`](../docs/GUIDELINES_MANIFEST.md)), then fix the
gaps. All three applicability profiles are in force: `Core Baseline`,
`Production App Extension`, `Sensitive Data Extension`.

---

## 1. What the audit found

I read `guideline.md`, `flutter_project_engineering_standard.md`, `DOCS_FOLDER_GUIDELINE.md`,
`CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md`, then checked the repository against them.

### 1.1 Already compliant — no change needed

| Rule | Where | Result |
|---|---|---|
| Tier 2 feature-first `lib/` layout | standard §3.1 | `lib/app/`, `lib/core/`, `lib/features/`, thin `main.dart` — matches |
| About-screen config pattern | `guideline.md` §1 | `assets/config/app_config.json` + `lib/core/config/app_config.dart` + `config_service.dart`, About screen loops `details` — matches, class names and paths exact |
| `assets/config/` registered | `guideline.md` §1.3 | present in `pubspec.yaml` |
| Keystore and secrets ignored | `guideline.md` §2.3 | `.gitignore` covers `key.properties`, `*.jks`, `*.keystore` |
| Analyzer rule set | standard §16.1 | `analysis_options.yaml` matches the recommended baseline rule for rule |
| `test/` mirrors `lib/` | standard §3.2 | 55 test files under a mirrored tree |
| `plans/` and `change_log/` exist | standard §21.1 | 22 plans, 21 change logs, plus a path-privacy pre-commit hook |
| Local blueprints filled in | `DOCS_FOLDER_GUIDELINE.md` §2 | `docs/architecture.md`, `docs/security.md`, `docs/release_process.md` are real local copies, not copied-down reference docs |
| Localization delegates wired | standard §8.1 | `localizationsDelegates` and `supportedLocales` are present in `lib/app/app.dart` |

### 1.2 Gaps found

Numbered so we can talk about them one at a time.

**G1 — Localization is missing (Core Baseline MUST).**
Standard §8.1/§8.2 and `guideline.md` §3 both make this mandatory for **every** app, including
single-language ones.

- `l10n.yaml` does not exist at the project root.
- `lib/l10n/` does not exist, so there is no `app_en.arb`.
- `pubspec.yaml` has no `flutter: generate: true`.
- No file in `lib/` imports `AppLocalizations`.
- Rough count of user-visible literals to move: **211** `Text('…')` plus **58**
  `labelText:` / `hintText:` / `title:` / `tooltip:` style literals, across about 20 files.

This gap is not listed in `docs/architecture.md` §21, so today it is invisible.

**G2 — `AGENTS.md` does not follow `AGENTS_MD_GUIDELINE.md`.**
The current file is a short "Global Prompt Constraints" note. The guideline requires a Thin-profile
file with these "Always" sections, none of which are present: read-first banner, project identity
table, doc references table, architecture rules, build and run commands, security rules,
localization rule, code style, testing rules, dependency constraints, where things live, workflow
rules (plan → approve → log), and communication rules. It also requires `AGENTS.md` and `CLAUDE.md`
to carry the same rules.

**G3 — `CLAUDE.md` is missing most required sections.**
`CLAUDE_MD_GUIDELINE.md` §3 marks these as "Always", and they are absent: project identity table,
doc references table, architecture rules, build and run commands, security rules, localization
rules, code style, testing rules, where things live, workflow rules, and communication rules.
What is there today (guidelines pointer, profile table, submodule notes, relative-path rule) is
good and will be kept.

**G4 — The `docs/` baseline set is incomplete.**
`DOCS_FOLDER_GUIDELINE.md` §6 requires 8 baseline documents. Five are missing:
`workflow_rules.md`, `dependencies.md`, `project_structure.md`, `implementation_plan.md`,
`implementation_progress.md`.

**G5 — Two `docs/` files break the naming rule.**
`DOCS_FOLDER_GUIDELINE.md` §3 requires lowercase `snake_case`.

- `docs/AI_Development_Prompts.md` → `docs/ai_development_prompts.md`
- `docs/SreerajP_Journal_Vault_Plan.md` → `docs/journal_vault_plan.md`

**G6 — `README.md` is still mostly the stock Flutter template.**
Standard §21.3 requires prerequisites with versions, clean-clone setup, how to run tests, how to
run `build_runner`, per-platform build commands, how to add a database migration, and any
`--dart-define` values. Only the submodule and hook setup is there today; the rest is boilerplate,
and the description line still says "A new Flutter project."

**G7 — `pubspec.yaml` description is stale.**
`description: "A new Flutter project."` It should match the real description already written in
`assets/config/app_config.json`.

**G8 — `.gitignore` is missing entries from standard §20.4.**
Missing: `*.apk`, `*.aab`, `*.ipa`, `*.msix`, `*.symbols/`, `.flutter-plugins`.

**G9 — No CI (standard §19, Production App Extension).**
There is no `.github/workflows/` folder. §19.1 is a SHOULD, and §23.2 ("required CI checks pass")
assumes CI exists for a Production-profile app.

**G10 — No `CHANGELOG.md`.** Standard §21.2, recommended.

**G11 — Two similarly named tool folders.**
`tool/` holds `check_absolute_paths.sh`; `tools/` holds two Python icon scripts. Neither folder is
in the recommended root layout, and the near-identical names are easy to confuse.

**G12 — The gap list in `docs/architecture.md` §21 is out of date.**
It does not mention G1, G2, G3 or G4. That list is the app's honest record, so it must name them.

**G13 — The pre-commit hook does not run format or analyze.**
Standard §19.3 recommends `dart format --set-exit-if-changed` and `flutter analyze` in the hook.
Today the hook only checks for absolute paths.

### 1.3 Deliberately not in scope

- `lib/app/app.dart` at 2,949 lines. Already recorded in `docs/architecture.md` §21 as its own
  deferred refactor. It needs a separate plan.
- Everything else already open in `docs/architecture.md` §21 (release keystore, R8 runtime check,
  delete-all-data, crypto version byte, sync transport, and so on). This plan is about guideline
  conformance, not those product gaps.

---

## 2. The plan

The work is split into phases so each one is small and testable. Phases 1 to 3 are documentation
and repository hygiene, and carry no runtime risk. Phase 4 is the large code change.

### Phase 1 — Root instruction files and README (G2, G3, G6, G7)

| File | Change |
|---|---|
| `CLAUDE.md` | Rewrite to the Thin-profile template in `CLAUDE_MD_GUIDELINE.md` §4. Keep the existing profile table, submodule notes and relative-path rule as sections. Add every "Always" section. |
| `AGENTS.md` | Rewrite to the Thin-profile template in `AGENTS_MD_GUIDELINE.md` §4, carrying the same rules as `CLAUDE.md`. Move the existing stack constraints into the identity table and the hard-rules section so nothing is lost. |
| `README.md` | Rewrite to cover standard §21.3: prerequisites, clean-clone setup, tests, `build_runner`, build commands per flavor, how to add a Drift migration, and `--dart-define` values. Keep the submodule and hook section. |
| `pubspec.yaml` | Replace the stock `description` with the real one. |

### Phase 2 — The `docs/` baseline set and naming (G4, G5, G12)

| File | Change |
|---|---|
| `docs/workflow_rules.md` | New. Plan → approve → log, mirroring the global rules. |
| `docs/dependencies.md` | New. Every package in `pubspec.yaml`, why it is there, and the blocked list. Records the existing `win32` / `file_picker` version knot in one place. |
| `docs/project_structure.md` | New. The file tree and what each folder owns. |
| `docs/implementation_plan.md` | New. Point-in-time, with a `**Date:**` header. Built from the phase list already in the product plan and the prompt list. |
| `docs/implementation_progress.md` | New. Point-in-time, with a `**Date:**` header. A checklist of completed, partial and open prompts. |
| `docs/AI_Development_Prompts.md` | Rename to `docs/ai_development_prompts.md` with `git mv`. |
| `docs/SreerajP_Journal_Vault_Plan.md` | Rename to `docs/journal_vault_plan.md` with `git mv`. |
| links to the two renamed files | Update every reference in `docs/`, `plans/`, `change_log/`, `AGENTS.md` and `CLAUDE.md`. |
| `docs/architecture.md` | Add G1 to G4 to the §21 gap list, and list the new files in §22. |

> Note on the renames: `plans/` and `change_log/` are a historical record. I will fix the links
> inside them so they still resolve, but I will not rewrite their text.

### Phase 3 — Repository hygiene (G8, G9, G10, G11, G13)

| File | Change |
|---|---|
| `.gitignore` | Add `*.apk`, `*.aab`, `*.ipa`, `*.msix`, `*.symbols/`, `.flutter-plugins`. |
| `.github/workflows/ci.yml` | New. The §19.1 minimum checks (pub get, build_runner, format, analyze, test) plus the §19.2 production build steps. |
| `CHANGELOG.md` | New. Seeded with `1.0.1`. |
| `.githooks/pre-commit` | Add `dart format --set-exit-if-changed lib test integration_test` and `flutter analyze --no-pub` after the existing path check. |
| `tools/` → `tool/` | Move the two Python scripts into `tool/` so there is one tool folder, and update any reference to them. |

Note on the CI release build: the release keystore does not exist yet (see `docs/architecture.md`
§21), so a `prod --release` build in CI would fall back to the debug key. The workflow will run
format, analyze, test and the `dev --debug` build now, with the signed release steps written in but
commented, and a note pointing at the keystore gap.

### Phase 4 — Localization (G1) — the big one

This is the only phase that touches app code. It is mechanical but wide.

1. Add `flutter: generate: true` and `intl` to `pubspec.yaml`.
2. Add `l10n.yaml` at the project root, exactly as standard §8.1 shows
   (`arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-class: AppLocalizations`,
   `nullable-getter: false`, `synthetic-package: false`).
3. Create `lib/l10n/app_en.arb`, with an `@key` description for every key.
4. Move the user-visible strings file by file, in this order, running `flutter test` after each
   group:
   1. `lib/features/about/`, `lib/features/permissions/`, `lib/features/tags/` (small, low risk)
   2. `lib/features/timeline/`, `lib/features/insights/`, `lib/features/search/`
   3. `lib/features/import/`, `lib/features/export/`, `lib/features/backup/`
   4. `lib/features/journal_lock/`, `lib/features/lock_gate/`, `lib/features/security/`
   5. `lib/features/entries/` (largest feature — the editor)
   6. `lib/app/app.dart` (largest single file — the shell and all of settings)
5. Keep literals only where §8.2 allows them: log messages, non-UI exception messages, asset paths,
   route names, and map or JSON keys.
6. Update the tests that match on literal text so they read the same ARB value, keeping the tests
   honest.
7. Update `docs/architecture.md` §16 and the localization sections of `CLAUDE.md` and `AGENTS.md`.

**Risk:** widget tests find widgets by their visible text. Around 55 test files may need touching.
That is why this phase is last and is split into six groups.

---

## 3. Verification

After each phase:

```powershell
flutter analyze
flutter test
dart format --set-exit-if-changed lib test integration_test
sh tool/check_absolute_paths.sh --all
```

After Phase 4, also:

```powershell
flutter gen-l10n
flutter build apk --flavor dev --debug
```

Definition of Done for this work, from standard §23.1: the analyzer is clean, tests pass, the
formatter reports nothing, `l10n.yaml` and `lib/l10n/app_en.arb` exist with every user-visible
string read from `AppLocalizations`, and no secrets or local paths were added.

---

## 4. Full list of files to be changed

**Rewritten:** `CLAUDE.md`, `AGENTS.md`, `README.md`

**Edited:** `pubspec.yaml`, `.gitignore`, `.githooks/pre-commit`, `docs/architecture.md`, plus
every Dart file in `lib/` that holds a user-visible string (about 20 files) and the tests that
assert on that text.

**New:** `l10n.yaml`, `lib/l10n/app_en.arb`, `CHANGELOG.md`, `.github/workflows/ci.yml`,
`docs/workflow_rules.md`, `docs/dependencies.md`, `docs/project_structure.md`,
`docs/implementation_plan.md`, `docs/implementation_progress.md`

**Renamed or moved:** `docs/AI_Development_Prompts.md`, `docs/SreerajP_Journal_Vault_Plan.md`,
`tools/gen_app_icon.py`, `tools/preview_adaptive.py`

---

## 5. Approval

Phases 1 to 3 are documentation and hygiene: low risk, and they close every `MUST` except
localization. Phase 4 is a wide code change and can be approved separately.

Please say which phases to run.
