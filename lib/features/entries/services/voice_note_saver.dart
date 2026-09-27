// Layer: service. Turns a finished recording into an encrypted attachment.
// Knows nothing about widgets; never logs a path, file name or any audio.

import 'dart:io';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_open_service.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';

/// MIME type of a voice note: AAC audio in an MP4 (`.m4a`) container.
const String voiceNoteMimeType = 'audio/mp4';

/// Why a voice note could not be saved.
class VoiceNoteSaveException implements Exception {
  const VoiceNoteSaveException(this.reason);

  /// A short code for logs. Never holds content.
  final String reason;

  @override
  String toString() => 'VoiceNoteSaveException($reason)';
}

/// `2026-09-19 09-41` — the time part of a voice note's file name.
///
/// Built by hand, not with a locale date format: it is part of a file name,
/// so it must stay plain digits and safe on every file system.
String voiceNoteTimestamp(DateTime time) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)} '
      '${two(time.hour)}-${two(time.minute)}';
}

/// Saves a recording as a normal attachment of an entry.
///
/// A voice note used to go into the `voice_notes` table, which no screen
/// reads, so it could never be played or deleted. As an attachment it shows
/// in the entry's attachment tray, plays in the in-app audio player, can be
/// locked and deleted, and is covered by backup and export.
class VoiceNoteSaver {
  VoiceNoteSaver({required this._importService, required this._db});

  final AttachmentImportService _importService;
  final AppDatabase _db;

  /// Encrypts the recording at [recordingPath] into an attachment of
  /// [entryId] named [fileName]. Returns the new attachment id.
  ///
  /// The plain recording is **always** deleted, whether saving worked or not.
  /// Throws [VoiceNoteSaveException] when the entry is not ready or the
  /// recording is empty; rethrows crypto and database errors.
  Future<int> save({
    required int? entryId,
    required String recordingPath,
    required String fileName,
  }) async {
    try {
      if (entryId == null) {
        throw const VoiceNoteSaveException('entry_not_ready');
      }
      final file = File(recordingPath);
      if (!file.existsSync()) {
        throw const VoiceNoteSaveException('recording_missing');
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw const VoiceNoteSaveException('recording_empty');
      return await _importService.importToEntry(
        database: _db,
        entryId: entryId,
        picked: PickedAttachmentData(
          fileName: fileName,
          mimeType: voiceNoteMimeType,
          bytes: bytes,
        ),
      );
    } finally {
      await _deleteQuietly(recordingPath);
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // The startup sweep clears the recording folder.
    }
  }
}
