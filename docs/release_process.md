# Release Process — SreerajP Journal Vault

> **This is the local copy.** It overrides `docs/guidelines/release_process.md` for this app, per
> the "local copy wins" rule in [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md).

Last reviewed: 2026-09-15 (against guidelines submodule commit `7ed5a36`)

> ## ⛔ This app cannot be released yet
>
> Release builds are currently signed with the **Android debug key**. The real keystore has never
> been created. A debug-signed build is not distributable, and worse, if you install one and later
> switch to a proper key, Android will refuse the update — the only way out is uninstalling and
> losing the data.
>
> **Do step 0 below before anything else.**

---

## 0. One-time setup — create the release keystore

Not yet done. Until it is, `android/app/build.gradle.kts` falls back to the debug key and prints
a warning during the build.

```bash
cd android

keytool -genkeypair -v \
  -keystore sreerajp_journal_vault.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias sreerajp_journal_vault
```

Then copy `android/key.properties.example` to `android/key.properties` and fill in the real
values. Both files are already git-ignored.

**Back the keystore up offline, in at least two places, along with its passwords.** Losing it
means you can never ship an update that the installed app will accept. This is unrecoverable —
there is no reset, no support line, nothing.

Verify it took effect: build a release APK and confirm the "signing with the DEBUG key" warning
no longer appears.

---

## 1. Release Scope

- App: `SreerajP_Journal_Vault`
- Platforms released: **Android only.** iOS, Windows, Linux and macOS are not supported targets
  and must not be released.
- Distribution: **direct sideload to the developer's own device** today. The app is still built to
  be publishable on Google Play, so the readiness gate in section 9A applies and MUST pass before
  any store upload.
- Profiles in force: all three (see [`architecture.md`](architecture.md) section 1), so this
  document is mandatory, not optional.

---

## 2. Roles

Single developer. Sreeraj P is author, reviewer, release manager, and the only user. There is no
second pair of eyes, which is exactly why the checklists below should be worked through rather
than recalled.

---

## 3. Versioning Policy

- `pubspec.yaml` `version: <major>.<minor>.<patch>+<build>` is the single source of truth.
- Current: `1.0.1+1`.
- Increment the build number on **every** artifact you install, even a re-build of the same
  version. Android refuses to install a lower `versionCode` over a higher one.
- Keep `assets/config/app_config.json` `version` and `build` in sync. `ConfigService` logs a
  warning on drift in debug builds, but it will not stop a release.
- Tag each release `v<version>` in git.

---

## 4. Branch And Merge Policy

`master` is the only branch today, and it has no remote. Before the first real release, at
minimum: commit everything, confirm `git status` is clean, and tag.

---

## 5. Environment And Flavor Matrix

| Flavor | Application ID | Label | Purpose |
|---|---|---|---|
| `dev` | `in.sreerajp.sreerajp_journal_vault` | `sreerajp_journal_vault (dev)` | Development and testing |
| `prod` | `in.sreerajp.sreerajp_journal_vault` | `sreerajp_journal_vault` | Release |

> **Known limitation.** Both flavors share one application ID, so they **cannot be installed side
> by side** — installing one replaces the other, taking its data with it. If you want a dev build
> on the same phone as your real journal, add an `applicationIdSuffix = ".dev"` to the dev flavor
> first. Until then, never install a dev build on the device holding real entries.

Flavor drives `AppFlavorConfig` at runtime (`APP_FLAVOR`, then `FLUTTER_APP_FLAVOR`, defaulting
to `prod`). Its only current effect is gating verbose logging.

---

## 6. Release Build Hardening

### 6.1 Obfuscation and debug symbols

Mandatory on every release build:

```
--obfuscate --split-debug-info=build/symbols/android-<version>/
```

Symbols are written per ABI. `build/symbols/` is git-ignored. **Archive the symbols for every
released version** — without the matching set, a crash report from that build is unreadable.

### 6.2 ProGuard / R8

Enabled. Rules in `android/app/proguard-rules.pro`.

