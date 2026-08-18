# Change log — Close the gaps against the three in-force profiles

**Date:** 2026-07-25 09:40 (local time)
**Implements:** [`plans/20260725_085907_close-profile-gaps.md`](../plans/20260725_085907_close-profile-gaps.md)

Seven commits, `d4140ed` through `4a99bfe`. Phase 8 (splitting `app.dart`) was deferred by
agreement.

## Result at a glance

| | Before | After |
|---|---|---|
| `flutter analyze` | clean | clean |
| Tests | 207 pass, 1 fail | **235 pass**, same 1 fail |
| Release build | never attempted | succeeds with `--obfuscate` + R8 |
| Screenshots of journal content | possible | blocked |
| Journal DB eligible for Google cloud backup | **yes** | no |

The one failing test (`widget_test.dart` → "Journal detail groups entries and reacts to entry
CRUD") failed before this work started and still does. It was measured at baseline precisely so
it could not be confused with a regression.

## What was fixed

### Phase 1 — the two live security holes (`d4140ed`)

- `FLAG_SECURE` set app-wide in `MainActivity.onCreate`. Screenshots, screen recording, and the
  task-switcher preview are now blocked everywhere. **Visible behaviour change:** you can no
  longer screenshot anything in the app.
- `android:allowBackup="false"` plus a new `res/xml/data_extraction_rules.xml` excluding every
  domain from both cloud backup and device-to-device transfer. Needed as a pair: on API 31+
  `allowBackup` alone does not stop device transfer.
- Verified in the **merged** manifest, not the source.

### Phase 2 — release signing and binary hardening (`62aadf3`)

- `build.gradle.kts` now reads `android/key.properties` for a real signing config, falling back
  to the debug key with a loud warning when absent.
- R8 enabled with `android/app/proguard-rules.pro`.
- `.gitignore` covers `key.properties`, `*.jks`, `*.keystore`, `/build/symbols/`.

**The first R8 run failed** on 11 missing `com.google.android.play.core` classes that the Flutter
engine references but this app does not use. Fixed with `-dontwarn`. This is exactly the failure
that would otherwise have appeared on release day.

Release build then succeeded (63.8 MB) and confirmed three things: no `INTERNET` permission, no
`android:debuggable`, and obfuscation symbols produced for all three ABIs.

### Phase 3 — Core Baseline cleanup (`759e23b`)

- Deleted `lib/application/`, `lib/data/`, `lib/domain/`, `lib/presentation/`. All four held
  **zero files** — only directory skeletons. `lib/presentation/screens/` contained folders named
  `copy_todos`, `daily_list`, `recurring_tasks`, `time_segments`: scaffolding from a **different
  app** entirely.
- Removed `go_router` (declared, imported nowhere).
- Added the stricter lint set from standard §16.1. It surfaced 48 issues, all mechanical; `dart
  fix --apply` made 53 fixes across 24 files.

### Phase 4 — the About config pattern (`32c8f4b`)

`guideline.md` §1 is a MUST and none of it was in place. Added `assets/config/app_config.json`,
`lib/core/config/app_config.dart`, `lib/core/config/config_service.dart`, registered the asset,
and rewrote the About screen to loop `details` instead of hard-coding `Author` / `AI Used` /
`IDE Used`.

**One real bug found and fixed while doing this.** The guideline's own reference `ConfigService`
awaits `PackageInfo.fromPlatform()`. That platform channel never answers under `flutter_test`,
which left the About screen stuck on its spinner and timed out three widget tests. The version
check is only a debug diagnostic, so it now runs unawaited and cannot block rendering.

Kept the existing user-visible labels rather than switching to the template's example casing —
renaming what the user sees was not part of the task.

### Phase 5 — the migration test (`e97e9c4`)

Seven tests covering v1 → v7: every table recreated, v7 columns added, `user_version` reaches 7,
**pre-existing journal rows survive with their values intact**, writes still work, foreign keys
still enforced.

Two things make this test trustworthy rather than decorative:

- The rewind helper **asserts its own drops landed**. Without that the suite could pass vacuously.
- I **verified the tests have teeth** by temporarily disabling the `from < 6` migration branch.
  The suite failed on the missing `auto_lock_profiles` table. Mutation reverted; `git diff`
  confirmed `app_database.dart` unchanged.

Honest limitation, documented at the top of the file: there are no `drift_schemas/` snapshots and
they cannot be reconstructed, so the historical v1–v6 table *shapes* are assumed to match today's.

### Phase 6 — structured logging (`d81248c`)

- `AppFlavorConfig` per standard §5.2 — also closes the separate gap where flavors changed the
  app label but drove no runtime config.
- `AppLogger` with the standard's six levels, verbose gated to `dev`, plus a `redact()` helper.
- Console only, no log file: a log file in an encrypted journal app is another place for content
  to leak. Recorded as a decision, not an omission.
- Logging before `init()` is a no-op rather than a crash.
- `ConfigService` switched from `debugPrint` to `AppLogger` — §14.3 bans `debugPrint` in
  committed code, and the linter cannot catch it.

### Phase 7 — the two blueprints (`97b230f`)

Written last on purpose, so they describe the app as it now is. `docs/security.md` and
`docs/release_process.md` are filled in from the real code.

`release_process.md` opens with a blunt notice that **the app cannot be released yet**.

## New problems found while doing the work

None of these were known when the plan was approved. All are recorded, none are fixed.

1. **No "Delete all data" action exists** anywhere in `lib/`. Standard §15.4 requires one.
2. **The SQLite database is not encrypted at rest.** Entry text and the FTS index sit in a plain
   SQLite file. Risk-accepted as OWASP M9 — the app sandbox covers the stated threat model, but
   root or an offline flash dump defeats it.
3. **The attachment crypto format has no version byte.** Any future crypto change would have no
   in-band way to tell old files from new. Cheap now, expensive once real data exists (M10).
4. **`dev` and `prod` share one application ID.** They cannot coexist on a device — installing a
   dev build over the real one destroys its data.
5. **`ACCESS_NETWORK_STATE` and `WAKE_LOCK`** arrive transitively from plugins and are unused.
6. **95 of 132 files do not match `dart format`.** Dart 3.11 changed the formatter style; the
   codebase predates it. Files touched today were formatted; the rest were deliberately left, to
   keep a mechanical 95-file diff out of the security commits.
7. **`dart format .` crashes** (`PathNotFoundException`) walking stale Gradle paths under
   `build/`. Both documents now say to name the source directories.

## Still blocked on you

**The release keystore does not exist.** This is the one item I could not complete and would not
fake: creating it means generating your signing identity and choosing its passwords, which do not
belong in an agent transcript.

Everything around it is done — Gradle wiring, `.gitignore`, and `android/key.properties.example`
with the exact command. Run it from the `android/` folder:

```bash
keytool -genkeypair -v \
  -keystore sreerajp_journal_vault.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias sreerajp_journal_vault
```

Then copy `key.properties.example` to `key.properties` and fill it in.

**Back the keystore up offline.** Losing it means you can never update the installed app.

Until this is done the build signs with the debug key and prints a warning. **Do not install a
debug-signed build on the phone you keep real entries on** — switching to a real key later
requires uninstalling, and uninstalling destroys the data.

## Also not done

- **R8 has never run on a device.** It compiles; missing keep rules fail only at runtime. The
  smoke-test list is in `release_process.md` §6.2.
- **Phase 8, splitting the 2,568-line `app.dart`** — deferred by agreement, still open.

## Suggested order from here

1. Create the keystore (5 minutes, unblocks everything else).
2. Add the "Delete all data" action — a required feature that is simply absent.
3. Add a version byte to the attachment crypto format, while the installed base is one device.
4. R8 smoke tests on a real device.
5. Fix or consciously accept the failing `widget_test.dart` test.
6. Reformat the codebase as its own commit.
