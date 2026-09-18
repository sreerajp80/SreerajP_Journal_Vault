# Strict guidelines conformance — change log

**Plan:** [`plans/20260915_200933_strict-guidelines-conformance.md`](../plans/20260915_200933_strict-guidelines-conformance.md)
**Date:** 2026-09-15 to 2026-09-16
**Guidelines:** submodule commit `7ed5a36`

All eight phases of the plan are done, with the decisions approved on 2026-09-15: (1a) all Sanskrit
written here, (2a) scripted key rename, (3b) every file over 500 lines split.

**Verification at the end:** `flutter analyze` clean · **881 tests passing** (840 before the plan) ·
`dart format` clean · `sh tool/check_sanskrit_markers.sh` passing ·
`sh tool/check_absolute_paths.sh --all` passing · `sh tool/check_no_internet_permission.sh` passing.

---

## Phase 1 — Documentation

- `CLAUDE.md` and `AGENTS.md`: new trilingual localization block (kept word-for-word the same in
  both), release rules for `--release`, `enableSplit = false` and the Play §9A gate, the Sanskrit
  gate and App Bundle commands, `assets/fonts/` in the tree.
- `docs/GUIDELINES_MANIFEST.md` replaced with the submodule copy.
- `docs/release_process.md`: §6.4 allowBackup, §6.5 cleartext, §6.6 asset leak audit, §6.7
  exported components (bash and PowerShell), Localization and Play checklists in §8, §9 rewritten,
  new §9A Play readiness gate.
- `docs/security.md`, `docs/architecture.md`, `docs/workflow_rules.md`, `docs/dependencies.md`,
  `docs/project_structure.md`, `docs/implementation_progress.md`, `README.md` brought in line.

## Phase 2 — Android and repository hygiene

- `android/app/build.gradle.kts`: `bundle { language { enableSplit = false } }`; the
  `manifestPlaceholders` app label removed.
- `AndroidManifest.xml` uses `@string/app_name`; per-flavor `strings.xml` files added.
- `plans/Remediation_Plan.md` renamed to `plans/20260725_000000_remediation-plan.md`; every reference
  updated. Empty root `doc/` folder deleted.

## Phase 3 — Localization framework

- New in `lib/core/l10n/`: `sa_framework_localizations.dart` (Material, Cupertino and Widgets
  fallbacks for Sanskrit), `formatting_locale.dart`, `app_locales.dart`, `locale_controller.dart`
  (`app_language` preference, applied without restart).
- Noto Sans Devanagari bundled (OFL), `fontFamilyFallback` for Malayalam and Devanagari.
- Language picker under Settings → Appearance → Language.
- Every `DateFormat` now gets `formattingLocaleTag(...)`, so Sanskrit falls back to English
  patterns instead of throwing: template tokens, time capsules (seal dialog, sealed screen, list),
  editor stats bar, sync landing, share dialog.

## Phase 4 — About screen

- `LocalizedText` in `lib/core/config/app_config.dart`; `app_config.json` keys are lowerCamelCase and
  `description`/`license` are `{en, ml, sa}` maps; labels come from `aboutDetail*` keys.
- `lib/features/about/presentation/made_with_love.dart` — the "Made with ❤️ from India" badge, last
  on the About screen.

## Phase 5 — Tooltips

Localized tooltips on every icon-only control found (app shell search, AirQR send/receive, voice
note recorder, ritual deck menu, security events, tamper alerts, sync client, callout embed).
`test/helpers/tooltip_expectations.dart` is now used by `test/l10n/tooltip_coverage_test.dart`,
which checks the tamper alerts and export screens in all three languages.

## Phase 6 — Strings

### Key rename
884 keys renamed to the §8.6 category prefixes by script, with every reference in `lib/`, `test/`
and `integration_test/`. Thirty unused keys removed.

### Literal pockets closed
Services and providers now hold **typed values**; the presentation layer words them in the user's
language. User-visible text left Dart code in:

| Area | How |
|---|---|
| Ritual cards (50) | `RitualCard.curated(id, number, theme)`; text via `ritual_card_text.dart` |
| Entry templates (46) | `EntryTemplate.builtIn(id, category)`; text via `entry_template_text.dart` |
| Export | `export_strings.dart` deleted; `ExportLabels` passed to every renderer; `ExportOmissionReason`, `ExportFailureReason`, `HtmlPdfFailure`; `export_text.dart` |
| AirQR | send, receive, landing and size warning; `airqr_payload_text.dart` words payload kinds and sizes; raw controller errors are no longer shown |
| Wi-Fi Sync | `ClientSyncState` lost `statusMessage` and its raw `error` string (now `hasFailed`); `HostSessionState.error` removed; `sync_text.dart` words steps and statuses; failures are logged redacted |
| Permissions | `AppPermissionItem` lost `title`/`description`/`statusDetail`; `permission_text.dart` words them by id |
| Security events | the stored `description` stays as the audit record; the screens show `security_event_text.dart` wording by `eventType`. The tamper screen also shows the stored finding, because it names which row failed |
| Template tokens | `TemplateTokenInfo` holds only the token and example; `template_token_text.dart` explains each |
| Also | time capsule screens, editor placeholder and seal error, biometric prompt reasons, drawing/image embed placeholders, template manager/editor errors, share dialog, typography "pt", relative dates and entry counts on the home cards, OCR camera, voice note sheet, version history, audio and archive viewers, notification channel name (now passed in), import format names, storage migration errors |

### Translations
- **Sanskrit:** `lib/l10n/app_sa.arb` now holds all 1,657 keys.
- **Malayalam:** the ten values that were still English were translated (for example
  `bodyEntryDeleteBody`, `titleSyncChangedFields`, `labelPermissionStatusRow`). The remaining
  identical values are units, format names, symbols or placeholder-only strings, listed in
  `test/l10n/translation_parity_test.dart`.
