# Strict Guidelines Conformance — Docs First, Then Code And Structure

**Status:** completed

**Date:** 2026-09-15

**Approved:** 2026-09-15, all phases. Decision 1 = (a) write all Sanskrit; Decision 2 = (a) scripted
key rename; Decision 3 = (b) split all 20 files over 500 lines.

**Scope:** Bring the whole repository into strict conformance with `docs/guidelines/` at submodule
commit `7ed5a36`. Docs first, then code and structure. All three applicability profiles are in
force: `Core Baseline`, `Production App Extension`, `Sensitive Data Extension`.

---

## 1. Why this is needed

The last full audit
([20260818_060606_guidelines-conformance-audit.md](20260818_060606_guidelines-conformance-audit.md))
was done against guideline commit `2b381be`. The submodule pointer has since moved to `7ed5a36`.
Three guideline commits landed in between (2026-09-03 and 2026-09-13). They add about 2,500 lines of
new rules. The biggest ones:

1. **Three mandatory languages** — English, Malayalam **and Sanskrit** — with key parity, an in-app
   language picker, a Sanskrit framework-delegate fallback, and an `intl` formatting fallback.
2. **Sanskrit and Malayalam quality rules** — a Hindi-marker gate, a standard UI glossary, and a
   fluent-reader review rule.
3. **Short-label budget** and an **ARB key prefix convention** (`action…`, `label…`, `title…`,
   `tab…`, `nav…`, `tooltip…` vs `desc…`, `help…`, `empty…`, `error…`, `body…`, `aboutDetail…`).
4. **Tooltips are a hard rule** on every icon-only control (§7.8).
5. **About screen** — localized config (`LocalizedText`, lowerCamelCase detail keys,
   `aboutDetail<Key>` labels) and the fixed **"Made with ❤️ from India"** badge (`guideline.md` §1.7).
6. **Play Store readiness gate** (`release_process.md` §9A), including
   `bundle.language.enableSplit = false`.
7. **Release hardening additions** — allowBackup, cleartext traffic, asset leak audit, exported
   component audit (`release_process.md` §6.4–§6.7), PowerShell build commands (`guideline.md` §2.4).
8. **Translation parity test** and **label length test** required in every app (§8.6, §8.7).

---

## 2. What the audit found

### 2.1 Already compliant — no change needed

| Rule | Evidence |
|---|---|
| Tier 2 feature-first layout, thin `main.dart` | unchanged since last audit |
| `l10n.yaml`, `app_en.arb`, `app_ml.arb`, `generate: true` | present; 1,026 keys in both files, zero missing, every key has `@key` |
| `android:allowBackup="false"` | `android/app/src/main/AndroidManifest.xml` |
| Cleartext traffic | minSdk 28 means cleartext is off by default; no network security config |
| Release flags `--obfuscate --split-debug-info --split-per-abi` | documented and used |
| CI, pre-commit hook, `CHANGELOG.md`, `.gitignore` | present from last audit |
| Malayalam font bundled | `assets/fonts/NotoSansMalayalam-*.ttf` with OFL |

### 2.2 Gaps — documentation (Phase 1)

| # | Gap | Rule |
|---|---|---|
| D1 | `CLAUDE.md` and `AGENTS.md` localization block still says two languages; missing the triad, Sanskrit-not-Hindi, picker, short-label, tooltip and About-badge rules | `CLAUDE_MD_GUIDELINE.md` / `AGENTS_MD_GUIDELINE.md` template + self-check |
| D2 | `docs/GUIDELINES_MANIFEST.md` is an old copy — no `CLAUDE_MD_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md` rows; old profile table | submodule `GUIDELINES_MANIFEST.md` |
| D3 | `docs/release_process.md` has no §6.4 allowBackup check, no §6.5 cleartext, §6.6 asset audit, §6.7 exported audit; no Localization checklist; no §9A Play readiness gate; no App Bundle command; no PowerShell commands | `release_process.md`, `guideline.md` §2.4 |
| D4 | `docs/architecture.md` §16 and §21 do not record Sanskrit, the picker, fonts, the badge, tooltips, or Play readiness; minSdk 28 decision not recorded as §9A.2 asks; §1 still names the old guideline commit | standard §8, `release_process.md` §9A.2 |
| D5 | `docs/security.md` OWASP / manifest checklist lacks the exported-component and asset-leak checks | `release_process.md` §6.6–§6.7 |
| D6 | `docs/workflow_rules.md` Definition of Done lacks the new §23.1 items (three-language parity, Sanskrit gate, label budget, tooltips, all-locale check, badge) and §23.2 Play gate | standard §23 |
| D7 | `docs/dependencies.md` does not record the Devanagari font or font script-coverage rule | standard §17.4 |
| D8 | `docs/project_structure.md`, `docs/implementation_progress.md`, `README.md` do not show the new files/tests/scripts | `DOCS_FOLDER_GUIDELINE.md` |

