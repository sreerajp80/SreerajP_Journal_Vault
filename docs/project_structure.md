# Project Structure — SreerajP Journal Vault

The file tree, and what each folder is responsible for. Read this to find where something lives,
or to decide where a new file belongs.

Read first: [`../CLAUDE.md`](../CLAUDE.md) · [`architecture.md`](architecture.md)

---

## 1. Layout tier

This app uses the **Tier 2 feature-first** layout from
[`guidelines/flutter_project_engineering_standard.md`](guidelines/flutter_project_engineering_standard.md)
section 3.1. Shared machinery lives in `lib/core/`, app-level wiring in `lib/app/`, and each
product area owns a folder under `lib/features/`.

Do not restructure without a plan and approval.

---

## 2. Repository root

```text
SreerajP_Journal_Vault/
├── android/              # Android host: Gradle, signing, manifest, native Kotlin
├── assets/
│   ├── config/           # app_config.json — the About screen source of truth
│   ├── fonts/            # Noto Sans Malayalam, for HTML and PDF export only
│   └── icon/             # Launcher icon sources
├── change_log/           # One log per implemented change
├── docs/                 # Design docs; docs/guidelines/ is a read-only submodule
├── integration_test/     # End-to-end tests that need a device
├── lib/                  # App source — see section 3
├── plans/                # One plan per change, written before the change
├── test/                 # Unit and widget tests, mirroring lib/
├── tool/                 # Repository scripts
├── ios/ linux/ macos/ web/ windows/   # Flutter scaffolding; not supported targets
├── .githooks/            # Pre-commit hook (needs core.hooksPath set once per clone)
├── .github/workflows/    # CI
├── AGENTS.md             # Project rules for AI agents and LLMs
├── CLAUDE.md             # The same rules for Claude Code
├── CHANGELOG.md          # User-facing release history
├── README.md             # Setup, run, test, build
├── analysis_options.yaml # Lint configuration
├── l10n.yaml             # Localization generator configuration
└── pubspec.yaml
```

---

## 3. `lib/` — application source

```text
lib/
├── main.dart             # Thin entry point: logging, database, platform services, runApp
├── app/
│   └── app.dart          # MaterialApp, the NavigationBar shell, and the settings UI
├── core/
│   ├── config/           # FIXED PATH — AppConfig, ConfigService, AppFlavorConfig
│   ├── database/         # Drift tables, DAOs, migrations, and the generated .g.dart
│   ├── links/            # Backlink parsing between entries
│   ├── logging/          # AppLogger — the only allowed logging path
│   ├── security/         # Shared security helpers, and VaultEnvelope — the one
│   │                     # password-sealed file format (backup archive, encrypted export)
│   ├── theme/            # ThemeData, colors, and the Light/Dark mode controller
│   └── utils/            # Small shared helpers
├── features/             # One folder per product area — see section 4
└── l10n/
    └── app_en.arb        # Every user-visible string, with an @key description each
```

### Rules that do not change

- **`lib/core/config/` is a fixed path.** It holds the About-screen `AppConfig` model and the
  `ConfigService` loader, with those exact class names, as required by
  [`guidelines/guideline.md`](guidelines/guideline.md) section 1. Do not move or rename them.
- **`main.dart` stays thin.** It initializes logging, builds the database and the platform
  services, and calls `runApp`. Heavy work belongs in a service.
- **`lib/l10n/` is mandatory.** Every user-visible string lives in `app_en.arb`, even though the
  app ships one language.

---

## 4. `lib/features/` — the product areas

Each feature folder uses the sub-folders it actually needs. Not every feature has all of them.

| Sub-folder | Holds | Must not know about |
|---|---|---|
| `domain/` | Pure types, value objects, and decision logic with no I/O | Flutter, the database, the file system |
| `data/` | Repositories and mappers over the database | `BuildContext`, navigation |
| `application/` | Use cases that coordinate services | UI widgets |
| `services/` | Platform and business services — crypto, files, channels | `BuildContext`, navigation, UI strings |
| `providers/` | Riverpod providers wiring services into the UI | SQL |
| `presentation/` | Screens and widgets | SQL, DAO types, file paths, platform channels |

The fifteen features:

| Feature | What it owns |
|---|---|
| `about/` | The About screen, rendered from `app_config.json` |
| `attachments/` | Import, AES-256-GCM encryption, storage location, open routing, in-app PDF/audio/archive viewers |
| `backup/` | The backup archive, the scheduler, and the backup health screen |
| `entries/` | The rich-text editor, templates, voice notes, version history |
| `export/` | Delta → Markdown / HTML / plain text / PDF, the export screen, and the screen that opens a password-sealed export again |
| `import/` | Reading entries in from outside the app |
| `insights/` | Counts, streaks and charts over the journal |
| `journal_lock/` | Per-journal locking and the Keystore-backed secret store |
| `lock_gate/` | The app-wide lock screen and the single active lock mode |
| `permissions/` | The Permissions Center and the runtime permission flow |
| `search/` | Search over entries, backed by FTS5 |
| `security/` | Security events and security settings |
| `smart_tags/` | Tag suggestions from the live document text |
| `sync/` | Encrypted sync and conflict resolution — **no transport yet**, UI is flag-gated |
| `tags/` | Tag management |
| `timeline/` | The calendar view of entries |

---

## 5. `test/` and `integration_test/`

`test/` mirrors `lib/`. The test for
`lib/features/backup/services/backup_service.dart` lives at
`test/features/backup/services/backup_service_test.dart`.

```text
test/
├── core/          # config, database, links, logging, theme, utils
└── features/      # one folder per feature, plus navigation and settings
integration_test/
└── lock_gate_test.dart
```

> `testWidgets` runs in a fake-async zone, so awaited real file I/O never completes inside a widget
> test. Use the `…Sync` variants, as `attachment_viewer_screen_test.dart` does.

---

## 6. `android/`

| Path | What it is |
|---|---|
| `android/app/build.gradle.kts` | minSdk 28, the `dev`/`prod` flavors, R8, and the release signing config |
| `android/app/proguard-rules.pro` | R8 keep rules |
| `android/app/src/main/AndroidManifest.xml` | Permissions, `allowBackup="false"`, the app label placeholder |
| `android/app/src/main/res/xml/data_extraction_rules.xml` | Blocks cloud backup and device transfer |
| `android/app/src/main/kotlin/.../MainActivity.kt` | `FLAG_SECURE`, the Keystore method channels, the SAF document client |
| `android/app/src/main/kotlin/.../print/JvHtmlToPdf.kt` | The native WebView PDF renderer used by export |
| `android/key.properties` | Signing secrets. **Git-ignored, never committed** |
| `android/key.properties.example` | The format to copy |

---

## 7. `docs/`

| File | Kind | What it holds |
|---|---|---|
| [`architecture.md`](architecture.md) | Living | Layers, data flow, schema, decisions, and the known gap list (section 21) |
| [`security.md`](security.md) | Living | Threat model, crypto design, permissions, OWASP checklist |
| [`release_process.md`](release_process.md) | Living | Versioning, keystore, hardening, build, verify, rollback |
| [`workflow_rules.md`](workflow_rules.md) | Living | Plan → approve → log, and the privacy rule |
| [`dependencies.md`](dependencies.md) | Living | Every package, why it is here, and the held versions |
| [`project_structure.md`](project_structure.md) | Living | This file |
| [`journal_vault_plan.md`](journal_vault_plan.md) | Living | The product concept, milestones, and UI plan |
| [`features.md`](features.md) | Living | What the app does, feature by feature |
| [`enhancement_ideas.md`](enhancement_ideas.md) | Living | Ideas not yet committed to a milestone |
| [`implementation_plan.md`](implementation_plan.md) | Point-in-time | The phase-by-phase build roadmap |
| [`implementation_progress.md`](implementation_progress.md) | Point-in-time | What is done, partial, and open |
| [`ai_development_prompts.md`](ai_development_prompts.md) | Point-in-time | The numbered build prompts and their status |
| [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md) | Shared | Index of the shared guidelines. Do not hand-edit |
| `guidelines/` | Submodule | The shared guideline repository. **Read-only from here** |

New `docs/` files use lowercase `snake_case`, no date prefix, and follow
[`guidelines/DOCS_FOLDER_GUIDELINE.md`](guidelines/DOCS_FOLDER_GUIDELINE.md).

---

## 8. Where to put a new file

| You are adding | It goes in |
|---|---|
| A new screen for an existing feature | `lib/features/<feature>/presentation/` |
| A whole new product area | a new `lib/features/<name>/`, with the sub-folders it needs |
| A service several features use | `lib/core/<concern>/`, not a shared `utils/` dump |
| A database table or query | `lib/core/database/`, plus a migration and a migration test |
| A user-visible string | `lib/l10n/app_en.arb`, then `flutter gen-l10n` |
| A repository script | `tool/` |
| A note about one feature | a `##` section in an existing `docs/` file, not a new file |

---

## 9. Related documents

- [`architecture.md`](architecture.md) — why the structure is shaped this way
- [`workflow_rules.md`](workflow_rules.md) — the approval gate before you move anything
- [`guidelines/flutter_project_engineering_standard.md`](guidelines/flutter_project_engineering_standard.md)
  section 3 — the shared structure rules
