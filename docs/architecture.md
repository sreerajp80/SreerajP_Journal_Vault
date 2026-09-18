# Architecture — SreerajP Journal Vault

> **This is the local copy.** It overrides `docs/guidelines/architecture.md` for this app, per the
> "local copy wins" rule in [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md).
>
> Sections marked `TODO` are not yet decided. They are left empty on purpose rather than filled
> with invented content, as the template instructs.

Last reviewed: 2026-09-15 (against guidelines submodule commit `7ed5a36`, 2026-09-13)

## 1. Scope

- Product: `SreerajP_Journal_Vault`
- Repository type: `application`
- **Engineering standard profiles in force — all three:**

| Profile | In force | Why |
|---|---|---|
| `Core Baseline` | **Yes** | Mandatory for every Flutter application repository. |
| `Production App Extension` | **Yes** | The project is planned and built to a release standard — `journal_vault_plan.md` sets "production-ready" V1 goals, a release delivery sequence, and release-candidate sign-off gates. Android `dev`/`prod` flavors already exist. Distribution today is sideload-to-self only, but the release discipline still applies: a bad build loses real journal content. |
| `Sensitive Data Extension` | **Yes** | Locally encrypted content (AES-256-GCM attachments), auth secrets (PIN verifier and journal secrets in the Android Keystore), encrypted sync payloads, and personal diary content that is PII by definition. |

- Platforms: `Android` (primary, minimum API 28). Flutter scaffolding for `iOS`, `Web`, `Windows`,
  `Linux`, `macOS` exists in the repository but is not a supported target.

### Toolchain in force

Pinned 2026-07-25. `pubspec.yaml` enforces the Flutter and Dart floors; the rest are set in
`android/`.

| Tool | Version | Where it is set |
|---|---|---|
| Flutter | `3.44.8` (stable, revision `058e0af2c2`) | `pubspec.yaml` → `environment.flutter` |
| Dart | `3.12.2` | `pubspec.yaml` → `environment.sdk` |
| JDK (Android) | Java 17 | `android/app/build.gradle.kts` |
| Gradle | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties` |
| AGP | 8.11.1 | `android/settings.gradle.kts` |
| Kotlin | 2.2.20 | `android/settings.gradle.kts` |
| Android SDK | `minSdk 28`, `compileSdk`/`targetSdk` from Flutter (36) | `android/app/build.gradle.kts` |

**On Gradle/AGP/Kotlin being behind the template.** The Flutter 3.44 app template now defaults to
Gradle 9.1.0, AGP 9.0.1 and Kotlin 2.3.20 — AGP 9 is no longer paused as older guideline copies
say. The versions above are still well inside the range Flutter 3.44.8 supports
(`maxKnownAndSupportedAgpVersion` is `9.1`), and the build works, so the move to AGP 9 is a
deliberate **later** item: it is a breaking-change migration with no benefit to this app today.
It needs its own plan. Note `docs/guidelines/flutter_build_flavors_guide.md` still states
"AGP 8.x — NOT 9.x"; that file lives in the read-only submodule and cannot be corrected here.

### What being in all three profiles means

These documents are binding for this app, not optional:

- `docs/guidelines/guideline.md` — cross-app conventions; **source of truth for keystore rules**
- `docs/guidelines/flutter_project_engineering_standard.md` — Core Baseline **plus** the
  Production and Sensitive Data sections, including the OWASP Mobile Top 10 checklist (15.3) and
  the data retention/purge policy (15.4)
- `docs/guidelines/release_process.md` — filled in locally as [`release_process.md`](release_process.md)
- `docs/guidelines/flutter_build_flavors_guide.md` — flavors are already in use
- `docs/guidelines/security.md` — filled in locally as [`security.md`](security.md)
- `docs/guidelines/CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md` — the root `CLAUDE.md` and
  `AGENTS.md`
- `docs/guidelines/DOCS_FOLDER_GUIDELINE.md` — how files in this `docs/` folder are shaped

Two rules from the 2026-09 guideline update shape the whole app, so they are named here:

- **Three languages.** The app ships English, Malayalam and Sanskrit, with an in-app language
  picker. See section 16.
- **Built for Google Play.** Even while it is sideloaded, the app must pass the Play readiness gate
  in [`release_process.md`](release_process.md) section 9A before any store upload.

---

## 2. Goals And Non-Goals

TODO — not yet written down. `journal_vault_plan.md` has per-milestone goals but no
stated product-level non-goals.

---

## 3. Architecture Summary

The app uses a Tier 2 feature-first structure with Riverpod for state management. Screens live
under `lib/features/<feature>/presentation/`, business logic under `.../services/`, and Riverpod
providers under `.../providers/`. Persistence is a Drift database over **SQLCipher** at
`lib/core/database/app_database.dart` with FTS5 virtual tables for full-text search; the whole
file is encrypted at rest with a key from the Android Keystore, opened by
`lib/core/database/encrypted_database_opener.dart`. Attachments
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
|-- features/     # 16 feature modules (see below)
|-- l10n/         # app_en.arb plus the generated AppLocalizations
`-- main.dart     # composition root and provider overrides
```

Feature modules under `lib/features/`: `about`, `attachments`, `backup`, `entries`, `export`,
`import`, `insights`, `journal_lock`, `lock_gate`, `permissions`, `search`, `security`,
`smart_tags`, `sync`, `tags`, `timeline`.

> `home` is not a feature folder. Home and Search are `_HomeTab` / `_SearchTab` inside
> `lib/app/app.dart`; the standalone screens were deleted on 2026-07-25 as dead code.
> Full tree and folder responsibilities: [`project_structure.md`](project_structure.md).

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/app/` | App shell, `MaterialApp`, bottom navigation, settings screen |
| `lib/core/config/` | `AppConfig` + `ConfigService` (About, fixed paths per `guideline.md` §1) and `AppFlavorConfig` |
| `lib/core/logging/` | `AppLogger` — the only logging entry point |
| `lib/core/database/` | Drift schema, DAOs, migrations, FTS5 tables |
| `lib/core/security/` | Shared security constants, and `VaultEnvelope` / `VaultPayload` — the one password-sealed file format, used by both the backup archive and an encrypted export |
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
- **Offline data source**: Drift / SQLCipher (encrypted SQLite)

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

