import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/entries/services/time_capsule_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TimeCapsuleService service;
  late int journalId;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    service = TimeCapsuleService(db, prefs: prefs);

    journalId = await db
        .into(db.journals)
        .insert(JournalsCompanion.insert(title: 'Capsule Journal'));
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'sealing an entry removes plaintext/contentJson from entries table and saves encrypted capsule',
    () async {
      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: const Value('Letter to 2030'),
              contentJson: const Value(
                '[{"insert":"Dear future me, keep building.\\n"}]',
              ),
              plainText: const Value('Dear future me, keep building.'),
            ),
          );

      final unlockDate = DateTime.now().add(const Duration(days: 365));
      final capsule = await service.sealEntry(
        entryId: entryId,
        unlockDate: unlockDate,
        teaserMessage: 'A note about life',
      );

      expect(capsule.entryId, equals(entryId));
      expect(capsule.isOpened, isFalse);
      expect(capsule.teaserMessage, equals('A note about life'));

      // Check entry table: plainText and contentJson must be wiped
      final updatedEntry = await db.entriesDao.getEntryById(entryId);
      expect(updatedEntry.contentJson, isNull);
      expect(updatedEntry.plainText, isNull);

      // Check capsule row exists in time_capsules table
      final fetchedCapsule = await db.timeCapsulesDao.getCapsuleForEntry(
        entryId,
      );
      expect(fetchedCapsule, isNotNull);
      expect(fetchedCapsule!.sealedCiphertext, isNotEmpty);
      expect(fetchedCapsule.ivBase64, isNotEmpty);
      expect(fetchedCapsule.macBase64, isNotEmpty);
    },
  );

  test(
    'searchEntries excludes unopened sealed time capsules before unlock date',
    () async {
      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: const Value('Secret Future Vision'),
              contentJson: const Value(
                '[{"insert":"Top secret rocket blueprint\\n"}]',
              ),
              plainText: const Value('Top secret rocket blueprint'),
            ),
          );

      // Before sealing, search matches
      final initialResults = await db.searchEntries('rocket');
      expect(initialResults.length, equals(1));

      // Seal the entry for 1 year in the future
      await service.sealEntry(
        entryId: entryId,
        unlockDate: DateTime.now().add(const Duration(days: 365)),
      );

      // After sealing, search matches 0
      final sealedResults = await db.searchEntries('rocket');
      expect(sealedResults, isEmpty);
    },
  );

  test(
    'attempting to unseal early throws TimeCapsuleLockedException',
    () async {
      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: const Value('Future goals'),
              contentJson: const Value(
                '[{"insert":"Reach financial freedom\\n"}]',
              ),
              plainText: const Value('Reach financial freedom'),
            ),
          );

      final futureDate = DateTime.now().add(const Duration(days: 100));
      await service.sealEntry(entryId: entryId, unlockDate: futureDate);

      expect(
        () => service.unsealEntry(entryId),
        throwsA(isA<TimeCapsuleLockedException>()),
      );
    },
  );

  test(
    'attempting to unseal with backward clock tampering throws TimeCapsuleClockTamperException',
    () async {
      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: const Value('Clock test'),
              contentJson: const Value(
                '[{"insert":"Testing clock tampering\\n"}]',
              ),
              plainText: const Value('Testing clock tampering'),
            ),
          );

      final futureDate = DateTime.now().add(const Duration(days: 10));
      await service.sealEntry(entryId: entryId, unlockDate: futureDate);

      // Simulate high-water mark being in the far future (tampered device clock that was moved back)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'time_capsule_high_water_mark_ms',
        DateTime.now().add(const Duration(days: 20)).millisecondsSinceEpoch,
      );

      expect(
        () => service.unsealEntry(
          entryId,
          customNow: DateTime.now().add(
            const Duration(days: 12),
          ), // pretends unlock date passed, but clock rollback detected
        ),
        throwsA(isA<TimeCapsuleClockTamperException>()),
      );
    },
  );

  test(
    'unsealing after unlockDate restores plaintext and contentJson',
    () async {
      const rawDocJson = '[{"insert":"Hello from past self!\\n"}]';
      const rawPlain = 'Hello from past self!';

      final entryId = await db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              journalId: journalId,
              title: const Value('Letter to tomorrow'),
              contentJson: const Value(rawDocJson),
              plainText: const Value(rawPlain),
            ),
          );

      final unlockDate = DateTime.now().add(const Duration(seconds: 1));
      await service.sealEntry(entryId: entryId, unlockDate: unlockDate);

      // Simulate time passing beyond unlock date
      final afterDate = unlockDate.add(const Duration(seconds: 10));
      final restoredEntry = await service.unsealEntry(
        entryId,
        customNow: afterDate,
      );

      final updatedCapsule = await db.timeCapsulesDao.getCapsuleForEntry(
        entryId,
      );
      expect(updatedCapsule!.isOpened, isTrue);
      expect(updatedCapsule.openedAt, isNotNull);

      // Verify restored entry content
      expect(restoredEntry.contentJson, equals(rawDocJson));
      expect(restoredEntry.plainText, equals(rawPlain));
    },
  );

  test('deleting an entry cascades and removes time_capsules row', () async {
    final entryId = await db
        .into(db.entries)
        .insert(
          EntriesCompanion.insert(
            journalId: journalId,
            title: const Value('To be deleted'),
            contentJson: const Value('[{"insert":"Gone soon\\n"}]'),
            plainText: const Value('Gone soon'),
          ),
        );

    await service.sealEntry(
      entryId: entryId,
      unlockDate: DateTime.now().add(const Duration(days: 30)),
    );

    expect(await db.timeCapsulesDao.getCapsuleForEntry(entryId), isNotNull);

    await db.entriesDao.deleteEntryById(entryId);

    expect(await db.timeCapsulesDao.getCapsuleForEntry(entryId), isNull);
  });
}