### 2.3 Gaps — code and structure (Phases 2–7)

| # | Gap | Rule | Size |
|---|---|---|---|
| C1 | No `app_sa.arb`; `supportedLocales` is `en`, `ml` only | standard §8.1–§8.3 | **1,026 keys to translate into Sanskrit** |
| C2 | No Sanskrit Material/Cupertino/Widgets fallback delegates; `quill_localizations_fallback.dart` must also answer for `sa` | §8.3.1 | small |
| C3 | No `formattingLocale(...)`; `template_token_engine.dart` passes the raw locale to `DateFormat` (14 calls) — throws under `sa` | §8.3.2, §8.9 | small |
| C4 | No Devanagari font — Sanskrit would render as boxes on some devices | §8.3.3, §17.4 | add Noto Sans Devanagari (OFL) + `fontFamilyFallback` |
| C5 | **No in-app language picker**; no `app_language` preference; no `localeResolutionCallback` | §8.4 | medium |
| C6 | 36 `app_ml.arb` values equal English; some are real untranslated text (`entryDeleteBody`, `syncHealthTitle`, `syncStatusFailed`, `permissionStatusRow`, …), the rest are pure format strings (`{bytes} B`) | §8.2, §8.7 | fix text ones; allow-list format-only ones |
| C7 | ARB keys use feature prefixes (`syncHealthTitle`), not the §8.6 category prefixes, so the length budget cannot be enforced | §8.6 | **1,026 keys renamed across `lib/`, `test/`** — see Decision 2 |
| C8 | About config: plain English strings, Title Case keys (`"AI Used"`), `Map<String, String>`; no `LocalizedText`; no `aboutDetail<Key>` labels | `guideline.md` §1.2, §1.4, §1.6 | small |
| C9 | **No "Made with ❤️ from India" badge** | `guideline.md` §1.7 | small |
| C10 | 14 icon-only controls without a tooltip, plus 1 literal tooltip | §7.3, §7.8 | small |
| C11 | Built-in ritual thought cards (50) carry `en` + `ml` text in code; no `sa`. No database change needed — the text lives in `lib/features/ritual/domain/ritual_card.dart` | §8.7 | 50 cards × title/prompt/quote |
| C12 | Two literal pockets still open from last audit: `entry_templates.dart` (46 templates, ~52 labels + bodies) and `export_strings.dart` | §8.2, §8.7 | large — needs restructure |
| C13 | No `bundle { language { enableSplit = false } }` in `android/app/build.gradle.kts` | §8.1, `release_process.md` §9A.3 | one block |
| C14 | No tests: `translation_parity_test.dart`, `label_length_test.dart`, Sanskrit delegate test (date picker + dialog under `sa`), tooltip helper, all-locale widget runs | §7.8, §8.3.1, §8.6, §8.7 | medium |
| C15 | No Sanskrit Hindi-marker gate script in CI or pre-commit | §8.5.1 | small |
| C16 | 20 source files over 500 lines; `lib/app/app.dart` is 2,368 lines | standard file-length table ("around 500: split or justify") | see Decision 3 |
| C17 | `plans/Remediation_Plan.md` breaks the plan naming rule | standard §21.1 | rename + fix references |
| C18 | Empty stray `doc/` folder at repo root (untracked) | recommended root layout | delete |

### 2.4 Out of scope (recorded, not fixed here)

- **Play Console tasks** that cannot be done in code: privacy policy URL, Data safety form, content
  rating, store listing assets, internal testing track. They go into `docs/release_process.md` §9A
  as an unchecked gate and into `docs/architecture.md` §21.
