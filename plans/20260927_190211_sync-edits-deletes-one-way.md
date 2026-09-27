# Plan — Wi-Fi Sync: send edits and deletes, host to client, with conflicts shown to the user

**Status:** completed
**Change log:** `change_log/20260927_192727_sync-edits-deletes-one-way.md`
**Note:** Approved 2026-09-27, without a "Keep both" button.

## Background

After `plans/20260927_131308_wifi-sync-id-mapping-and-attachments.md`, Wi-Fi Sync copies **new**
items from the host phone to the client phone, once. Edits and deletes never travel. The user
decided (2026-09-27) what sync should do:

| Question | Decision |
|---|---|
| Direction | **One way.** Only the host sends; the client receives. For the other phone's changes to travel, that phone must be the host. |
| Deletes | **A delete on the host deletes the item on the client.** |
| Both phones changed the same item | **It goes to the conflict screen** for the user to choose. |
| What syncs | **Everything already synced**: journals, entries, tags, journal tags, entry tags, links (backlinks), revisions, attachments (and legacy voice notes). |

Words used below:

- **Host** is the phone showing the pairing code: it sends. **Client** is the phone that scans:
  it receives.
- A record is **pending** on a phone when it changed there since that phone last sent or received
  it.
- A **tombstone** is a record that says "this item was deleted".

---

## What is wrong today (found while planning)

1. **Nothing marks an edit or a delete.** `sync_metadata` has `last_modified_at`, `version` and
   `is_deleted`, but nothing outside sync ever changes them. After an item's first sync, it never
   looks changed again. Deleting an item removes its row, and `is_deleted` is never set.
2. **The client drops its own changes.** The client runs the full cycle: it "pushes" its pending
   records (the host never reads them) and then marks every pending record as synced. So a client
   edit is quietly lost. It will never go out, even when that phone later becomes the host.
3. **The host marks records as synced before the client has applied them.** If the client's apply
   fails, and it now rolls back as one transaction, the host still thinks everything arrived.
4. **"Keep remote" on the conflict screen cannot work.** A conflict stores the other phone's data
   still encrypted with the pairing code (`remoteDataJson`). The code is gone once the session
   ends, so `resolveConflict(keepRemote)` always throws "decryption required".
5. **The apply rule relies on version numbers alone** (`remote.version > local.version`). Once both
   phones count their own edits, two phones can reach the same number, and a real conflict would
   be skipped without a word.
6. `docs/features.md` says the conflict screen offers "Keep Both". It does not: it offers Keep
   Remote and Keep Local.

---

## The design

### Part 1 — Mark every edit and delete (database triggers, schema 11 → 12)

