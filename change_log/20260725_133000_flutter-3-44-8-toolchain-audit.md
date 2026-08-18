# Change log — Flutter 3.44.8 / Dart 3.12.2 upgrade and app-wide update

Implements [`plans/20260725_120906_flutter-3-44-8-toolchain-audit.md`](../plans/20260725_120906_flutter-3-44-8-toolchain-audit.md).

Date: 2026-07-25

## Result

| Check | Before | After |
|---|---|---|
| `flutter analyze` | clean (on the old SDK pin) | **clean** |
| `flutter test` | 257 passing | **290 passing** |
| `dart format` | 88 of 132 files unformatted | **clean** |
| `flutter build apk --flavor dev --debug` | not run | **succeeds** |

## Slice 1 — toolchain pinned

- `SreerajP_Journal_Vault/pubspec.yaml` — `sdk: ^3.12.2`, added `flutter: ">=3.44.8"`. There was
  no Flutter floor at all before, so nothing stopped a build on an older SDK.
- `SreerajP_Journal_Vault/.metadata` — revision updated to `058e0af2c2b57e369d905a03ac9748b0ebf543c6`.
- `AGENTS.md`, `ai_development_prompts.md`, `journal_vault_plan.md` — target stack text
  changed from Flutter `3.41` / Dart `3.11`.
- `SreerajP_Journal_Vault/docs/architecture.md` — new "Toolchain in force" table.

**Side effect worth knowing.** Raising the SDK floor also raised the language version to 3.12,
which enables private initializing formals. `prefer_initializing_formals` then flagged 24 places.
All were converted to `required this._field`. In three files the parameter name did not match the
field (`database` vs `_db`), so the *field* was renamed `_db` → `_database` — this keeps the public
argument name identical and no call site changed:

- `features/attachments/services/attachment_storage_migration_service.dart`
- `features/security/services/attachment_lock_service.dart`
- `features/security/services/auto_lock_service.dart`

Also touched: `attachment_crypto_storage.dart`, `attachment_open_service.dart`,
`attachment_temp_file_manager.dart`, `journal_password_service.dart`, `app_lock_controller.dart`,
`app_pin_service.dart`, `conflict_resolution_service.dart`, `sync_engine.dart`, and
`test/features/permissions/permissions_flow_test.dart`.

## Slice 2 — formatting gap closed

Ran `dart format lib test integration_test` — 87 files reformatted. The gap recorded in
`docs/architecture.md` section 21 and `docs/release_process.md` is now closed, and both documents
were updated to say so. The stale "widget_test.dart fails" blocker in `release_process.md` was also
cleared; it was fixed in the earlier last-mile pass.

`dart format .` still crashes on stale `build/` paths — keep naming the source directories.

## Slice 3 — dependency upgrades

Upgraded:

| Package | From | To | Code change |
|---|---|---|---|
| `file_picker` | 10.3.10 | **11.0.2** | `FilePicker.platform.pickFiles` → `FilePicker.pickFiles` (API is static in 11). Two call sites. |
| `local_auth` | 2.3.0 | **3.0.2** | `AuthenticationOptions(stickyAuth: true)` → `persistAcrossBackgrounding: true`; failures are now `LocalAuthException` with structured codes. |
| `local_auth_android` | 1.0.41 | **2.0.9** | none |
| `record` | 6.2.0 | **7.1.1** | none |

`file_picker` 11.0.2 also fixes an Android path-traversal issue (CWE-22) when resolving paths from
external content providers — directly relevant to the attachment import path.

`biometric_authenticator.dart` now maps every `LocalAuthExceptionCode` onto the app's three
outcomes: user-recoverable codes (cancel, timeout, lockout, fallback) → `failed`; device-level
codes (no credentials, no hardware, device error) → `unavailable`. The switch is exhaustive on
purpose, so a future plugin release that adds a code fails at compile time instead of silently
misclassifying. **20 new tests** in `test/features/lock_gate/biometric_authenticator_test.dart`
cover the whole mapping, using a fake `LocalAuthPlatform`. This class had no tests before.
`local_auth_platform_interface` was added as a **dev**-dependency for that fake.

