# Close last-mile implementation gaps

**Status:** completed

Implemented 2026-07-25 — see
[change_log/20260725_120203_close-last-mile-gaps.md](../change_log/20260725_120203_close-last-mile-gaps.md).
Two deviations, both recorded in the change log: Issue 3 took option (b) as recommended, and
Issue 4's chip bar went into the entry editor rather than Search, because reading the code showed
it suggests tags for the entry being edited rather than filtering search results.

Follow-up to [20260725_000000_remediation-plan.md](20260725_000000_remediation-plan.md), whose boxes are all ticked. This plan
covers gaps that plan did not look for: places where the data layer, the native layer, and the
unit tests all exist and pass, but the path a real user takes is not connected.

## How this was found

- `flutter analyze` — clean, 0 issues.
- `flutter test` — 235 pass, 1 fail.
- Traced every `UnimplementedError` in `lib/` back to the UI that calls it.
- Checked which services and screens are actually imported by a reachable widget.
- Read the merged `prodRelease` Android manifest.

## The pattern

Five prompts are marked `[COMPLETED]` in `ai_development_prompts.md` but stop one step short of
working. The unit tests pass because they call the services directly and never walk the user's
path. Fixing the code is only half the job — the prompt file has to stop claiming these are done.

---

## Issue 1 — Tapping an attachment crashes the app

**Severity: high.** Attachments can be imported and encrypted, but never opened.

`AttachmentOpenRouter.open` throws `UnimplementedError`
(`lib/features/attachments/domain/attachment_open_router.dart:35`). It is reached from
`_open` in `lib/features/entries/presentation/entry_editor_screen.dart:1008`, which catches only
`AttachmentOpenException` — so the error escapes uncaught into the framework.

Prompt 05 (`Attachment Import + Open`) is marked `[COMPLETED]`.

`open_filex: ^4.7.0` is already in `pubspec.yaml` and is otherwise unused, so the intended
implementation is clear.

### Fix

- Implement `open` with `OpenFilex.open(prepared.tempFilePath, type: prepared.mimeType)`.
- Map its `ResultType` to the existing `AttachmentOpenFailure` values, which already cover every
  case the UI dialog handles:
  - `noAppToOpen` → `AttachmentOpenFailure.noCompatibleApp`
  - `fileNotFound` → `AttachmentOpenFailure.fileNotFound`
  - `permissionDenied` → `AttachmentOpenFailure.permissionDenied`
  - `error` → `AttachmentOpenFailure.noCompatibleApp`
- Keep `AttachmentOpenRouter` injectable so it can be faked in tests. It is already constructed in
  `lib/main.dart:53`, so only the class body changes.

### Files

- `lib/features/attachments/domain/attachment_open_router.dart`
- `test/features/attachments/attachment_open_router_test.dart` (new)

### Acceptance

- Importing then tapping a PDF, an image, and an audio attachment opens each one.
- Tapping an attachment whose file was deleted shows the "Attachment file is missing" dialog
  rather than crashing.

---

## Issue 2 — SD-card storage migration is a stub, and the setting lies

**Severity: high.** Silent data-location mismatch.

`AesGcmAttachmentCryptoStorage.migrateStoredFile` throws `UnimplementedError`
(`lib/features/attachments/services/attachment_crypto_storage.dart:227`).

The whole UI above it is wired and reachable: the picker, the confirm dialog, the progress dialog
with cancel, and the retry path (`lib/app/app.dart:2136`). It fails on the first file.

Two follow-on problems:

- With **zero** attachments the loop body never runs, so the migration "succeeds" and writes
  `sd_card` into `AppSettings.attachmentStorageLocation` — but `encryptAndStore` always writes to
  the documents directory regardless of the setting, so every later attachment silently lands in
  app-private storage while the UI reports SD card.
- `cleanupMigrationArtifacts` is an empty method, so a failed migration leaves partial documents
  on the tree.

