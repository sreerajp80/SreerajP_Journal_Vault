# Flutter 3.44.8 / Dart 3.12.2 toolchain audit and app-wide update

**Status:** completed

> **Approved 2026-07-25.** All slices approved. For Slice 4 the user chose **Option B — build the
> in-app viewers**. Slice 4 below has been rewritten from a question into the agreed design.

## Why this plan exists

The team is moving to:

```
Flutter 3.44.8 • channel stable • revision 058e0af2c2 • 2026-07-23
Tools • Dart 3.12.2 • DevTools 2.57.0
```

The repo still declares Flutter `3.41` / Dart `3.11` in several places. I checked the whole app
against the installed 3.44.8 toolchain before writing this plan.

## What I found (facts, already verified)

Good news first — the app is healthy on the new SDK:

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** (127 source files) |
| `flutter test` | **257 tests, all passing** |
| Android `compileOptions` / `jvmTarget` | Java 17 — correct for 3.44 |
| `android.newDsl` / `android.builtInKotlin` flags | Already present in `gradle.properties` |
| `minSdk = 28` | Pinned as `AGENTS.md` requires |

Now the gaps:

1. **Stale version declarations.** `pubspec.yaml` says `sdk: ^3.11.1`; `AGENTS.md`,
   `ai_development_prompts.md` and `journal_vault_plan.md` all say "Flutter `3.41`,
   Dart `3.11`". There is no `flutter:` SDK constraint in `pubspec.yaml` at all, so nothing stops
   a build on an older Flutter.

2. **`.metadata` points at an old framework revision** (`ff37bef6…`). The current one is
   `058e0af2c2b57e369d905a03ac9748b0ebf543c6`. This is what `flutter migrate` reads.

3. **88 of 132 source files do not match `dart format`.** This is the known gap already written
   up in `docs/architecture.md` section 21. The Dart 3.12 formatter makes it worse, not better,
   and every future diff is noisy until it is fixed.

4. **7 direct dependencies are a major version behind**, and 25 more behind transitively:

   | Package | Now | Latest |
   |---|---|---|
   | `local_auth` | 2.3.0 | 3.0.2 |
   | `local_auth_android` | 1.0.56 | 2.0.9 |
   | `package_info_plus` | 9.0.1 | 10.2.1 |
   | `device_info_plus` | 12.4.0 | 13.2.0 |
   | `record` | 6.2.1 | 7.1.1 |
   | `syncfusion_flutter_pdfviewer` | 33.2.13 | 34.1.32 |
   | `file_picker` | 10.3.10 | 11.0.2 |

   The Dart code touching these packages is small — 8 import sites in total.

5. **Three declared dependencies are never imported by any Dart file:**
   `syncfusion_flutter_pdfviewer`, `just_audio`, `flutter_quill_extensions`.
   (`sqlite3_flutter_libs` and `cupertino_icons` are also unimported but are legitimately needed —
   native libraries and template icons.)

6. **This is why item 5 matters — a real feature gap.** `AttachmentOpenRouter` computes
   `inAppPdf`, `inAppAudio` and `inAppArchive` decisions, and the tests check them, but **no screen
   consumes those values**. `open()` sends every attachment to the external app handler via
   `open_filex`. So V1 Slices 3, 4 and 5 of the attachment plan (in-app PDF viewer, in-app audio
   player, in-app archive listing) are **not delivered** — the packages for them were added but the
   UI was never built.

7. **Android build toolchain is behind the 3.44 template, but still supported.**
   Project: Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20. Flutter 3.44 templates now default to
   Gradle 9.1.0, AGP **9.0.1**, Kotlin 2.3.20 — AGP 9 is no longer paused. The project's versions
   are well inside the supported range (`maxKnownAndSupportedAgpVersion = 9.1`), so this is *not*
   broken. Note `docs/guidelines/flutter_build_flavors_guide.md` still says "AGP 8.x — NOT 9.x",
   which is now out of date; that file is in the read-only submodule and cannot be fixed here.

## Proposed scope

### Slice 1 — Pin the new toolchain (low risk)

Files:

- `SreerajP_Journal_Vault/pubspec.yaml` — `sdk: ^3.12.2`, add `flutter: ">=3.44.8"`.
- `SreerajP_Journal_Vault/.metadata` — revision to `058e0af2c2b57e369d905a03ac9748b0ebf543c6`.
- `AGENTS.md` line 5 — Flutter `3.44.8`, Dart `3.12.2`.
- `ai_development_prompts.md` line 26 — same.
- `journal_vault_plan.md` line 6 — same.
- `SreerajP_Journal_Vault/docs/architecture.md` — add a toolchain row and correct the
  "Dart 3.11 formatter" wording.
- `SreerajP_Journal_Vault/docs/release_process.md` — same wording fix.

Verify: `flutter pub get`, `flutter analyze`, `flutter test`.

### Slice 2 — Format the codebase with the Dart 3.12 formatter (low risk, wide diff)

Run `dart format lib test integration_test` (never `dart format .` — it crashes on stale `build/`
paths). Then mark the gap closed in `docs/architecture.md` section 21 and
`docs/release_process.md`.