- Malayalam data fixes in the ritual cards: card 26 had Telugu letters inside ബ്രഹ്മചര്യം; card 38
  had a typo in സന്തോഷാദനുത്തമഃ.

### Label budget (§8.6)
Measured in visible characters (grapheme clusters). **English copy changed** so labels fit in 20
characters — for example "The vault cannot be opened" → "Vault unavailable", "Distraction-free
mode" → "Focus mode", "Attachment library access" → "File access", "Unlock with Phone Lock" → "Use
phone lock", "Migrating attachments" → "Moving attachments". Ten Malayalam labels were shortened,
mostly by dropping English glosses in brackets. Documented exceptions: the app name, the Features
screen header, and feature-catalogue titles (rows of content that wrap).

### Things found on the way
- Two English keys were defined twice in the original ARB (`commonClose`, `syncStatusSyncing`); the
  later value was kept, which matches what `gen-l10n` had been using.
- The Sanskrit gate matches markers as plain substrings, so correct Sanskrit can trip it: `ग्रहीतुं`,
  `संग्रहात्`, `संग्रहे` contain रहा/रहे/रही, `अशक्यानि` and `शक्या` contain क्या, and a bare `हो`
  is flagged. Those strings were reworded (`आदातुं`, `कोशात्`, `न शक्तानि`, `होरा`) rather than
  weakening the gate.
- `labelMigrationProgress` placeholders stay `String`: the total is shown as `?` while unknown.

## Phase 7 — Tests and gates

- `test/l10n/translation_parity_test.dart` — key parity, `@key` descriptions, matching placeholders,
  no English left in `ml`/`sa` outside the allow-list.
- `test/l10n/label_length_test.dart` — the §8.6 budget in visible characters.
- `test/l10n/tooltip_coverage_test.dart` — tooltips in all three languages.
- Existing delegate, locale controller, formatting-locale and language picker tests from Phase 3.
- `package:characters` declared in `pubspec.yaml` (it was only transitive).
- `tool/check_sanskrit_markers.sh` now runs in `.github/workflows/ci.yml` (job `sanskrit-check`) and
  in `.githooks/pre-commit`.

## Phase 8 — File length

Every source and test file is at or under 500 lines. The method, recorded in
`docs/project_structure.md` section 3:

- Whole classes moved into `part` files beside their library (for example `lib/app/app.dart`
  2,384 → 431 lines, with `app_lock_setup_screens.dart`, `app_lock_widgets.dart`,
  `app_home_tab.dart`, `app_journal_card.dart`, `app_journal_detail.dart`, `app_search_tab.dart`;
  `app_database.dart` 1,575 → 358 with tables and DAOs in three parts; Drift code regenerated).
- A large `State` or service class keeps its fields, constructor and `@override` members; its
  private methods moved into a private `extension` on the same class in a part file. `setState`
  is reached through a `_rebuild` helper because extensions may not call protected members; static
  members are qualified by class name.
- Two blocks of `EntryEditorScreen.build` (the focus-mode scaffold and the app-bar actions) became
  methods in `entry_editor_layout.dart`.
- Tests: shared fakes moved to `test/app_test_support.dart`,
  `test/features/export/export_test_fakes.dart` and
  `test/features/settings/settings_test_fakes.dart`; groups moved to `test/journal_flow_test.dart`,
  `test/features/export/export_service_inline_images_test.dart` and
  `test/features/backup/backup_restore_attachments_test.dart`.

These are pure moves: no behaviour changed, and every existing test passed unchanged in logic.

## Incident during Phase 6

A PowerShell replace with a flattened array replaced every `t` with `o` in `lib/app/app.dart` and
`lib/features/entries/presentation/entry_editor_screen.dart`. Both files were rebuilt line by line
from git `HEAD` and the rest of the codebase, then confirmed by analyze, the full test suite and a
diff review of every changed comment line. No content was lost.

---

## Needs native-reader review (§8.5.4)

Every value in `lib/l10n/app_sa.arb` (1,657 strings) and every Malayalam value added or changed in
this change is new and **needs a fluent reader's review before release**. Terms chosen that are most
worth checking:

| English | Sanskrit | Malayalam |
|---|---|---|
| Journal | दैनन्दिनी | ജേണൽ |
| Entry | प्रविष्टिः | കുറിപ്പ് |
| Attachment | संलग्नम् | അറ്റാച്ച്മെന്റ് |
| Backup | प्रतिलिपिः | ബാക്കപ്പ് |
| Settings | विन्यासाः | ക്രമീകരണങ്ങൾ |
| Password | गुप्तशब्दः | പാസ്‌വേഡ് |
| Pairing code | युग्मसङ्केतः | ജോടിയാക്കൽ കോഡ് |
| Time capsule | कालपेटिका | ടൈം കാപ്സ്യൂൾ |
| Tag | चिह्नम् | ടാഗ് |
| Template | प्रतिरूपम् | ടെംപ്ലേറ്റ് |
| Sync | समन्वयः | സമന്വയം |
| Camera | छायायन्त्रम् | ക്യാമറ |
| Screenshot | पटलचित्रम् | സ്ക്രീൻഷോട്ട് |
| Tampering | विकृतिः | കൃത്രിമം |
| Minutes / seconds (units) | निमेषाः / क्षणाः | മിനിറ്റ് / സെക്കൻഡ് |

## Still open (only a person can do these)

- Fluent-reader review of Malayalam and Sanskrit.
- Play Console tasks in `docs/release_process.md` §9A.
- A manual pass on a test device in all three languages (no clipping, no missing glyphs, the badge
  last on About, a date picker in Sanskrit), using a device that holds no real journal data.