SQLite schema version: **8** (`lib/core/database/app_database.dart`)

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
| 8 | `tags.colorArgb` — optional per-tag display colour |

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
- Settings is a card menu: the Settings tab lists one card per section and pushes that
  section's own screen (`_SecuritySettingsScreen`, `_AppearanceSettingsScreen`,
  `_StorageSettingsScreen`, `_PermissionsSettingsScreen`, `AboutScreen`)
- Deep-link support: no

> `go_router` was removed from `pubspec.yaml` on 2026-07-25 — it was declared but never imported.

---

## 14. Persistence And External Systems

### Local Storage

- Database: Drift over **SQLCipher**, encrypted at rest. The native library comes from
  `package:sqlite3`'s build hook, selected by the `hooks:` block in `pubspec.yaml`
  (`source: sqlcipher`). `sqlite3_flutter_libs` and `drift_flutter` were removed with A5.1 —
  a second copy of libsqlite3 in the APK can win the symbol lookup and quietly disable
  encryption.
- Database key: 32 bytes from `SecureRandom`, Keystore-wrapped, over the
  `sreerajp.journal_vault/database_key` channel. Passed to SQLCipher as a raw key.
- Plain-to-encrypted migration: `lib/core/database/plain_database_converter.dart`, run on every
  start. It repairs an interrupted conversion before doing anything else.
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
- On-device speech check: `sreerajp.journal_vault/speech` (`onDeviceSpeechStatus`) reports whether
  `SpeechRecognizer` can work offline and which languages it has. `PluginSpeechEngine`
  (`lib/features/entries/services/speech_engine.dart`) reads it; `DictationService` will not
  start without it. The recogniser itself is the `speech_to_text` plugin in on-device mode
- `local_auth`: device credential and biometric prompts

---

## 15. Environment And Build Model

- Flavors used: `dev` and `prod` on flavor dimension `env`, defined in
  `android/app/build.gradle.kts`. They differ only by the `@string/app_name` resource in `src/dev/res` and `src/prod/res` — they
  share one application ID and so cannot coexist on a device (see section 21).
- Runtime config mechanism: `AppFlavorConfig` (`lib/core/config/app_flavor_config.dart`), added
  2026-07-25. Reads `APP_FLAVOR` then `FLUTTER_APP_FLAVOR`, defaulting to `prod`. Currently
  gates verbose logging only.
- Build outputs supported: release APK with `--split-per-abi` for sideloading (used today), and
  an App Bundle for Google Play (built and checked, not yet uploaded). See `release_process.md`.
- App Bundle language splitting is **disabled** (`bundle { language { enableSplit = false } }`),
  so a Play install carries all three languages and the in-app picker can switch to any of them.
- Obfuscation: **enabled** for release builds via `--obfuscate --split-debug-info`, alongside R8.
  Symbols are git-ignored and must be archived per release.

---

## 16. UI System