### Held back — a real dependency conflict

`package_info_plus` 10, `device_info_plus` 13 and `syncfusion_flutter_pdfviewer` 34 all require
`win32 ^6`; every stable `file_picker` (through 11.x) requires `win32 ^5`. They cannot resolve
together. `win32` only affects the Windows target, which this app does not support, but pub
resolves for all platforms regardless.

`file_picker` was chosen over the other three because of the security fix above; the held packages
only supply version strings, an SDK-int check and PDF rendering, all of which work fine on their
current versions. The reasoning is written into `pubspec.yaml` next to the constraints. Revisit
when `file_picker` 12 leaves beta — it moves to `win32 ^6` and the conflict disappears.

## Slice 4 — in-app attachment viewers built

The audit found that `AttachmentOpenRouter` had been returning `inAppPdf` / `inAppAudio` /
`inAppArchive` decisions that **no screen consumed** — every attachment went to an external app —
while `syncfusion_flutter_pdfviewer` and `just_audio` sat unused in `pubspec.yaml`. The user chose
to build the viewers rather than drop the packages.

New files under `lib/features/attachments/presentation/`:

- `attachment_viewer_screen.dart` — host screen, app bar with `Open with...`, shared unsupported
  state, and ownership of the decrypted temp file (released on dispose).
- `pdf_attachment_view.dart` — `SfPdfViewer.file`, plus a missing-file state.
- `audio_attachment_view.dart` — play/pause, seek bar, elapsed/total time. `just_audio` sits behind
  an `AudioPlaybackHandle` interface so widget tests need no platform channel. Pauses on
  backgrounding so audio cannot keep playing behind the lock gate.
- `archive_attachment_view.dart` — ZIP entry listing via `archive`, nothing extracted to disk.
  `readZipEntries` checks the `PK` signature first, because `ZipDecoder` returns an empty archive
  instead of throwing when handed arbitrary bytes.

Changed:

- `attachment_open_service.dart` — new `AttachmentOpenSession` (handle + routing decision +
  `opensInApp` + `close`), new `prepare` and `openExternally`. `prepareOpen` kept as
  `prepare` + `openExternally` for callers that always want the hand-off.
- `entry_editor_screen.dart` — the tray now pushes the viewer for in-app kinds and hands off
  everything else. Failure dialogs are unchanged.
- `pubspec.yaml` — `flutter_quill_extensions` removed; it was imported by nothing and had no
  feature behind it.
- `test/features/attachments/attachment_tray_test.dart` — its fake overrode `prepareOpen`; it now
  overrides `prepare` too, preserving the test's original intent.

**12 new tests** in `test/features/attachments/attachment_viewer_screen_test.dart`.

Security note: on the in-app path the decrypted plaintext never leaves the app cache and is deleted
when the viewer closes. The external path still leaves the file for the receiving app, swept later
by `AttachmentTempFileManager` — unchanged behaviour.

## Slice 5 — Android toolchain: no change, documented

Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20 are kept. Flutter 3.44's template now defaults to
Gradle 9.1.0 / AGP 9.0.1 / Kotlin 2.3.20 — AGP 9 is no longer paused — but the current versions are
inside the supported range and the build works, so moving to AGP 9 is left as its own plan.
Recorded in `docs/architecture.md`. `docs/guidelines/flutter_build_flavors_guide.md` still says
"AGP 8.x — NOT 9.x", which is now out of date; it is in the read-only submodule and cannot be
corrected from this repo.

## Note for future test authors

`testWidgets` runs in a fake-async zone: an **awaited real file operation inside a widget test
never completes**, and the test hangs until the 10-minute framework timeout. Use the `…Sync` file
APIs in widget tests (or `tester.runAsync`). Existing temp-directory tests were unaffected because
they are plain `test()` cases.
