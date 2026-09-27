import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';
import 'package:sreerajp_journal_vault/features/backup/services/backup_attachment_cipher.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_engine.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_protocol.dart';

/// Sync between two phones whose row IDs differ: every reference must land
/// on the receiver's own rows, and attachment files must really arrive.
void main() {
  const password = 'pairing-code';
  final encryption = SyncEncryptionService();

  late AppDatabase sender;
  late AppDatabase receiver;
  late _MemoryCipher senderFiles;
  late _MemoryCipher receiverFiles;

  setUp(() {
    sender = AppDatabase.forExecutor(NativeDatabase.memory());
    receiver = AppDatabase.forExecutor(NativeDatabase.memory());
    senderFiles = _MemoryCipher('sender');
    receiverFiles = _MemoryCipher('receiver');
  });

  tearDown(() async {
    await sender.close();
    await receiver.close();
  });

  /// Pushes everything unsynced on [sender] and applies it on [receiver].
  Future<void> syncOnce({int? maxFileBytes}) async {
    final pipe = _Pipe();
    final sent = await SyncEngine(
      db: sender,
      protocol: pipe.senderSide,
      encryption: encryption,
      deviceId: 'sender-phone',
      role: SyncRole.sender,
      attachmentCipher: senderFiles,
      maxFileBytes: maxFileBytes ?? SyncEngine.maxFileBytesPerSync,
    ).performSync(syncPassword: password, maxRetries: 0);
    expect(sent, SyncStatus.success);
    final received = await SyncEngine(
      db: receiver,
      protocol: pipe.receiverSide,
      encryption: encryption,
      deviceId: 'receiver-phone',
      role: SyncRole.receiver,
      attachmentCipher: receiverFiles,
    ).performSync(syncPassword: password, maxRetries: 0);
    expect(received, SyncStatus.success);
  }

  /// Applies hand-made [records] on [receiver], as if another phone sent
  /// them.
  Future<SyncStatus> receive(List<_Sent> records) async {
    final key = await encryption.deriveKey(
      password,
      List.generate(16, (i) => i),
    );
    final built = <SyncRecord>[
      for (final r in records)
        SyncRecord(
          syncId: r.syncId,
          recordTable: r.table,
          version: r.version,
          deviceId: 'other-phone',
          isDeleted: false,
          lastModifiedAt: DateTime(2026, 9, 27),
          encryptedData: await encryption.encryptRecord(r.data, key),
        ),
    ];
    return SyncEngine(
      db: receiver,
      protocol: _PipeEnd(onPush: (_) {}, onPull: () => built),
      encryption: encryption,
      deviceId: 'receiver-phone',
      role: SyncRole.receiver,
      attachmentCipher: receiverFiles,
    ).performSync(syncPassword: password, maxRetries: 0);
  }

  Future<int> journal(AppDatabase db, String title) =>
      db.journalsDao.createJournal(JournalsCompanion.insert(title: title));

  Future<int> entry(
    AppDatabase db,
    int journalId,
    String title, {
    String? contentJson,
    String? plainText,
  }) => db.entriesDao.createEntry(
    EntriesCompanion.insert(
      journalId: journalId,
      title: Value(title),
      contentJson: Value(contentJson),
      plainText: Value(plainText),
    ),
  );

  Future<int> attachment(
    AppDatabase db,
    _MemoryCipher files,
    int entryId,
    List<int> bytes,
  ) async {
    final stored = await files.encryptFromBytes(
      bytes: bytes,
      fileName: 'photo.png',
    );
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

  Future<Entry> receivedEntry(String title) async =>
      (await receiver.select(receiver.entries).get()).singleWhere(
        (e) => e.title == title,
      );

  test(
    'a synced entry lands in the synced journal, not the same number',
    () async {
      // The receiver already has journals 1 and 2.
      await journal(receiver, 'Mine one');
      await journal(receiver, 'Mine two');
      final trip = await journal(sender, 'Trip');
      await entry(sender, trip, 'Day one');

      await syncOnce();

      final synced = await receivedEntry('Day one');
      final landedIn = await receiver.journalsDao.getJournalById(
        synced.journalId,
      );
      expect(landedIn.title, 'Trip');
      expect(
        await receiver.entriesDao.getEntriesForJournal(1),
        isEmpty,
        reason:
            'nothing may land in the local journal numbered like the sender',
      );
    },
  );

  test(
    'tags, links, backlinks and revisions attach to the right rows',
    () async {
      await journal(receiver, 'Mine');
      final r1 = await journal(receiver, 'Mine too');
      await entry(receiver, r1, 'Local entry');
      await receiver.tagsDao.getOrCreateTag('local-only');

      final j = await journal(sender, 'Trip');
      final e1 = await entry(sender, j, 'First');
      final e2 = await entry(sender, j, 'Second');
      final fun = await sender.tagsDao.getOrCreateTag('fun');
      await sender.journalTagsDao.addTagToJournal(j, fun);
      await sender.tagsDao.addTagToEntry(e1, fun);
      await sender.backlinksDao.replaceBacklinksForEntry(e1, [
        VaultBacklinkTarget(type: VaultBacklinkTargetType.entry, targetId: e2),
      ]);
      await sender.entryRevisionsDao.createRevision(
        EntryRevisionsCompanion.insert(entryId: e2, title: const Value('Old')),
      );

      await syncOnce();

      final first = await receivedEntry('First');
      final second = await receivedEntry('Second');
      final trip = (await receiver.journalsDao.getAllJournals()).singleWhere(
        (x) => x.title == 'Trip',
      );
      final funTag = (await receiver.tagsDao.getAllTags()).singleWhere(
        (t) => t.name == 'fun',
      );

      final journalTags = await receiver.journalTagsDao.getTagsForJournal(
        trip.id,
      );
      expect(journalTags.map((t) => t.id), [funTag.id]);
      final entryTags = await receiver.select(receiver.entryTags).get();
      expect(entryTags.single.entryId, first.id);
      expect(entryTags.single.tagId, funTag.id);
      final links = await receiver.backlinksDao.getBacklinksForEntryTarget(
        second.id,
      );
      expect(links.single.sourceEntryId, first.id);
      final revisions = await receiver.entryRevisionsDao.getRevisionsForEntry(
        second.id,
      );
      expect(revisions.single.title, 'Old');
    },
  );

  test('an entry whose journal never arrived is skipped', () async {
    final status = await receive([
      const _Sent('j-1', 'journals', {'id': 5, 'title': 'Arrived'}),
      const _Sent('e-1', 'entries', {
        'id': 9,
        'journal_id': {r'$ref': 'j-missing'},
        'title': 'Orphan',
      }),
      const _Sent('e-2', 'entries', {
        'id': 10,
        'journal_id': {r'$ref': 'j-1'},
        'title': 'Kept',
      }),
      // The old format: a raw number is not trusted.
      const _Sent('e-3', 'entries', {
        'id': 11,
        'journal_id': 1,
        'title': 'Raw number',
      }),
    ]);

    expect(status, SyncStatus.success);
    final titles = (await receiver.select(receiver.entries).get()).map(
      (e) => e.title,
    );
    expect(titles, ['Kept']);
  });

  test('a synced tag reuses the local tag with the same name', () async {
    final localWork = await receiver.tagsDao.getOrCreateTag('work');
    final j = await journal(sender, 'Office');
    final work = await sender.tagsDao.getOrCreateTag('work');
    await sender.journalTagsDao.addTagToJournal(j, work);

    await syncOnce();

    final tags = await receiver.tagsDao.getAllTags();
    expect(tags.where((t) => t.name == 'work'), hasLength(1));
    final office = (await receiver.journalsDao.getAllJournals()).single;
    final linked = await receiver.journalTagsDao.getTagsForJournal(office.id);
    expect(linked.single.id, localWork);
  });

  test('pictures and wiki links in synced text point at local rows', () async {
    // Make the receiver's numbers differ from the sender's.
    final rj = await journal(receiver, 'Mine');
    final re = await entry(receiver, rj, 'Local');
    await attachment(receiver, receiverFiles, re, [9, 9]);
    await attachment(receiver, receiverFiles, re, [8, 8]);

    final j = await journal(sender, 'Trip');
    final target = await entry(sender, j, 'Target');
    final host = await entry(sender, j, 'Host');
    final picture = await attachment(sender, senderFiles, host, [1, 2, 3]);
    final content = jsonEncode([
      {'insert': 'See [[entry:$target]]\n'},
      {
        'insert': {
          'vault_image': jsonEncode({
            'attachmentId': picture,
            'fileName': 'photo.png',
          }),
        },
      },
      {'insert': '\n'},
    ]);
    await sender.entriesDao.updateEntryById(
      host,
      EntriesCompanion(
        contentJson: Value(content),
        plainText: Value('See [[entry:$target]]'),
      ),
    );

    await syncOnce();

    final localTarget = await receivedEntry('Target');
    final localHost = await receivedEntry('Host');
    final localPicture = (await receiver.attachmentsDao.getAttachmentsForEntry(
      localHost.id,
    )).single;
    expect(localHost.plainText, 'See [[entry:${localTarget.id}]]');
    final ops = jsonDecode(localHost.contentJson!) as List;
    expect(ops.first['insert'], 'See [[entry:${localTarget.id}]]\n');
    final embed = jsonDecode(ops[1]['insert']['vault_image'] as String) as Map;
    expect(embed['attachmentId'], localPicture.id);
    expect(localPicture.id, isNot(picture));
  });

  test(
    'the attachment file arrives and opens with the receiver\'s key',
    () async {
      final j = await journal(sender, 'Trip');
      final e = await entry(sender, j, 'Day');
      final original = [10, 20, 30, 40, 50];
      await attachment(sender, senderFiles, e, original);

      await syncOnce();

      final synced = (await receiver.select(receiver.attachments).get()).single;
      expect(synced.keyReference, 'key-receiver');
      expect(receiverFiles.has(synced.encryptedPath), isTrue);
      expect(synced.sizeBytes, original.length);
      final bytes = await receiverFiles.decryptToBytes(
        encryptedPath: synced.encryptedPath,
        nonceBase64: synced.nonceBase64,
        keyReference: synced.keyReference,
        fileName: synced.fileName,
      );
      expect(bytes, original);
    },
  );

  test('an attachment record without its file is not stored', () async {
    final status = await receive([
      const _Sent('j-1', 'journals', {'id': 1, 'title': 'J'}),
      const _Sent('e-1', 'entries', {
        'id': 1,
        'journal_id': {r'$ref': 'j-1'},
        'title': 'E',
      }),
      const _Sent('a-1', 'attachments', {
        'id': 1,
        'entry_id': {r'$ref': 'e-1'},
        'file_name': 'photo.png',
        'size_bytes': 3,
        'encrypted_path': '/other/phone/path.bin',
        'nonce_base64': 'n',
        'key_reference': 'other-key',
      }),
    ]);

    expect(status, SyncStatus.success);
    expect(await receiver.select(receiver.attachments).get(), isEmpty);
  });

  group('an update to a synced attachment', () {
    Future<Attachment> syncedAttachment() async {
      await receive([
        const _Sent('j-1', 'journals', {'id': 1, 'title': 'J'}),
        const _Sent('e-1', 'entries', {
          'id': 1,
          'journal_id': {r'$ref': 'j-1'},
          'title': 'E',
        }),
        _Sent('a-1', 'attachments', {
          'id': 1,
          'entry_id': {r'$ref': 'e-1'},
          'file_name': 'photo.png',
          'size_bytes': 3,
          '_fileBase64': base64Encode([1, 2, 3]),
        }),
      ]);
      return (await receiver.select(receiver.attachments).get()).single;
    }

    test('without a file keeps the local file', () async {
      final before = await syncedAttachment();

      await receive([
        const _Sent('a-1', 'attachments', {
          'id': 1,
          'entry_id': {r'$ref': 'e-1'},
          'file_name': 'renamed.png',
          'size_bytes': 999,
          'encrypted_path': '/other/phone/path.bin',
          'nonce_base64': 'other-nonce',
          'key_reference': 'other-key',
        }, version: 2),
      ]);

      final after = (await receiver.select(receiver.attachments).get()).single;
      expect(after.fileName, 'renamed.png');
      expect(after.encryptedPath, before.encryptedPath);
      expect(after.nonceBase64, before.nonceBase64);
      expect(after.keyReference, before.keyReference);
      expect(after.sizeBytes, before.sizeBytes);
    });

    test('with a file replaces it and deletes the old one', () async {
      final before = await syncedAttachment();

      await receive([
        _Sent('a-1', 'attachments', {
          'id': 1,
          'entry_id': {r'$ref': 'e-1'},
          'file_name': 'photo.png',
          '_fileBase64': base64Encode([7, 7, 7, 7]),
        }, version: 2),
      ]);

      final after = (await receiver.select(receiver.attachments).get()).single;
      expect(after.encryptedPath, isNot(before.encryptedPath));
      expect(after.sizeBytes, 4);
      expect(receiverFiles.has(before.encryptedPath), isFalse);
      expect(receiverFiles.has(after.encryptedPath), isTrue);
    });
  });

  test('a file over the limit is left out and stays unsynced', () async {
    final j = await journal(sender, 'Trip');
    final e = await entry(sender, j, 'Day');
    final big = await attachment(sender, senderFiles, e, List.filled(20, 1));

    await syncOnce(maxFileBytes: 10);

    expect(await receiver.select(receiver.attachments).get(), isEmpty);
    expect((await receivedEntry('Day')).title, 'Day');
    final meta = await sender.syncMetadataDao.getByRecord('attachments', big);
    expect(meta!.lastSyncedAt, isNull);
    final entryMeta = await sender.syncMetadataDao.getByRecord('entries', e);
    expect(entryMeta!.lastSyncedAt, isNotNull);
  });

  test('a failure in the middle of a pull changes nothing', () async {
    final status = await receive([
      const _Sent('j-1', 'journals', {'id': 1, 'title': 'Would be kept'}),
      // A value SQLite cannot store makes this insert throw.
      const _Sent('e-1', 'entries', {
        'id': 1,
        'journal_id': {r'$ref': 'j-1'},
        'title': {'not': 'a string'},
      }),
    ]);

    expect(status, SyncStatus.failed);
    expect(await receiver.journalsDao.getAllJournals(), isEmpty);
  });
}

/// A record as another phone would send it.
class _Sent {
  const _Sent(this.syncId, this.table, this.data, {this.version = 1});

  final String syncId;
  final String table;
  final Map<String, dynamic> data;
  final int version;
}

/// Hands what one side pushes to the other side's pull.
class _Pipe {
  List<SyncRecord> _carried = const [];

  SyncProtocol get senderSide =>
      _PipeEnd(onPush: (records) => _carried = records, onPull: () => const []);

  SyncProtocol get receiverSide =>
      _PipeEnd(onPush: (_) {}, onPull: () => _carried);
}

class _PipeEnd implements SyncProtocol {
  _PipeEnd({required this.onPush, required this.onPull});

  final void Function(List<SyncRecord>) onPush;
  final List<SyncRecord> Function() onPull;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<SyncPushResult> push(SyncPayload payload) async {
    onPush(payload.records);
    return SyncPushResult(
      accepted: payload.records.length,
      rejected: 0,
      conflicts: 0,
    );
  }

  @override
  Future<SyncPullResult> pull(DateTime? since, String deviceId) async =>
      SyncPullResult(records: onPull());

  @override
  Future<SyncRemoteInfo> getRemoteInfo() async =>
      const SyncRemoteInfo(serverVersion: 'test', connectedDevices: 1);

  @override
  Future<void> acknowledge(SyncAck ack) async {}
}

/// Attachment storage in memory. Each phone has its own key name.
class _MemoryCipher implements BackupAttachmentCipher {
  _MemoryCipher(this.phone);

  final String phone;
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
    final path = '$phone/${_next++}_$fileName.bin';
    _files[path] = Uint8List.fromList(bytes);
    return BackupStoredFile(
      encryptedPath: path,
      nonceBase64: 'nonce-$_next',
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