- Theme source of truth: `lib/core/theme/`
- Mode control: `theme_mode_controller.dart`, Light/Dark only, persisted via `shared_preferences`
- Accessibility expectations: as per the template — 48×48 dp targets, WCAG AA contrast, TalkBack
  tested, layouts verified at 1.0×/1.5×/2.0× text scale. TODO — confirm these are actually
  verified rather than merely intended.
- **Tooltips:** every icon-only control (`IconButton`, FAB, `PopupMenuButton`, icon-only gesture,
  unlabeled navigation destination) has a localized tooltip. `test/helpers/` holds the check.

### Localization

| Item | Decision |
|---|---|
| Languages | `en` (template), `ml`, `sa` — fixed, in that order |
| Strings | `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`, generated into `lib/l10n/` by `flutter gen-l10n` |
| Key naming | Category prefix: `action…`, `label…`, `title…`, `tab…`, `nav…`, `tooltip…` (short, ≤ 20 characters in English and ≤ 22 in Malayalam and Sanskrit), and `desc…`, `help…`, `empty…`, `error…`, `body…`, `aboutDetail…` (long prose allowed) |
| Language choice | `LocaleController` in `lib/core/l10n/`, a Riverpod notifier. Saved under `app_language` (`system`, `en`, `ml`, `sa`) and read in `main.dart` before the first frame. `MaterialApp.locale` follows it; `null` means "follow the system", falling back to English |
| Picker | Settings → Appearance → Language. System default, English, മലയാളം, संस्कृतम्. Applies at once, no restart |
| Sanskrit framework strings | Flutter ships none. `lib/core/l10n/sa_framework_localizations.dart` answers `sa` with the English Material, Cupertino and Widgets strings, registered before the global delegates. The Quill fallback does the same |
| Dates and numbers | `formattingLocale()` in `lib/core/l10n/formatting_locale.dart` — `intl` has no `sa` data, so Sanskrit formats with English patterns |
| Fonts | Noto Sans Malayalam and Noto Sans Devanagari are bundled and set as `fontFamilyFallback`, so neither script depends on the device's fonts |
| About screen | `app_config.json` values are `LocalizedText` (`{en, ml, sa}` maps for prose); row labels come from `aboutDetail<Key>`; the fixed "Made with ❤️ from India" badge ends the screen |
| Gates | `test/l10n/translation_parity_test.dart`, `test/l10n/label_length_test.dart`, `tool/check_sanskrit_markers.sh` (CI and pre-commit) |
| Review | Every new Malayalam or Sanskrit term is listed as "needs native-reader review" in its change log |

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
| Integration | `integration_test/lock_gate_test.dart`, `integration_test/encrypted_database_test.dart` | Lock gate, and the Keystore key plus SQLCipher packaging (device only) |
| Performance | none | TODO |

235 tests pass as of 2026-07-25, with one known failure (see section 21).

### Critical Test Areas

- App lock trigger and re-authentication across restart — covered
- Attachment encryption round-trip and temp-file cleanup — covered
- Database upgrade path from version 1 to 7 — **covered** since 2026-07-25
  (`test/core/database/migration_test.dart`), including data survival. Its stated limits are
  documented at the top of that file.
- Backup/restore round-trip — **covered** since 2026-08-18
  (`test/features/backup/backup_round_trip_test.dart`), including a restore onto a database
  that shares nothing with the source
- Malformed import input — **not covered**
- Error boundary behavior for unhandled exceptions — TODO

---

## 19. Operational Constraints

- Minimum supported OS versions: Android API 28. **Decision (recorded for Play readiness §9A.2):**
  secrets are wrapped by Keystore keys created with `KeyGenParameterSpec` and the lock flows use
  `BiometricPrompt`-era `local_auth`; both were designed and tested only on API 28+. Lowering it
  needs a security re-review first.
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
| Database encryption | SQLCipher, Keystore raw key | Closes the last plaintext store of journal text; no password to forget | Slower reads, FTS5 most of all; losing the Keystore key loses the vault |
| Attachment storage | Encrypted files outside the DB | Keeps the database small; allows SD-card migration | Two things to keep consistent — DB rows and files on disk |
| Secure storage | Native Keystore method channel | Avoids a plugin dependency; direct Keystore control | Custom native code to maintain and test |

---

## 21. Known Risks And Follow-Ups

Gaps between what the three in-force profiles require and what the app does. Opened 2026-07-25
when the profile was declared; worked through the same day.

### Closed on 2026-07-25