- New SQLite triggers on each synced table, created in `onCreate` and in a `from < 12` migration,
  the same way the FTS triggers are:
  - **after update**: the row's `sync_metadata` gets `version + 1`, `last_modified_at = now` and
    `last_synced_at = NULL` (pending).
  - **after delete**: the same, plus `is_deleted = 1` (a tombstone). Cascaded deletes (for example
    an entry's tags) fire their own triggers, so their tombstones exist too.
- New rows need no trigger. `_ensureSyncMetadata` already gives them pending metadata at the next
  sync.
- **Attachments and voice notes** only count as changed when a column that travels changes (file
  name, entry, size of the shown file). A storage move (app-private ↔ SD card) rewrites
  `encrypted_path` only, and must not resend every file.
- Using `last_synced_at = NULL` as the "pending" mark avoids comparing two times stored to the
  second.
- Schema change, so: bump `schemaVersion` to 12, add the migration, and add a migration test
  (hard rule 5).

### Part 2 — Roles: the host only sends, the client only receives

- `SyncEngine` gets a role: **sender** (host) or **receiver** (client).
  - **Sender:** make sure metadata exists, send its pending records **including tombstones**, wait
    for the client's acknowledgement, then mark as synced **only** the records it sent.
    Records left out for the 100 MB file limit stay pending, as now.
  - **Receiver:** receive, apply everything in one transaction, send the acknowledgement, and mark
    as synced **only** the records it applied. Its own pending changes stay pending, ready for when
    it becomes the host.
- **Acknowledgement:** after the client's transaction commits, it sends one encrypted message back
  over the same socket: that it applied the payload, with counts. The host waits for it, using the
  existing payload timeout. No acknowledgement means the host marks nothing, and everything is
  sent again next time. Applying the same record twice is harmless, because it is matched by sync
  ID.
- The client no longer sends a payload that nobody reads.

### Part 3 — Applying an edit

For each received record that is **not** a tombstone:

| On the client | Result |
|---|---|
| Not known (no metadata) | Insert it (as today) |
| Known, **not** pending | Apply the edit (as today, with ID translation and file rules) |
| Known, **pending** (changed here too) | **Conflict**: store both versions and show them on the conflict screen |
| Known, but deleted here and not pending | Re-create it from the received data (the host still has it) |

- The client's own triggers fire while it applies. Afterwards, every record the apply touched is
  marked synced: the records received **and** their cascaded children. Records that were already
  pending before the apply keep their pending mark, so a real local change is never hidden. The
  set of "pending before" is taken at the start of the apply.
- Received version numbers are stored, but they no longer decide anything.

### Part 4 — Applying a delete (tombstone)

| On the client | Result |
|---|---|
| Not known | Nothing to do |
| Known, not pending | **Delete it here**, including its files |
| Known, pending (edited here) | **Conflict**: "deleted on the other phone" vs. "your version" |

- Deletes run **after** all inserts and edits of the payload, **children first** (the reverse of
  `SyncEngine.syncableTables`), inside the same transaction.
- Deleting goes through the app's own rules, not a bare `DELETE`. An entry's attachments go
  first (there is no cascade), a journal takes its entries with it, and a tag loses its links.
  `EntryDeletionService` gets variants that delete the rows and **return** the file paths instead
  of deleting the files. Sync deletes those files only **after** its transaction commits, so a
  rolled-back sync never loses a file whose row came back.

### Part 5 — Conflicts that can be resolved

- **Store the other phone's version in the clear**, as decoded JSON, in `sync_conflicts`. The
  database itself is encrypted with SQLCipher, so it is still encrypted at rest. The pairing-code
  encryption is dropped for this column, because the code does not outlive the session. This fixes
  "Keep remote".
- **Attachments in conflict:** the other phone's file is stored straight away under this phone's
  key. Its path is kept in the conflict. "Keep remote" swaps it in and deletes the local file.
  "Keep local" deletes the stored copy. The startup orphan sweep must count these paths as used
  (`storedFilePaths` in `lib/app/startup_maintenance.dart`), or it would delete them after an
  hour.
- **Keep remote** applies the stored version with the same ID translation as a normal sync. For a
  delete conflict, it deletes the item here. If a parent it needs is missing, the conflict stays
  open and the screen says so.
- **Keep local** leaves this phone's version pending, so it goes to the other phone the next time
  this phone is the host. For a delete conflict, the other phone re-creates the item then (Part 3,
  last row).
- **The conflict screen** gains wording for a delete conflict ("Deleted on the other phone"). This
  needs new ARB keys in English, Malayalam and Sanskrit, marked "needs native-reader review".
  **No "Keep both" button is added.** Say if you want one: for entries it would keep your version
  and save theirs as a new entry.

### Part 6 — What this means, stated plainly in the docs and the sync screen help

- The **client becomes a copy of the host** for everything that changed on the host since the last
  sync, deletes included, except items the client also changed, which go to the conflict screen.
- **Two phones.** Sync keeps one "sent / not sent" mark per item, not one per phone. With three
  phones, a change reaches only the first client that syncs with the host.
- **Restoring a backup in "replace" mode** deletes and re-creates every item. The next time that
  phone is the host, the client will delete its copies and receive the restored ones. The restore
  screen's warning and `docs/features.md` will say so.
- The stale comment on `AppFlavorConfig.enableSyncUi` ("no transport") is corrected. The flag
  itself is not changed in this plan. The conflict screen stays reachable from the Wi-Fi Sync
  screen, as today.

---

## Slices (each: code, tests, `flutter analyze`, `flutter test`, then the next)

1. **Triggers and migration** (Part 1).
2. **Roles and acknowledgement** (Part 2).
3. **Edits** (Part 3).
4. **Deletes** (Part 4).
5. **Conflicts** (Part 5), including the screen text.
6. **Docs** (Part 6) and the change log.

## Tests

- `test/core/database/migration_test.dart`: an 11 → 12 upgrade creates the triggers. An update
  and a delete then mark metadata pending, and a delete sets `is_deleted`. A storage-path-only
  change of an attachment does **not** mark it.
- New `test/features/sync/sync_edits_deletes_test.dart` (two in-memory phones, with the fake
  protocol and in-memory cipher style of `sync_id_mapping_test.dart`):
  - an edit on the host reaches the client;
  - a second edit reaches it too (repeat syncs keep working);
  - a delete on the host deletes the item on the client, with its attachment files;
  - deleting a journal on the host deletes its entries on the client;
  - an edit on the client is still pending after receiving, and is sent when the client becomes
    the host;
  - both phones edited the same entry: a conflict appears; "keep remote" applies the host's
    version; "keep local" keeps the client's and leaves it pending;
  - host deleted, client edited: a conflict; both choices work;
  - the host marks nothing synced without an acknowledgement;
  - a client apply that fails marks nothing on either phone, and the next sync sends it all
    again;
  - an attachment conflict keeps both files until it is resolved, and the orphan sweep does not
    touch the stored copy.
- `test/features/sync/sync_engine_wifi_test.dart`: over the real socket, an edit and a delete
  travel host → client, and the acknowledgement arrives.
- `conflict_resolution_service_test.dart`: updated for the stored decoded data.
- `test/app/startup_maintenance_test.dart`: conflict file paths count as used.

## Files (expected)

- `lib/core/database/app_database.dart` (schema 12, triggers, migration)
- `lib/core/database/app_database_daos_sync_security.dart` (`getUnsyncedRecords` includes
  tombstones; helpers to mark applied records)
- `lib/features/sync/services/sync_engine.dart`, `sync_engine_records.dart` (roles, edits,
  deletes, marking rules)
- `lib/features/sync/services/sync_protocol.dart`, `wifi_sync_protocol.dart`,
  `wifi_sync_transport.dart` (acknowledgement message)
- `lib/features/sync/services/conflict_resolution_service.dart` (decoded remote data, delete
  conflicts, file conflicts)
- `lib/features/sync/providers/wifi_sync_providers.dart`, `lib/features/sync/presentation/sync_host_screen.dart`
  (host = sender, client = receiver)
- `lib/features/sync/presentation/conflict_resolution_screen.dart` (delete-conflict wording)
- `lib/features/entries/services/entry_deletion_service.dart` (variants that return file paths)
- `lib/app/startup_maintenance.dart` (conflict file paths count as used)
- `lib/core/config/app_flavor_config.dart` (comment only)
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` (delete-conflict text), then `flutter gen-l10n`
- The backup restore screen's replace-mode warning text, if it needs one more sentence (ARB)
- Tests listed above
- `docs/architecture.md` §21, `docs/features.md` §8 (and the "Keep Both" correction), `docs/security.md`
  (decoded conflict data at rest inside SQLCipher), `CHANGELOG.md` ("Known issues")

## Risks

- **This deletes data on the client by design.** A mistaken delete on the host spreads at the next
  sync. That is the chosen behaviour. The only guard is the conflict screen, which only helps when
  the client also changed the item. The docs and the sync screen help will say so.
- The triggers run on every edit in the app. They are single-row updates of a table with an index
  on `(record_table, local_id)`, so the cost is small. Autosave-heavy editing is checked in tests.
- Schema change: the migration is tested from 11. Older schemas upgrade through the existing
  chain.

## Checks after the change

- `dart format lib test integration_test`: clean.
- `flutter analyze`: zero issues.
- `flutter test`: all pass.
- `flutter build apk --flavor dev --debug` builds. It is not installed on a phone holding real
  entries.
- `sh tool/check_sanskrit_markers.sh` and `sh tool/check_absolute_paths.sh --all`: pass.
- A manual two-phone check, described in the change log.

## Out of scope

- Two-way sync in one session (decided against).
- Per-phone sync state for three or more phones.
- A "Keep both" button (unless you ask for it).
- Changing `AppFlavorConfig.enableSyncUi`.
