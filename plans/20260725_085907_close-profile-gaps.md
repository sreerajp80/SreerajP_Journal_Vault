# Close the gaps against the three in-force profiles

**Status:** partial_completion

**Approved 2026-07-25.** Phases 1–7 completed. Phase 8 deferred to its own plan, per the
recommendation above. Phase 2 is complete as far as it could go — the wiring is in place, but the
keystore itself must be created by the user, so release builds are still debug-signed.

Change log: [`change_log/20260725_094053_close-profile-gaps.md`](../change_log/20260725_094053_close-profile-gaps.md)

## What this covers

Everything from the previous change log: the four named items (signing config, `FLAG_SECURE`,
`security.md`, `release_process.md`) **and** the gap list. Those two sets overlap — three of the
four named items were already gaps — so this plan treats them as one backlog.

While reading the code to prepare this plan I found **two more gaps** and **resolved one**.

### New gap found: the About-screen config pattern is not followed

`guideline.md` §1 is a **MUST**, and it is very specific: About values come from one JSON asset,
at three fixed paths, with fixed class names.

| Required | Present? |
|---|---|
| `assets/config/app_config.json` | **No** — `assets/` holds only icons |
| `lib/core/config/app_config.dart` (class `AppConfig`) | **No** — `lib/core/config/` does not exist |
| `lib/core/config/config_service.dart` (class `ConfigService`) | **No** |
| `assets/config/` registered in `pubspec.yaml` | **No** — the assets block is still all comments |
| About screen renders `details` dynamically | **No** — `about_metadata.dart` hard-codes `author`, `aiUsed`, `ideUsed` |

§1.6 explicitly forbids what the code does today: "The screen MUST NOT hard-code field names like
`Author` or `Email`."

### New gap found: Android auto-backup is on by default

`AndroidManifest.xml` does not set `android:allowBackup`. On Android that **defaults to `true`**,
so the encrypted database and the SharedPreferences holding wrapped key material can be copied to
Google's cloud backup. `security.md` §10 says a sensitive-data app MUST set this to `false` or
restrict it with `fullBackupContent`. For an encrypted journal this is a real leak of the whole
data set to a third party.

### Resolved — not a gap after all

The open "secrets in SharedPreferences" question from the last change log is **closed as
compliant**. I read `MainActivity.kt`: `wrapPayload()` encrypts with AES-GCM using a
Keystore-resident 256-bit key from `getOrCreateWrappingKey()`, with
`setRandomizedEncryptionRequired(true)`. Only `iv:ciphertext` reaches SharedPreferences. That
satisfies §15.2. No change needed.

## Two things I will not do

1. **I will not create your release keystore.** It is your signing identity, and its passwords
   would end up in this transcript and in my tool output. I will do all the Gradle wiring, the
   `.gitignore` entries, and give you the exact `keytool` command to run yourself. The build stays
   debug-signed until you run it — I will say so plainly rather than report the gap as closed.
2. **I will not invent security or release decisions.** Where `security.md` or
   `release_process.md` need a real decision from you, I will fill in what the code proves and
   mark the rest `TODO`, as I did for `architecture.md`.

## Verification available

`flutter` and `keytool` are both on `PATH`. Every phase below ends with
`flutter analyze` and `flutter test`, and I will report real output — including failures.

---

## Phases

Each phase is a separate commit and independently useful. I recommend running them in this order:
security holes first, cosmetics last, documents last of all so they record what is true rather
than what is intended.

### Phase 1 — Close the two live security holes

| File | Change |
|---|---|
| `android/app/src/main/kotlin/.../MainActivity.kt` | Add `FLAG_SECURE` to the window in `onCreate`. |
| `android/app/src/main/AndroidManifest.xml` | Add `android:allowBackup="false"` and `android:fullBackupContent="@xml/backup_rules"`. |
| `android/app/src/main/res/xml/backup_rules.xml` | New — explicitly exclude the database, attachments, and shared prefs. |

`FLAG_SECURE` is applied app-wide, not per screen. Every screen in a journal app shows private
content, so a per-screen channel would be complexity with no benefit. Side effect you should know
about: **screenshots stop working inside the app entirely**, and the task-switcher preview goes
blank. That is the intent, but it is a visible behaviour change.

### Phase 2 — Release signing (partly blocked on you)

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | Load `android/key.properties` if present; define a `release` signing config from it; fall back to debug **only** when the file is absent, so `flutter run --release` still works on a fresh clone. |
| `.gitignore` | Add `android/key.properties`, `android/*.jks`, `android/*.keystore` per `guideline.md` §2.3. |
| `android/key.properties.example` | New — a committed template with placeholder values. |

Then I give you the `keytool -genkeypair` command. **You run it.** Until you do, release builds
remain debug-signed and I will report the gap as still open.

### Phase 3 — Core Baseline cleanup