- **Release keystore** and **shared dev/prod application ID** — already open in §21. §9A.1 allows a
  `.dev` suffix but does not require it.
- **Fluent-reader review.** I can write the Sanskrit and fix the Malayalam, but §8.5.4 requires a
  fluent reader to approve new terms before release. Every new Sanskrit string will be listed in
  the change log as "needs native-reader review".

---

## 3. Decisions I need from you

**Decision 1 — Sanskrit translation (C1, C11).** Writing 1,026 Sanskrit ARB values plus 50 ritual
cards is the largest single item. Options:
- (a) I write all of it following §8.5 and the glossary, run the Hindi-marker gate, and list
  everything for your review. **Recommended.**
- (b) I build the framework only (delegates, picker, parity test) and leave `app_sa.arb` for a
  human translator. The parity test would fail until it is filled, so CI stays red.

**Decision 2 — ARB key rename to the §8.6 prefixes (C7).** Strict reading says every key gets a
category prefix. Options:
- (a) Scripted rename of all keys (e.g. `syncHealthTitle` → `titleSyncHealth`,
  `entryDeleteBody` → `bodyEntryDelete`), updating every `l10n.x` call in `lib/` and `test/`.
  Mechanical, but touches ~150 files. **Recommended for strict conformance.**
- (b) Keep the names, and drive the length test from an explicit short/long list in the test.
  Smaller diff, but not the convention the standard asks for.

**Decision 3 — Files over 500 lines (C16).** Options:
- (a) Split `lib/app/app.dart` (settings UI → `lib/features/settings/presentation/`, shell stays in
  `lib/app/`) and `entry_editor_screen.dart` (toolbar and bars into sub-widgets). Justify the other
  18 in `docs/architecture.md` (generated data tables, the Drift database, OCR camera state
  machine). **Recommended.**
- (b) Split all 20.
- (c) Justify all 20 in docs, split none.

---

## 4. The plan

Each phase ends with the verification in section 5. Phases are ordered so the app builds and tests
pass after each one.

### Phase 1 — Documentation (D1–D8)

| File | Change |
|---|---|
| `CLAUDE.md`, `AGENTS.md` | Replace the Localization rules block with the new template block (three languages, all three ARB files, key parity, Sanskrit-not-Hindi, delegates + `formattingLocale`, Settings picker, short labels, tooltips, About badge). Add a Play-readiness line under release rules. Keep both files word-for-word aligned. |
| `docs/GUIDELINES_MANIFEST.md` | Replace with the current submodule copy (it is a portable pointer file, no app-specific content). |
| `docs/release_process.md` | Add §6.4 allowBackup check, §6.5 cleartext, §6.6 asset audit, §6.7 exported audit, with bash and PowerShell commands. Add Localization and Play readiness blocks to §8. Add App Bundle build and PowerShell variants to §9. Add §9A Play readiness gate filled in for this app, with console-only items unchecked. |
| `docs/architecture.md` | §1: guideline commit `7ed5a36`. §9A.2 minSdk 28 decision recorded. §15: language split. §16: three locales, picker, delegates, fonts, badge, tooltips. §21: new "Still open — trilingual conformance (opened 2026-09-15)" list; file-length justifications per Decision 3. |
| `docs/security.md` | Add exported-component and asset-leak checks to the OWASP/manifest checklist. |
| `docs/workflow_rules.md` | Add the new §23.1 and §23.2 Definition of Done items. |
| `docs/dependencies.md` | Record bundled fonts and the script-coverage rule. |
| `docs/project_structure.md`, `docs/implementation_progress.md`, `README.md` | New files, tests, scripts; progress checklist for this plan. |

Doc text describes the **target** state and marks each gap open in §21 until its phase lands.

### Phase 2 — Android build and structure hygiene (C13, C17, C18)

- `android/app/build.gradle.kts`: add `bundle { language { enableSplit = false } }` with the
  guideline's comment.
- Rename `plans/Remediation_Plan.md` → `plans/20260725_000000_remediation-plan.md` (date from its
  first reference) and fix references, including the comment in `build.gradle.kts`.
- Delete the empty root `doc/` folder.
- Verify the merged manifest: only the launcher/share activity is exported, and it validates input.

### Phase 3 — Localization framework (C2, C3, C4, C5)

New or changed files, and their layer:

