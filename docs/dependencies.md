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
| `crypto` | SHA-256 checksum that confirms the payload AirQR rebuilds from the QR frames matches what was sent. A Dart team package with no dependencies of its own; it is not used for encryption | `lib/features/airqr/services/airqr_codec.dart` |
| `local_auth` / `local_auth_android` | Biometric and device-credential prompts for the lock gate | `lib/features/lock_gate/`, `lib/features/journal_lock/` |
| `permission_handler` | Runtime permission requests and the Permissions Center | `lib/features/permissions/` |

> Key material itself never touches Dart. Keystore-backed keys are vended over a `MethodChannel`
> implemented in `MainActivity.kt`. See [`security.md`](security.md).

### Editor and media

| Package | Used for | Where |
|---|---|---|
| `flutter_quill` | The rich-text entry editor and its Delta document format | `lib/features/entries/presentation/editor/` |
| `record` | Voice note recording | `lib/features/entries/services/voice_note_service.dart` |
| `speech_to_text` | On-device dictation into the editor. Always called with `onDevice: true`, and only after the app's own `sreerajp.journal_vault/speech` channel confirms on-device recognition exists — the plugin otherwise falls back to the online system recogniser. Not used by voice notes | `lib/features/entries/services/speech_engine.dart`, `dictation_service.dart` |
| `image_picker` | Gallery image selection and fallback photo capture for OCR | `lib/features/entries/presentation/entry_editor_screen.dart` |
| `image_cropper` | Crop-and-rotate UI before OCR scanning, wraps Android uCrop (offline) | `lib/features/entries/services/image_edit_service.dart` |
| `google_mlkit_text_recognition` | On-device fallback text extraction from images | `lib/features/entries/services/ocr_service.dart` |
| `tesseract4android` (native) | On-device, 100% offline Tesseract 5 OCR text extraction supporting English, Malayalam, and bilingual recognition via native MethodChannel | `android/app/build.gradle.kts`, `MainActivity.kt`, `lib/features/entries/services/ocr_service.dart` |
| `image` | Pure-Dart image decode, resize, grayscale and contrast. Prepares a photo before OCR so thin marks (`.`, `=`, `,`, `:`) are large and clear enough to be recognised. No networking dependency | `lib/features/entries/services/ocr_image_preprocessor.dart` |
| `just_audio` | In-app audio attachment playback | `lib/features/attachments/presentation/audio_attachment_view.dart` |
| `pdfrx` | In-app PDF attachment viewing (PDFium-based, open source) | `.../pdf_attachment_view.dart` |
| `table_calendar` | The timeline calendar view | `lib/features/timeline/` |
| `camera` | The in-app OCR camera: live preview and full-resolution still capture. Wraps Android CameraX; its own dependencies are the platform packages only, no networking | `lib/features/entries/presentation/ocr_camera_screen.dart` |
| `qr_flutter` | Draws QR codes on screen for AirQR transfer and the Wi-Fi Sync pairing code. Pure Dart (depends only on `qr`), no networking | `lib/features/airqr/presentation/airqr_send_screen.dart`, `lib/features/sync/presentation/sync_host_screen.dart` |
| `mobile_scanner` | Reads those QR codes with the camera. Uses the **bundled** ML Kit barcode model (`com.google.mlkit:barcode-scanning`), so nothing is downloaded at runtime. Never set `dev.steenbakker.mobile_scanner.useUnbundled=true` in `android/gradle.properties` — that switches to a model fetched through Google Play Services | `lib/features/airqr/presentation/airqr_receive_screen.dart`, `lib/features/sync/presentation/sync_client_screen.dart` |

#### OCR language models (`assets/tessdata/`)

These are data files, not packages. They ship inside the app and are copied to
internal storage on first run by `ensureTessData` in `MainActivity.kt`. Nothing
is downloaded — the app has no HTTP client and none of this leaves the device.

The Tesseract project publishes each language in three builds. They differ in how
precisely the recogniser's weights are stored, which trades accuracy against size
and speed.

| File | Build used | Size | Why |
|---|---|---|---|
| `mal.traineddata` | `tessdata_best` | 12.5 MB | Full-precision weights. Malayalam has stacked vowel signs and joined letter shapes, which are the first thing lost when weights are rounded, so it gains the most from this build. |
| `eng.traineddata` | `tessdata_best` | 15.4 MB | Full-precision weights. The `tessdata_fast` build (4.1 MB) was used until 2026-09-16, but it missed and garbled English words on phone photos. The owner accepted the 11.3 MB size increase for better English. |

Source: `github.com/tesseract-ocr/tessdata_best`, Apache 2.0.

The `tessdata` (standard) build is deliberately not used. Its extra size is the
pre-neural engine from Tesseract 3, which this app never switches on.

**When changing any model file, bump `TESSDATA_VERSION` in `MainActivity.kt`.**
The copy to internal storage is skipped when the files are already there, so
without a version bump an app update would keep using the old model for everyone
who already had the app installed.

#### Bundled fonts (`assets/fonts/`)

Data files, not packages. They are bundled so Malayalam and Sanskrit never render as empty boxes,
and so export can shape both scripts offline. Runtime font fetching (for example `google_fonts`) is
not allowed — a device offline on first launch would show boxes for two of the three languages
(engineering standard §8.3.3 and §17.4).

| File | Script | Used by | Licence |
|---|---|---|---|
| `NotoSansMalayalam-Regular.ttf`, `NotoSansMalayalam-Bold.ttf` | Malayalam | UI `fontFamilyFallback`, HTML and PDF export | SIL OFL 1.1 (`OFL-Noto.txt`) |
| `NotoSansDevanagari-Regular.ttf`, `NotoSansDevanagari-Bold.ttf` | Devanagari (Sanskrit) | UI `fontFamilyFallback`, HTML and PDF export | SIL OFL 1.1 (`OFL-Noto.txt`) |

`package:characters` is declared in `pubspec.yaml` and used by
`test/l10n/label_length_test.dart` to count visible characters (grapheme clusters), not code units.
It ships with the Dart SDK team, adds no platform code and does no I/O; it is named explicitly
rather than relied on through Flutter so the import is a declared dependency.

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

`package_info_plus` 10 and `device_info_plus` 13 need `win32` version 6. Every stable `file_picker`
up to 11.x needs `win32` version 5. The two groups cannot resolve together. `win32` only affects
the Windows target, which this app does not support, but pub resolves for every platform anyway.

**`file_picker` won.** Version 11.0.2 fixes an Android path-traversal issue (CWE-22) on the
attachment import path, which matters directly to this app. The held packages only supply
version strings and an SDK-int check.

So these are pinned on purpose:

| Package | Held at | Release |
|---|---|---|
| `package_info_plus` | `^9.0.0` | 10.x needs `win32` 6 |
| `device_info_plus` | `^12.1.0` | 13.x needs `win32` 6 |

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