> **R8 has never been runtime-verified on a device.** It compiles, but a missing keep rule shows
> up only at runtime. Before the first release, smoke-test each of these on the actual release
> build:
>
> - [ ] Open a PDF attachment (`pdfrx`)
> - [ ] Play an audio attachment (`just_audio`)
> - [ ] Record a voice note (`record`)
> - [ ] Speech-to-text transcription (`speech_to_text`)
> - [ ] Biometric and device-credential unlock (`local_auth`)
> - [ ] Pick a file to attach (`file_picker`)
> - [ ] Grant and deny a permission (`permission_handler`)
> - [ ] Open a ZIP/7z archive preview (`archive`)
> - [ ] SD-card storage migration (SAF / `documentfile`)
>
> A `ClassNotFoundException` or `NoSuchMethodException` here means a missing keep rule. Add it
> from the failing package's own documentation, not as a blanket `-keep class **`.

### 6.3 Size analysis

`flutter build apk --flavor prod --release --analyze-size`. Use `--split-per-abi`
for real distribution.

### 6.4 Debuggable and backup verification

Check the **merged** manifest or the built APK, never the source:

```
build/app/intermediates/merged_manifests/prodRelease/processProdReleaseManifest/AndroidManifest.xml
```

1. `android:debuggable` must be absent or `false`. A debuggable build lets anyone with ADB attach a
   debugger and read memory. Verified absent on 2026-07-25.
2. `android:allowBackup` must be `false`. With backup on, `adb backup` could copy the database,
   the wrapped keys and every file without root. This app also sets
   `android:dataExtractionRules` to block cloud backup and device transfer (see
   [`security.md`](security.md) section 10).

```bash
# bash
APK="build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk"
aapt2 dump badging "$APK" | grep -i debuggable          # expect no output
aapt2 dump xmltree "$APK" --file AndroidManifest.xml | grep -i allowBackup   # expect =0x0
```

```powershell
# PowerShell
$APK = "build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk"
aapt2 dump badging $APK | Select-String -Pattern "debuggable"
aapt2 dump xmltree $APK --file AndroidManifest.xml | Select-String -Pattern "allowBackup"
```

### 6.5 Cleartext traffic

- minSdk is 28, so `usesCleartextTraffic` defaults to `false`. The manifest does not turn it on and
  there is no `network_security_config.xml`. Keep it that way.
- Wi-Fi Sync uses a raw TCP socket sealed with AES-256-GCM, not HTTP, so it does not need
  cleartext HTTP. No `<trust-anchors>` for user certificates may ever be added.

### 6.6 Pre-release asset and secret leak audit

`--obfuscate` only scrambles Dart code. Files under `assets/` and `res/` sit in the APK unencrypted
and anyone can list them.

```bash
# bash
unzip -l build/app/outputs/apk/prod/release/app-arm64-v8a-prod-release.apk "assets/*"
```

```powershell
# PowerShell
tar -tf build\app\outputs\apk\prod\release\app-arm64-v8a-prod-release.apk | Select-String "assets/"
```

- [ ] No `.env`, credentials, `.pem`, `.p12` or keystore file in `assets/`.
- [ ] No database file or sample journal content bundled.
- [ ] Only the expected assets: `assets/config/app_config.json`, `assets/fonts/`, `assets/tessdata/`,
      and the launcher icon sources.

### 6.7 Exported component audit

Read every activity, service and receiver in the merged manifest.

| Component | Exported | Why | Input handling |
|---|---|---|---|
| `.MainActivity` | yes | Launcher, inbound share (`SEND`, `SEND_MULTIPLE`) and `VIEW` for `.jvenc` / `.jvbk` | Shared text and files go through `lib/features/share_receiver/`, which only offers a quick capture the user must confirm. Opened archives still need the archive password |
| `com.yalantis.ucrop.UCropActivity` | no | Internal crop screen for OCR; no intent filter | n/a |

- [ ] No component other than those above is exported in the merged manifest.
- [ ] Any new intent filter validates its input and never skips the lock gate.

---

## 7. Signing And Secret Handling

