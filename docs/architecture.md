# Architecture — SreerajP Journal Vault

> **This is the local copy.** It overrides `docs/guidelines/architecture.md` for this app, per the
> "local copy wins" rule in [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md).
>
> Sections marked `TODO` are not yet decided. They are left empty on purpose rather than filled
> with invented content, as the template instructs.

Last reviewed: 2026-07-25

## 1. Scope

- Product: `SreerajP_Journal_Vault`
- Repository type: `application`
- **Engineering standard profiles in force — all three:**

| Profile | In force | Why |
|---|---|---|
| `Core Baseline` | **Yes** | Mandatory for every Flutter application repository. |
| `Production App Extension` | **Yes** | The project is planned and built to a release standard — `SreerajP_Journal_Vault_Plan.md` sets "production-ready" V1 goals, a release delivery sequence, and release-candidate sign-off gates. Android `dev`/`prod` flavors already exist. Distribution today is sideload-to-self only, but the release discipline still applies: a bad build loses real journal content. |
| `Sensitive Data Extension` | **Yes** | Locally encrypted content (AES-256-GCM attachments), auth secrets (PIN verifier and journal secrets in the Android Keystore), encrypted sync payloads, and personal diary content that is PII by definition. |

- Platforms: `Android` (primary, minimum API 28). Flutter scaffolding for `iOS`, `Web`, `Windows`,
  `Linux`, `macOS` exists in the repository but is not a supported target.

### What being in all three profiles means

These documents are binding for this app, not optional:

- `docs/guidelines/guideline.md` — cross-app conventions; **source of truth for keystore rules**
- `docs/guidelines/flutter_project_engineering_standard.md` — Core Baseline **plus** the
  Production and Sensitive Data sections, including the OWASP Mobile Top 10 checklist (15.3) and
  the data retention/purge policy (15.4)
- `docs/guidelines/release_process.md` — not yet filled in for this app
- `docs/guidelines/flutter_build_flavors_guide.md` — flavors are already in use
- `docs/guidelines/security.md` — not yet filled in for this app

---

## 2. Goals And Non-Goals

TODO — not yet written down. `SreerajP_Journal_Vault_Plan.md` has per-milestone goals but no
stated product-level non-goals.

---

## 3. Architecture Summary

The app uses a Tier 2 feature-first structure with Riverpod for state management. Screens live
under `lib/features/<feature>/presentation/`, business logic under `.../services/`, and Riverpod
providers under `.../providers/`. Persistence is a Drift (SQLite) database at
`lib/core/database/app_database.dart` with FTS5 virtual tables for full-text search. Attachments
are stored as AES-256-GCM encrypted files outside the database, with keys held by the Android
Keystore and reached through a platform method channel. The app is single-device today; a
multi-device encrypted sync module exists under `lib/features/sync/` but its transport is
TODO — see section 7.

---

## 4. Repository Structure

### Current Structure Tier

- `Tier 2` (feature-first)
- Why this tier is appropriate now:
  - 15 distinct feature areas under `lib/features/`, each with its own presentation, service, and
    provider layers.
  - Feature count and cross-feature coupling are past the point where a flat `Tier 1` layout stays
    readable.

### Top-Level Source Layout

```text
lib/
|-- app/          # app shell, routing, bottom nav, settings UI (app.dart)
|-- core/         # cross-cutting: config, logging, database, security, theme,
|                 # errors, links, utils, constants
|-- features/     # 15 feature modules (see below)
`-- main.dart     # composition root and provider overrides
```

Feature modules under `lib/features/`: `about`, `attachments`, `backup`, `entries`, `home`,
`import`, `insights`, `journal_lock`, `lock_gate`, `permissions`, `search`, `security`,
`smart_tags`, `sync`, `timeline`.

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/app/` | App shell, `MaterialApp`, bottom navigation, settings screen |
| `lib/core/config/` | `AppConfig` + `ConfigService` (About, fixed paths per `guideline.md` §1) and `AppFlavorConfig` |
| `lib/core/logging/` | `AppLogger` — the only logging entry point |
| `lib/core/database/` | Drift schema, DAOs, migrations, FTS5 tables |
| `lib/core/security/` | Shared security constants |
| `lib/core/theme/` | Theme tokens and the Light/Dark mode controller |
| `lib/features/*/presentation/` | Widgets and screens only |
| `lib/features/*/services/` | Business logic; no widget imports |
| `lib/features/*/providers/` | Riverpod wiring between the two |

