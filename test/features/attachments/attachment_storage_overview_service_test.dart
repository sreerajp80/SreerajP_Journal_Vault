import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_storage_overview_service.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('load returns the settings and the summed attachment size', () async {
    final journal = await db.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'J'),
    );
    final entry = await db.entriesDao.createEntry(
      EntriesCompanion.insert(journalId: journal),
    );
    for (final size in [100, 250]) {
      await db.attachmentsDao.createAttachment(
        AttachmentsCompanion.insert(
          entryId: entry,
          fileName: 'f$size',
          encryptedPath: 'p$size',
          nonceBase64: 'n',
          keyReference: 'k',
          sizeBytes: size,
        ),
      );
    }

    final overview = await AttachmentStorageOverviewService(db).load();

    expect(overview.totalBytes, 350);
    expect(overview.settings.id, (await db.appSettingsDao.getSettings()).id);
  });

  test('no attachments means zero bytes', () async {
    final overview = await AttachmentStorageOverviewService(db).load();
    expect(overview.totalBytes, 0);
  });
}