- Keystore: `android/sreerajp_journal_vault.jks` (git-ignored).
- Properties: `android/key.properties` (git-ignored).
- Neither may ever be committed. `.gitignore` covers `android/key.properties`, `android/*.jks`,
  `android/*.keystore`, and `/build/symbols/`.
- If `key.properties` is missing the build falls back to the debug key **and prints a warning**.
  Never distribute a build that printed that warning.

---

## 8. Release Checklist

### Code and quality

- [ ] `git status` clean; on the intended commit.
- [ ] `pubspec.yaml` version and build number incremented.
- [ ] `assets/config/app_config.json` version and build match.
- [ ] `dart run build_runner build --delete-conflicting-outputs` run (Drift codegen).
- [ ] `dart format --output=none --set-exit-if-changed lib test integration_test` passes.
- [ ] `flutter analyze` reports no issues.
- [ ] `flutter test` — **all** tests pass.
- [ ] The built APK carries `lib/<abi>/libsqlcipher.so` and **no** `libsqlite3.so`.
      Two copies of sqlite can leave the vault written in plain form. Unzip the APK and
      look, or run `flutter test integration_test/encrypted_database_test.dart -d <device>`.

> **Do not run `dart format .`** — it walks into `build/` and crashes on stale Gradle transform
> paths (`PathNotFoundException`). Always name the source directories.

> **Both former blockers are now cleared (2026-07-25):**
>
> 1. The `test/widget_test.dart` failure — "Journal detail groups entries and reacts to entry
>    CRUD" — was a test bug, not an app bug, and was fixed in the last-mile integration pass.
> 2. The formatting gap — the whole codebase was reformatted with the Dart 3.12 formatter during
>    the Flutter 3.44.8 upgrade. The `dart format` checklist item above now passes honestly.
>
> Current state on Flutter `3.44.8` / Dart `3.12.2`: `flutter analyze` clean, 257 tests passing,
> `dart format` clean. Keep all three green.

### Security

- [ ] Work through the checklist in [`security.md`](security.md) section 18.
- [ ] Merged release manifest re-checked: no `INTERNET`, `allowBackup="false"`, no `debuggable`.
- [ ] `FLAG_SECURE` confirmed: with "Block Screenshots" on (the default) a screenshot of the
      running app fails, and with it off a screenshot succeeds.
- [ ] Obfuscation flags present in the command actually used.
- [ ] Signed with the real release key, not the debug key.
- [ ] `android:allowBackup=false` confirmed in the built APK (section 6.4).
- [ ] Cleartext traffic still off; no network security config added (section 6.5).
- [ ] Asset audit passed — nothing secret or personal in `assets/` (section 6.6).
- [ ] Exported component audit passed (section 6.7).

### Localization

- [ ] `app_en.arb`, `app_ml.arb` and `app_sa.arb` all present;
      `flutter test test/l10n/translation_parity_test.dart` passes (ARB keys, `app_config.json`,
      asset twins).
- [ ] No untranslated English value left in the Malayalam or Sanskrit file.
- [ ] `sh tool/check_sanskrit_markers.sh` passes, and glossary terms from engineering standard §8.5
      are used.
- [ ] `flutter test test/l10n/label_length_test.dart` passes (short-label budget, §8.6).
- [ ] Every Malayalam and Sanskrit term listed as "needs native-reader review" in change logs since
      the last release has been reviewed by a fluent reader.
- [ ] Every screen opened in `en`, `ml` and `sa` on a clean device — no boxes, no overflow, no
      clipped Malayalam or Devanagari letters.
- [ ] Settings language picker works: System default / English / മലയാളം / संस्कृतम्; persists across
      a restart; applies without a restart.
- [ ] `bundle.language.enableSplit = false` still in `android/app/build.gradle.kts`.
- [ ] Date pickers and dialogs checked under `sa` (Sanskrit framework fallback).
- [ ] Every icon-only control has a localized tooltip.
- [ ] About screen ends with the "Made with ❤️ from India" badge, localized and centered.

### Google Play readiness (only when uploading to Play)