> Four empty leftover folders (`lib/application/`, `lib/data/`, `lib/domain/`, `lib/presentation/`)
> were deleted on 2026-07-25. They contained no files at all — only directory skeletons, some of
> them (`copy_todos`, `daily_list`, `recurring_tasks`) scaffolding from a different app.

---

## 5. App Initialization Sequence

TODO — needs to be read out of `lib/main.dart` and written down. The template warns that a wrong
order here causes crashes that only appear in release builds, so this is worth doing properly
rather than guessing.

---

## 6. App Lifecycle Behavior

Partly implemented — `AppLockController` in `lib/features/lock_gate/app_lock_controller.dart`
observes lifecycle changes and drives the lock gate.

TODO — the full state-by-state table is not yet documented. Note that the engineering standard
(section 12.4 table) requires that under `Sensitive Data Extension`, `paused` MUST flush unsaved
data and trigger the app lock.

---

## 7. Offline Behavior

- **Connectivity requirement**: `fully offline`
- **Network permission**: **`INTERNET` is absent.** Verified 2026-07-25 against the merged
  `prodRelease` manifest at
  `build/app/intermediates/merged_manifests/prodRelease/processProdReleaseManifest/AndroidManifest.xml`,
  not the source manifest. (It *is* present in debug builds — Flutter injects it for hot reload.)
- **Offline data source**: Drift / SQLite

The `lib/features/sync/` module implements encrypted sync protocol and conflict resolution logic,
but no network client is present in `pubspec.yaml` (no `dio`, no `http`). So sync logic exists
without a transport. TODO — decide whether sync is deferred, or transport-agnostic by design.

Because the app is currently offline, the template's offline obligations apply: dependency audit
for transitive network activity, and an airplane-mode integration test. Neither exists yet.

---

## 8. State Management

- Primary pattern: **Riverpod** (`flutter_riverpod: ^3.3.1`)
- Why this pattern was chosen:
  - Mandated by `AGENTS.md` as a workspace-wide constraint.
  - Compile-safe dependency overrides make the security services testable — `main.dart` overrides
    the journal secret store and lock providers.
- State boundaries:
  - Widgets own: layout, local form state, animation
  - State layer owns: screen state via Riverpod notifiers in `*/providers/`
  - Services own: crypto, database access, business rules in `*/services/`

---

## 9. Data Flow

```text
Widget -> Riverpod provider -> Service -> Drift DAO -> SQLite
```

Attachments take a parallel path: `Service -> AttachmentCryptoStorage -> encrypted file on disk`,
with key material fetched over a `MethodChannel` to the Android Keystore.

### Rules

- Widgets must not know: SQL, crypto primitives, file paths, method channels
- Services must not know: navigation, user-facing copy
- Repositories abstract: TODO — this app uses DAOs directly rather than a repository layer.
  Record whether that is a deliberate choice.

---

## 10. Error Handling Architecture

TODO. `lib/core/errors/` exists but has not been reviewed for this document. The template
requires a documented exception hierarchy, a global handler in `main()`, and an escalation policy.

---

## 11. Domain Model

### Current Schema Version

SQLite schema version: **7** (`lib/core/database/app_database.dart`)

Migration history, read from the `onUpgrade` strategy:

| Version | Change Summary |
|---------|---------------|
| 1 | Initial schema |
| 2 | `entryTags`, `attachmentTexts`; FTS5 tables created and backfilled from `entries` |
| 3 | `entryRevisions`, `voiceNotes` |
| 4 | `backupLogs` |
| 5 | `syncMetadata`, `syncConflicts`, `syncLogs` |
| 6 | `autoLockProfiles`, `attachmentLocks`, `securityEvents`, `entryMoods` |
| 7 | `appSettings` columns: attachment storage tree label, migration target, migration failure, `updatedAt` |

`PRAGMA foreign_keys = ON` is set in `beforeOpen`.

### Core Models Or Entities

TODO — the Drift table set is large and has not been summarised here yet.

### Database Indexes

TODO — not yet audited. FTS5 covers entry title and plain text; other query paths are unverified.

---

## 12. Dependency Management And Injection

- DI approach: Riverpod provider overrides at the composition root (`lib/main.dart`)
- Test replacement strategy: provider overrides with in-memory fakes — e.g.
  `_InMemoryJournalSecretStore` is retained as a test-only default

---

## 13. Navigation

- Navigation approach: **`Navigator` 1.0** — `MaterialApp` with a `NavigationBar` shell in
  `lib/app/app.dart` and imperative `Navigator.push` for secondary routes
- Route definition location: inline in `lib/app/app.dart`
- Protected-route strategy: a lock gate wraps the shell; `AppLockController` drives it
- Deep-link support: no

> `go_router` was removed from `pubspec.yaml` on 2026-07-25 — it was declared but never imported.

---

## 14. Persistence And External Systems

### Local Storage

- Database: Drift over `sqlite3_flutter_libs`
- WAL mode: TODO — not verified
- Key-value storage: `shared_preferences`
- Secure storage: Android Keystore via a `MethodChannel` implemented in `MainActivity.kt`
  (channel `sreerajp.journal_vault/attachment_keys` and a separate PIN-verifier channel).
  No `flutter_secure_storage` dependency; the native implementation wraps secrets with a
  Keystore-resident AES key before persisting the ciphertext in SharedPreferences.

### Network

- Network client: none
- Offline behavior: fully offline (see section 7)

### Platform Channels Or Native Integrations

- Attachment key manager: vends Keystore-backed AES keys for attachment encryption
- Journal secret store: persists Keystore-wrapped journal secrets
- `local_auth`: device credential and biometric prompts

---

## 15. Environment And Build Model

- Flavors used: `dev` and `prod` on flavor dimension `env`, defined in
  `android/app/build.gradle.kts`. They differ only by the `appLabel` manifest placeholder — they
  share one application ID and so cannot coexist on a device (see section 21).
- Runtime config mechanism: `AppFlavorConfig` (`lib/core/config/app_flavor_config.dart`), added
  2026-07-25. Reads `APP_FLAVOR` then `FLUTTER_APP_FLAVOR`, defaulting to `prod`. Currently
  gates verbose logging only.
- Build outputs supported: release APK, `--split-per-abi` for sideloading. No app bundle (no
  store distribution). See `release_process.md`.
- Obfuscation: **enabled** for release builds via `--obfuscate --split-debug-info`, alongside R8.
  Symbols are git-ignored and must be archived per release.

---

## 16. UI System

- Theme source of truth: `lib/core/theme/`
- Mode control: `theme_mode_controller.dart`, Light/Dark only, persisted via `shared_preferences`
- Accessibility expectations: as per the template — 48×48 dp targets, WCAG AA contrast, TalkBack
  tested, layouts verified at 1.0×/1.5×/2.0× text scale. TODO — confirm these are actually
  verified rather than merely intended.

---

## 17. Logging

- Logger implementation: `AppLogger` (`lib/core/logging/app_logger.dart`) over the `logger`
  package, added 2026-07-25. The six standard levels; `AppLogger.init()` runs first in `main()`.
