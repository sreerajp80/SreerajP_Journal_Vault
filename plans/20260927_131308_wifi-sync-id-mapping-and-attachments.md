# Plan — Wi-Fi Sync: map row IDs between phones, and send attachment files correctly

**Status:** completed
**Change log:** `change_log/20260927_132902_wifi-sync-id-mapping-and-attachments.md`
**Note:** Approved 2026-09-27.

## Background

These are review items 2 and 3 from the 2026-09-27 project review. Both are in
`lib/features/sync/services/sync_engine_records.dart`. `docs/architecture.md` §21 lists the
attachment problem as open. The ID problem was not recorded anywhere.

How sync works today, in short:

- Every row of a syncable table gets a `sync_metadata` row with a **sync ID**. A sync ID is the
  same on both phones for the same record. A row's own `id` is local and differs between phones.
- The **host** sends its unsynced records, and the **client** applies them. The host does not apply
  anything the client sends: `WifiSyncProtocol.pull` returns nothing on the host. So in practice
  sync goes host → client.
- A record is sent as `SELECT *` of its row, encrypted. The client applies it by building an
  `INSERT` or `UPDATE` from the row's columns (now filtered by `SyncSchemaGuard`).

---

## Bug 1 — Rows that point at other rows keep the other phone's IDs

### Issue

`_insertRemoteRecord` drops the remote `id`, but copies every other column as it is. Several
columns hold the **other phone's** row IDs:

| Table | Column | Points at |
|---|---|---|
| `entries` | `journal_id` | journals |
| `journal_tags` | `journal_id`, `tag_id` | journals, tags |
| `entry_tags` | `entry_id`, `tag_id` | entries, tags |
| `attachments` | `entry_id` | entries |
| `backlinks` | `source_entry_id` | entries |
| `backlinks` | `target_id` (no foreign key; `target_type` says `entry` or `journal`) | entries or journals |
| `entry_revisions` | `entry_id` | entries |
| `voice_notes` | `entry_id` | entries |

IDs also sit **inside entry text**:

- picture and drawing embeds in `entries.content_json` (and `entry_revisions.content_json`) store
  an `attachmentId`;
- wiki links such as `[[entry:7]]` and `[[journal:3]]` in the text store row IDs.

The only sync test copies into an **empty** phone, where the IDs happen to line up.

What goes wrong on a phone that already has data:

- A synced entry lands in **whichever local journal has that number**. That can be a different,
  password-locked journal, which mixes private content across journals. Or it can be no journal
  at all, and then the insert fails and the whole sync fails.
- Tags, attachments, backlinks and revisions attach to the wrong entry, or fail the same way.
- Pictures in synced entries show another entry's attachment, or a placeholder.
- A wiki link opens the wrong entry.
- The **update** path (`_updateLocalRecord`) has the same problem. It can move an existing local
  entry to another journal.

Also, tag names are unique in practice (`getOrCreateTag` looks up by name), but a synced tag is
inserted as a new row. Both phones having a tag "work" gives two "work" tags.

### Fix

The sender translates every local ID into a **sync ID**. The receiver translates sync IDs back
into **its own** local IDs, using its `sync_metadata`. No raw row ID ever crosses between phones.

1. **One table of references.** New `lib/features/sync/services/sync_references.dart` lists, per
   table, the columns that point at other rows (the table above), plus how to read
   `backlinks.target_id` by `target_type`. It is pure Dart and has a unit test.
2. **Sender (`_getRecordData`):** for each reference column, look up the referenced row's sync
   ID and send it in its place, for example `journal_id` becomes `{"$ref": "<sync id>"}`. The
   sender makes sure the referenced row has metadata first; `_ensureSyncMetadata` already runs
   before a push. The local `id` is still sent, but it is only used to rewrite text (step 5).
3. **Receiver, order:** pulled records are applied in the dependency order of
   `SyncEngine.syncableTables` (journals first, then entries, tags, and so on), not in the order
   they arrived. A parent is then always in place before its children.
4. **Receiver, IDs:** before an insert or update, each `$ref` is looked up with
   `syncMetadataDao.getBySyncId` and replaced by the local ID. If a reference **cannot** be
   resolved (the parent was never received), the record is **skipped**, never inserted with a
   guessed ID. Skipped records are counted and logged, without names or data.
5. **Receiver, text:** the sender also sends a small map with each entry and revision, listing the
   `attachmentId`s in its embeds and the targets of its wiki links as sync IDs. After all records
   of a pull are applied, a fix-up pass rewrites those numbers in `content_json` and `plain_text`
   into local IDs. It uses the existing embed format (`attachmentIdsInDelta` helpers) and
   `VaultBacklinkParser`. An embed or link whose target did not arrive is left as it is, so it
   shows the same placeholder as a deleted attachment.
6. **Tags by name:** when a synced tag has the same name (lower case, trimmed) as an existing
   local tag, no new row is made. The sync ID is mapped to the existing tag.
7. **One transaction:** all database writes of one pull run in a single transaction, so a failure
   leaves the database as it was. Encrypted files written during a failed pull are removed by the
   startup orphan sweep later, as today.

---

## Bug 2 — Attachment files are never sent, and a synced update can break a local attachment

### Issue

- The sender reads the file path from a column named `file_path` or `filePath`. The real column
  is `encrypted_path`. So the bytes are never read, and `_attachmentBytesBase64` is never set.
