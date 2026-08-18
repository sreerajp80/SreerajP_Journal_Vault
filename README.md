# SreerajP Journal Vault

A private, encrypted journal for Android. Entries are rich text, the database itself is encrypted
at rest with SQLCipher, attachments are encrypted with AES-256-GCM, both keyed from the Android
Keystore — and the whole app works offline; it never asks for the `INTERNET` permission.

Before changing anything, read [`CLAUDE.md`](CLAUDE.md) or [`AGENTS.md`](AGENTS.md) (same rules,
one for Claude Code and one for other AI tools) and the design docs under [`docs/`](docs/).

---

## 1. Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.44.8 (stable) |
| Dart | 3.12.2 |
| JDK | 17 |
| Android SDK | compileSdk / targetSdk 36, **minSdk 28** |
| Gradle | 8.14 (via the wrapper — nothing to install) |
| Android Gradle Plugin | 8.11.1 |
| Kotlin | 2.2.20 |

Android is the only supported target. The iOS, Web, Windows, Linux and macOS folders are Flutter
scaffolding and are not built or tested.

---

## 2. Setup from a clean clone

```sh
git submodule update --init --recursive
git config core.hooksPath .githooks
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor dev
```

Line by line:

1. **`git submodule update`** fills [`docs/guidelines/`](docs/), the shared guideline documents.
   They live in a separate repository and are read-only from here.
2. **`git config core.hooksPath`** turns on the pre-commit hook. Git does not track `.git/hooks/`,
   which is why the hook lives in `.githooks/` and needs this one-time command per clone. The hook
   blocks absolute local paths from reaching `plans/`, `change_log/` and `docs/`, then runs the
   formatter and the analyzer. See section 8.
3. **`build_runner`** generates `lib/core/database/app_database.g.dart` from the Drift table
   definitions. Generated files **are** committed, so this only matters after you change a table.
4. **`--flavor dev`** is required. This app defines flavors, so a bare `flutter run` fails.

---

## 3. Run

```sh
flutter run --flavor dev     # daily development
flutter run --flavor prod    # production flavor, debug tooling still attached
```

There are two flavors on the `env` dimension, defined in `android/app/build.gradle.kts`:

| Flavor | Display name | Signing |
|---|---|---|
| `dev` | SreerajP Journal Vault(dev) | Debug keystore |
| `prod` | SreerajP Journal Vault | Release keystore (`android/key.properties`) |

> **Warning:** both flavors share one application ID today, so they cannot be installed side by
> side. Installing a dev build over a real one destroys its data. Tracked in
> [`docs/architecture.md`](docs/architecture.md) section 21.

---

## 4. Environment values

The app reads its flavor at runtime through `AppFlavorConfig`
(`lib/core/config/app_flavor_config.dart`).

| Value | Where it comes from | Default | What it does |
|---|---|---|---|
| `FLUTTER_APP_FLAVOR` | Set by Flutter itself from `--flavor`. Do not pass it by hand. | — | The flavor the app was built with |
| `APP_FLAVOR` | `--dart-define=APP_FLAVOR=dev` | `prod` | Overrides the flavor. Useful for a desktop or test run where `--flavor` does not apply |

There are no other `--dart-define` values, no API keys, and no `.env` file. Everything the app
shows on the About screen comes from [`assets/config/app_config.json`](assets/config/app_config.json).

---

## 5. Tests

```sh
flutter test                                    # all unit and widget tests
flutter test test/features/entries              # one folder
flutter test --coverage                         # with coverage
flutter test integration_test/lock_gate_test.dart -d <device>   # end-to-end, needs a device
flutter test integration_test/encrypted_database_test.dart -d <device>  # Keystore + SQLCipher on device
```

The database is encrypted at rest, so two checks are worth knowing about. On the host,
`flutter test test/core/database/encrypted_database_test.dart` proves an existing plain vault
converts without losing a row. On a device, the command above proves the Keystore hands back a
usable key and that `libsqlcipher.so` really shipped in the APK.

