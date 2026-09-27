// Layer: service. Moves voice notes from the old `voice_notes` table into
// `attachments`. Knows nothing about widgets; never logs a name or path.

import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_saver.dart';

/// Length of the AES-GCM tag stored at the end of every encrypted file.
const int _gcmTagLength = 16;

/// Moves voice notes recorded before they became attachments.
///
/// Older builds saved recordings to `voice_notes`, which no screen reads, so
/// those notes could not be played or deleted. Each row becomes an
/// `attachments` row pointing at the **same** encrypted file, nonce and key.
/// Nothing is decrypted or rewritten. Each move is one transaction, so a note
/// is never in both tables or in neither.
///
/// Safe to run on every start: once the table is empty it does nothing. The
/// table itself stays, so older backups still restore.
class LegacyVoiceNoteMover {
  LegacyVoiceNoteMover(this._db);

  final AppDatabase _db;

  /// Moves every row. Returns how many were moved. Never throws.
  Future<int> moveAll() async {
    var moved = 0;
    try {
      final notes = await _db.select(_db.voiceNotes).get();
      for (final note in notes) {
        try {
          await _db.transaction(() async {
            await _db.attachmentsDao.createAttachment(
              AttachmentsCompanion.insert(
                entryId: note.entryId,
                fileName: _fileName(note.fileName),
                mimeType: const Value(voiceNoteMimeType),
                encryptedPath: note.encryptedPath,
                nonceBase64: note.nonceBase64,
                keyReference: note.keyReference,
                sizeBytes: _plainSize(note.encryptedPath),
                createdAt: Value(note.createdAt),
              ),
            );
            await _db.voiceNotesDao.deleteVoiceNoteById(note.id);
          });
          moved++;
        } catch (_) {
          // Left in place; the next start tries again.
        }
      }
    } catch (e) {
      AppLogger.warning('LegacyVoiceNoteMover: could not read voice notes');
    }
    if (moved > 0) {
      AppLogger.info('LegacyVoiceNoteMover: moved $moved voice notes');
    }
    return moved;
  }

  /// Keeps the `.m4a` ending so the file opens in the audio player.
  static String _fileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'voice_note.m4a';
    return trimmed.toLowerCase().endsWith('.m4a') ? trimmed : '$trimmed.m4a';
  }

  /// The audio's own size: the encrypted file minus the GCM tag. Zero when the
  /// file is on the SD card (a `content://` URI) or cannot be read; the size
  /// is only shown, never used to read the file.
  static int _plainSize(String encryptedPath) {
    if (encryptedPath.startsWith('content://')) return 0;
    try {
      final length = File(encryptedPath).lengthSync();
      return length > _gcmTagLength ? length - _gcmTagLength : 0;
    } catch (_) {
      return 0;
    }
  }
}
