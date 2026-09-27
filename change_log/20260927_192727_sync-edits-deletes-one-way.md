# Change log — Wi-Fi Sync sends edits and deletes, host to client, with conflicts shown to the user

**Plan:** `plans/20260927_190211_sync-edits-deletes-one-way.md` (approved 2026-09-27, without a
"Keep both" button)

Decisions from the user: one way (only the host sends); a delete on the host deletes the item on
the client; an item changed on both phones goes to the conflict screen; everything that syncs
also syncs edits and deletes.

## Slice 1 — Mark every edit and delete (schema 11 → 12)

- `lib/core/database/app_database.dart`: `schemaVersion` 12. New `syncTrackedTables` list and
  `_createSyncTriggers()`, run in `onCreate` and in the `from < 12` migration. For each synced
  table:
  - `sync_<table>_au` (after update) sets the row's `sync_metadata` to pending
    (`last_synced_at = NULL`), bumps `version` and sets `last_modified_at`;
  - `sync_<table>_ad` (after delete) does the same and sets `is_deleted = 1` (a tombstone).
    Cascaded deletes fire their own triggers.
  - For `attachments` and `voice_notes`, the update trigger fires only when a column that travels
    changes, so a storage move (`encrypted_path` only) does not resend every file.
- `SyncEngine.syncableTables` now **is** `syncTrackedTables`, so the list lives in one place.
- `test/core/database/migration_test.dart`: the rewind helper drops the new triggers for older
  versions; new tests: "v11 → v12 creates the sync change triggers", schema version 12, and a
  "sync change triggers" group (update marks pending, delete leaves tombstones incl. cascades, a
  storage move does not mark, a never-synced row is left alone).

## Slice 2 — Roles and acknowledgement

- `SyncRole { sender, receiver }`, required on `SyncEngine`. `syncEngineBuilderProvider` takes the
  role: the host screen passes `sender`, the client provider `receiver`.
- **Sender:** sends its pending records (tombstones included), waits for the acknowledgement,
  then marks as synced only the records it sent, and only while their version is unchanged
  (`SyncMetadataDao.markSyncedAtVersion`), so an edit made during the sync stays pending. The
  payload is sent even when empty, so the client is never left waiting.
- **Receiver:** applies everything in one transaction. It takes the set of records already
  pending before the apply (`pendingSyncIds`), and afterwards marks every other pending record as
  synced (`markPendingSyncedExcept`). That covers the received records and their cascades, but
  never the client's own changes. Then it acknowledges.
- `SyncProtocol.acknowledge(SyncAck)` and the `SyncAck` message (applied / skipped / conflicts).
  `WifiSyncProtocol.push` (host) now waits for the client's reply over the same encrypted socket,
  and throws without one. The client no longer sends a payload that nobody read.
- `SyncMetadataDao.getUnsyncedRecords` now means "pending" (`last_synced_at IS NULL`), tombstones
  included.

## Slice 3 — Edits

- A received record that is not pending here is applied (insert, update, or re-create if it was
  deleted here earlier). One that **is** pending here is stored as a conflict, not applied.
  Version numbers are stored but no longer decide anything.
- New `lib/features/sync/services/sync_record_applier.dart` (`SyncRecordApplier`): insert, update
  and delete of one received record, with the ID translation and file rules, plus
  `rewriteTextIds`. Sync and conflict resolution both use it, so they follow the same rules. This
  file was not named in the plan: it replaces the private insert and update code in
  `sync_engine_records.dart`.

## Slice 4 — Deletes

- Tombstones are applied after all inserts and edits, children first, in the same transaction.
  An unknown or already-deleted item is skipped. An item pending here becomes a delete conflict.
- Deletes follow the app's rules: an entry with its attachments, a journal with its entries, a
  tag with its links. `EntryDeletionService` gained `deleteEntryRows` / `deleteJournalRows`,
  which delete rows and **return** file paths. `deleteEntry` / `deleteJournal` now use them. Sync
  deletes the files only after its transaction commits.

## Slice 5 — Conflicts

- `sync_engine_records.dart` stores both sides as decoded JSON; a deleted side is
  `{"_deleted": true}`. A file sent with the other phone's version is stored now under this
  phone's key, and its details are kept under `_conflictFile`. A newer conflict for the same
  record replaces an open one (`SyncConflictsDao.replaceOpenConflict`, old one marked
  `superseded`, its file removed).
