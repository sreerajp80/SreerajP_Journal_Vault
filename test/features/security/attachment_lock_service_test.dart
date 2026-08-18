import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/services/attachment_lock_service.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AttachmentLockService service;
  late int attachmentId;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    service = AttachmentLockService(
      database: database,
      securityEventService: SecurityEventService(database: database),
    );

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final entryId = await database.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: const Value('E'),
        contentJson: const Value('[]'),
      ),
    );
    attachmentId = await database.attachmentsDao.createAttachment(
      AttachmentsCompanion.insert(
        entryId: entryId,
        fileName: 'a.bin',
        mimeType: const Value('application/octet-stream'),
        encryptedPath: 'app_private/a.enc',
        nonceBase64: 'n',
        keyReference: 'k',
        sizeBytes: 1,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('lockAttachment marks the attachment locked', () async {
    expect(await service.isLocked(attachmentId), isFalse);
    await service.lockAttachment(attachmentId: attachmentId);
    expect(await service.isLocked(attachmentId), isTrue);
  });

  test('unlockAttachment clears the lock until relocked', () async {
    await service.lockAttachment(attachmentId: attachmentId);
    expect(await service.isLocked(attachmentId), isTrue);

    await service.unlockAttachment(attachmentId);
    expect(await service.isLocked(attachmentId), isFalse);

    await service.relockAttachment(attachmentId);
    expect(await service.isLocked(attachmentId), isTrue);
  });

  test('removeLock deletes the lock row entirely', () async {
    await service.lockAttachment(attachmentId: attachmentId);
    await service.removeLock(attachmentId);
    expect(await service.getLock(attachmentId), isNull);
  });

  test('isLocked is false for never-locked attachments', () async {
    expect(await service.isLocked(attachmentId), isFalse);
  });

  test('logs a security event on every lock/unlock action', () async {
    await service.lockAttachment(attachmentId: attachmentId);
    await service.unlockAttachment(attachmentId);
    await service.relockAttachment(attachmentId);
    await service.removeLock(attachmentId);

    final events = await database.securityEventsDao.getRecentEvents(limit: 10);
    expect(
      events.where((e) => e.eventType == 'attachment_locked'),
      hasLength(2),
    );
    expect(
      events.where((e) => e.eventType == 'attachment_unlocked'),
      hasLength(2),
    );
  });
}