- Log file location: **none.** Console output only — a log file in an encrypted journal app is
  another place for content to leak, and nothing needs post-hoc retrieval. Deliberate, not an
  omission.
- Log rotation policy: n/a, no files.
- Verbose logging gate: `AppFlavorConfig.enableVerboseLogging` — `trace` and `debug` are silent
  outside the `dev` flavor.
- Sensitive data policy: never log journal content, attachment names or bytes, PINs, salts,
  verifiers, or key material. `AppLogger.redact()` masks values that might carry user data. Full
  policy in `security.md` section 9.

> Pre-existing log statements elsewhere in the codebase have not been audited against this
> policy — the policy and the logger are both newer than the code. See section 21.

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | Services across all 15 feature modules | Backfilled by Slice E of the remediation plan |
| Widget | Settings sections, navigation, screen states | |
| Integration | `integration_test/lock_gate_test.dart` | Lock gate only |
| Performance | none | TODO |

235 tests pass as of 2026-07-25, with one known failure (see section 21).

### Critical Test Areas

- App lock trigger and re-authentication across restart — covered
- Attachment encryption round-trip and temp-file cleanup — covered
- Database upgrade path from version 1 to 7 — **covered** since 2026-07-25
  (`test/core/database/migration_test.dart`), including data survival. Its stated limits are
  documented at the top of that file.
- Backup/restore round-trip — **not covered**, see `security.md` section 17
- Malformed import input — **not covered**
- Error boundary behavior for unhandled exceptions — TODO

---

## 19. Operational Constraints

- Minimum supported OS versions: Android API 28
- Team constraints: single developer
- Performance constraints: template defaults apply (cold start under 2 s, 16 ms frame budget).
  TODO — never measured.

---

## 20. Decisions And Tradeoffs

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| Profile declaration | All three profiles | Encrypted local content plus a release-oriented plan | Binds the app to release and security rules that are not yet met — see section 21 |
| State management | Riverpod | Mandated by `AGENTS.md`; testable overrides | Learning curve; provider sprawl if unmanaged |
| Persistence | Drift + FTS5 | Type-safe SQL, migrations, built-in full-text search | Code generation step in the build |
| Attachment storage | Encrypted files outside the DB | Keeps the database small; allows SD-card migration | Two things to keep consistent — DB rows and files on disk |
| Secure storage | Native Keystore method channel | Avoids a plugin dependency; direct Keystore control | Custom native code to maintain and test |

---

## 21. Known Risks And Follow-Ups

Gaps between what the three in-force profiles require and what the app does. Opened 2026-07-25
when the profile was declared; worked through the same day.

### Closed on 2026-07-25

| Gap | How it was closed |
|---|---|
| No screenshot protection | `FLAG_SECURE` set app-wide in `MainActivity.onCreate`. Screenshots and task-switcher previews are now blocked everywhere. |
| Android auto-backup enabled | `allowBackup="false"` plus `res/xml/data_extraction_rules.xml` blocking cloud backup **and** device transfer. Verified in the merged release manifest. |
| Obfuscation not configured | Release builds verified working with `--obfuscate --split-debug-info`. Symbols git-ignored. |
| No R8 / ProGuard | Enabled with keep rules in `android/app/proguard-rules.pro`. First run failed on 11 Play Core classes; `-dontwarn` added. |
| Signing secrets not git-ignored | `.gitignore` now covers `key.properties`, `*.jks`, `*.keystore`, `/build/symbols/`. |
| Four empty leftover folders | Deleted. They held only directory skeletons — `lib/presentation/screens/` contained folders from a **different app** (`copy_todos`, `daily_list`, `recurring_tasks`). |
| `go_router` unused dependency | Removed. |
| Stock analyzer config | Stricter rule set from standard §16.1 added. Surfaced 48 issues, all fixed. |
| About screen hard-codes field names | Replaced with the `guideline.md` §1 config pattern: `assets/config/app_config.json` + `lib/core/config/`. The screen now loops `details`. |
| Migration v1→v7 untested | 7 tests added, mutation-verified. |
| No structured logging | `AppLogger` + `AppFlavorConfig` added; verbose gated to the `dev` flavor. |
| Flavors drove no runtime config | `AppFlavorConfig` now reads `APP_FLAVOR` / `FLUTTER_APP_FLAVOR`. |
| `security.md` blank | Filled — see [`security.md`](security.md). |
| `release_process.md` blank | Filled — see [`release_process.md`](release_process.md). |
| **Resolved as compliant:** secrets in SharedPreferences | Read `MainActivity.kt`: `wrapPayload()` AES-GCM-encrypts under a Keystore-resident key with `setRandomizedEncryptionRequired(true)`. Only `iv:ciphertext` is stored. Satisfies §15.2 — no change needed. |

