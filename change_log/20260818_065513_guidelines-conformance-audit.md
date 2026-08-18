# Guidelines Conformance — Structure, Code and Docs

**Date:** 2026-08-18
**Implements:** [`../plans/20260818_060606_guidelines-conformance-audit.md`](../plans/20260818_060606_guidelines-conformance-audit.md)
**Result:** All four phases run. `flutter analyze` clean, **507 tests pass**, formatter clean,
absolute-path check clean. Two localization pockets left open on purpose — see section 6.

---

## 1. Phase 1 — root instruction files and README

| File | What changed |
|---|---|
| `CLAUDE.md` | Rewritten to the Thin-profile shape in `CLAUDE_MD_GUIDELINE.md` §4. Added all 11 missing "Always" sections: identity table, doc references, hard rules, architecture, build commands, flavors, signing, security, localization, code style, testing, dependencies, tree, workflow, communication, dos and don'ts. Kept the existing profile table, submodule notes and relative-path rule. |
| `AGENTS.md` | Was a short "Global Prompt Constraints" note. Rewritten to the Thin-profile shape in `AGENTS_MD_GUIDELINE.md` §4, carrying the same rules as `CLAUDE.md`. Nothing was lost: the old stack constraints became the identity table, and the "small testable slices" and "mark the prompt `[COMPLETED]`" rules became hard rules 6 and 7. |
| `README.md` | Rewritten against standard §21.3: prerequisites with versions, clean-clone setup, run and flavors, environment values, tests, code generation, adding a Drift migration, the release build, repository hygiene, and a documentation map. |
| `pubspec.yaml` | `description` changed from "A new Flutter project." to the real one, matching `assets/config/app_config.json`. |

## 2. Phase 2 — the `docs/` baseline set and naming

**Added** the five missing baseline documents from `DOCS_FOLDER_GUIDELINE.md` §6:

- `docs/workflow_rules.md` — plan → approve → log, the status values, the privacy rule with a
  bad → good table, and the Definition of Done.
- `docs/dependencies.md` — every package with why it is there and where it is used, the blocked
  list, the generated-code policy, and the held versions with their reasons (the `win32` /
  `file_picker` knot in one place).
- `docs/project_structure.md` — the repository and `lib/` trees, what each feature folder owns,
  the sub-folder rules, and a "where to put a new file" table.
- `docs/implementation_plan.md` — the V1/V2/V3 roadmap condensed from the product plan and the
  prompt list, plus the new post-V1 and conformance phases.
- `docs/implementation_progress.md` — the real status: V1 and V2 complete, V3 complete except
  sync transport, and every open item.

**Renamed** to lowercase `snake_case` (§3): `AI_Development_Prompts.md` → `ai_development_prompts.md`,
`SreerajP_Journal_Vault_Plan.md` → `journal_vault_plan.md`. Every reference was updated across
`docs/`, `plans/` and `change_log/` — 10 files. Plain `mv`, not `git mv`, because these two files
are not tracked (see section 5).

**Updated `docs/architecture.md`:** a new "Closed on 2026-08-18" table in section 21, new
"Still open" entries, the review date, section 22 split into local documents and submodule
documents, and two corrections found while reading — section 1 still said `release_process.md` and
`security.md` were "not yet filled in" when both were filled in on 2026-07-25, and section 4 listed
a `home` feature folder that does not exist while omitting `export` and `tags`.

## 3. Phase 3 — repository hygiene

| File | What changed |
|---|---|
| `.gitignore` | Added the six missing standard §20.4 entries: `*.apk`, `*.aab`, `*.ipa`, `*.msix`, `*.symbols/`, `.flutter-plugins`. |
| `.github/workflows/ci.yml` | New. Three jobs: analyze-and-test (pub get, build_runner, gen-l10n, format, analyze, test with coverage), privacy-check (the absolute-path scan), and build-dev (`--flavor dev --debug`). The signed `prod --release` job from §19.2 is written up in a comment but not enabled — with no keystore it would fall back to the debug key and produce an artifact that must not be distributed. |
| `CHANGELOG.md` | New, seeded with 1.0.1 and an Unreleased section. States plainly that nothing has been distributed yet. |
| `.githooks/pre-commit` | Now runs the formatter and the analyzer after the path check. Both are skipped when Flutter is not on `PATH`, so a docs-only clone can still commit. Also fixed a latent bug: the path check's exit status was not being propagated, so a failure would not have stopped the commit once more steps were added after it. |
| `tools/` → `tool/` | The two Python icon scripts moved into `tool/`, `tools/` removed, and the usage line inside `gen_app_icon.py` corrected. |

