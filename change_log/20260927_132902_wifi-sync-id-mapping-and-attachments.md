# Change log — Wi-Fi Sync: row IDs mapped between phones, attachment files sent correctly

**Plan:** `plans/20260927_131308_wifi-sync-id-mapping-and-attachments.md` (approved 2026-09-27)

No schema change.

## Bug 1 — Row IDs from the other phone

New `lib/features/sync/services/sync_references.dart` (pure Dart):

- `syncReferenceColumns`: per synced table, the columns that point at another row. Plus
  `backlinkTargetTable` for `backlinks.target_id` by `target_type`.
- `syncRef` / `syncIdOfRef`: a reference travels as `{"$ref": "<sync id>"}`. A raw number (the
  old format) is **not** accepted as a reference.
- `textReferences`, `rewriteContentJson`, `rewriteWikiLinks`: find and rewrite picture/drawing
  `attachmentId`s and `[[entry:N]]` / `[[journal:N]]` links in entry text. An ID without a
  mapping is left as it is.

New `lib/features/sync/services/sync_reference_resolver.dart` (`SyncReferenceResolver`). It turns
a received record into this phone's column values: every reference becomes a local row ID
through `sync_metadata`, `_…` keys and other-phone file columns are dropped, and it returns
null when a reference cannot be resolved. It also finds a local tag by name. This file was not
named in the plan: the logic is shared by the engine and conflict resolution, so it got its own
file.

`sync_engine_records.dart` (rewritten):

- **Sender** (`_getRecordData`): reference columns and `backlinks.target_id` are sent as sync IDs.
  Entries and revisions carry `_textRefs`: the sync IDs of the attachments, entries and journals
  their text points at.
- **Receiver** (`_pullRemoteChanges`): records are sorted parents first (the order of
  `SyncEngine.syncableTables`), and all are applied in **one transaction**. A record whose
  reference cannot be resolved is skipped. A tag with the same name as a local tag is mapped to
  it, not inserted again. After all records are in, a fix-up pass rewrites the IDs in synced
  text. One log line gives the skipped counts only.
- The update path uses the same translation, so it can no longer move a local entry to another
  journal.

## Bug 2 — Attachment files

- **Sender:** for `attachments` and `voice_notes`, the file is read from the real columns
  (`encrypted_path`, `nonce_base64`, `key_reference`, `file_name`), decrypted, and sent as
  `_fileBase64`. `encrypted_path`, `nonce_base64` and `key_reference` are **never** sent.
- **Size limit:** files are added while their total stays under 100 MB
  (`SyncEngine.maxFileBytesPerSync`; a test can set a smaller `maxFileBytes`). A record whose file
  does not fit, or cannot be read, is left out, and `sync_engine.dart` does not mark it as synced,
  so a later sync sends it.
- **Receiver, insert:** the bytes are stored under this phone's key. `encrypted_path`,
  `nonce_base64`, `key_reference` and (for attachments) `size_bytes` come from the stored result.
  A record without bytes, or without a cipher, is skipped.
- **Receiver, update:** with bytes, the new file is stored and the old file is deleted **after**
  the transaction commits. Without bytes, the local file columns and `size_bytes` are never
  changed.
- The dead `file_path` / `filePath` / `file_size_bytes` / `fileSizeBytes` branches are gone.

`conflict_resolution_service.dart`: "keep remote" and "merge" translate references the same way,
skip a record with a missing parent, and never change a file's columns or size.

## Tests

- New `test/features/sync/sync_id_mapping_test.dart` (11 tests, two in-memory phones with
  different row IDs and an in-memory cipher per phone): journal mapping; tags, journal tags,
  entry tags, backlinks and revisions; missing parent and old-format raw numbers skipped; tag
  reused by name; picture embed and wiki link rewritten; file arrives and opens with the
  receiver's key and right size; attachment without a file not stored; update without a file keeps
  the local file; update with a file replaces it and deletes the old one; a file over the limit is
  left out and stays unsynced; a failure mid-pull changes nothing.
- New `test/features/sync/sync_references_test.dart`: every listed reference and file column
  exists in the schema, plus the helpers.
- `test/features/sync/sync_engine_wifi_test.dart`: a second real-socket case where the client
  already has journals.
- Mutation checks. With the sender's reference translation switched off, 6 tests failed. With
  file sending switched off, the file and picture tests failed. The code was restored after each.

## Docs

- `docs/architecture.md` §21: the attachment item is closed, and a new "Closed on 2026-09-27 —
  Wi-Fi Sync IDs and attachment files" section records both fixes and the remaining sync limits.
- `docs/features.md` §8: what sync sends today.
- `CHANGELOG.md` "Known issues": now says sync copies new items from host to client only.

## Checks

- `dart format lib test integration_test`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 1,171 tests pass (1,154 before).
- `sh tool/check_absolute_paths.sh --all`: passes.

## Not done here (as planned)

- Sync is still one-way (host → client), and edits and deletes after a record's first sync are
  still never sent. Both need their own plan.
- The conflict screen shows references as `{"$ref": …}` in its field list. Nothing reaches this
  path until edits are synced (the point above).

## Manual check for the user, on two phones

This needs two builds that do not replace an install holding real entries (see "Build flavors"
in CLAUDE.md).

1. On the client phone, create a journal and an entry first, so its numbers differ.
2. On the host phone, create a journal with an entry that has a picture and a `[[entry:…]]` link
   to another entry.
3. Sync. On the client: the entry is in the host's journal, not the client's; the picture opens;
   the link opens the right entry.