| Gap | How it was closed |
|---|---|
| No screenshot protection | `FLAG_SECURE` set app-wide in `MainActivity.onCreate`. Screenshots and task-switcher previews are blocked everywhere by default; since 2026-08-18 the user can switch this off in Settings, and the change is recorded in the security event log. |
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
- ~~**The SQLite database is not encrypted at rest**~~ — closed 2026-08-18 with A5.1. The vault
  is SQLCipher with a Keystore-held key, and an existing plain database is converted on first
  launch. Two consequences to keep in mind: losing the Keystore key loses the journal, and reads
  are slower. See [`security.md`](security.md) sections 5 and 17.
- **The attachment crypto format has no version byte** (M10). Cheap to fix now, expensive later.
- ~~**No backup/restore round-trip test**~~ — closed 2026-08-18 with A4.1. **No
  malformed-import test** still stands.
- **Existing log statements not yet audited** against the new logging policy.
- **`ACCESS_NETWORK_STATE` and `WAKE_LOCK`** arrive transitively from plugins and are unused.
- **No retention caps** on entry revisions, security events, or sync logs.

### Closed on 2026-07-25 — last-mile integration pass

A second audit looked for a different class of gap: features whose data layer, native layer, and
unit tests all existed and passed, but whose user-facing path was never connected. Five prompts
marked `[COMPLETED]` stopped one step short. See
`plans/20260725_113628_close-last-mile-gaps.md`.

| Gap | How it was closed |
|---|---|
| `AttachmentOpenRouter.open` threw `UnimplementedError`, so tapping any attachment crashed — the editor catches only `AttachmentOpenException`, so it escaped uncaught | Implemented on `open_filex` (already a dependency, otherwise unused). Every `ResultType` maps to an `AttachmentOpenFailure`. 8 tests added covering `open`; the existing test file only ever exercised `resolve`, which is why the stub survived. |
| `migrateStoredFile` threw `UnimplementedError` behind a fully wired migration UI | Implemented both directions over the existing native SAF channel. |
| `encryptAndStore` ignored the storage setting and always wrote app-private — so a migration with zero attachments "succeeded", set `sd_card`, and then silently kept writing app-private | Storage is now location-aware end to end: write, read, delete, and migrate all branch on the `content://` test. The active target is read per write, so a Settings change applies without a restart. |
| `cleanupMigrationArtifacts` was an empty method | Calls `cleanupPendingTreeDocuments` for tree targets. |
| `AttachmentStorageUnavailableException` was defined but never thrown | A removed SD card now surfaces as a real message on write, and as `fileNotFound` on open. |
| Smart Tags unreachable — service, providers, and `SmartTagChipBar` built and tested, imported by no screen | Chip bar mounted in the entry editor, reading the live document text. 4 widget tests added. |
| `minSdk` resolved to 24 via `flutter.minSdkVersion`, against the API 28 required by `AGENTS.md` | Pinned to `minSdk = 28`. Verified in the merged `prodRelease` manifest. |
| The long-standing `widget_test.dart` failure | **Was a test bug, not an app bug.** `enterText` does not pump, so the `setState` in `_markDirty` had not rebuilt when the test looked for the save button's `'Save'` tooltip — it still read `'No unsaved changes'`. One `await tester.pump()` in each of the two affected spots. The editor's dirty tracking was correct all along. |
| Dead code: `search_screen.dart`, `home_screen.dart`, `journal_lock_controller.dart`, `attachment_storage_location_service.dart` | Deleted. Search and Home were reimplemented as `_SearchTab` / `_HomeTab` inside `app.dart`. Before deleting `journal_lock_controller_test`, its one real assertion — unlocked journals clear on re-lock — was ported to a widget test against the live `AppLockNotifier._onLocked` path. |

Test suite went from 235 passing / 1 failing to **257 passing / 0 failing**.

### Closed on 2026-07-25 — in-app attachment viewers

`AttachmentOpenRouter` had computed `inAppPdf` / `inAppAudio` / `inAppArchive` decisions since V1,
and the tests asserted them, but **no screen ever read those values** — `open()` sent every
attachment to an external app through `open_filex`. `pdfrx` and
`just_audio` sat in `pubspec.yaml` imported by nothing. V1 attachment slices 3, 4, 5 and 7 were
unbuilt.

Now delivered:

| Piece | File |
|---|---|
| Host screen, shared shell, owns the temp file | `features/attachments/presentation/attachment_viewer_screen.dart` |
| PDF body (`PdfViewer.file` via `pdfrx`) | `.../pdf_attachment_view.dart` |
| Audio body (`just_audio` behind `AudioPlaybackHandle`) | `.../audio_attachment_view.dart` |
| ZIP listing (`archive`, nothing extracted) | `.../archive_attachment_view.dart` |

