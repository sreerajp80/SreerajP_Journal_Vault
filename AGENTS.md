# AGENTS.md — SreerajP Journal Vault

This file is read by AI agents and LLM coding assistants (Gemini, Antigravity, Cursor, Windsurf,
Codex, and others) at the start of every session in this repository.
Read it before making any change. This is a **Thin** file: it holds identity, commands and rule
summaries, and points to `docs/` for the detail. `CLAUDE.md` carries the same rules for Claude
Code — if you change a rule here, change it there too.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | SreerajP Journal Vault |
| Type | A private, encrypted journal with attachments, search, export and insights |
| Platform(s) | Android only (minSdk 28, targetSdk from Flutter 36). iOS/Web/desktop scaffolding exists but is not a supported target |
| Package / org id | `in.sreerajp.sreerajp_journal_vault` |
| Flutter SDK | 3.44.8 |
| Dart SDK | 3.12.2 |
| State management | `flutter_riverpod` |
| Navigation | `Navigator` 1.0 — a `NavigationBar` shell in `lib/app/app.dart`, imperative `Navigator.push` for secondary routes. No `go_router` |
| Database | Drift over **SQLCipher** (`package:sqlite3`, `source: sqlcipher` build hook) — encrypted at rest, key in the Keystore |
| Secure storage | Android Keystore through a `MethodChannel` in `MainActivity.kt`. No `flutter_secure_storage` |
| Orientation | Both |
| Connectivity | Fully offline — no `INTERNET` permission, no network client |

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| [`docs/architecture.md`](docs/architecture.md) | Changing structure, screens, state, services, models, or the database |
| [`docs/security.md`](docs/security.md) | Touching permissions, logging, storage, crypto, or the manifest |
| [`docs/release_process.md`](docs/release_process.md) | Building a release, versioning, signing, the release checklist |
| [`docs/project_structure.md`](docs/project_structure.md) | Finding where something lives |
| [`docs/dependencies.md`](docs/dependencies.md) | Adding, removing or upgrading any package |
| [`docs/workflow_rules.md`](docs/workflow_rules.md) | Before any change — the plan/approve/log gate |
| [`docs/implementation_progress.md`](docs/implementation_progress.md) | Checking what is built, partial, or still open |
| [`docs/GUIDELINES_MANIFEST.md`](docs/GUIDELINES_MANIFEST.md) | The shared Flutter guidelines index |

> If a guideline document is also copied into this app's own `docs/`, the **local copy wins**.
> Use the `docs/guidelines/` copy only when there is no local copy.

**Known gaps** against the rules are listed in [`docs/architecture.md`](docs/architecture.md)
section 21. Read that before starting release or security work — release builds are currently
signed with debug keys.

---

## Applicability profiles in force — all three

Declared 2026-07-25 in [`docs/architecture.md`](docs/architecture.md) section 1, which is the
authoritative record.

| Profile | Why it applies |
|---|---|
| `Core Baseline` | Mandatory for every Flutter app. |
| `Production App Extension` | Built to a release standard — production-ready milestones, release sign-off gates, `dev`/`prod` flavors. |
| `Sensitive Data Extension` | AES-256-GCM encrypted attachments, Keystore-held secrets, PIN and biometric lock, encrypted sync, private diary content. |

So `release_process.md` and `security.md` are **required** for this app, not optional, along with
the Production and Sensitive Data sections of the engineering standard.

---

## Hard rules (must follow — these override convenience)

1. **Fully offline.** The app never asks for `INTERNET`. Do not add a network client, an
   analytics SDK, a crash reporter, or any package that pulls one in.
2. **Journal content never leaves encrypted.** Attachments are AES-256-GCM, and the database
   itself is SQLCipher. Keys live in the Android Keystore, never in Dart, never in
   SharedPreferences in the clear. The `hooks: user_defines: sqlite3: source: sqlcipher` block in
   `pubspec.yaml` is what makes the database encrypted — never change it, and never re-add
   `sqlite3_flutter_libs` or `drift_flutter`, which would quietly undo it.
3. **Never log content.** No journal text, attachment names or bytes, PINs, salts, verifiers, or
   key material — not even in debug builds. Use `AppLogger.redact()` when in doubt.
4. **Lock modes are mutually exclusive.** `phone_lock` **or** `app_lock`, one active mode.
5. **A schema change needs a migration.** Check the current version in
   `lib/core/database/app_database.dart` first, then add a migration and a test for it.
6. **Keep changes small and scoped.** No unrelated refactors. Preserve existing behaviour unless
   the task explicitly changes it. Split work into small, testable slices with acceptance criteria.
