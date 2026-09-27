import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/startup_maintenance.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_deletion_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/conflict_resolution_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_transport.dart';
import 'package:cryptography/cryptography.dart' show SecretKey;

/// One-way sync, host to client: edits and deletes travel, a record changed
/// on both phones goes to the conflict screen, and nothing is marked as sent
/// until the client has saved it.
void main() {
  const password = 'pairing-code';
  // Derives the key once for the whole file; see _OnceEncryption.
  final encryption = _OnceEncryption();

  late AppDatabase phoneA;
  late AppDatabase phoneB;
  late _MemoryCipher filesA;
  late _MemoryCipher filesB;

  setUp(() {
    phoneA = AppDatabase.forExecutor(NativeDatabase.memory());
    phoneB = AppDatabase.forExecutor(NativeDatabase.memory());
    filesA = _MemoryCipher('a');
    filesB = _MemoryCipher('b');
  });

  tearDown(() async {
    await phoneA.close();
    await phoneB.close();
  });

  _MemoryCipher filesOf(AppDatabase db) => db == phoneA ? filesA : filesB;

  /// One sync from [host] to [client]. Both run at once; the host waits for
  /// the client's acknowledgement, as over the real socket.
  Future<(SyncStatus, SyncStatus)> sync(
    AppDatabase host,
    AppDatabase client, {
    _MemoryCipher? clientFiles,
  }) async {
    final link = _Link();
    final receiving =
        SyncEngine(
          db: client,
          protocol: link.clientSide,
          encryption: encryption,
          deviceId: client == phoneA ? 'phone-a' : 'phone-b',
          role: SyncRole.receiver,
          attachmentCipher: clientFiles ?? filesOf(client),
        ).performSync(syncPassword: password, maxRetries: 0).then((status) {
          if (status == SyncStatus.failed) link.abort();
          return status;
        });
    final sending = SyncEngine(
      db: host,
      protocol: link.hostSide,
      encryption: encryption,
      deviceId: host == phoneA ? 'phone-a' : 'phone-b',
      role: SyncRole.sender,
      attachmentCipher: filesOf(host),
    ).performSync(syncPassword: password, maxRetries: 0);
    final results = await Future.wait([sending, receiving]);
    return (results[0], results[1]);
  }

  Future<int> journal(AppDatabase db, String title) =>
      db.journalsDao.createJournal(JournalsCompanion.insert(title: title));

  Future<int> entry(AppDatabase db, int journalId, String title) =>
      db.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: Value(title),
          contentJson: Value('[{"insert":"$title\\n"}]'),
          plainText: Value(title),
        ),
      );

  Future<void> retitle(AppDatabase db, int entryId, String title) =>
      db.entriesDao.updateEntryById(
        entryId,
        EntriesCompanion(title: Value(title), plainText: Value(title)),
      );

  Future<int> attachment(AppDatabase db, int entryId, List<int> bytes) async {
    final stored = await filesOf(
      db,
    ).encryptFromBytes(bytes: bytes, fileName: 'photo.png');
    return db.attachmentsDao.createAttachment(
      AttachmentsCompanion.insert(
        entryId: entryId,
        fileName: 'photo.png',
        mimeType: const Value('image/png'),
        encryptedPath: stored.encryptedPath,
        nonceBase64: stored.nonceBase64,
        keyReference: stored.keyReference,
        sizeBytes: stored.sizeBytes,
      ),
    );
  }

  Future<List<String?>> titles(AppDatabase db) async =>
      [for (final e in await db.select(db.entries).get()) e.title]
        ..sort((a, b) => (a ?? '').compareTo(b ?? ''));

  /// The local ID on [db] of the entry titled [title].
  Future<int> idOf(AppDatabase db, String title) async =>
      (await db.select(db.entries).get())
          .singleWhere((e) => e.title == title)
          .id;

  EntryDeletionService deleterFor(AppDatabase db) => EntryDeletionService(
    db: db,
    deleteStoredFile: filesOf(db).deleteStoredFile,
  );

  ConflictResolutionService conflictsOn(AppDatabase db) =>
      ConflictResolutionService(
        db: db,
        encryption: encryption,
        cipher: filesOf(db),
      );

  test(
    'an edit on the host reaches the client, and so does the next',
    () async {
      final j = await journal(phoneA, 'Trip');
      final e = await entry(phoneA, j, 'Draft');
      await sync(phoneA, phoneB);
      expect(await titles(phoneB), ['Draft']);

      await retitle(phoneA, e, 'First edit');
      await sync(phoneA, phoneB);
      expect(await titles(phoneB), ['First edit']);

      await retitle(phoneA, e, 'Second edit');
      await sync(phoneA, phoneB);
      expect(await titles(phoneB), ['Second edit']);
    },
  );

  test(
    'a delete on the host deletes the entry and its file on the client',
    () async {
      final j = await journal(phoneA, 'Trip');
      final e = await entry(phoneA, j, 'Photo day');
      await attachment(phoneA, e, [1, 2, 3]);
      await entry(phoneA, j, 'Keep me');
      await sync(phoneA, phoneB);
      final bFile = (await phoneB.select(phoneB.attachments).get()).single;
      expect(filesB.has(bFile.encryptedPath), isTrue);

      await deleterFor(phoneA).deleteEntry(e);
      await sync(phoneA, phoneB);

      expect(await titles(phoneB), ['Keep me']);
      expect(await phoneB.select(phoneB.attachments).get(), isEmpty);
      expect(filesB.has(bFile.encryptedPath), isFalse);
    },
  );

  test(
    'deleting a journal on the host deletes its entries on the client',
    () async {
      final j = await journal(phoneA, 'Old');
      await entry(phoneA, j, 'One');
      await entry(phoneA, j, 'Two');
      final kept = await journal(phoneA, 'Kept');
      await entry(phoneA, kept, 'Three');
      await sync(phoneA, phoneB);

      await deleterFor(phoneA).deleteJournal(j);
      await sync(phoneA, phoneB);

      expect((await phoneB.journalsDao.getAllJournals()).map((x) => x.title), [
        'Kept',
      ]);
      expect(await titles(phoneB), ['Three']);
    },
  );

  test(
    'an edit on the client waits, and goes out when it is the host',
    () async {
      final j = await journal(phoneA, 'Trip');
      await entry(phoneA, j, 'Shared');
      await sync(phoneA, phoneB);

      await retitle(phoneB, await idOf(phoneB, 'Shared'), 'Edited on B');
      // A hosts again: B's edit is not overwritten, and stays pending.
      await entry(phoneA, j, 'New on A');
      await sync(phoneA, phoneB);
      expect(await titles(phoneB), ['Edited on B', 'New on A']);

      // B hosts: its edit reaches A.
      await sync(phoneB, phoneA);
      expect(await titles(phoneA), ['Edited on B', 'New on A']);
    },
  );

  group('changed on both phones', () {
    Future<void> sharedEntryEditedOnBoth() async {
      final j = await journal(phoneA, 'Trip');
      await entry(phoneA, j, 'Shared');
      await sync(phoneA, phoneB);
      await retitle(phoneA, await idOf(phoneA, 'Shared'), 'From A');
      await retitle(phoneB, await idOf(phoneB, 'Shared'), 'From B');
      final (_, status) = await sync(phoneA, phoneB);
      expect(status, SyncStatus.conflict);
    }

    test('goes to the conflict screen and keeps both versions', () async {
      await sharedEntryEditedOnBoth();

      expect(await titles(phoneB), ['From B']);
      final conflicts = await conflictsOn(phoneB).getPendingConflicts();
      expect(conflicts.single.localData['title'], 'From B');
      expect(conflicts.single.remoteData['title'], 'From A');
    });

    test('keep remote applies the host version', () async {
      await sharedEntryEditedOnBoth();
      final conflict = (await conflictsOn(phoneB).getPendingConflicts()).single;

      await conflictsOn(phoneB).resolveConflict(
        conflictId: conflict.conflictId,
        resolution: ConflictResolution.keepRemote,
      );

      expect(await titles(phoneB), ['From A']);
      expect(await phoneB.syncMetadataDao.pendingSyncIds(), isEmpty);
    });

    test(
      'keep local keeps this version, pending for the next host sync',
      () async {
        await sharedEntryEditedOnBoth();
        final conflict = (await conflictsOn(
          phoneB,
        ).getPendingConflicts()).single;

        await conflictsOn(phoneB).resolveConflict(
          conflictId: conflict.conflictId,
          resolution: ConflictResolution.keepLocal,
        );

        expect(await titles(phoneB), ['From B']);
        expect(await phoneB.syncMetadataDao.pendingSyncIds(), hasLength(1));
        await sync(phoneB, phoneA);
        expect(await titles(phoneA), ['From B']);
      },
    );
  });

  group('deleted on the host, edited on the client', () {
    Future<ConflictDetail> deletedThereEditedHere() async {
      final j = await journal(phoneA, 'Trip');
      final e = await entry(phoneA, j, 'Shared');
      await sync(phoneA, phoneB);
      await deleterFor(phoneA).deleteEntry(e);
      await retitle(phoneB, await idOf(phoneB, 'Shared'), 'Edited on B');
      await sync(phoneA, phoneB);
      final conflict = (await conflictsOn(phoneB).getPendingConflicts()).single;
      expect(conflict.isRemoteDeleted, isTrue);
      expect(await titles(phoneB), ['Edited on B']);
      return conflict;
    }

    test('keep remote deletes it here', () async {
      final conflict = await deletedThereEditedHere();

      await conflictsOn(phoneB).resolveConflict(
        conflictId: conflict.conflictId,
        resolution: ConflictResolution.keepRemote,
      );

      expect(await titles(phoneB), isEmpty);
    });

    test('keep local keeps it, and the host gets it back later', () async {
      final conflict = await deletedThereEditedHere();

      await conflictsOn(phoneB).resolveConflict(
        conflictId: conflict.conflictId,
        resolution: ConflictResolution.keepLocal,
      );
      await sync(phoneB, phoneA);

      expect(await titles(phoneB), ['Edited on B']);
      expect(await titles(phoneA), ['Edited on B']);
    });
  });

  test('without the acknowledgement the host marks nothing as sent', () async {
    final j = await journal(phoneA, 'Trip');
    await entry(phoneA, j, 'Unconfirmed');

    final status = await SyncEngine(
      db: phoneA,
      protocol: _NoAckProtocol(),
      encryption: encryption,
      deviceId: 'phone-a',
      role: SyncRole.sender,
    ).performSync(syncPassword: password, maxRetries: 0);

    expect(status, SyncStatus.failed);
    final pending = await phoneA.syncMetadataDao.pendingSyncIds();
    expect(pending, hasLength(2), reason: 'the journal and the entry');
  });

  test(
    'a failed apply marks nothing, and the next sync sends it all again',
    () async {
      final j = await journal(phoneA, 'Trip');
      final e = await entry(phoneA, j, 'With photo');
      await attachment(phoneA, e, [4, 5, 6]);

      final (hostStatus, clientStatus) = await sync(
        phoneA,
        phoneB,
        clientFiles: _MemoryCipher('b', failWrites: true),
      );
      expect(clientStatus, SyncStatus.failed);
      expect(hostStatus, SyncStatus.failed);
      expect(await phoneB.journalsDao.getAllJournals(), isEmpty);
      expect(await phoneA.syncMetadataDao.pendingSyncIds(), hasLength(3));

      await sync(phoneA, phoneB);
      expect(await titles(phoneB), ['With photo']);
      expect(await phoneB.select(phoneB.attachments).get(), hasLength(1));
    },
  );

  test(
    'an attachment conflict keeps both files until it is resolved',
    () async {
      final j = await journal(phoneA, 'Trip');
      final e = await entry(phoneA, j, 'Photo');
      final a = await attachment(phoneA, e, [1, 1, 1]);
      await sync(phoneA, phoneB);

      // Both phones rename the same attachment; the host also has new bytes.
      await phoneA.customStatement(
        "UPDATE attachments SET file_name = 'from-a.png' WHERE id = $a",
      );
      final bAttachment =
          (await phoneB.select(phoneB.attachments).get()).single;
      await phoneB.customStatement(
        "UPDATE attachments SET file_name = 'from-b.png' "
        'WHERE id = ${bAttachment.id}',
      );
      await sync(phoneA, phoneB);

      final conflict = (await conflictsOn(phoneB).getPendingConflicts()).single;
      final storedCopy =
          (conflict.remoteData['_conflictFile'] as Map)['encrypted_path']
              as String;
      expect(filesB.has(storedCopy), isTrue);
      expect(filesB.has(bAttachment.encryptedPath), isTrue);
      // The startup sweep counts the stored copy as in use.
      expect(await storedFilePaths(phoneB), contains(storedCopy));

      await conflictsOn(phoneB).resolveConflict(
        conflictId: conflict.conflictId,
        resolution: ConflictResolution.keepLocal,
      );
      expect(filesB.has(storedCopy), isFalse);
      expect(filesB.has(bAttachment.encryptedPath), isTrue);
    },
  );

  test('keep remote on an attachment swaps in the stored file', () async {
    final j = await journal(phoneA, 'Trip');
    final e = await entry(phoneA, j, 'Photo');
    final a = await attachment(phoneA, e, [1, 1, 1]);
    await sync(phoneA, phoneB);
    await phoneA.customStatement(
      "UPDATE attachments SET file_name = 'from-a.png' WHERE id = $a",
    );
    final bAttachment = (await phoneB.select(phoneB.attachments).get()).single;
    await phoneB.customStatement(
      "UPDATE attachments SET file_name = 'from-b.png' "
      'WHERE id = ${bAttachment.id}',
    );
    await sync(phoneA, phoneB);
    final conflict = (await conflictsOn(phoneB).getPendingConflicts()).single;
    final storedCopy =
        (conflict.remoteData['_conflictFile'] as Map)['encrypted_path']
            as String;

    await conflictsOn(phoneB).resolveConflict(
      conflictId: conflict.conflictId,
      resolution: ConflictResolution.keepRemote,
    );

    final after = (await phoneB.select(phoneB.attachments).get()).single;
    expect(after.fileName, 'from-a.png');
    expect(after.encryptedPath, storedCopy);
    expect(filesB.has(bAttachment.encryptedPath), isFalse);
    expect(
      await filesB.decryptToBytes(
        encryptedPath: after.encryptedPath,
        nonceBase64: after.nonceBase64,
        keyReference: after.keyReference,
        fileName: after.fileName,
      ),
      [1, 1, 1],
    );
  });
}