- `AttachmentOpenService.prepare` decrypts and returns an `AttachmentOpenSession` without
  launching anything; `openExternally` keeps the old hand-off. The editor picks between them on
  `session.opensInApp`.
- **Temp-file rule:** the viewer deletes the decrypted plaintext on dispose. The external path
  still leaves it in place — the receiving app needs it — and `AttachmentTempFileManager` sweeps
  it. Plaintext never leaves the app cache on the in-app path.
- Audio pauses itself when the app is backgrounded, so nothing keeps playing behind the lock gate.
- 12 widget/unit tests added. Note for future test authors: `testWidgets` runs in a fake-async
  zone, so **awaited real file I/O inside a widget test never completes** — use the `…Sync`
  variants, as `attachment_viewer_screen_test.dart` does.
- `flutter_quill_extensions` was imported by nothing and had no feature behind it, so it was
  removed.

Still deferred: `7z` listing (external hand-off only, as planned), and image/text in-app viewers
(V2).

### Closed on 2026-08-18 — backup restore (A4.1)

`BackupService` could write an archive and check that it decrypted, but nothing could read
one back. A backup that has never been restored is a file, not a backup. Closed by
`lib/features/backup/`. See `plans/20260818_134141_a4-1-backup-restore.md`.

| Piece | File |
|---|---|
| Format versions, manifest, the errors a reader can hit | `features/backup/domain/backup_format.dart` |
| Restore mode, preview, and result models | `features/backup/domain/restore_models.dart` |
| The sealed container, old and new envelopes | `core/security/vault_envelope.dart` (moved out of `features/backup/` by A4.2) |
| Read, plan, dry run, apply, verify | `features/backup/services/backup_restore_service.dart` |
| What backup needs from attachment storage | `features/backup/services/backup_attachment_cipher.dart` |
| The screen, behind a PIN or device check | `features/backup/presentation/restore_backup_screen.dart` |

Three problems were found while building it and fixed in the same pass: entry moods and
saved search presets were never exported, so a "complete" backup silently lost them;
attachment files went into the archive still encrypted with the device key, so they could
not be opened after a phone was replaced; and the archive key came from a fixed salt. No
schema change and no migration were needed — the restore log reuses the free-text `trigger`
column on `backup_logs` with the values `restore` and `pre_restore`.

### Closed on 2026-08-16 — export (A1.1 / W5)

The app imported but never exported. Nothing in `lib/` wrote an entry back out, so the only way
data left the vault was a backup archive that cannot yet be restored — the "one-way door" named in
`docs/enhancement_ideas.md` B2. Closed by `lib/features/export/`. See
`plans/20260816_135333_a1-1-entry-and-journal-export.md`.

| Piece | File |
|---|---|
| Delta → blocks, the shared parser all renderers walk | `features/export/services/delta_document.dart` |
| Markdown / HTML / plain-text renderers | `.../delta_to_markdown.dart`, `.../delta_to_html.dart`, `.../delta_to_plain_text.dart` |
| Reads the database for a scope | `.../export_collector.dart` |
| Self-contained HTML page, fonts embedded | `.../export_html_builder.dart` |
| Native PDF renderer client | `.../html_pdf_service.dart` + `android/.../android/print/JvHtmlToPdf.kt` |
| Packing, zipping, attachment decryption | `.../export_service.dart` |
| The screen | `features/export/presentation/export_screen.dart` |

Decisions worth keeping in mind:

- **PDF goes through a native WebView, not a Dart PDF package.** Malayalam needs real text shaping,
  and the platform WebView does it while keeping the PDF text selectable. Ported from
  `SreerajP_lyricchord` §2.9. The WebView must be **attached to the window** or the print callbacks
  never fire on newer Android — that is the whole reason `JvHtmlToPdf` exists rather than
  `Printing.convertHtml`.
- **No new package dependency.** Reuses `archive` and `file_picker`, so the documented
  `win32` / `file_picker` version knot is untouched.
- **Offline is enforced twice.** The page embeds its fonts as base64 data URIs so it holds no URL
  at all, and the WebView sets `blockNetworkLoads`. The first matters most: the `.html` export is
  opened in the user's own browser, where this app's WebView settings do not apply.
- **Locks are honoured.** A locked journal is not offered in the Settings picker, and a locked
  attachment is never decrypted — both are reported to the user rather than quietly dropped.
- `SecurityEvents` now actually records `export_attempt`, a type the table documented but nothing
  wrote.
