# Dependencies — SreerajP Journal Vault

Every package this app depends on, why it is here, and what it is actually used for. Read this
before adding, removing, or upgrading anything in `pubspec.yaml`. Some versions are held back on
purpose, and the reasons are recorded in section 5.

Read first: [`../CLAUDE.md`](../CLAUDE.md) · [`architecture.md`](architecture.md) ·
[`security.md`](security.md)

---

## 1. The rules

1. **Open source only.** No commercial or source-available SDKs. Check the licence before adding.
2. **Nothing that reaches the network.** This app has no `INTERNET` permission. Before adding a
   package, read its own `pubspec.yaml` for networking dependencies.
3. **Say why.** A new package needs a stated reason and a named feature behind it. A package that
   nothing imports is deleted, not kept "for later" — three of them were removed on 2026-07-25 and
   2026-08-16 for exactly this reason.
4. **Check the size budget** when adding anything to a release build.

### Blocked — never add

| Category | Why |
|---|---|
| HTTP clients (`http`, `dio`, `chopper`) | The app is fully offline |
| Cloud or BaaS SDKs (Firebase, Supabase, Appwrite) | Offline, and journal content must not leave the device |
| Analytics and crash reporting | Would send content or usage off-device |
| Ads | Not that kind of app |
| Network-status packages (`connectivity_plus`) | Nothing to check |
| `flutter_secure_storage` | Secrets go through the native Keystore channel in `MainActivity.kt`; a second mechanism would split the story |

---

## 2. Runtime dependencies

### State, framework and platform

| Package | Used for | Where |
|---|---|---|
| `flutter_riverpod` / `riverpod` | The only state-management system in the app | everywhere under `providers/` |
| `flutter_localizations` | Material, Widgets and Cupertino localization delegates | `lib/app/app.dart` |
| `intl` | Date and number formatting, and the ARB toolchain | `lib/l10n/`, timeline and insights |
| `cupertino_icons` | Icon set that ships with the Flutter template | UI |
| `path` / `path_provider` | Building and finding app directories | attachments, backup, export |
| `uuid` | Stable ids for entries, attachments and sync rows | services |

### Database

| Package | Used for | Where |
|---|---|---|
| `drift` | The typed SQL layer — tables, DAOs, migrations, FTS5 | `lib/core/database/` |
| `sqlite3` | The native database, built as **SQLCipher** by its build hook | `lib/core/database/encrypted_database_opener.dart` |

The current `schemaVersion` is **8**. Migration rules are in [`../README.md`](../README.md)
section 7.

### Security and lock

| Package | Used for | Where |
|---|---|---|
| `cryptography` | AES-256-GCM for attachment and sync payload encryption | `lib/features/attachments/services/`, `lib/features/sync/` |
| `local_auth` / `local_auth_android` | Biometric and device-credential prompts for the lock gate | `lib/features/lock_gate/`, `lib/features/journal_lock/` |
| `permission_handler` | Runtime permission requests and the Permissions Center | `lib/features/permissions/` |

> Key material itself never touches Dart. Keystore-backed keys are vended over a `MethodChannel`
> implemented in `MainActivity.kt`. See [`security.md`](security.md).

### Editor and media

| Package | Used for | Where |
|---|---|---|
| `flutter_quill` | The rich-text entry editor and its Delta document format | `lib/features/entries/presentation/editor/` |
| `record` | Voice note recording | `lib/features/entries/services/voice_note_service.dart` |
| `speech_to_text` | Dictation into the editor | `lib/features/entries/` |
| `just_audio` | In-app audio attachment playback | `lib/features/attachments/presentation/audio_attachment_view.dart` |
| `syncfusion_flutter_pdfviewer` | In-app PDF attachment viewing | `.../pdf_attachment_view.dart` |
| `table_calendar` | The timeline calendar view | `lib/features/timeline/` |

### Files, attachments and export

| Package | Used for | Where |
|---|---|---|
| `file_picker` | Picking attachments and choosing an export or backup destination | attachments, export, backup, import |
| `open_filex` | Handing an attachment to an external app when it cannot open in-app | `attachment_open_service.dart` |
| `mime` | Deciding an attachment's type so the open router can pick a viewer | `attachment_open_router.dart` |
| `archive` | Reading ZIP attachment listings, and writing the export and backup archives | export, backup, attachments |
| `shared_preferences` | Small settings, and the store for Keystore-wrapped ciphertext | theme, settings, secrets |

### Diagnostics