Verify: `flutter analyze`, `flutter test` — behaviour must be unchanged; formatting only.

### Slice 3 — Upgrade the 7 major-version dependencies (medium risk)

One package at a time, in this order, running `flutter analyze` + `flutter test` after each:

1. `package_info_plus` 10 — used only in `lib/core/config/config_service.dart`.
2. `device_info_plus` 13 — used only in
   `lib/features/permissions/services/permission_handler_app_permissions_service.dart`.
3. `file_picker` 11 — used in `import_screen.dart` and
   `file_picker_attachment_picker_service.dart`.
4. `local_auth` 3 + `local_auth_android` 2 — used in
   `lib/features/lock_gate/services/biometric_authenticator.dart`. **Highest risk: this is the app
   lock path.** Covered by `integration_test/lock_gate_test.dart`.
5. `record` 7 — used in `lib/features/entries/services/voice_note_service.dart`.
6. `syncfusion_flutter_pdfviewer` 34 — only if the package is kept (see Slice 4).

If any upgrade needs an API change, the code change is made in the same step, with its test.
If an upgrade turns out to need real rework, I stop, leave that package on its current version,
and report it rather than half-migrating.

Verify: `flutter analyze`, `flutter test`, and an actual
`flutter build apk --flavor dev --debug` to prove the Android native side still links.

### Slice 4 — Build the in-app attachment viewers (chosen: Option B)

Delivers V1 Slices 3, 4, 5 and 7 of `journal_vault_plan.md` — the in-app PDF viewer,
audio player and archive listing — so the router's existing `inAppPdf` / `inAppAudio` /
`inAppArchive` decisions finally reach a screen. This also gives
`syncfusion_flutter_pdfviewer` and `just_audio` a real purpose.

New files under `lib/features/attachments/presentation/`:

- `attachment_viewer_screen.dart` — the host screen. Takes an attachment, decrypts it to a temp
  file through the existing secure temp-file path, asks `AttachmentOpenRouter.resolve` for the
  kind, and injects the matching body widget. Owns the shared loading / error / empty shell so
  every viewer reports failures the same way, using the existing `AttachmentOpenFailure` codes
  and the existing `Retry` / `Open with…` recovery actions.
- `pdf_attachment_view.dart` — `SfPdfViewer.file` on the decrypted temp file.
- `audio_attachment_view.dart` — `just_audio` player: play/pause, seek bar, elapsed/total time,
  and a lifecycle-safe pause when the app is backgrounded or the lock gate closes.
- `archive_attachment_view.dart` — ZIP entry listing (name, path, size) via the `archive` package,
  already a dependency. Nothing is extracted to shared storage. `7z` and encrypted or corrupt
  archives fall back to the metadata + external-open state, as the plan requires.

Changed files:

- `lib/features/attachments/domain/attachment_open_router.dart` — `open()` currently sends
  everything to `open_filex`. It keeps doing that for `externalOnly`, but the in-app kinds now
  route to the viewer screen instead.
- The entry editor's attachment tray — tapping an attachment opens the viewer screen.
- `pubspec.yaml` — `flutter_quill_extensions` is genuinely unused with no plan behind it, so it
  is removed. `syncfusion_flutter_pdfviewer` and `just_audio` are kept and now used.

Temp-file rule, unchanged from the existing security design: plaintext lives only in the app
cache, is deleted when the viewer closes, and is swept on startup. No plaintext reaches shared
storage, and no key leaves the existing service.

Tests:

- Widget tests for each of the three views: loading, loaded, and the error shell with `Retry`.
- A router test proving in-app kinds no longer fall through to the external handler.
- A test that the temp file is deleted when the viewer is disposed.

Verify by hand: open a multi-page PDF, rotate, lock and unlock; play an audio note and background
the app mid-playback; list a ZIP; confirm a `.docx` still hands off externally.

### Slice 5 — Android toolchain: no change, documented

Keep Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20. They are supported by Flutter 3.44.8, the build
works, and moving to AGP 9 is a breaking-change migration with no benefit to this app right now.
I will add a short note to `docs/architecture.md` recording the current versions, the 3.44 template
defaults, and that AGP 9 is a deliberate "later, on its own plan" item.

## Out of scope

- The open items already listed in `docs/architecture.md` section 21 (release keystore, R8 runtime
  verification, delete-all-data, DB-at-rest encryption, sync transport, the 2,830-line
  `app.dart` refactor, dev/prod application ID suffix). None of them are affected by the SDK move.
- Anything inside `docs/guidelines/` — read-only submodule.

## Verification for the whole plan

1. `flutter pub get`
2. `flutter analyze` — must stay at zero issues.
3. `flutter test` — must stay at 257 passing (more if tests are added).
4. `flutter build apk --flavor dev --debug` — must succeed.
5. `dart format --output=none --set-exit-if-changed lib test integration_test` — must exit 0.

## Rollback

Each slice is a separate commit in `SreerajP_Journal/`. `pubspec.lock` is committed, so any
dependency slice can be reverted with a single `git revert` plus `flutter pub get`.