- ~155 KB of Noto Sans Malayalam (SIL OFL) added under `assets/fonts/`, listed as an **asset** and
  not a Flutter font: only the export WebView renders with it, and it needs the raw bytes.

**Still deferred:** share-sheet hand-off, exporting across all journals at once, and PDF on
iOS — the native renderer is Android only, and the other three formats work everywhere.
Encrypting the exported file was the fourth item here and was closed on 2026-08-18 by A4.2,
below.

### Closed on 2026-08-18 — one sealed-file format, and encrypted export (A4.2)

A4.1 gave the backup archive a versioned, self-describing envelope. The export file had none,
and the envelope sat inside the backup feature where nothing else could reach it. Closed by
`lib/core/security/`. See `plans/20260818_145453_a4-2-encrypted-export-envelope.md`.

| Piece | File |
|---|---|
| The envelope, moved to core and renamed `VaultEnvelope` | `core/security/vault_envelope.dart` |
| The `JVP1` header that travels inside the sealed bytes | `core/security/vault_payload.dart` |
| Optional `password` on the export build | `features/export/services/export_service.dart` |
| The switch and its two fields | `features/export/presentation/export_screen.dart` |
| Unwrapping a sealed export again | `features/export/presentation/open_encrypted_export_screen.dart` |

Decisions worth keeping in mind:

- **The bytes on disk did not change.** Moving the class was a move, not a format change, so
  every backup written by A4.1 still opens. The A4.1 tests were carried over unchanged apart
  from the new names.
- **The envelope version and the archive format version are now separate numbers.**
  `vaultEnvelopeVersion` says how a file is sealed; `backupFormatVersion` says what the sealed
  bytes contain. They are both 2 today, which is exactly why the coupling was easy to miss.
- **The file name is sealed with the payload.** `Leaving my job.md.jvenc` would give away the
  thing the password hides, so the real name rides inside a `JVP1` header and the file is
  offered as `journal_export_<date>.jvenc`.
- **Argon2id was kept over the family's PBKDF2.** Reasoning in `docs/security.md` section 14.
- `BackupCorruptedException` and `BackupPasswordException` are now type aliases of the core
  exceptions, so backup code and its tests read as backup code while there is only one class.

### Still open — sync has no transport

`SyncEngine` (392 lines) is constructed by nothing, and `SyncProtocol` has no concrete
implementation, so nothing can push or pull. `SyncEncryptionService` and
`ConflictResolutionService` are genuinely implemented and tested; the transport is the gap.

The UI is hidden behind `AppFlavorConfig.enableSyncUi` (currently `false`) rather than left
showing a health dashboard for a sync that cannot run. Prompt 19 is marked `[PARTIAL]`.

*Action:* choose a transport (REST, WebDAV, folder sync), then write a plan for it. Flip the flag
to `isDev` when a transport lands, and delete it when sync ships.

### Closed on 2026-08-18 — guidelines conformance audit

A full re-read of `docs/guidelines/` against the repository. Most of the structural rules were
already met — the Tier 2 `lib/` layout, the About-screen config pattern, the analyzer rule set, the
mirrored `test/` tree, and the keystore `.gitignore` rules all matched. The gaps were in the
instruction files and the documentation set. See
`plans/20260818_100606_guidelines-conformance-audit.md`.

