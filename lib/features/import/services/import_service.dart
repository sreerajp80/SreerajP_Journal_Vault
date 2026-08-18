import 'package:drift/drift.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/import/services/import_adapter.dart';
import 'package:sreerajp_journal_vault/features/import/services/plain_text_import_adapter.dart';
import 'package:sreerajp_journal_vault/features/import/services/markdown_import_adapter.dart';
import 'package:sreerajp_journal_vault/features/import/services/docx_import_adapter.dart';

/// Orchestrates file import into journal entries.
///
/// Selects the appropriate [ImportAdapter] based on file extension or MIME type,
/// converts file content to a Quill delta, and creates a new entry in the
/// target journal.
class ImportService {
  final AppDatabase _db;

  ImportService(this._db);

  /// All registered import adapters.
  final List<ImportAdapter> _adapters = [
    PlainTextImportAdapter(),
    MarkdownImportAdapter(),
    DocxImportAdapter(),
  ];

  /// Returns the list of supported format names for display.
  List<String> get supportedFormats =>
      _adapters.map((a) => a.formatName).toList();

  /// Returns all supported file extensions across adapters.
  List<String> get supportedExtensions =>
      _adapters.expand((a) => a.supportedExtensions).toList();

  /// Finds the appropriate adapter for a given file name.
  ImportAdapter? adapterForFile(String fileName) {
    final lower = fileName.toLowerCase();
    for (final adapter in _adapters) {
      for (final ext in adapter.supportedExtensions) {
        if (lower.endsWith(ext)) return adapter;
      }
    }
    return null;
  }

  /// Finds the appropriate adapter for a given MIME type.
  ImportAdapter? adapterForMimeType(String mimeType) {
    for (final adapter in _adapters) {
      if (adapter.supportedMimeTypes.contains(mimeType)) return adapter;
    }
    return null;
  }

  /// Imports a file into the specified journal, creating a new entry.
  ///
  /// Returns the ID of the newly created entry.
  /// Throws [UnsupportedError] if no adapter handles the file format.
  Future<int> importFile({
    required int journalId,
    required String fileName,
    required List<int> bytes,
    String? mimeType,
  }) async {
    final adapter =
        adapterForFile(fileName) ??
        (mimeType != null ? adapterForMimeType(mimeType) : null);

    if (adapter == null) {
      throw UnsupportedError('Unsupported import format: $fileName');
    }

    final result = await adapter.import(bytes, fileName);

    final entryId = await _db.entriesDao.createEntry(
      EntriesCompanion.insert(
        journalId: journalId,
        title: Value(result.title),
        contentJson: Value(result.contentJson),
        plainText: Value(result.plainText),
        entryDate: Value(DateTime.now()),
      ),
    );

    return entryId;
  }

  /// Imports multiple files into the specified journal.
  ///
  /// Returns a map of file name to either the entry ID (success) or
  /// error message (failure).
  Future<Map<String, ImportFileResult>> importFiles({
    required int journalId,
    required List<ImportFileInput> files,
  }) async {
    final results = <String, ImportFileResult>{};

    for (final file in files) {
      try {
        final entryId = await importFile(
          journalId: journalId,
          fileName: file.fileName,
          bytes: file.bytes,
          mimeType: file.mimeType,
        );
        results[file.fileName] = ImportFileResult.success(entryId);
      } catch (e) {
        results[file.fileName] = ImportFileResult.failure(e.toString());
      }
    }

    return results;
  }
}

/// Input for batch file import.
class ImportFileInput {
  final String fileName;
  final String? mimeType;
  final List<int> bytes;

  const ImportFileInput({
    required this.fileName,
    this.mimeType,
    required this.bytes,
  });
}

/// Result of importing a single file.
class ImportFileResult {
  final int? entryId;
  final String? error;
  final bool isSuccess;

  const ImportFileResult.success(int this.entryId)
    : error = null,
      isSuccess = true;

  const ImportFileResult.failure(String this.error)
    : entryId = null,
      isSuccess = false;
}