| File | Layer | Purpose |
|---|---|---|
| `lib/core/l10n/sa_framework_localizations.dart` | core | `SaMaterialLocalizationsDelegate`, `SaCupertinoLocalizationsDelegate`, `SaWidgetsLocalizationsDelegate` (§8.3.1) |
| `lib/core/l10n/formatting_locale.dart` | core | `formattingLocale(Locale)` (§8.3.2) |
| `lib/core/l10n/quill_localizations_fallback.dart` | core | also answer `sa` with English |
| `lib/core/l10n/locale_controller.dart` | core | Riverpod `Notifier`, key `app_language`, values `system`/`en`/`ml`/`sa` (§8.4) |
| `lib/main.dart` | entry | read the saved language before `runApp`, so no wrong-language flash |
| `lib/app/app.dart`, `lib/app/vault_unavailable_app.dart` | app | `locale:` from the controller, Sanskrit delegates first, `localeResolutionCallback` |
| `lib/features/settings/presentation/language_settings_*.dart` | presentation | picker: System default / English / മലയാളം / संस्कृतम्, radio, semantics label with current value, applies without restart |
| `lib/features/entries/templates/template_token_engine.dart` | feature | use `formattingLocale` |
| `assets/fonts/NotoSansDevanagari-{Regular,Bold}.ttf`, `pubspec.yaml`, theme | assets / core theme | bundle font (OFL, already covered by `OFL-Noto.txt`); `fontFamilyFallback` for Malayalam + Devanagari |

### Phase 4 — About screen (C8, C9)

- `lib/core/config/app_config.dart`: add `LocalizedText`; `description` and `details` become
  localized, exactly as `guideline.md` §1.4. Fixed path and class names kept.
- `assets/config/app_config.json`: lowerCamelCase keys (`author`, `email`, `license`, `aiUsed`,
  `ideUsed`); `description` and `license` become `{en, ml, sa}` maps.
- Check `tool/generate_app_version.dart` still writes only version/build.
- ARB: `aboutDetailAuthor`, `aboutDetailEmail`, `aboutDetailLicense`, `aboutDetailAiUsed`,
  `aboutDetailIdeUsed`, `madeWithLove`, `madeWithLoveA11y` — fixed wording from §1.7, all three files.
- `lib/features/about/presentation/about_screen.dart`: localized labels and resolved values; badge
  last, ≥ 24 dp above, safe-area below.
- `lib/features/about/presentation/made_with_love.dart`: the §1.7 reference widget
  (`WidgetSpan` + `Icons.favorite`, `#E53935`). Placed in the `about` feature because this app is
  Tier 2 feature-first, not Tier 1 `lib/widgets/`.

### Phase 5 — Tooltips (C10)

Add a localized `tooltip:` to the 14 controls found, and move the literal tooltip in
`airqr_receive_screen.dart` to ARB:

- `lib/app/app.dart` (2)
- `lib/features/airqr/presentation/airqr_receive_screen.dart` (2 + 1 literal)
- `lib/features/airqr/presentation/airqr_send_screen.dart` (3)
- `lib/features/entries/presentation/editor/voice_note_recorder.dart` (FAB)
- `lib/features/ritual/presentation/ritual_deck_screen.dart` (PopupMenuButton)
- `lib/features/security/presentation/security_events_screen.dart` (1)
- `lib/features/security/presentation/tamper_alerts_screen.dart` (1)
- `lib/features/sync/presentation/sync_client_screen.dart` (3)

Also sweep `InkWell`/`GestureDetector` with an icon-only child, and navigation destinations without a
visible label.

### Phase 6 — Strings: rename, translate, close the literal pockets (C1, C6, C7, C11, C12)

Order matters, so each step is testable:

1. **Key rename** (per Decision 2) with a throwaway script in the scratch area — ARB files, every
   `l10n.<key>` in `lib/` and `test/`, then `flutter gen-l10n`, analyze, test.
2. **Malayalam fixes** — translate the real untranslated values from C6 and fix any glossary
   conflicts found in `app_ml.arb` (§8.5.2: no lazy transliterations, `-ക്കുക` verbs on buttons,
   `ഇല്ല` vs `അല്ല`, `ആപ്പിനെക്കുറിച്ച്` for About).