| Gap | How it was closed |
|---|---|
| `AGENTS.md` was a short "Global Prompt Constraints" note, missing every "Always" section from `AGENTS_MD_GUIDELINE.md` | Rewritten as a Thin-profile file: identity table, doc references, hard rules, architecture, commands, flavors, signing, security, localization, style, testing, dependencies, tree, workflow and communication rules. The old stack constraints were folded into the identity table and the hard rules, so nothing was lost. |
| `CLAUDE.md` was missing 11 of the sections `CLAUDE_MD_GUIDELINE.md` marks "Always" | Rewritten to the same Thin-profile shape, carrying the same rules as `AGENTS.md`. The existing profile table, submodule notes and relative-path rule were kept as sections. |
| `README.md` was still the stock Flutter template | Rewritten against standard §21.3: prerequisites with versions, clean-clone setup, environment values, tests, code generation, adding a migration, release build, and a documentation map. |
| `pubspec.yaml` still said "A new Flutter project." | Replaced with the real description, matching `app_config.json`. |
| Five of the eight baseline `docs/` files required by `DOCS_FOLDER_GUIDELINE.md` §6 were missing | Added `workflow_rules.md`, `dependencies.md`, `project_structure.md`, `implementation_plan.md`, `implementation_progress.md`. |
| Two `docs/` files broke the lowercase `snake_case` rule | `AI_Development_Prompts.md` → `ai_development_prompts.md`; `SreerajP_Journal_Vault_Plan.md` → `journal_vault_plan.md`. Every reference in `docs/`, `plans/` and `change_log/` was updated. |
| `.gitignore` was missing six entries from standard §20.4 | Added `*.apk`, `*.aab`, `*.ipa`, `*.msix`, `*.symbols/`, `.flutter-plugins`. |
| No CI at all (standard §19) | `.github/workflows/ci.yml` added — pub get, build_runner, format, analyze, test, and a `dev --debug` build. |
| No `CHANGELOG.md` (standard §21.2) | Added, seeded at 1.0.1. |
| The pre-commit hook only checked absolute paths (standard §19.3) | Now also runs the formatter and the analyzer. |
| Both a `tool/` and a `tools/` folder | The two Python icon scripts moved into `tool/`; `tools/` deleted. |
| **No localization at all** — the largest gap. No `l10n.yaml`, no `lib/l10n/`, no `generate: true`, nothing importing `AppLocalizations`, and about 270 user-visible string literals across roughly 20 files. Mandatory for every app under standard §8.2 and `guideline.md` §3, single-language included. | Mostly closed. `l10n.yaml`, `lib/l10n/app_en.arb` (372 keys, each with an `@key` description), `intl`, and `flutter: generate: true` added; `AppLocalizations.delegate` wired into `MaterialApp`. Every string rendered directly by a widget now reads through `AppLocalizations` — 20 files, including all 2,950 lines of `lib/app/app.dart`. Two literals remain and are correct: `Text('$conflictCount')` and `Text('#${tag.name}')`, both pure data with no words in them. **Two pockets are still open — see below.** The seven tests that build their own `MaterialApp` now pass `AppLocalizations.localizationsDelegates`. |

> **Note on `synthetic-package`.** Standard §8.1 lists `synthetic-package: false` in `l10n.yaml`.
> Flutter 3.44 has removed that option — it warns on every `pub get` and does nothing, because
> writing into `lib/` is now the only behaviour. `output-dir: lib/l10n` says the same thing and is
> what this app sets. The guideline lives in the read-only submodule and cannot be corrected here.

### Closed on 2026-09-16 — localization pockets (opened 2026-08-18)

Both pockets of literal text are gone. The entry template catalogue is text-free
(`EntryTemplate.builtIn(id, category)`) and worded by `entry_template_text.dart`; bodies are
treated as UI text, per language. `export_strings.dart` is deleted: renderers take `ExportLabels`,
omissions and failures are typed (`ExportOmissionReason`, `ExportFailureReason`, `HtmlPdfFailure`)
and worded by `export_text.dart`. See the strict-conformance change log.

### Closed on 2026-09-16 — strict guidelines conformance (opened 2026-09-15)

The guidelines moved from commit `2b381be` to `7ed5a36`. Closed by
`plans/20260915_200933_strict-guidelines-conformance.md`; details in its change log.

| Gap | Rule | How it was closed |
|---|---|---|
| No Sanskrit: no `app_sa.arb`, `supportedLocales` is `en`, `ml` only | standard §8.1–§8.3 | `app_sa.arb` with all 1,657 keys; `appSupportedLocales` = en, ml, sa |
| No Sanskrit framework delegates; Quill fallback does not answer `sa` | §8.3.1 | `sa_framework_localizations.dart`; date picker and dialog tested under `sa` |
| `DateFormat` gets the raw locale — throws under `sa` | §8.3.2, §8.9 | `formattingLocaleTag` everywhere a date or time is formatted |
| No Devanagari font | §8.3.3, §17.4 | Noto Sans Devanagari bundled; `fontFamilyFallback` |
| No in-app language picker, no `app_language` preference | §8.4 | `LocaleController` + Appearance → Language, applied without restart |
| Malayalam values equal to English | §8.2, §8.7 | translated; the rest are unit/format strings on the parity allow-list |
| ARB keys use feature prefixes | §8.6 | every key renamed to a category prefix |
| About config not localized; no `aboutDetail<Key>` labels | `guideline.md` §1.2–§1.6 | `LocalizedText`, lowerCamelCase keys, `aboutDetail*` labels |
| No "Made with ❤️ from India" badge | `guideline.md` §1.7 | `made_with_love.dart`, last on the About screen |
| Icon-only controls without a tooltip | §7.8 | tooltips added; `tooltip_coverage_test.dart` checks screens in all three languages |
| Ritual cards have no Sanskrit text | §8.7 | card text moved to ARB, all three languages |
| Literal text in templates, export, AirQR, sync, time capsules, permissions, security events, typography, share, OCR and more | §8.2, §8.7 | moved to ARB; services and providers hold typed values, presentation words them |
| No `enableSplit = false` | §8.1, release §9A.3 | added to `build.gradle.kts` |
| App label is a manifest placeholder | release §9A.1 | `@string/app_name` per flavor |
| No parity, label-length or tooltip tests; no Sanskrit marker gate | §7.8, §8.5–§8.7 | tests in `test/l10n/`; the gate runs in CI and the pre-commit hook |
| Label budget | §8.6 | English and Malayalam labels shortened; feature-catalogue titles and the app name are the documented exceptions in `label_length_test.dart` |
| 20 files over 500 lines | standard file-length table | every source and test file at or under 500 lines, split into `part` files and sibling tests — see [`project_structure.md`](project_structure.md) section 3 |
| `plans/Remediation_Plan.md` breaks the plan naming rule | §21.1 | renamed to `plans/20260725_000000_remediation-plan.md` |