Prompt 12 (`Storage Migration`) is marked `[COMPLETED]`.

**The native side is already complete.** `MainActivity.kt` exposes, on the
`sreerajp.journal_vault/attachment_storage` channel: `migrateLocalFileToTree`,
`migrateTreeDocumentToLocalFile`, `writeStorageDocument`, `readStorageDocument`,
`deleteStorageDocument`, `cleanupPendingTreeDocuments`, and `checkStorageTreeAccess`. Only
`pickStorageTree` has a Dart wrapper today
(`lib/features/attachments/services/attachment_storage_picker.dart`). The missing work is entirely
on the Dart side.

### Fix

- Add a `AttachmentStorageDocumentClient` wrapper over the remaining channel methods, next to the
  existing picker wrapper, so the crypto storage does not talk to a raw `MethodChannel`.
- Inject it into `AesGcmAttachmentCryptoStorage` and implement:
  - `migrateStoredFile` — app-private → SD via `migrateLocalFileToTree`; SD → app-private via
    `migrateTreeDocumentToLocalFile`. Return the new path or `content://` URI.
  - `cleanupMigrationArtifacts` — call `cleanupPendingTreeDocuments` when the target is `sdCard`.
- Make the read/write/delete paths location-aware, keyed off the existing `content://` test that
  `isStoredInLocation` already uses:
  - `encryptAndStore` — take the active location (and tree URI) and write via
    `writeStorageDocument` when it is `sdCard`.
  - `decryptToTempFile` — read via `readStorageDocument` for `content://` paths.
  - `deleteStoredFile` — delete via `deleteStorageDocument` for `content://` paths.
- Throw `AttachmentStorageUnavailableException` (already defined, currently unused) when the
  channel reports `storage_unavailable`, so a removed SD card gives a real message.
- Delete `lib/features/attachments/services/attachment_storage_location_service.dart`. It is
  imported nowhere and its only method returns a hardcoded `appPrivate`, which is exactly the bug
  above in miniature.

### Files

- `lib/features/attachments/services/attachment_crypto_storage.dart`
- `lib/features/attachments/services/attachment_storage_picker.dart` (add the document client)
- `lib/features/attachments/services/attachment_storage_location_service.dart` (delete)
- `lib/main.dart` (pass the client and the settings-backed location)
- `test/features/attachments/` — migration tests against a fake channel

### Acceptance

- Migrating app-private → SD card moves every file, updates each row's `encryptedPath`, and leaves
  no file behind in `encrypted_attachments/`.
- After migrating, a newly imported attachment is written to the SD tree, not app-private.
- Migrating back to app-private restores the original layout.
- Cancelling mid-migration leaves already-moved rows correct and the status retryable.
- Pulling the SD card mid-run surfaces a storage-unavailable message, not a raw exception string.

---

## Issue 3 — Sync has no working path

**Severity: medium.** Dead subsystem behind live UI.

`SyncEngine` (`lib/features/sync/services/sync_engine.dart`, 392 lines) is referenced by nothing —
no provider, no screen, no test. `SyncProtocol` has no concrete implementation anywhere in the
repo. `lib/features/sync/providers/sync_providers.dart` has no `syncEngineProvider`.

The conflict-resolution screen (`app.dart:1110`, `app.dart:1755`) and the health dashboard
(`app.dart:2274`) are reachable, but they read tables that nothing ever writes. `SyncStatusNotifier`
is never moved off `idle`.

Prompt 19 (`V3 Encrypted Sync + Conflict Resolution`) is marked ✅.

`SyncEncryptionService` and `ConflictResolutionService` are genuinely implemented and tested — the
missing pieces are the transport and the wiring.

### Decision needed

This is the one item where I need your call, because there is no half-answer:

- **(a) Finish it** — needs a real backend or transport chosen first (REST endpoint, WebDAV,
  file-based folder sync). This is a feature-sized piece of work, not a fix, and it needs its own
  plan once the transport is chosen.