/// The real encryption, but the key is derived once and reused. Argon2id in
/// pure Dart takes seconds, and these tests run several syncs each.
class _OnceEncryption extends SyncEncryptionService {
  Future<SecretKey>? _key;

  @override
  Future<SecretKey> deriveKey(String password, List<int> salt) =>
      _key ??= super.deriveKey(password, salt);
}

/// A connection between two engines in one test: the host's push waits for
/// the client's acknowledgement.
class _Link {
  final Completer<List<SyncRecord>> _records = Completer();
  final Completer<SyncPushResult> _ack = Completer();

  void abort() {
    if (!_ack.isCompleted) {
      _ack.completeError(
        const SyncTransportException('The other phone did not confirm.'),
      );
    }
  }

  SyncProtocol get hostSide => _End(
    onPush: (records) {
      _records.complete(records);
      return _ack.future;
    },
    onPull: () => throw StateError('the host does not receive'),
    onAck: (_) => throw StateError('the host does not acknowledge'),
  );

  SyncProtocol get clientSide => _End(
    onPush: (_) => throw StateError('the client does not send'),
    onPull: () => _records.future,
    onAck: (ack) => _ack.complete(
      SyncPushResult(
        accepted: ack.applied,
        rejected: ack.skipped,
        conflicts: ack.conflicts,
      ),
    ),
  );
}