- The receiver then stores the row as sent: the **other phone's** `encrypted_path`, `nonce_base64`
  and `key_reference` (a Keystore alias that exists only on that phone). The attachment can never
  be opened.
- The receiver also writes the size to `file_size_bytes` / `fileSizeBytes`. The real column is
  `size_bytes`.
- On an **update**, the same values overwrite a **good** local row. The local attachment can no
  longer be decrypted. The startup orphan sweep then sees its file as unused and deletes it an
  hour later.
- `voice_notes` has the same columns and the same problem. The table is normally empty, because
  voice notes are moved into attachments at start-up.

### Fix

1. **Sender:** for `attachments` and `voice_notes`, read `encrypted_path`, `nonce_base64`,
   `key_reference` and `file_name`, decrypt with `BackupAttachmentCipher.decryptToBytes`, and send
   the bytes as `_fileBase64`. **Remove** `encrypted_path`, `nonce_base64` and `key_reference`
   from what is sent. They mean nothing on another phone.
2. **Size limit:** the whole payload is one line, capped at 150 MB
   (`WifiSyncConstants.payloadLineCap`), and base64 grows data by a third. The sender adds file
   bytes only while the total stays under **100 MB of file data**. An attachment that does not
   fit is left out of this sync, and **its metadata is not marked as synced**, so a later sync
   sends it. The sync log records how many were left out.
3. **Receiver, insert:** with bytes, store them through `encryptFromBytes`, and set
   `encrypted_path`, `nonce_base64`, `key_reference` and `size_bytes` from the result. Without
   bytes, or without a cipher, the attachment row is **skipped**. No row may point at a file that
   is not there.
4. **Receiver, update:** with bytes, store the new file, update the row, and then delete the old
   local file (after the database write succeeds). Without bytes, the local file columns are
   **never** changed; only the other columns (for example `file_name`) are updated.
5. The dead `file_path` / `filePath` / `file_size_bytes` branches are removed.

---

## Tests

New `test/features/sync/sync_id_mapping_test.dart`, using the existing fake-protocol style from
`sync_schema_guard_test.dart` and an in-memory fake `BackupAttachmentCipher`:

- **Journal mapping:** the receiver already has two journals, so IDs differ. A synced entry lands
  in the synced journal, not in the local journal with the same number.
- **Children:** tags, entry tags, journal tags, backlinks and revisions attach to the right rows.
- **Missing parent:** an entry whose journal was not received is skipped, and the rest applies.
- **Tag by name:** a synced tag "work" reuses the local "work" tag.
- **Text:** a picture embed and an `[[entry:N]]` link in a synced entry point at the receiver's own
  IDs afterwards.
- **Attachment bytes:** the receiver can decrypt the synced attachment to the original bytes.
  `encrypted_path`, `nonce_base64` and `key_reference` are its own, and `size_bytes` is right.
- **No bytes:** an attachment record without bytes is skipped, not stored.
- **Update keeps a good local file:** an update without bytes leaves the local file columns alone.
  An update with bytes replaces the file and deletes the old one.
- **Size limit:** an attachment over the limit is left out, and its metadata stays unsynced.
- **Atomic:** a failure in the middle of a pull leaves the database unchanged.

The existing `sync_engine_wifi_test.dart` (real sockets, empty receiver) must still pass. A second
case is added there with data already on the receiver.

Unit test for `sync_references.dart`: every reference column it lists exists in the schema, so
a column rename breaks the test instead of breaking sync quietly.

## Files

- `lib/features/sync/services/sync_engine_records.dart` (sender and receiver changes)
- `lib/features/sync/services/sync_engine.dart` (apply order, transaction, not marking left-out
  records as synced, counts in the sync log)
- `lib/features/sync/services/sync_references.dart` (new)
- `lib/features/sync/services/conflict_resolution_service.dart` ("keep remote" and "merge" apply
  remote data, so they go through the same ID translation and file rules)
- `test/features/sync/sync_id_mapping_test.dart` (new), `test/features/sync/sync_references_test.dart`
  (new), `test/features/sync/sync_engine_wifi_test.dart`
- `docs/architecture.md` §21 (close the attachment item, record the ID fix), `docs/features.md`
  §8 if its sync description needs correcting, `CHANGELOG.md` (update the "Known issues" note)

No schema change. `sync_metadata` already holds everything needed.

## Checks after the change

- `dart format lib test integration_test`: clean.
- `flutter analyze`: zero issues.
- `flutter test`: all pass.
- `sh tool/check_absolute_paths.sh --all`: passes.
- Manual check on two phones, described in the change log. It needs a build installed without
  replacing real data; see "Build flavors" in CLAUDE.md.

## Related problems found while planning (not fixed here)

1. **Edits are never sent again.** Nothing outside sync updates `sync_metadata.last_modified_at`
   when a journal, entry or tag changes. After a record's first sync it counts as synced for
   ever, so later edits, and deletes, never reach the other phone. Sync today copies **new**
   records once.
2. **Sync is one-way.** The host sends, and only the client applies. What the client sends is
   never read.

Both change what "sync" means for the user and need their own plan. Until then, the CHANGELOG
"Known issues" note will say sync copies new items from the host phone to the client phone only.

## Out of scope

- Review item 4 (AirQR turning off screenshot blocking) and item 1 (commit `third_party/`).
- The two small findings (the English "Entry #" text, and AirQR entries on a phone with no
  journals).