Still open, because only a person can do it:

- **Fluent-reader review** of every Malayalam and Sanskrit term the plan adds (§8.5.4).
- **Play Console work** — privacy policy URL, Data safety form, content rating, listing assets,
  photo and video permission declaration, internal testing. See `release_process.md` §9A.
- **16 KB page-size and edge-to-edge checks** on a real Android 15+ device.

### Still open — Core Baseline

- **`plans/`, `change_log/`, and four `docs/` files are not tracked by git.** Standard §21.1 lists
  `plans/` and `change_log/` as required documents, and the §21.1.1 privacy rule exists precisely
  because they are committed and may become public. Today they exist only on disk, so the record
  the standard assumes does not exist. Untracked: all of `plans/`, all of `change_log/`, and
  `docs/ai_development_prompts.md`, `docs/journal_vault_plan.md`, `docs/enhancement_ideas.md`,
  `docs/features.md`.
  *Action:* decide deliberately whether these are committed. If yes, `git add` them after a
  privacy pass with `sh tool/check_absolute_paths.sh --all`.

- ~~**`plans/Remediation_Plan.md` does not follow the plan naming rule.**~~ Closed 2026-09-15:
  renamed to `plans/20260725_000000_remediation-plan.md`, references updated.

- ~~**`lib/app/app.dart` is ~2,830 lines.**~~ Closed 2026-09-16: settings live in
  `lib/features/settings/`, and `app.dart` is 431 lines with the rest in part files.

- **The Home tab has no error state.** `_HomeTab` renders a spinner while loading and the list
  once loaded, but a load failure leaves the spinner up forever. The deleted `HomeScreen` had an
  "Unable to load journals" + Retry state and a test for it — but that screen was never reachable,
  so the test was covering a screen no user ever saw. The behaviour is worth adding to `_HomeTab`.

- ~~**88 of 132 source files do not match `dart format`.**~~ **Closed 2026-07-25** during the
  Flutter 3.44.8 upgrade: all 127 source files were reformatted with the Dart 3.12 formatter and
  `dart format --set-exit-if-changed lib test integration_test` now exits 0. Keep it that way —
  and note `dart format .` still crashes on stale paths under `build/`, so always name the source
  directories instead.

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
- `docs/guidelines/release_process.md` — filled in locally as [`release_process.md`](release_process.md)
- `docs/guidelines/security.md` — filled in locally as [`security.md`](security.md)

### This app's own documents

- [`../README.md`](../README.md) — setup, run, test, build
- [`../CLAUDE.md`](../CLAUDE.md) and [`../AGENTS.md`](../AGENTS.md) — project rules for AI tools;
  same content, one file per ecosystem
- [`security.md`](security.md) — threat model, crypto design, OWASP checklist
- [`release_process.md`](release_process.md) — the release runbook
- [`workflow_rules.md`](workflow_rules.md) — plan → approve → log, and the privacy rule
- [`dependencies.md`](dependencies.md) — every package, why it is here, and the held versions
- [`project_structure.md`](project_structure.md) — the file tree and folder responsibilities
- [`implementation_plan.md`](implementation_plan.md) — the phase-by-phase roadmap
- [`implementation_progress.md`](implementation_progress.md) — what is done, partial, and open
- [`journal_vault_plan.md`](journal_vault_plan.md) — product and milestone plan
- [`ai_development_prompts.md`](ai_development_prompts.md) — the numbered build prompts
- [`features.md`](features.md) — what the app does, feature by feature
- [`enhancement_ideas.md`](enhancement_ideas.md) — ideas not yet in a milestone
- [`../CHANGELOG.md`](../CHANGELOG.md) — user-facing release history
