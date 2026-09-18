# Change log — close last-mile implementation gaps

Implements [plans/20260725_113628_close-last-mile-gaps.md](../plans/20260725_113628_close-last-mile-gaps.md).

Date: 2026-07-25

## Why

An audit of the app found a specific kind of gap: features whose data layer, native layer, and
unit tests all existed and passed, but whose user-facing path was never connected. Five prompts
marked `[COMPLETED]` in `ai_development_prompts.md` stopped one step short of working. The unit
tests passed because they called the services directly and never walked the path a user takes.

## Result

| | Before | After |
|---|---|---|
| `flutter analyze` | clean | clean |
| `flutter test` | 235 pass, 1 fail | **257 pass, 0 fail** |
| `prodRelease` merged manifest `minSdkVersion` | 24 | **28** |
| Release build | compiles | compiles |

## What changed

### 1. Attachments could be imported but never opened

`AttachmentOpenRouter.open` threw `UnimplementedError`. The entry editor calls it and catches only
`AttachmentOpenException`, so tapping any attachment threw an uncaught error into the framework.

- Implemented `open` on `open_filex`, which was already a dependency and otherwise unused.
- Every `ResultType` maps to an existing `AttachmentOpenFailure`, so the failure dialog the editor
  already had now actually receives the cases it handles.
- The opener is injectable, so tests drive every result without a platform channel.
- Added 8 tests for `open`. The test file already existed but only covered `resolve` — that is why
  the stub survived.

Files: `lib/features/attachments/domain/attachment_open_router.dart`,
`test/features/attachments/attachment_open_router_test.dart`

### 2. SD-card storage migration was a stub, and the setting lied

`migrateStoredFile` threw `UnimplementedError` behind a fully wired UI — picker, confirm dialog,
progress dialog, cancel, retry. It failed on the first file.

Worse: with zero attachments the migration loop never ran, so it "succeeded" and wrote `sd_card`
into settings — but `encryptAndStore` always wrote to the app documents directory regardless. The
UI reported SD card while every attachment went to app-private storage.

**The native SAF layer was already complete.** `MainActivity.kt` had implemented
`migrateLocalFileToTree`, `migrateTreeDocumentToLocalFile`, `writeStorageDocument`,
`readStorageDocument`, `deleteStorageDocument`, and `cleanupPendingTreeDocuments` all along. Only
`pickStorageTree` had a Dart caller. The missing work was entirely Dart-side.

- Added `AttachmentStorageDocumentClient` wrapping the remaining native methods, alongside the
  existing picker wrapper.
- Implemented `migrateStoredFile` in both directions. The encrypted blob moves byte-for-byte, so
  the nonce and key reference in the database stay valid and migrated files decrypt unchanged.
- Made `encryptAndStore`, `decryptToTempFile`, and `deleteStoredFile` location-aware, branching on
  the same `content://` test `isStoredInLocation` already used.
- The active target is read on every write, so changing the location in Settings takes effect
  without an app restart.
- Implemented `cleanupMigrationArtifacts` for tree targets.
- `AttachmentStorageUnavailableException` — defined but never thrown — now reports a removed SD
  card properly: a real message on write, and `fileNotFound` rather than `decryptFailed` on open,
  since the bytes are intact and merely unreachable.
- A `sdCard` target with no tree URI falls back to app-private rather than losing the attachment.
- Deleted `attachment_storage_location_service.dart`: imported nowhere, and its only method
  returned a hardcoded `appPrivate` — the same bug in miniature.
- Added 11 storage-level tests with a fake document client. The existing migration *service* test
  used a fake storage, which is why the real stub went unnoticed.

Files: `lib/features/attachments/services/attachment_crypto_storage.dart`,
`lib/features/attachments/services/attachment_storage_picker.dart`, `lib/main.dart`,
`test/features/attachments/attachment_crypto_storage_test.dart`,
`lib/features/attachments/services/attachment_storage_location_service.dart` (deleted)

### 3. Sync shelved rather than left misleading

`SyncEngine` (392 lines) is constructed by nothing — no provider, no screen, no test — and
`SyncProtocol` has no concrete implementation. Nothing can push or pull. But the conflict screen
and health dashboard were reachable from Home and Settings, reading tables nothing ever writes.

Per the approved plan, option (b): shelve it honestly rather than ship a dashboard reporting on a
sync that cannot run.

- Added `AppFlavorConfig.enableSyncUi`, currently `false`.
- Gated the Home app-bar sync status widget and both Settings rows. The Settings rows now render
  as `_ComingSoonTile`, the pattern already used for Tamper Alerts.
