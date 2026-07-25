import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';

void main() {
  group('VoiceNotesDao', () {
    late AppDatabase database;
    late int journalId;
    late int entryId;

    setUp(() async {
      database = AppDatabase.forExecutor(NativeDatabase.memory());

      journalId = await database.journalsDao.createJournal(
        JournalsCompanion.insert(title: 'Voice Test'),
      );
      entryId = await database.entriesDao.createEntry(
        EntriesCompanion.insert(
          journalId: journalId,
          title: const Value('Entry with voice notes'),
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('create and retrieve voice notes', () async {
      final id = await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice_001.m4a',
          encryptedPath: '/data/encrypted/voice_001.enc',
          nonceBase64: 'abc123',
          keyReference: 'key_ref_001',
          durationMs: 15000,
          transcript: const Value('Hello, this is a test'),
        ),
      );

      expect(id, isPositive);

      final notes = await database.voiceNotesDao.getVoiceNotesForEntry(entryId);
      expect(notes, hasLength(1));
      expect(notes.single.fileName, 'voice_001.m4a');
      expect(notes.single.durationMs, 15000);
      expect(notes.single.transcript, 'Hello, this is a test');
    });

    test('updateTranscript modifies only transcript field', () async {
      final id = await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice_002.m4a',
          encryptedPath: '/data/encrypted/voice_002.enc',
          nonceBase64: 'def456',
          keyReference: 'key_ref_002',
          durationMs: 30000,
        ),
      );

      var notes = await database.voiceNotesDao.getVoiceNotesForEntry(entryId);
      expect(notes.single.transcript, isNull);

      await database.voiceNotesDao.updateTranscript(
        id,
        'Transcribed text here',
      );

      notes = await database.voiceNotesDao.getVoiceNotesForEntry(entryId);
      expect(notes.single.transcript, 'Transcribed text here');
      expect(notes.single.fileName, 'voice_002.m4a'); // unchanged
      expect(notes.single.durationMs, 30000); // unchanged
    });

    test('deleteVoiceNoteById removes the note', () async {
      final id = await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice_003.m4a',
          encryptedPath: '/data/encrypted/voice_003.enc',
          nonceBase64: 'ghi789',
          keyReference: 'key_ref_003',
          durationMs: 5000,
        ),
      );

      expect(
        await database.voiceNotesDao.getVoiceNotesForEntry(entryId),
        hasLength(1),
      );

      await database.voiceNotesDao.deleteVoiceNoteById(id);

      expect(
        await database.voiceNotesDao.getVoiceNotesForEntry(entryId),
        isEmpty,
      );
    });

    test('voice notes are cascade-deleted when entry is deleted', () async {
      await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice_004.m4a',
          encryptedPath: '/data/encrypted/voice_004.enc',
          nonceBase64: 'jkl012',
          keyReference: 'key_ref_004',
          durationMs: 10000,
        ),
      );

      expect(
        await database.voiceNotesDao.getVoiceNotesForEntry(entryId),
        hasLength(1),
      );

      await database.entriesDao.deleteEntryById(entryId);

      expect(
        await database.voiceNotesDao.getVoiceNotesForEntry(entryId),
        isEmpty,
      );
    });

    test('multiple voice notes returned for same entry', () async {
      await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice_first.m4a',
          encryptedPath: '/data/encrypted/first.enc',
          nonceBase64: 'nonce1',
          keyReference: 'key1',
          durationMs: 5000,
        ),
      );

      await database.voiceNotesDao.createVoiceNote(
        VoiceNotesCompanion.insert(
          entryId: entryId,
          fileName: 'voice_second.m4a',
          encryptedPath: '/data/encrypted/second.enc',
          nonceBase64: 'nonce2',
          keyReference: 'key2',
          durationMs: 8000,
        ),
      );

      final notes = await database.voiceNotesDao.getVoiceNotesForEntry(entryId);
      expect(notes, hasLength(2));
      final fileNames = notes.map((n) => n.fileName).toSet();
      expect(fileNames, contains('voice_first.m4a'));
      expect(fileNames, contains('voice_second.m4a'));
    });
  });
}
