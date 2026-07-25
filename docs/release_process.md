# Release Process — SreerajP Journal Vault

> **This is the local copy.** It overrides `docs/guidelines/release_process.md` for this app, per
> the "local copy wins" rule in [`GUIDELINES_MANIFEST.md`](GUIDELINES_MANIFEST.md).

Last reviewed: 2026-07-25

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
- Distribution: **direct sideload to the developer's own device.** No store, no other users.
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
> - [ ] Open a PDF attachment (`syncfusion_flutter_pdfviewer`)
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

`flutter build apk --flavor prod --release --analyze-size`. The last release APK was **63.8 MB**
(universal, unsplit) — large, driven mainly by the Syncfusion PDF viewer. Use `--split-per-abi`
for real distribution.

### 6.4 Debuggable verification

Check the **merged** manifest, never the source:

```
build/app/intermediates/merged_manifests/prodRelease/processProdReleaseManifest/AndroidManifest.xml
```

`android:debuggable` must be absent or `false`. Verified absent on 2026-07-25.

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
- [ ] `dart format --output=none --set-exit-if-changed .` passes.
- [ ] `flutter analyze` reports no issues.
- [ ] `flutter test` — **all** tests pass.

> **Blocker today:** `test/widget_test.dart` → "Journal detail groups entries and reacts to entry
> CRUD" has been failing since before 2026-07-25. Fix it or consciously accept it; do not let it
> quietly become normal.

### Security

- [ ] Work through the checklist in [`security.md`](security.md) section 18.
- [ ] Merged release manifest re-checked: no `INTERNET`, `allowBackup="false"`, no `debuggable`.
- [ ] `FLAG_SECURE` confirmed by trying to take a screenshot in the running app.
- [ ] Obfuscation flags present in the command actually used.
- [ ] Signed with the real release key, not the debug key.

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

```bash
# 1. Verify clean state
git status

# 2. Dependencies and codegen
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 3. Quality gates
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# 4. Build (split per ABI for sideloading)
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info=build/symbols/android-1.0.1/ \
  --split-per-abi

# 5. Size analysis
flutter build apk --flavor prod --release --analyze-size

# 6. Verify the merged manifest (see section 6.4)

# 7. Archive build/symbols/android-1.0.1/ somewhere durable

# 8. Install and run the section 8 validation

# 9. Tag
git tag v1.0.1
```

Artifacts land in `build/app/outputs/flutter-apk/`.

---

## 10-11. iOS and Windows

**Not supported.** Do not release for these platforms. The scaffolding exists but nothing has
been built, tested, or security-reviewed for them. `security.md` explicitly covers Android only.

---

## 12. Distribution

Direct install of the APK onto the developer's own device. No store listing, no other users, so
no store review, privacy policy, or data-safety declaration is currently required. If that ever
changes, both this document and `security.md` need reworking first.

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