7. **Re-test earlier work.** After finishing a task, check that previously built features still
   work. When a numbered prompt is finished, mark it `[COMPLETED]` in
   [`docs/ai_development_prompts.md`](docs/ai_development_prompts.md).

---

## Architecture rules

- **Layout: Tier 2, feature-first.** `lib/app/` (shell, theme wiring), `lib/core/` (config,
  database, logging, security, theme, links, utils), `lib/features/<feature>/` split into
  `data/` · `domain/` · `application/` · `services/` · `providers/` · `presentation/`, and a thin
  `lib/main.dart`. Do not restructure without instruction. Full tree:
  [`docs/project_structure.md`](docs/project_structure.md).
- `lib/core/config/` is a **fixed path** — it holds the About-screen `AppConfig` and
  `ConfigService`. Do not move or rename them.
- **Layer boundaries:** widgets must not know SQL, DAO types, file paths, or platform channels.
  Services must not know `BuildContext`, navigation, or UI strings.
- **Dependency direction:** presentation → providers → services → database → models.
- `main.dart` stays thin: init logging, build the database and platform services, `runApp`.
- Never edit generated files (`*.g.dart`). Change the source and re-run `build_runner`.

---

## Build & run commands

```bash
flutter pub get                        # install dependencies
flutter run --flavor dev               # daily development
flutter run --flavor prod              # production flavor
flutter analyze                        # static analysis (must be clean)
flutter test                           # run all tests
flutter gen-l10n                       # regenerate AppLocalizations after editing any .arb
dart run build_runner build --delete-conflicting-outputs   # after changing Drift tables
dart format lib test integration_test  # format before committing

# Production release APK, split per ABI (sideload distribution)
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/ --split-per-abi
```

> This app defines flavors, so a bare `flutter run` fails — always pass `--flavor`.
> Run `dart format` against the named source folders, not `.` — it crashes on stale paths
> under `build/`.

---

## Build flavors

| Flavor | App ID | Display name | Signing |
|--------|--------|--------------|---------|
| dev | `in.sreerajp.sreerajp_journal_vault` | SreerajP Journal Vault(dev) | Debug keystore |
| prod | `in.sreerajp.sreerajp_journal_vault` | SreerajP Journal Vault | Release keystore (`android/key.properties`) |

Read the flavor at runtime through `AppFlavorConfig`
(`lib/core/config/app_flavor_config.dart`), which reads `APP_FLAVOR` then `FLUTTER_APP_FLAVOR`
and defaults to `prod`. Never use `kDebugMode` or `kReleaseMode` as a stand-in for the flavor.

> **Warning:** both flavors currently share one application ID, so they cannot be installed side
> by side. Installing a dev build over the real one destroys its data. See
> [`docs/architecture.md`](docs/architecture.md) section 21.

---

## Signing / keystore

- Keystore lives at `android/<name>.jks`; `android/key.properties` points to it. Both are
  git-ignored and must never be committed. Format: `android/key.properties.example`.
- Keep at least one offline backup of the keystore. Losing it means no more updates under the
  same signature.
- If `key.properties` is absent the release build falls back to the **debug key** and prints a
  warning. Such a build must never be installed on a device holding real entries — switching to a
  real key later requires an uninstall, which destroys all journal data.
- Full runbook: [`docs/release_process.md`](docs/release_process.md).

---

## Security rules

- Never log secrets, keys, tokens, PINs, or decrypted content — even in debug builds.
- Secrets go to the Android Keystore through `MainActivity.kt`. Only `iv:ciphertext` is ever
  written to SharedPreferences.
- Request only the permissions the app needs. Never add `INTERNET`.
- `android:allowBackup="false"` and `res/xml/data_extraction_rules.xml` must stay in the
  manifest. `FLAG_SECURE` must stay set in `MainActivity.onCreate`.
- Release builds must keep `--obfuscate --split-debug-info` and R8. Symbols are git-ignored and
  archived per release.
- Full threat model and OWASP checklist: [`docs/security.md`](docs/security.md).

---

## Localization rules

- All user-visible text comes from `lib/l10n/*.arb` through `AppLocalizations` — never a raw
  string literal in a widget. This applies even though the app ships only English.
- `l10n.yaml` (project root) and `lib/l10n/app_en.arb` must exist. Run `flutter gen-l10n` after
  editing any `.arb` file.
- Every ARB key needs an `@key` description entry, so a future translator has context.
- Literals are allowed only for log messages, non-UI exception messages, asset paths, route
  names, and map/JSON keys.