3. **Close the literal pockets** — `entry_templates.dart`: labels and descriptions to ARB via a
   context-dependent lookup; template bodies treated as UI text (they are shown in the picker
   preview and seed the editor), stored per language. `export_strings.dart`: typed omission reasons
   and PDF exceptions, mapped to ARB in `export_screen.dart`; exported file headers become
   per-language as §8.7 requires.
4. **Sanskrit** (per Decision 1) — `lib/l10n/app_sa.arb` with `"@@locale": "sa"`, every key,
   glossary terms, polite `-ताम्` imperatives on buttons, nominal forms on titles, daṇḍa in prose.
   Ritual cards gain `titleSa`/`promptSa`/`quoteSa` and the `localized*()` methods handle `sa`.
5. Short-label budget pass over all three files; shorten anything over 20/22 characters.

### Phase 7 — Tests and gates (C14, C15)

| File | Purpose |
|---|---|
| `test/l10n/translation_parity_test.dart` | §8.7 suite: key parity, no English copies (short allow-list for pure format strings), `{heart}` marker, `app_config.json` languages and `aboutDetail*` labels, `_en` asset twins |
| `test/l10n/label_length_test.dart` | §8.6 budget by prefix, counted with `characters.length` |
| `test/core/l10n/sa_framework_localizations_test.dart` | pump under `sa`, open a date picker and a dialog, no exception |
| `test/core/l10n/locale_controller_test.dart` | resolution order, persistence, `system` value |
| `test/features/settings/.../language_settings_test.dart` | picker applies immediately, marks selection |
| `test/core/config/app_config_test.dart` | `LocalizedText` plain/map/fallback parsing |
| `test/features/about/about_screen_test.dart` | localized labels, badge is last, semantics label |
| `test/helpers/tooltip_expectations.dart` | §7.8 helper, called from existing screen tests in all three locales |
| `test/core/l10n/formatting_locale_test.dart` | `sa` → `en`, `ml` → `ml` |
| `tool/check_sanskrit_markers.sh` | §8.5.1 gate verbatim, including self-test |
| `.github/workflows/ci.yml`, `.githooks/pre-commit` | run the Sanskrit gate |
| existing widget tests | switch hard-coded `supportedLocales: [Locale('en')]` to `AppLocalizations.supportedLocales` and the full delegate list |

### Phase 8 — Structure (C16), per Decision 3

- Move the settings UI out of `lib/app/app.dart` into `lib/features/settings/presentation/`,
  leaving the shell and `NavigationBar` in `lib/app/`. No behaviour change; existing settings tests
  must pass unchanged.
- Split `entry_editor_screen.dart` bars and toolbar into sub-widgets in the same folder.
- Record the justified exceptions in `docs/architecture.md` §21.

Last step: update `docs/architecture.md` §21 and `docs/implementation_progress.md` to close each
gap, write the change log, set this plan to `completed`.

---

## 5. Verification

After every phase:

```powershell
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs   # only if a Drift/annotated file changed
dart format --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
sh tool/check_absolute_paths.sh --all
sh tool/check_no_internet_permission.sh
```

After Phases 3, 6 and 8, also:

```powershell
sh tool/check_sanskrit_markers.sh
flutter build apk --flavor dev --debug
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols/android-prod-check/
```

Manual check on a device with test data only (never the device holding real entries — the flavors
share an application ID): open every main screen in English, Malayalam and Sanskrit; switch language
from Settings without restart; kill and relaunch to confirm it persisted; open a date picker and a
dialog in Sanskrit; confirm no boxes, no clipping, the badge is last on About.

---

## 6. Risks

- **Size.** Phases 6.1 and 6.4 are wide. I will keep them as separate commits-worth of work so a
  bad step can be undone alone.
- **Sanskrit quality.** Machine-style Sanskrit drifts into Hindi. The gate catches obvious markers
  only; your review is still required before release.
- **Test churn.** Tests that find widgets by English text are unaffected by the rename (the English
  values do not change), but tests that call `l10n.<oldKey>` must be renamed with the ARB keys.
- **Settings extraction** touches every settings flow. Pure move, tests unchanged, but it is the
  riskiest structural step, so it is last.

---

## 7. Approval

Please answer Decisions 1–3 in section 3, and say which phases to run (all, or e.g. "Phase 1 only
first"). I will not change any project file other than this plan until you approve.