`test/` mirrors `lib/`, so the test for `lib/features/backup/services/backup_service.dart` is at
`test/features/backup/services/`.

Static checks, both of which must be clean before a commit:

```sh
flutter analyze
dart format --set-exit-if-changed lib test integration_test
```

> Give `dart format` the source folders by name. Plain `dart format .` crashes on stale paths
> under `build/`.

---

## 6. Code generation

Two generators run in this project.

**Drift** — after changing any table, DAO, or query in `lib/core/database/`:

```sh
dart run build_runner build --delete-conflicting-outputs
```

**Localization** — after editing any file in `lib/l10n/`:

```sh
flutter gen-l10n
```

Never hand-edit a generated file (`*.g.dart`, `app_localizations*.dart`). Change the source and
re-run the generator.

---

## 7. Adding a database migration

The schema lives in `lib/core/database/app_database.dart`. The current `schemaVersion` is **8**.

1. Change or add the table.
2. Raise `schemaVersion` by one.
3. Add a matching `if (from < <new version>) { … }` block to the `onUpgrade` handler in
   `MigrationStrategy`. Never edit an existing block — a user on an old version still runs it.
4. Run `dart run build_runner build --delete-conflicting-outputs`.
5. Add a test to `test/core/database/` that opens a database at the previous version, runs the
   migration, and checks the result. Every migration from v1 up has one.
6. Run `flutter test`.

A schema change without a migration and a test is not finished.

---

## 8. Building a release

Read [`docs/release_process.md`](docs/release_process.md) first — it is the full runbook, and it
covers creating the keystore, which does not exist yet.

```sh
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/ --split-per-abi
```

Distribution is sideload-to-self, so the APK is what ships; there is no app bundle.

> **Signing.** The release build reads `android/key.properties`, which is git-ignored along with
> `*.jks` and `*.keystore`. If that file is missing the build silently falls back to the **debug
> key** and prints a warning. A debug-signed build must never be installed on a device holding
> real entries — moving to a real key later needs an uninstall, and that destroys all journal data.

Keep the obfuscation symbols from every release. They are the only way to read a later crash
trace, and they are git-ignored on purpose.

---

## 9. Repository hygiene

The pre-commit hook in `.githooks/pre-commit` runs three checks: the absolute-path scan, the
formatter, and the analyzer. To audit every tracked file for absolute paths at once:

```sh
sh tool/check_absolute_paths.sh --all
```

`plans/`, `change_log/` and `docs/` may become public, so they must use relative repository paths
only and must never carry local system details or secrets. Full rule in
[`docs/workflow_rules.md`](docs/workflow_rules.md).

---

## 10. Documentation map

| File | What it holds |
|---|---|
| [`docs/architecture.md`](docs/architecture.md) | Layers, data flow, schema, decisions, and the honest list of known gaps (section 21) |
| [`docs/security.md`](docs/security.md) | Threat model, crypto design, permissions, OWASP checklist |
| [`docs/release_process.md`](docs/release_process.md) | Versioning, keystore, hardening, build, verify, rollback |
| [`docs/project_structure.md`](docs/project_structure.md) | The file tree and what each folder owns |
| [`docs/dependencies.md`](docs/dependencies.md) | Every package, why it is there, and the blocked list |
| [`docs/workflow_rules.md`](docs/workflow_rules.md) | Plan → approve → log, and the privacy rule |
| [`docs/implementation_plan.md`](docs/implementation_plan.md) | The phase-by-phase build roadmap |
| [`docs/implementation_progress.md`](docs/implementation_progress.md) | What is done, partial, and open |
| [`docs/GUIDELINES_MANIFEST.md`](docs/GUIDELINES_MANIFEST.md) | Index of the shared Flutter guidelines |
| [`CHANGELOG.md`](CHANGELOG.md) | User-facing release history |