- `conflict_resolution_service.dart` (rewritten on the applier):
  - **Keep remote** applies the stored version (update, or re-create, or delete), rewrites text
    IDs, swaps in the stored file, and marks the record and its cascades synced. If an item it
    points at is missing, it throws `ConflictResolutionException(missingParent: true)`, the
    transaction rolls back, and the conflict stays open.
  - **Keep local** keeps this phone's version pending and deletes the stored file. **Dismiss**
    deletes it too.
  - `ConflictDetail.isLocalDeleted` / `isRemoteDeleted`; internal `_` keys are left out of the
    field list.
  - The provider passes the attachment cipher.
- `lib/app/startup_maintenance.dart`: `storedFilePaths` counts conflict files as in use, so the
  orphan sweep keeps them.
- `conflict_resolution_screen.dart`: a delete conflict says which side deleted it, and a
  missing-parent failure shows a translated message instead of raw exception text.
- **New ARB keys** (en / ml / sa): `descSyncConflictDeletedRemote`,
  `descSyncConflictDeletedLocal`, `errorSyncConflictMissingParent`. **Malayalam and Sanskrit
  need native-reader review.**

## Slice 6 — Docs and wording

- `bodyRestoreConfirmReplaceBody` (en / ml / sa) gained one sentence: after a replace restore,
  the next Wi-Fi Sync from this device replaces the other device's copies too. **The Malayalam and
  Sanskrit sentence need native-reader review.**
- `AppFlavorConfig.enableSyncUi`: comment corrected. It said sync had no transport. The flag
  itself is unchanged.
- `docs/architecture.md` §21 (new "Closed on 2026-09-27 — sync edits and deletes"),
  `docs/features.md` §8 (what sync sends, deletes, two phones, restore; the "Keep Both" claim
  corrected), `docs/security.md` (decoded conflict data inside SQLCipher), `CHANGELOG.md`
  ("Known issues").

## Tests

- New `test/features/sync/sync_edits_deletes_test.dart` (13 tests). The host and client run at
  once, joined by a fake link where the host waits for the client's real acknowledgement. The
  tests cover:
  - edits reach the client, repeatedly;
  - a delete removes the entry and its file on the client;
  - a journal delete takes its entries;
  - a client edit waits and goes out when that phone is the host;
  - an entry changed on both phones: stored as a conflict, keep remote, and keep local (which
    later reaches the host);
  - deleted on the host, edited on the client: keep remote and keep local;
  - no acknowledgement → nothing marked;
  - a failed apply marks nothing, and the next sync sends everything;
  - an attachment conflict keeps both files, and the sweep counts the stored copy;
  - keep remote on an attachment swaps in the stored file.

  The key is derived once per file there (`_OnceEncryption`, test-only). Argon2id in pure Dart
  takes seconds, and these tests run several syncs each.
- `test/features/sync/sync_engine_wifi_test.dart`: over the real socket, an edit and a delete
  reach the client, and the host ends with nothing pending (so the acknowledgement arrived).
- Existing sync tests: roles added, and `acknowledge` added to their fake protocols.
- Mutation checks, each restored afterwards:
  - with tombstones not sent, 4 tests fail;
  - with conflict detection off, 5 fail;
  - with the client marking its own changes synced, 3 fail.
- The plan named `test/app/startup_maintenance_test.dart` for the sweep. The check is in the
  attachment-conflict test instead, which calls `storedFilePaths` on a real conflict.

## Found by the checks

- The architecture guard (`test/architecture/no_dao_in_presentation_test.dart`) failed at first:
  the conflict-file lookup had been added to `lib/app/startup_maintenance.dart` as a DAO call.
  It now lives in the sync service layer (`conflictStoredFilePaths` in
  `sync_record_applier.dart`), and start-up calls it.

## Checks

- `flutter gen-l10n`, then `dart format lib test integration_test`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 1,201 tests pass (1,182 before this plan).
- `sh tool/check_sanskrit_markers.sh`, `sh tool/check_absolute_paths.sh --all`: pass.
- `flutter build apk --flavor dev --debug`: built. It ran before the last wording and doc changes
  and the guard fix; those are Dart and ARB only, and `flutter analyze` is clean after them. Not
  installed on any phone.

## Manual check for the user, on two phones

This needs two builds that do not replace an install holding real entries (see "Build flavors"
in CLAUDE.md).

1. Phone A hosts, phone B joins, sync. Then on A: edit an entry and delete another. Sync again
   (A hosts). On B, the edit is there and the deleted entry is gone.
2. Edit the same entry on both phones, then sync (A hosts). B shows a conflict. Try "Keep
   Remote", then repeat and try "Keep Local".
3. Make an edit on B. Sync with B as the host. The edit reaches A.