- Marked Prompt 19 `[PARTIAL]` with the reason.
- Updated `settings_tab_test.dart`, which asserted the old behaviour.

`SyncEncryptionService` and `ConflictResolutionService` are genuinely implemented and tested and
were left alone. Finishing sync needs a transport decision and its own plan.

Files: `lib/core/config/app_flavor_config.dart`, `lib/app/app.dart`,
`test/features/settings/settings_tab_test.dart`, `ai_development_prompts.md`

### 4. Smart tags were unreachable

`SmartTagService`, its providers, and `SmartTagChipBar` were built and unit-tested, but no screen
imported any of it.

**Correction to the plan:** the plan said to mount the chip bar in Search as a tag filter. Reading
the code showed that is not what it does — it takes `entryId` and `plainText` and suggests
existing tags for *the entry being edited*, adding one on tap. It was mounted in the entry editor
instead, which is where its parameters point. The goal — make smart tags reachable — is unchanged.

- Mounted `SmartTagChipBar` in the entry editor above the mood picker, reading the live document
  text so suggestions track what is being typed.
- Added 4 widget tests: chips render for matching tags, nothing renders with no match, tapping
  applies the tag, and an applied tag stops being suggested.

Files: `lib/features/entries/presentation/entry_editor_screen.dart`,
`test/features/smart_tags/smart_tag_chip_bar_test.dart`

### 5. `minSdk` was 24, not the required 28

`android/app/build.gradle.kts` used `minSdk = flutter.minSdkVersion`, resolving to 24. `AGENTS.md`
requires API 28, and `20260725_000000_remediation-plan.md` slice A2 chose Keystore-backed secret storage assuming
API 28+.

- Pinned `minSdk = 28`.
- Verified `android:minSdkVersion="28"` in the merged `prodRelease` manifest, and that the release
  build still compiles.

Files: `android/app/build.gradle.kts`

### 6. The long-standing test failure was a test bug

`test/widget_test.dart` → "Journal detail groups entries and reacts to entry CRUD" had been failing
since before the previous plan and was recorded as unexplained.

**It was not an app bug.** The test called `enterText` and then immediately tapped
`find.byTooltip('Save')`. `WidgetTester.enterText` does not pump, so the `setState` inside
`_markDirty` had not rebuilt — the save button still read `'No unsaved changes'` and the finder
matched nothing.

Confirmed by instrumenting `_markDirty`: it ran with `isDirty=false, mounted=true`, the `setState`
fired, and no build followed before the tap. The editor's dirty tracking was correct throughout.

- Added `await tester.pump()` after each of the two affected `enterText` calls.
- No file under `lib/` changed for this.

Files: `test/widget_test.dart`

### 7. Dead code removed

Superseded by reimplementations inside `app.dart`, but still compiled and still misleading:

- `lib/features/search/presentation/search_screen.dart` — imported nowhere; Search is `_SearchTab`.
- `lib/features/home/presentation/home_screen.dart` + its test — imported only by its own test;
  Home is `_HomeTab`.
- `lib/features/journal_lock/journal_lock_controller.dart` + its test — imported only by its test.

Before deleting `journal_lock_controller_test`, its one real assertion — session-unlocked journals
clear when the app re-locks — was **ported to a widget test against the live path**
(`AppLockNotifier._onLocked`), so the coverage moved rather than disappeared.

The `home_screen_test` assertions were **not** ported, because the behaviour they covered
(an "Unable to load journals" + Retry error state) does not exist in the live `_HomeTab`. That is
recorded as an open gap in `docs/architecture.md` section 21 rather than silently dropped.

## Documentation updated

- `ai_development_prompts.md` — Prompt 19 → `[PARTIAL]` with reason; Prompts 05, 12, and 16 keep
  `[COMPLETED]` but now carry a note on what was actually missing until today.
- `docs/architecture.md` section 21 — new "Closed on 2026-07-25 — last-mile integration pass"
  table, a new "Still open — sync has no transport" section, and corrected stale figures
  (`app.dart` 2,568 → ~2,830 lines; unformatted files 95 → 88).

## Known gaps left open, deliberately

Unchanged and still recorded in `docs/architecture.md` section 21:

- Sync has no transport (above).
- `_HomeTab` has no error state (new entry).
- Splitting `lib/app/app.dart` — a pure refactor with real regression risk; needs its own plan.
- 88 of 132 files fail `dart format` — mechanical, but would touch nearly every file and bury
  these changes in the diff.
- The release keystore still does not exist, and R8 has never been runtime-verified.
- No "Delete all data" action.
- The attachment crypto format still has no version byte; the SQLite database is still unencrypted
  at rest (risk-accepted).
