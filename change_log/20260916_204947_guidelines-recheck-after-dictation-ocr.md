# Guidelines Re-check After The Dictation, OCR And Editor Changes

**Plan:** [`plans/20260916_203953_guidelines-recheck-after-dictation-ocr.md`](../plans/20260916_203953_guidelines-recheck-after-dictation-ocr.md)
(approved 2026-09-16, all of G1–G7)

**Guidelines version:** `docs/guidelines/` at `7ed5a36` (newest upstream).

---

## G1 — Long lists are now built lazily

The rule: never use `ListView(children: [...])` for a list that can grow past 20 items.

| Screen | Before | After |
|---|---|---|
| `lib/app/app_search_tab.dart` | Two `ListView`s, each holding a `Column` with every result | One `ListView.builder` over a flat row list (section header, journal rows, entry rows). The `search-section-journals` / `search-section-entries` keys moved onto the header rows |
| `lib/features/entries/presentation/time_capsules_list_screen.dart` | `ListView` with every capsule | `CustomScrollView`, one `SliverList.builder` per section (Ready, Sealed, Opened) |
| `lib/features/backup/presentation/restore_backup_screen.dart` | Backup files in a `Column` inside a `ListView` | `CustomScrollView`; the backup files are a `SliverList.builder`, and the fixed controls stay in plain slivers |

Looks and keys are unchanged. The short, fixed preset-chip row in search keeps its plain `ListView`.

New tests, each with 30 items, scroll to the last item:
- `test/journal_flow_test.dart` — "Search results build lazily and reach the last of many"
- `test/features/entries/time_capsule_widget_test.dart` — "TimeCapsulesListScreen builds a long list lazily"
- `test/features/backup/restore_backup_screen_test.dart` — "a long backup list builds lazily and reaches the last file"
  (the screen's test helper gained an optional `backups` list)

These tests check that a long list shows and scrolls. On their own they cannot prove the list is
lazy, because Flutter also builds the old form lazily on screen. The code change is what fixes the
rule break.

## G2 — Dependency record

`docs/dependencies.md` gained rows for four packages that were in `pubspec.yaml` but missing from
the record. The re-check found `crypto` while fixing G2, on top of the three in the plan.

| Package | Checked |
|---|---|
| `camera` | Depends only on its platform packages (CameraX on Android). No networking |
| `qr_flutter` | Depends only on `qr`. No networking |
| `mobile_scanner` | Uses the **bundled** ML Kit barcode model. The row warns never to set `dev.steenbakker.mobile_scanner.useUnbundled=true`, which would switch to a model downloaded through Play Services. That property is not set today |
| `crypto` | SHA-256 check on AirQR payloads. No dependencies; not used for encryption |

## G3 — `CLAUDE.md` matches `AGENTS.md` again

- Added hard rule 7 "Re-test earlier work".
- Rule 6 gained the sentence "Split work into small, testable slices with acceptance criteria."

The Hard rules sections of the two files are now identical.

## G4 — Plan status values

37 plans used a status outside the allowed set in `docs/workflow_rules.md` §1, and 1 had no status
line. Each one was checked against `change_log/`:

- **36 → `completed`.** Each has a matching change log. That covers plans still marked `Proposed`,
  `Awaiting approval` or `Pending Approval` whose features were built. The remediation plan had no
  status line; all 52 of its task boxes are ticked, and its follow-up plan confirms that.
- **1 → `dropped`:** `20260912_154629_upgrade_malayalam_traineddata_to_best.md`. It was replaced by
  a later plan that made the same change.
- **1 → `completed`, with a note:** `20260916_202828_editor-typing-and-selection-fixes.md`
  (the Problem 1 fix was later reverted, as its note says).

Where the old status held more than a value (for example "Superseded by …" or "Implemented — see
…"), that text now sits on a `**Status note:**` line under the status. No plan was left for the
owner to decide.

**Fixed along the way.** The first status script treated the metadata lines under a status
(`**Date:**`, `**Author:**`, `**Scope:**`) as part of the status. It merged them onto one line and
dropped a closing backtick in four places. It was caught before anything else ran. Every block was
rebuilt from the git `HEAD` copy, including line wraps and the two trailing spaces that make a
Markdown line break. `git diff plans/` now shows only status-line changes, plus the three new note
lines. The two plans not yet in git (`20260916_200330_…`, `20260916_202828_…`) were checked by eye.

## G5 — File size

`test/features/entries/presentation/ocr_enhance_screen_test.dart` went from 525 to 413 lines. Its six
test doubles moved to a new sibling file, `ocr_enhance_test_fakes.dart` (125 lines). Their names
lost the leading `_` so the test file can import them.

**Change from the plan:** the plan said to move a test group. Moving the fakes instead follows what
the last pass did with `export_test_fakes.dart`, and keeps each test next to its setup. It is still
a pure move, and no test logic changed.

## G6 — Pairing-code hint

The raw `'XXXX-XXXX-XXXX-XXXX'` hint in `lib/features/airqr/presentation/airqr_receive_views.dart`
now comes from a new key, `labelSyncPairingCodeHint`, in `app_en.arb` (with an `@` description),
`app_ml.arb` and `app_sa.arb`. The value is the same mask in all three, because it shows a shape,
not words. It was added to the parity test's allow-list under "Format masks". The plan named the
key `hintSyncPairingCodeFormat`, but `hint…` is not an allowed key prefix, so it uses `label…`.
`flutter gen-l10n` was run.

## G7 — Relative imports in `test/`

`docs/project_structure.md` §5 now explains that helpers and fakes under `test/` are imported with
relative paths, because a `package:` import cannot reach them. This is the only allowed use.

---

## Verification

| Check | Result |
|---|---|
| `flutter gen-l10n` | Done |
| `flutter analyze` | No issues |
| `dart format --set-exit-if-changed lib test integration_test` | 0 changed |
| `flutter test` | 919 tests, all passed (916 before + 3 new) |
| `tool/check_absolute_paths.sh --all` | Passed |
| `tool/check_no_internet_permission.sh` | Passed |
| `tool/check_sanskrit_markers.sh` | Passed |
| Dart files over 500 lines | None |
| Raw `hintText:` literals in `lib/` | None |
| Plans with a status outside the allowed set | None |
| `pubspec.yaml` runtime packages missing from `docs/dependencies.md` | None |

## Needs native-reader review

Nothing new. The only new ARB value is a format mask (`XXXX-XXXX-XXXX-XXXX`), not Malayalam or
Sanskrit words.
