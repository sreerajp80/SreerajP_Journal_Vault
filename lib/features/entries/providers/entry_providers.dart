import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/entry_revision_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/voice_note_service.dart';

/// Provides the [EntryRevisionService] for managing version history.
final entryRevisionServiceProvider = Provider<EntryRevisionService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return EntryRevisionService(db);
});

/// Watches all revisions for a specific entry.
final entryRevisionsProvider =
    StreamProvider.family<List<EntryRevision>, int>((ref, entryId) {
  final service = ref.read(entryRevisionServiceProvider);
  return service.watchRevisions(entryId);
});

/// Provides a single [VoiceNoteService] instance.
final voiceNoteServiceProvider = Provider<VoiceNoteService>((ref) {
  final service = VoiceNoteService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Watches voice notes for a specific entry.
final entryVoiceNotesProvider =
    StreamProvider.family<List<VoiceNote>, int>((ref, entryId) {
  final db = ref.read(appDatabaseProvider);
  return db.voiceNotesDao.watchVoiceNotesForEntry(entryId);
});