| File | Change |
|---|---|
| `lib/application/`, `lib/data/`, `lib/domain/`, `lib/presentation/` | Delete. All four are empty (0 files) and contradict the declared feature-first structure. |
| `pubspec.yaml` | Remove `go_router: ^17.1.0` — declared, imported nowhere. |
| `analysis_options.yaml` | Add the stricter rule set from engineering standard §16.1. |

**Risk I want to flag:** tightening lint rules on a codebase this size will surface warnings.
`app.dart` alone is 2,568 lines. If the count is small I will fix them in this phase. If it is
large, I will fix what is mechanical, list the rest, and stop — rather than silently disabling
rules to make the output green.

### Phase 4 — The About config pattern (`guideline.md` §1)

| File | Change |
|---|---|
| `assets/config/app_config.json` | New — appName, description, version, build, details map. |
| `pubspec.yaml` | Register `assets/config/` under `flutter: assets:`. |
| `lib/core/config/app_config.dart` | New — `AppConfig` with `fromJson` + `fallback`, per the reference implementation. |
| `lib/core/config/config_service.dart` | New — `ConfigService` with `load()` + `loadAndVerify()`, injectable asset loader. |
| `lib/features/about/**` | Rewire the About screen to loop `config.details.entries`. Remove hard-coded `author` / `aiUsed` / `ideUsed` fields. |
| `test/features/about/**` | Update the existing two About tests; add tests for `AppConfig.fromJson` fallback behaviour and `ConfigService` error paths. |

This is the largest *code* change in the plan. The existing About tests will need rewriting, not
just adjusting.

### Phase 5 — The untested migration path

| File | Change |
|---|---|
| `test/core/database/migration_test.dart` | New — verify schema v1 → v7 upgrade using Drift's migration test helpers. |

The standard names this a critical test area, and a migration bug destroys journal entries with no
recovery. **Possible blocker:** proper Drift migration testing wants generated schema snapshots
(`drift_dev schema dump`), which do not exist for v1–v6 and cannot be reconstructed after the
fact. If that turns out to be the case I will write the strongest test the current setup allows
and say clearly what it does and does not prove.

### Phase 6 — Structured logging

| File | Change |
|---|---|
| `pubspec.yaml` | Add a logging package. |
| `lib/core/logging/` | New — logger setup, verbose gated by flavor, redaction helper. |
| `analysis_options.yaml` | Turn on `avoid_print`. |

Required by §15.5. This is a design decision as much as a change; I will keep it minimal and not
retrofit log calls across the whole app in this phase.

### Phase 7 — Fill in the two blueprints

| File | Change |
|---|---|
| `docs/security.md` | New local copy, filled from the real code: threat model, data inventory, the AES-GCM/Keystore crypto design, lock strategy, permissions table, OWASP Mobile Top 10 sign-off, retention and purge policy. |
| `docs/release_process.md` | New local copy, filled: versioning, the flavor-aware build commands with `--obfuscate --split-debug-info`, signing, distribution, rollback. |

Deliberately last, so they describe the app after phases 1–6 rather than describing intentions.

**Expect open items.** §13 requires a user-accessible "Delete all data" action; I have not
verified one exists, and if it does not, that becomes a new gap rather than something I quietly
implement here. The OWASP table will also contain honest `risk-accepted` rows — for example M7
stays unmet until you generate the keystore in phase 2.

### Phase 8 — Split `app.dart` (recommend deferring)

`lib/app/app.dart` is 2,568 lines holding the shell, navigation, and the entire settings UI. The
fix is to extract settings into `lib/features/settings/`.

**I recommend not doing this now.** It is a pure-refactor change with real regression risk across
every settings flow — lock mode, storage migration, permissions, sync — and the existing widget
tests reach into that file's structure. It is also the only item on the list that fixes no
security or correctness problem. My advice is to do phases 1–7, confirm the app still works, and
treat this as its own plan afterwards.

I will do it if you want it in scope. Say so and I will include it; otherwise I will leave it
recorded as an open gap in `architecture.md` §21.

---

## Files changed overall

New: `backup_rules.xml`, `key.properties.example`, `assets/config/app_config.json`,
`lib/core/config/` (2 files), `lib/core/logging/`, `test/core/database/migration_test.dart`,
`docs/security.md`, `docs/release_process.md`.

Edited: `MainActivity.kt`, `AndroidManifest.xml`, `build.gradle.kts`, `.gitignore`,
`pubspec.yaml`, `analysis_options.yaml`, About feature + its tests, `docs/architecture.md`
(§21 gap list updated to reflect what is actually closed), `CLAUDE.md` if needed.

Nothing inside `docs/guidelines/` is touched.

## How I will report

One commit per phase. At the end, a change log with a table of all gaps and their true state:
closed, still open, or blocked on you. I will not mark the signing gap closed while the build is
still debug-signed.

## Do you approve this plan?

Two questions worth answering with your approval:

1. **Phase 8** — in scope, or defer it to its own plan? (I recommend defer.)
2. **Phase 2** — do you want to generate the keystore yourself after I wire it up, or should the
   signing work stop at the wiring and wait?