- [ ] Full section 9A gate completed for this release.
- [ ] `targetSdk` meets Play's current target API level policy — re-checked, not assumed.
- [ ] `versionCode` strictly greater than every build ever uploaded.
- [ ] App Bundle built; Play App Signing on; native debug symbols uploaded.
- [ ] Privacy policy URL live; Data safety form matches what the app does; content rating done.
- [ ] English and Malayalam store listings complete, with screenshots in each language.
- [ ] Internal testing upload done and the pre-launch report is clean.
- [ ] Staged rollout percentage chosen.

### Data safety

- [ ] Migration test passes.
- [ ] Install over the **previous** release build and confirm existing journals survive. This is
      the single most important check in this document — it is the failure that cannot be undone.
- [ ] Take a backup before installing, and confirm the backup restores.

### Artifact validation

- [ ] Installs on a physical device.
- [ ] App label reads `sreerajp_journal_vault`, not the dev label.
- [ ] R8 smoke tests from section 6.2 pass.
- [ ] Light and dark themes both render correctly.

---

## 9. Android Release Steps

Every production build uses `--release`, `--obfuscate` and `--split-debug-info` — all three,
always. `--split-per-abi` is for sideloaded APKs; Google Play takes an App Bundle instead.

Steps, in order:

1. Verify clean state and the intended commit.
2. Fetch dependencies and run code generation.
3. Run format, analyze, test, and the Sanskrit marker check.
4. Build the production artifacts with all hardening flags.
5. Run size analysis and keep the output.
6. Verify `debuggable` and `allowBackup` (section 6.4), then the asset audit (6.6) and exported
   component audit (6.7).
7. Install and run the section 8 validation on a device.
8. Archive `build/symbols/android-prod-<version>/` somewhere durable.
9. For Play only: complete the section 9A gate, then upload.
10. Tag the release: `git tag v<version>`.

**bash:**

```bash
git status
flutter pub get
dart run build_runner build --delete-conflicting-outputs

dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
sh tool/check_sanskrit_markers.sh

VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)

# Split APKs for sideloading
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-$VERSION/ \
  --split-per-abi

# App Bundle for Google Play
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-prod-$VERSION/

# Size analysis
flutter build apk --flavor prod --release --analyze-size

git tag v$VERSION
```

**PowerShell:**

```powershell
git status
flutter pub get
dart run build_runner build --delete-conflicting-outputs

dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
sh tool/check_sanskrit_markers.sh

$VERSION = (Get-Content pubspec.yaml | Select-String '^version:').ToString().Split(' ')[1].Trim()

# Split APKs for sideloading
flutter build apk `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/" `
  --split-per-abi

# App Bundle for Google Play
flutter build appbundle `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/"

# Size analysis
flutter build apk --flavor prod --release --analyze-size

git tag "v$VERSION"
```

> Note: name the source folders for `dart format`. `dart format .` walks into `build/` and crashes.

Artifacts land in `build/app/outputs/apk/prod/release/` (APKs) and
`build/app/outputs/bundle/prodRelease/` (App Bundle).

---

## 9A. Google Play Store Readiness (mandatory gate before any Play upload)

The app is sideloaded today, but it is built to be publishable. This gate MUST pass before the
first Play upload and be re-checked before every Play release. *(one-time)* items are set up once
and only re-verified later. Unticked boxes are open work, not done work.

### 9A.1 Identity and versioning

| Item | This app | State |
|---|---|---|
| `applicationId` *(one-time)* | `in.sreerajp.sreerajp_journal_vault` — permanent after first publish, no suffix on prod | set |
| `versionCode` | `flutter.versionCode`, from the `+build` part of `pubspec.yaml`; never reused | set |
| `versionName` | `flutter.versionName`, from `pubspec.yaml` | set |
| App name | `@string/app_name` resource per flavor, matching the store title | see architecture §21 |
| Package visibility | `<queries>` declares only `PROCESS_TEXT`, used by the Flutter engine | set |

### 9A.2 API level, ABI and compatibility

- [ ] `targetSdk` (36 today, from Flutter) meets Play's current target API policy — check at release
      time, do not trust this line.