---

## Code style / naming

- Files `snake_case.dart`; classes `PascalCase`; variables and methods `camelCase`; Riverpod
  providers `camelCase` + `Provider` suffix.
- Use `package:` imports, never relative — `always_use_package_imports` is enforced.
- Prefer `const` constructors, `final` locals, and single quotes.
- Keep `flutter analyze` at zero issues and `dart format` clean before every commit.
- Add a `Semantics` label to every custom interactive widget.

---

## Testing rules

- `test/` mirrors `lib/` — `test/features/<feature>/…` next to `lib/features/<feature>/…`.
- Add or update a test whenever you change a service, DAO, or use case.
- Must be covered before any release: database migrations, attachment crypto, the lock gate,
  backup and import round trips, and export.
- Note for widget tests: `testWidgets` runs in a fake-async zone, so awaited real file I/O never
  completes — use the `…Sync` variants.
- `integration_test/` holds the end-to-end lock gate test.

---

## Dependency constraints

- **Blocked, never add:** HTTP clients, cloud or BaaS SDKs, analytics, crash reporting, ads,
  network-status packages, and anything source-available rather than open source.
- Before adding a package, check its own `pubspec.yaml` for networking dependencies, say why it
  is needed, and confirm it fits the hard rules above.
- Some versions are pinned on purpose (the `win32` / `file_picker` conflict). Read
  [`docs/dependencies.md`](docs/dependencies.md) before changing any version.

---

## Where things live

```
AGENTS.md            # this file — project rules for AI agents and LLMs
CLAUDE.md            # the same rules for Claude Code
README.md            # setup, run, test, build
docs/                # design docs; docs/guidelines/ is a read-only submodule
plans/               # one plan per change (see workflow rules)
change_log/          # one log per implemented change
lib/                 # app source (app/, core/, features/, l10n/, main.dart)
test/                # unit and widget tests, mirroring lib/
integration_test/    # end-to-end tests
android/             # Android host, signing, native Keystore and print code
assets/config/       # app_config.json — the About screen source of truth
tool/                # repository scripts
```

---

## Workflow rules (mandatory — from global rules)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to change, the issue,
   and the fix. Then **STOP and get explicit approval** before editing, creating, or deleting any
   project file other than the plan. A question or an ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to `change_log/` named
   `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.
3. **Relative paths and privacy only.** `plans/`, `change_log/` and `docs/` files are committed
   and may become public. They MUST use relative repository paths only — never an absolute local
   path (a drive letter, a home folder, or a `file:///` URI). <!-- allow-abs-path -->
   They MUST NOT contain any local
   system details — OS user name, computer or host name, network share names, LAN or internal IP
   addresses, local server URLs with ports, device serial numbers, personal email addresses — or
   any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII). Write them as
   if a stranger will read them.

This is enforced by `tool/check_absolute_paths.sh`, wired in as a pre-commit hook via
`.githooks/pre-commit`. Turn it on in a fresh clone with `git config core.hooksPath .githooks`.
Audit everything tracked with `sh tool/check_absolute_paths.sh --all`.

`docs/guidelines/` is out of scope (it is a submodule), and so is source code — the attachment
storage migration test uses invented Windows-style fixture paths on purpose. If a covered file
genuinely needs an absolute path, put `allow-abs-path` in a comment on that line.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in
  plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## Working with the guidelines submodule

- After a fresh clone, run `git submodule update --init --recursive` to fill `docs/guidelines/`.
- To pull newer guidelines: `git submodule update --remote docs/guidelines`, then commit the
  updated submodule pointer.
- Do not edit files inside `docs/guidelines/`. That is a separate repository. Change them there,
  or make a local override copy in `docs/`.
- Start points: `docs/guidelines/guideline.md` and
  `docs/guidelines/flutter_project_engineering_standard.md`. If a document looks dense, open its
  plain-English explainer under `docs/guidelines/docs/` first.

---

## What AI agents must always / never do

**Always:** read this file and the relevant `docs/` file first; write a plan and wait for
approval; state which layer a new class belongs to; keep `main.dart` thin; use `AppLogger`; put
user-visible text in `app_en.arb`; run `flutter analyze` and `flutter test` after a change; add a
migration with every schema change; keep file context narrow to save tokens.

**Never:** put business logic in a widget; call a DAO from a widget; edit `*.g.dart` by hand; add
a blocked dependency; use `print` or `debugPrint`; log secrets or journal content; weaken crypto;
use `ListView(children: [...])` for a list that can exceed 20 items; commit a keystore, a
`key.properties`, or build output.