## 4. Phase 4 — localization

The largest piece. Nothing in `lib/` read a translated string before this.

**Set up:**

- `l10n.yaml` at the project root — `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  `output-class: AppLocalizations`, `nullable-getter: false`. Standard §8.1 also lists
  `synthetic-package: false`; Flutter 3.44 has removed that option and warns on every `pub get`, so
  `output-dir: lib/l10n` says the same thing instead. The reason is written into the file.
- `pubspec.yaml`: added `intl: ^0.20.2` and `flutter: generate: true`.
- `lib/l10n/app_en.arb` — **372 keys**, every one with an `@key` description, as §8.2 requires.
- `AppLocalizations.delegate` added to `MaterialApp`, `supportedLocales` now comes from
  `AppLocalizations`, and the hard-coded `title: 'Journal Vault'` became `onGenerateTitle`.

**Converted** every string a widget renders, in 20 files:

| Area | Files |
|---|---|
| About, permissions, tags | 3 |
| Timeline, insights | 2 |
| Import, attachment viewers | 4 |
| Security, sync | 5 |
| Backup | 2 |
| Entry editor and its widgets | 5 |
| App shell and all of settings | `lib/app/app.dart`, ~2,950 lines |

Two literals remain in widgets and are correct: `Text('$conflictCount')` and
`Text('#${tag.name}')`. Both are pure data with no words in them.

**Along the way:**

- Database codes that were being shown to the user by capitalising them — backup `trigger`,
  `status` and `interval`, the attachment migration status, the callout `type` — now go through a
  small mapping function to a translated label. Capitalising a stored code was never right.
- `BackupScheduleSettings.intervalDisplayName` was deleted. A service must not build text for the
  user, and after the mapping moved to the UI nothing called it.
- Byte and timeout formatters now take an `AppLocalizations` and return translated units.

**Tests:** the seven test files that build their own `MaterialApp` now pass
`AppLocalizations.localizationsDelegates` and `supportedLocales`. Without them
`AppLocalizations.of(context)` throws, because `nullable-getter: false` makes it a null check.
No test assertion was changed.

One UI string was almost changed by accident and put back: the theme subtitle reads
"Choose how SreerajP_Journal_Vault looks." with underscores. Rewriting it to spaces would have
been an unrequested copy change, and `widget_test.dart` caught it.

## 5. Found while working, not fixed

Two things turned up that the plan did not anticipate. Both are recorded in
`docs/architecture.md` section 21 and `docs/implementation_progress.md`, and neither was changed,
because both are decisions for the repository owner:

- **`plans/`, `change_log/`, and four `docs/` files are not tracked by git.** Standard §21.1 lists
  `plans/` and `change_log/` as required documents, and the §21.1.1 privacy rule exists precisely
  because they are committed. Today they only exist on disk. Untracked: all of `plans/`, all of
  `change_log/`, and `ai_development_prompts.md`, `journal_vault_plan.md`, `enhancement_ideas.md`,
  `features.md`.
- **`plans/Remediation_Plan.md`** does not use the required `yyyymmdd_hhMMss_<slug>.md` name.
  Renaming it would break the change logs that reference it by name, so it needs its own small task.

## 6. Deliberately left open

Two pockets of user-visible text are still Dart literals. Both need real refactors, not a
find-and-replace, so they were kept out rather than half-done:

- **`lib/features/entries/templates/entry_templates.dart`** — 46 entry templates, each with a
  label, description, default title and a whole prefilled document. Roughly 190 short strings plus
  46 documents, held in a `const` catalogue that providers read. Moving it to ARB means
  restructuring the catalogue into a context-dependent lookup as well. The first question is
  whether template bodies are UI text or seeded content.
- **`lib/features/export/export_strings.dart`** — half of it is exported-document content written
  by renderers that have no `BuildContext`; the other half is messages produced in
  `export_service.dart` and `html_pdf_service.dart` that only later reach a snackbar. Closing the
  second half needs an error model: `ExportOmission` carrying a reason enum instead of a sentence,
  typed PDF exceptions, and a mapping in `export_screen.dart`. The file's own doc comment now
  records exactly this, replacing the older note that assumed a simple extraction.

## 7. Verification

```powershell
flutter analyze                                               # No issues found
flutter test                                                  # 507 passed, 0 failed
dart format --set-exit-if-changed lib test integration_test   # 166 files, 0 changed
sh tool/check_absolute_paths.sh --all                         # clean
flutter gen-l10n                                              # regenerates cleanly
```

Not run: a device build. The change touches no build, signing, or native code, and CI now runs the
`dev --debug` build on every push.