### Still open — release-blocking

- **The release keystore does not exist.** The Gradle wiring is in place and reads
  `android/key.properties`, but with no keystore the build falls back to the **debug key** and
  prints a warning. A debug-signed build must not be installed: switching to a real key later
  requires uninstalling, which destroys all journal data.
  *Action:* run the `keytool` command in [`release_process.md`](release_process.md) section 0.

- **R8 has never been runtime-verified.** It compiles, but no shrunk, obfuscated build has run on
  a device. Missing keep rules fail only at runtime.
  *Action:* the smoke-test list in `release_process.md` section 6.2.

### Still open — Sensitive Data

Detailed in [`security.md`](security.md) section 17. Summary:

- **No "Delete all data" action** anywhere in `lib/`. Required by standard §15.4.
- **The SQLite database is not encrypted at rest** — entry text and the FTS index are plain
  inside the app-private directory. Risk-accepted (OWASP M9); only defeated by root or an
  offline flash dump, both out of scope.
- **The attachment crypto format has no version byte** (M10). Cheap to fix now, expensive later.
- **No backup/restore round-trip test**, and **no malformed-import test**.
- **Existing log statements not yet audited** against the new logging policy.
- **`ACCESS_NETWORK_STATE` and `WAKE_LOCK`** arrive transitively from plugins and are unused.
- **No retention caps** on entry revisions, security events, or sync logs.

### Still open — Core Baseline

- **`lib/app/app.dart` is 2,568 lines**, holding the shell, navigation, and the whole settings UI.
  Deliberately deferred to its own plan: it is a pure refactor with real regression risk across
  every settings flow, and it fixes no security or correctness problem.
  *Action:* extract settings into `lib/features/settings/`.

- **One pre-existing test failure.** `test/widget_test.dart` → "Journal detail groups entries and
  reacts to entry CRUD" was already failing before this work began and still is. Everything else
  passes (235 tests).

- **95 of 132 source files do not match `dart format`.** Pre-existing: Dart 3.11 changed the
  formatter style and the codebase predates it. Files added or edited on 2026-07-25 are
  formatted; the rest are not. Reformatting is mechanical but touches nearly every file, so it
  was kept out of the security commits. Note `dart format .` crashes on stale paths under
  `build/` — name the source directories instead.

- **`dev` and `prod` flavors share one application ID**, so they cannot be installed side by side.
  Installing a dev build over the real one destroys its data. Add an `applicationIdSuffix` to the
  dev flavor before ever using it on the device holding real entries.

---

## 22. Related Documents

- `README.md`
- [`docs/GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md) — index of all guideline documents
- `docs/guidelines/flutter_project_engineering_standard.md`
- `docs/guidelines/guideline.md` — source of truth for keystore rules
- `docs/guidelines/flutter_build_flavors_guide.md` — flavors are in use
- `docs/guidelines/release_process.md` — **required**, not yet filled in for this app
- `docs/guidelines/security.md` — **required**, not yet filled in for this app
- `../SreerajP_Journal_Vault_Plan.md` — product and milestone plan
- `../AGENTS.md` — workspace-wide stack constraints
