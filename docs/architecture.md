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
|-- core/         # cross-cutting: database, security, theme, errors, links, utils, constants
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
| `lib/core/database/` | Drift schema, DAOs, migrations, FTS5 tables |
| `lib/core/security/` | Shared security constants |
| `lib/core/theme/` | Theme tokens and the Light/Dark mode controller |
| `lib/features/*/presentation/` | Widgets and screens only |
| `lib/features/*/services/` | Business logic; no widget imports |
| `lib/features/*/providers/` | Riverpod wiring between the two |

> **Known deviation.** `lib/application/`, `lib/data/`, `lib/domain/`, and `lib/presentation/` also
> exist but are **empty** — 0 files each. They are leftovers from an abandoned layer-first layout.
> See section 21.

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

- **Connectivity requirement**: `fully offline` in practice today
- **Network permission**: TODO — verify. `AndroidManifest.xml` declares `USE_BIOMETRIC` and one
  other permission; `INTERNET` was not observed, but this MUST be verified against the **merged
  release manifest**, not the source manifest, per the template's instructions.
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

> **Known deviation.** `go_router: ^17.1.0` is declared in `pubspec.yaml` but **never imported**
> anywhere in `lib/`. See section 21.

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
  `android/app/build.gradle.kts`; they differ only by `appLabel` manifest placeholder
- Runtime config mechanism: TODO — no `AppFlavorConfig` equivalent was found in `lib/`. The
  flavors change the app label but do not appear to drive any runtime configuration.
- Build outputs supported: TODO
- Obfuscation: **not configured** — see section 21

---

## 16. UI System

- Theme source of truth: `lib/core/theme/`
- Mode control: `theme_mode_controller.dart`, Light/Dark only, persisted via `shared_preferences`
- Accessibility expectations: as per the template — 48×48 dp targets, WCAG AA contrast, TalkBack
  tested, layouts verified at 1.0×/1.5×/2.0× text scale. TODO — confirm these are actually
  verified rather than merely intended.

---

## 17. Logging

TODO — no logging framework was found. `pubspec.yaml` declares no `logger` package. The
engineering standard requires structured logging under `Sensitive Data Extension`, with verbose
logging gated by flavor config and no protected data in logs. See section 21.

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | Services across all 15 feature modules | Backfilled by Slice E of the remediation plan |
| Widget | Settings sections, navigation, screen states | |
| Integration | `integration_test/lock_gate_test.dart` | Lock gate only |
| Performance | none | TODO |

### Critical Test Areas

- App lock trigger and re-authentication across restart — covered
- Attachment encryption round-trip and temp-file cleanup — covered
- Database upgrade path from version 1 to 7 — **TODO, not covered**
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

These are gaps between what the three in-force profiles require and what the app does today.
Found while declaring the profile on 2026-07-25. **None of these are fixed by this document.**

### Release-blocking under `Production App Extension`

- **Risk: release builds are signed with debug keys.**
  `android/app/build.gradle.kts` still carries the Flutter starter code
  `signingConfig = signingConfigs.getByName("debug")` with the `TODO: Add your own signing config`
  comment. An app signed with the debug key cannot be updated later by a properly signed build,
  and the debug key is not secret. This also breaks `guideline.md`, which the manifest names as
  the source of truth for keystore rules.
  *Mitigation:* create a real release keystore and signing config. Needs its own plan.

- **Risk: `release_process.md` has not been filled in for this app.** No versioning, hardening,
  signing, build, or rollback runbook exists.
  *Mitigation:* fill in the local copy. Separate plan.

- **Risk: obfuscation is not configured.** The standard requires `--obfuscate` on release builds
  (OWASP M7). No build script or documented command applies it.
  *Mitigation:* add it to the release runbook along with a symbol-storage location.

### Required under `Sensitive Data Extension`

- **Risk: `security.md` has not been filled in.** No threat model, no sensitive-data inventory, no
  crypto design record, no OWASP Mobile Top 10 sign-off, and no data retention and purge policy.
  Section 15.4 requires a user-accessible "delete all data" action; whether one exists is unverified.
  *Mitigation:* fill in the local copy. Separate plan.

- **Risk: screenshot and screen-recording protection is not implemented.** Section 15.2 states
  `FLAG_SECURE` MUST be enabled. No `FLAG_SECURE` or `setFlags` call was found in
  `MainActivity.kt`. Journal content and attachments are currently capturable by screenshot and
  visible in the Android task switcher.
  *Mitigation:* add `FLAG_SECURE` via the existing method channel pattern.

- **Risk: no structured logging.** Section 15.5 requires structured logging with verbose output
  gated by flavor config. No logging package is present.
  *Mitigation:* choose a logger and define the sensitive-data policy in `security.md`.

- **To verify, not yet a confirmed violation: secrets in SharedPreferences.** Section 15.2 states
  sensitive values MUST NOT be stored in `SharedPreferences`.
  `method_channel_journal_secret_store.dart` and `platform_attachment_key_manager.dart` both use
  it. The code comments say the native side Keystore-wraps the secret first, so only ciphertext
  is stored — which would be compliant. This needs an actual read of `MainActivity.kt` to confirm.

### Core Baseline hygiene

- **Risk: four empty leftover folders.** `lib/application/`, `lib/data/`, `lib/domain/`, and
  `lib/presentation/` contain zero files. They contradict the declared Tier 2 feature-first
  structure and will mislead anyone reading the tree.
  *Mitigation:* delete them.

- **Risk: `go_router` is an unused dependency.** Declared at `^17.1.0`, imported nowhere.
  Unused dependencies are supply-chain surface (OWASP M2).
  *Mitigation:* remove it, or adopt it and retire the imperative navigation in `app.dart`.

- **Risk: `lib/app/app.dart` is 2,568 lines.** It holds the shell, navigation, and the entire
  settings UI. This is well past the point where it should be split.
  *Mitigation:* extract the settings screen into its own feature module.

- **Risk: analyzer config is stock.** `analysis_options.yaml` includes `flutter_lints` (pinned at
  `^6.0.0`, satisfying the pin requirement) but adds none of the stricter rules the standard
  recommends as a baseline.
  *Mitigation:* add the recommended rule set from engineering standard section 16.1.

- **Risk: database migration path from v1 to v7 is untested.** The standard names this a critical
  test area. A migration bug destroys journal entries with no recovery path.
  *Mitigation:* add a migration test.

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
