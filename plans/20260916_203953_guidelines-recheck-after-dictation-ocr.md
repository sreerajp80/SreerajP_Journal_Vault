# Guidelines Re-check After The Dictation, OCR And Editor Changes

**Status:** completed

**Approved:** 2026-09-16, all of G1–G7.

**Date:** 2026-09-16

**Scope:** Re-check the whole repository against `docs/guidelines/` at submodule commit `7ed5a36`
(still the newest upstream). The last full pass
([20260915_200933_strict-guidelines-conformance.md](20260915_200933_strict-guidelines-conformance.md))
targeted the same commit. Since then, on-device dictation, OCR changes and editor fixes landed. This
plan fixes the gaps found in the re-check. All three applicability profiles stay in force.

---

## 1. What already passes (no change needed)

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `dart format --set-exit-if-changed lib test integration_test` | 0 files changed |
| `flutter test` | 916 tests, all passed (includes ARB parity, label length, tooltip coverage) |
| `tool/check_absolute_paths.sh --all` | Passed |
| `tool/check_no_internet_permission.sh` | Passed |
| `tool/check_sanskrit_markers.sh` | Passed |
| `print` / `debugPrint` in `lib/` | None |
| `kDebugMode` / `kReleaseMode` as a flavor stand-in | None (one debug-only diagnostic in `config_service.dart`, allowed) |
| SQLCipher build hook, no `sqlite3_flutter_libs` / `drift_flutter` | Intact |
| Dictation stays on-device | Yes — checks the on-device recogniser first and always listens with `onDevice: true` |
| Icon-only buttons have tooltips | Yes |
| Logs in the new services | IDs and error codes only, no content |

## 2. Gaps found

| # | Rule | Gap | Files |
|---|---|---|---|
| G1 | CLAUDE.md "Never use `ListView(children: [...])` for a list that can exceed 20 items"; standard §10.3 | Four lists built from database rows or files have no upper bound | `lib/app/app_search_tab.dart` (entry-only results, and the mixed journals + entries results), `lib/features/entries/presentation/time_capsules_list_screen.dart`, `lib/features/backup/presentation/restore_backup_screen.dart` (backup files inside a `Column`) |
| G2 | CLAUDE.md dependency rules; `docs/dependencies.md` is the record | `camera`, `qr_flutter` and `mobile_scanner` are in `pubspec.yaml` but not in the record | `docs/dependencies.md` |
| G3 | CLAUDE.md header: "if you change a rule here, change it there too" | `AGENTS.md` has hard rule 7 "Re-test earlier work"; `CLAUDE.md` does not | `CLAUDE.md` |
| G4 | `docs/workflow_rules.md` §1 status values | 38 of 86 plans use a status outside the allowed set (`Proposed`, `Awaiting approval`, `Complete`, `Approved`, one has no status line). Several are stale — the features were built | `plans/*.md` (status line only) |
| G5 | Standard §16.2 file size (500-line ceiling used by the last pass) | One test file is 525 lines | `test/features/entries/presentation/ocr_enhance_screen_test.dart` |
| G6 | CLAUDE.md localization: no raw string in a widget | Pairing-code hint `'XXXX-XXXX-XXXX-XXXX'` is a literal | `lib/features/airqr/presentation/airqr_receive_views.dart`, three ARB files |
| G7 | CLAUDE.md "use `package:` imports, never relative" | 10 test files import `test/helpers/` with relative paths. A `package:` import cannot reach `test/`, so this cannot be fixed — only recorded as an allowed exception | `docs/project_structure.md` |

## 3. The fix

**G1.** Keep the look the same, change only how the list is built.
- Search tab: build the results with `ListView.builder` over a flat list of rows (section header,
  journal row, entry row). The horizontal preset-chip list is short and fixed, so it stays.
- Time capsules: `CustomScrollView` with one `SliverList.builder` per section (Ready, Sealed,
  Opened) and the existing header widgets as `SliverToBoxAdapter`s.
- Restore backup: turn the screen into a `CustomScrollView`; the backup files become a
  `SliverList.builder`. The other controls stay as box adapters.
- Existing widget tests find items by key and text; they must pass unchanged. Add one test per
  screen with 30+ items that scrolls to the last one.

**G2.** Add three rows to the "Editor and media" table: what each is used for, where, and a note
that none pulls in an HTTP or cloud client (checked against each package's own `pubspec.yaml`
before writing the row).

**G3.** Copy rule 7 into `CLAUDE.md` hard rules, worded the same way.

**G4.** Status line only, no other text changes. For each plan: a matching change log exists →
`completed`; partly built → `partial_completion`; never built → `dropped`. Any plan I cannot
place with evidence goes in the change log as a list for the owner to decide, left as
`approval_pending`.

**G5.** Move one `group` into `ocr_enhance_screen_test_extra.dart` beside it, sharing the setup
helper. Pure move.

**G6.** New key `hintSyncPairingCodeFormat` in `app_en.arb` (with `@` description), `app_ml.arb` and
`app_sa.arb`. The value is the same mask in all three, because it shows the format, not words, so
it goes on the parity test's allow-list. Run `flutter gen-l10n`.

**G7.** One paragraph in `docs/project_structure.md` saying test helpers under `test/` are imported
relatively because `package:` cannot reach them. No code change.

## 4. Verification

- `flutter gen-l10n`, `flutter analyze`, `dart format` on `lib test integration_test`, `flutter test`.
- `sh tool/check_absolute_paths.sh --all`, `sh tool/check_no_internet_permission.sh`,
  `sh tool/check_sanskrit_markers.sh`.
- Re-run the greps from section 2 and confirm each gap is gone.
- Change log written to `change_log/` referencing this plan.

## 5. Not in scope (only a person can do these)

- Fluent-reader review of Malayalam and Sanskrit.
- Play Console tasks in `docs/release_process.md` §9A.
- Release signing with a real keystore (see `docs/architecture.md` section 21).