- [x] `compileSdk` ≥ `targetSdk`.
- [x] `minSdk` 28 is a recorded decision: Keystore-backed secret storage assumes API 28+
      ([`architecture.md`](architecture.md) section 19).
- [x] 64-bit: the App Bundle carries `arm64-v8a`.
- [ ] 16 KB page size verified for every native library, including `libsqlcipher.so` and the
      Tesseract libraries.
- [ ] Edge-to-edge layout verified on Android 15+.

### 9A.3 Signing and upload

- [ ] Ship an App Bundle (`.aab`), not an APK.
- [x] Language splitting disabled: `bundle { language { enableSplit = false } }` in
      `android/app/build.gradle.kts`, so all three languages reach every device.
- [ ] Release keystore created (section 0) — **still open**.
- [ ] Play App Signing enabled *(one-time)*; upload key backed up offline.
- [ ] Native debug symbols uploaded to Play and archived.

### 9A.4 Manifest, permissions and policy declarations

- [x] Every permission is justified ([`security.md`](security.md) section 11); `WAKE_LOCK` is
      stripped with `tools:node="remove"`.
- [ ] `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` (from `file_picker`) need the Play photo and video
      permissions declaration, or replacement with the system photo picker.
- [ ] `CAMERA` and `RECORD_AUDIO` declared in the console as foreground-only use.
- [x] No foreground service.
- [x] `debuggable=false`, `allowBackup=false`, cleartext off, exported audit done (6.4–6.7).
- [x] No ads, payments or analytics SDKs.

### 9A.5 Store account declarations

- [ ] Privacy policy URL — public and app-specific. Required even though no data is collected.
- [ ] Data safety form — "no data collected, no data shared"; Wi-Fi Sync stays on the user's own
      local network.
- [ ] Content rating questionnaire.
- [ ] Target audience declared (adults; not a Families app).
- [x] No account creation, so no account deletion path is needed.

### 9A.6 Store listing assets

- [ ] App icon 512 × 512 PNG.
- [ ] Feature graphic 1024 × 500.
- [ ] 2–8 phone screenshots per listing language.
- [ ] Short description ≤ 80 characters; full description ≤ 4000; title ≤ 30.

### 9A.7 Listing localization

- [ ] English listing.
- [ ] Malayalam (`ml-IN`) listing, with Malayalam screenshots.
- Sanskrit is not a Play listing language. It ships inside the app only.

### 9A.8 Pre-launch verification

- [ ] Internal testing upload; pre-launch report clean (crashes, ANRs, accessibility, security).
- [ ] Play-served build installs and completes the main flow in all three languages.
- [ ] Staged rollout (for example 10% → 50% → 100%) with vitals checked at each step.

---

## 10-11. iOS and Windows

**Not supported.** Do not release for these platforms. The scaffolding exists but nothing has
been built, tested, or security-reviewed for them. `security.md` explicitly covers Android only.

---

## 12. Distribution

Today: direct install of the split APK onto the developer's own device.

Google Play: allowed only after the section 9A gate passes. Before the first upload, re-read
`security.md` — its single-user assumptions (incident response, user communication) change once
other people install the app.

---

## 13. Rollback And Hotfix

Rollback on Android is genuinely awkward — you cannot install an older `versionCode` over a newer
one without uninstalling, and **uninstalling deletes all journal data** (there is no cloud backup
by design).

So:

1. **Always take an in-app backup before installing a new build.** This is the rollback plan.
2. Keep the previous release APK and its debug symbols.
3. To roll back: take a backup, uninstall, install the older APK, restore the backup.
4. For a hotfix, prefer rolling forward with an incremented build number.

---

## 14. Release Evidence

Keep, per release: the APK(s), the debug symbols, the `--analyze-size` output, the merged release
manifest, and a note of who ran the checklist and when.

---

## 15. Post-Release Checks

- [ ] App launches from cold on the target device.
- [ ] Existing journals, entries, and attachments all still open.
- [ ] Lock flow works: relock on background, unlock on return.
- [ ] Take a fresh backup and confirm it verifies.