| Package | Used for | Where |
|---|---|---|
| `logger` | Backs `AppLogger`, the only allowed logging path | `lib/core/logging/app_logger.dart` |
| `package_info_plus` | Version and build number, for the About screen drift check | `config_service.dart` |
| `device_info_plus` | Android SDK-int checks in permission and storage flows | permissions, attachments |

---

## 3. Development dependencies

| Package | Used for |
|---|---|
| `flutter_test` | Unit and widget tests |
| `integration_test` | The end-to-end lock gate test |
| `flutter_lints` | The lint baseline `analysis_options.yaml` extends |
| `build_runner` | Runs the Drift generator |
| `drift_dev` | Generates `app_database.g.dart` |
| `flutter_launcher_icons` | Generates the Android launcher icons from `assets/icon/` |
| `local_auth_platform_interface` | Test-only. `local_auth` does not re-export `LocalAuthPlatform`, which `biometric_authenticator_test.dart` swaps out to fake the device |

---

## 4. Generated code policy

Generated Dart files (`*.g.dart`) **are committed**. After changing an annotated source, run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Never edit a generated file by hand. The same rule applies to the localization output — change
`lib/l10n/app_en.arb` and run `flutter gen-l10n`.

---

## 5. Held versions — do not "just upgrade"

### The `win32` knot (recorded 2026-07-25)

`package_info_plus` 10, `device_info_plus` 13, and `syncfusion_flutter_pdfviewer` 34 all need
`win32` version 6 (Syncfusion pulls it through `device_info_plus`). Every stable `file_picker`
up to 11.x needs `win32` version 5. The two groups cannot resolve together. `win32` only affects
the Windows target, which this app does not support, but pub resolves for every platform anyway.

**`file_picker` won.** Version 11.0.2 fixes an Android path-traversal issue (CWE-22) on the
attachment import path, which matters directly to this app. The three held packages only supply
version strings, an SDK-int check, and PDF rendering.

So these are pinned on purpose:

| Package | Held at | Release |
|---|---|---|
| `package_info_plus` | `^9.0.0` | 10.x needs `win32` 6 |
| `device_info_plus` | `^12.1.0` | 13.x needs `win32` 6 |
| `syncfusion_flutter_pdfviewer` | `^33.2.13` | 34.x needs `device_info_plus` 13 |

**Revisit when `file_picker` 12 leaves beta.** It moves to `win32` 6 and the conflict disappears.

### `sqlite3` and the `hooks:` block

`package:sqlite3` supplies the native library itself, through a Dart build hook. The bottom of
`pubspec.yaml` selects which build:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlcipher
```

**That one line decides whether journal text is encrypted at rest.** With `source: sqlite3` (the
default) the app would write a plain database and lose the protection A5.1 added. Treat it as
security configuration, not build configuration: read [`security.md`](security.md) section 5
before changing it. The app double-checks at runtime — it asks `PRAGMA cipher_version` on every
open and refuses to start if plain SQLite answers — but that is a safety net, not a substitute.

Verify after any change to it: `flutter test test/core/database/encrypted_database_test.dart`,
and check the built APK carries `lib/<abi>/libsqlcipher.so` and no `libsqlite3.so`.

---

## 6. Removed on purpose

Do not re-add these without a plan. Each was declared but imported by nothing.

| Package | Removed | Why |
|---|---|---|
| `go_router` | 2026-07-25 | Never imported. Navigation is `Navigator` 1.0 |
| `flutter_quill_extensions` | 2026-07-25 | Imported by nothing, no feature behind it |
| `sqlite3_flutter_libs` | 2026-08-18 | Replaced by the SQLCipher build hook (A5.1). **Must not come back:** it bundles a second `libsqlite3.so`, which can win the symbol lookup and silently turn encryption off |
| `drift_flutter` | 2026-08-18 | Only supplied `driftDatabase()`, one line of `main.dart`, and pulled `sqlite3_flutter_libs` back in with it. Replaced by `EncryptedDatabaseOpener` |

---

## 7. Audit cadence

Run `flutter pub outdated` at the start of each milestone, and before every release. Upgrade
deliberately, one package at a time, with `flutter test` after each. Record any new held version in
section 5 with its reason — an undocumented pin becomes a mystery within a month.

---

## 8. Related documents

- [`architecture.md`](architecture.md) — where each package sits in the layer model
- [`security.md`](security.md) — the crypto and secret-storage rules the packages must respect
- [`project_structure.md`](project_structure.md) — the folder each package is used from
- [`../README.md`](../README.md) — setup and code generation commands