- **(b) Shelve it honestly** — hide the sync entry points behind an off-by-default flag, mark
  Prompt 19 as partial in `ai_development_prompts.md`, and record the decision in
  `docs/architecture.md` section 21.

**My recommendation is (b) for now.** Shipping a Settings screen that reports sync health for a
sync that cannot run is worse than not showing it. (a) should be its own plan with a chosen
transport, not a line item here.

I have written this plan assuming **(b)**. Say so if you want (a) and I will re-present.

### Files (for (b))

- `lib/app/app.dart` — gate the sync rows
- `ai_development_prompts.md` — Prompt 19 → partial, with the reason
- `docs/architecture.md` — add to section 21

---

## Issue 4 — Smart tags are unreachable

**Severity: medium.** Dead subsystem, no UI at all.

`SmartTagService`, `smart_tag_providers.dart`, and `SmartTagChipBar` exist and
`test/features/smart_tags/smart_tag_service_test.dart` passes — but no screen imports any of it.
A repo-wide search for `SmartTag` outside `lib/features/smart_tags/` returns nothing.

Prompt 16 (`V2 FTS5 + Smart Tags + Timeline`) is marked ✅. FTS5 and Timeline are genuinely wired;
Smart Tags is not.

Unlike sync, this one is cheap to finish — the service and the chip widget are both already built.

### Fix

- Mount `SmartTagChipBar` in `_SearchTab` (`lib/app/app.dart:2499`) above the results list.
- Tapping a chip filters the current search by that tag.
- Verify Light and Dark parity.

### Files

- `lib/app/app.dart`
- `lib/features/smart_tags/presentation/smart_tag_chip_bar.dart` (only if the API needs adjusting)
- `test/features/smart_tags/` — widget test for chip → filtered results

### Acceptance

- The chip bar renders in Search with the tags the service derives.
- Tapping a chip narrows the results; tapping again clears it.

---

## Issue 5 — `minSdk` is 24, but the constraint is 28

**Severity: medium.** Violates a stated global constraint, and weakens a security assumption.

`android/app/build.gradle.kts:47` uses `minSdk = flutter.minSdkVersion`, which resolves to 24. I
confirmed `android:minSdkVersion="24"` in the merged `prodRelease` manifest under `build/`.

`AGENTS.md` mandates Android minimum API 28. `20260725_000000_remediation-plan.md` slice A2 also assumed API 28+
when it chose Keystore-backed storage.

### Fix

- Set `minSdk = 28` explicitly in `android/app/build.gradle.kts`.
- Rebuild and re-read the merged manifest to confirm.

### Files

- `android/app/build.gradle.kts`

### Acceptance

- The merged `prodRelease` manifest reads `android:minSdkVersion="28"`.
- A release build still compiles.

---

## Issue 6 — The one failing test is a test bug

**Severity: low.** One line.

`test/widget_test.dart` → "Journal detail groups entries and reacts to entry CRUD" has been failing
since before the last plan and is recorded in `docs/architecture.md` section 21 as unexplained.

**It is not an app bug.** I traced it. At `test/widget_test.dart:451-458` the test calls
`enterText` and then immediately `tap(find.byTooltip('Save'))` with **no pump in between**.
`WidgetTester.enterText` does not pump. The `setState` inside `_markDirty` therefore never
rebuilds, `_isDirty` is still `false` at the widget level, and the save button's tooltip is still
`'No unsaved changes'` — so `find.byTooltip('Save')` matches nothing.

I confirmed this by instrumenting `_markDirty`: it runs with `isDirty=false, mounted=true`, the
`setState` fires, and no `build` follows before the tap. The editor's dirty-tracking logic is
correct.

### Fix

- Add `await tester.pump();` after the `enterText` at `test/widget_test.dart:454`.
- Check the second `enterText` → `tap` pair at line 468-472 for the same missing pump.

### Files

- `test/widget_test.dart`