class _End implements SyncProtocol {
  _End({required this.onPush, required this.onPull, required this.onAck});

  final Future<SyncPushResult> Function(List<SyncRecord>) onPush;
  final Future<List<SyncRecord>> Function() onPull;
  final void Function(SyncAck) onAck;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SyncPushResult> push(SyncPayload payload) => onPush(payload.records);

  @override
  Future<SyncPullResult> pull(DateTime? since, String deviceId) async =>
      SyncPullResult(records: await onPull());

  @override
  Future<void> acknowledge(SyncAck ack) async => onAck(ack);

  @override
  Future<SyncRemoteInfo> getRemoteInfo() async =>
      const SyncRemoteInfo(serverVersion: 'test', connectedDevices: 1);
}

/// A host connection where the client never answers.
class _NoAckProtocol implements SyncProtocol {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SyncPushResult> push(SyncPayload payload) async =>
      throw const SyncTransportException('No acknowledgement.');

  @override
  Future<SyncPullResult> pull(DateTime? since, String deviceId) =>
      throw StateError('not used');

  @override
  Future<void> acknowledge(SyncAck ack) => throw StateError('not used');

  @override
  Future<SyncRemoteInfo> getRemoteInfo() async =>
      const SyncRemoteInfo(serverVersion: 'test', connectedDevices: 1);
}

/// Attachment storage in memory. Each phone has its own key name.
class _MemoryCipher implements BackupAttachmentCipher {
  _MemoryCipher(this.phone, {this.failWrites = false});

  final String phone;
  final bool failWrites;
  final Map<String, Uint8List> _files = {};
  var _next = 0;

  bool has(String path) => _files.containsKey(path);

  @override
  Future<Uint8List> decryptToBytes({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) async {
    if (keyReference != 'key-$phone') {
      throw StateError('not this phone\'s key');
    }
    final bytes = _files[encryptedPath];
    if (bytes == null) throw StateError('no such file');
    return bytes;
  }

  @override
  Future<BackupStoredFile> encryptFromBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    if (failWrites) throw StateError('storage full');
    final path = '$phone/${_next++}_$fileName.bin';
    _files[path] = Uint8List.fromList(bytes);
    return BackupStoredFile(
      encryptedPath: path,
      nonceBase64: base64Encode([_next]),
      keyReference: 'key-$phone',
      sizeBytes: bytes.length,
    );
  }

  @override
  Future<String> storeRawEncryptedBytes({
    required List<int> bytes,
    required String fileName,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {
    _files.remove(encryptedPath);
  }
}
