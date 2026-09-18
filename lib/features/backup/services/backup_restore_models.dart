part of 'backup_restore_service.dart';

/// A decrypted archive, parsed and version-checked.
class _ReadArchive {
  _ReadArchive({
    required this.manifest,
    required this.tables,
    required this.archive,
  });

  final BackupManifest manifest;
  final Map<String, List<Map<String, dynamic>>> tables;
  final Archive archive;

  int countFilesIn(String folder) =>
      archive.files.where((f) => f.name.startsWith('$folder/')).length;

  ArchiveFile? findFileWithPrefix(String prefix) {
    for (final file in archive.files) {
      if (file.name.startsWith(prefix)) return file;
    }
    return null;
  }
}

/// What a restore intends to do, decided before anything is written.
class _RestorePlan {
  _RestorePlan({required this.mode});

  final RestoreMode mode;
  final Map<String, RestoreTableOutcome> outcomes = {};
  final List<RestoreWarning> warnings = [];

  /// Old archive id → the id it maps to in this database. Filled in during
  /// planning for rows that already exist, and during insertion for new ones.
  final Map<String, Map<int, int>> _idMap = {};

  /// Old archive ids that are new here and must be inserted. A replace has no
  /// entry for a table, which means "insert everything".
  final Map<String, Set<int>> _toInsert = {};

  int rowsToClear = 0;
  int attachmentRowsToInsert = 0;
  int voiceNoteRowsToInsert = 0;

  void mapExisting(String table, int oldId, int newId) {
    (_idMap[table] ??= {})[oldId] = newId;
  }

  void markForInsert(String table, int oldId) {
    (_toInsert[table] ??= {}).add(oldId);
  }

  int? mappedId(String table, int? oldId) {
    if (oldId == null) return null;
    return _idMap[table]?[oldId];
  }

  bool willInsert(String table, int oldId) {
    if (mode == RestoreMode.replace) return true;
    return _toInsert[table]?.contains(oldId) ?? false;
  }
}

/// Files written to storage during a restore, keyed `<table>:<old id>`.
class _RestoredFiles {
  final Map<String, BackupStoredFile> stored = {};
  final List<RestoreWarning> warnings = [];

  int attachmentsRestored = 0;
  int attachmentsFailed = 0;
  int voiceNotesRestored = 0;
  int voiceNotesFailed = 0;
}