### Acceptance

- `flutter test` is 236 passing, 0 failing.
- The fix is in the test only. No file under `lib/` changes for this issue.

---

## Issue 7 — Dead code

**Severity: low.**

Superseded by reimplementations inside `app.dart`, but still compiled and still misleading:

| File | Status |
|---|---|
| `lib/features/search/presentation/search_screen.dart` | Imported nowhere. Search is `_SearchTab` in `app.dart:2499`. |
| `lib/features/attachments/services/attachment_storage_location_service.dart` | Imported nowhere. Removed as part of Issue 2. |
| `lib/features/home/presentation/home_screen.dart` | Imported only by its own test. Home is `_HomeTab` in `app.dart:945`. |
| `lib/features/journal_lock/journal_lock_controller.dart` | Imported only by its own test. |

### Fix

- Delete `search_screen.dart`.
- For `home_screen.dart` and `journal_lock_controller.dart`: confirm the behaviour they cover is
  also covered against the live `_HomeTab` / lock gate, then delete both the file and its test. If
  the coverage is not duplicated elsewhere, port the test to the live widget first — do not lose
  the assertions.

### Files

- The four files above and their tests.

### Acceptance

- `flutter analyze` stays clean.
- Test count does not drop except for tests deliberately ported.

---

## Out of scope

Left alone on purpose, all already recorded in `docs/architecture.md` section 21:

- Splitting `lib/app/app.dart`. Now **2,806 lines** (section 21 says 2,568 — worth correcting in
  that doc). Still a pure refactor with real regression risk; needs its own plan.
- `dart format`. 88 of 132 files differ (section 21 says 95 — also slightly stale). Mechanical, but
  it would touch nearly every file and bury the fixes above in the diff.
- The missing release keystore, and R8 never having been runtime-verified.
- No "Delete all data" action. Confirmed still absent — a repo-wide search for `deleteAllData` /
  `wipe` returns nothing.
- The unversioned attachment crypto format, and the unencrypted SQLite database.

---

## Order of work

1. **Issue 6** — one line, gets the suite green so everything after is measured against a clean run.
2. **Issue 1** — highest user impact; users currently cannot open their own attachments.
3. **Issue 5** — one line, unblocks the API-28 security assumption.
4. **Issue 2** — the largest piece; the native half already exists.
5. **Issue 4** — cheap, both parts already built.
6. **Issue 3** — decision first, then the (b) wiring.
7. **Issue 7** — cleanup last, once nothing above still depends on those files.

After each issue: `flutter analyze` and `flutter test` both clean before starting the next.

## Prompt-file corrections

Once the code is fixed, `ai_development_prompts.md` needs updating so it stops overstating. Prompts
05, 12, and 16 become genuinely complete; Prompt 19 gets marked partial with its reason.

## Files changed — summary

| File | Issue |
|---|---|
| `test/widget_test.dart` | 6 |
| `lib/features/attachments/domain/attachment_open_router.dart` | 1 |
| `test/features/attachments/attachment_open_router_test.dart` (new) | 1 |
| `android/app/build.gradle.kts` | 5 |
| `lib/features/attachments/services/attachment_crypto_storage.dart` | 2 |
| `lib/features/attachments/services/attachment_storage_picker.dart` | 2 |
| `lib/features/attachments/services/attachment_storage_location_service.dart` (delete) | 2, 7 |
| `lib/main.dart` | 2 |
| `test/features/attachments/` | 2 |
| `lib/app/app.dart` | 3, 4 |
| `test/features/smart_tags/` | 4 |
| `lib/features/search/presentation/search_screen.dart` (delete) | 7 |
| `lib/features/home/presentation/home_screen.dart` (delete) | 7 |
| `lib/features/journal_lock/journal_lock_controller.dart` (delete) | 7 |
| `ai_development_prompts.md` | 3, and the prompt corrections |
| `docs/architecture.md` | 3, plus the stale line/file counts |
