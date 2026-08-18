import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// One row in the archive listing.
class ArchiveEntryInfo {
  const ArchiveEntryInfo({
    required this.path,
    required this.sizeBytes,
    required this.isDirectory,
  });

  final String path;
  final int sizeBytes;
  final bool isDirectory;

  String get name =>
      path.split('/').where((p) => p.isNotEmpty).lastOrNull ?? path;
}

/// Reads the entry list of a ZIP file without extracting anything.
///
/// Nothing is written to disk, so no archive content can escape into shared
/// storage. Throws [FormatException] when the archive is unreadable — which
/// includes encrypted archives, since their central directory cannot be parsed.
List<ArchiveEntryInfo> readZipEntries(String filePath) {
  final bytes = File(filePath).readAsBytesSync();

  // ZipDecoder returns an empty archive rather than throwing when handed
  // arbitrary bytes, so check the signature first. Every ZIP starts with 'PK'
  // — 0x03 0x04 for a normal archive, 0x05 0x06 for an empty one, 0x07 0x08
  // for a spanned one.
  if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
    throw const FormatException('Not a ZIP archive');
  }

  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (e) {
    throw FormatException('Archive could not be read: $e');
  }
  return [
    for (final file in archive)
      ArchiveEntryInfo(
        path: file.name,
        sizeBytes: file.size,
        isDirectory: !file.isFile,
      ),
  ];
}

/// In-app ZIP listing for an attachment (V1 attachment plan, slice 5).
class ArchiveAttachmentView extends StatefulWidget {
  const ArchiveAttachmentView({
    required this.filePath,
    this.entryReader = readZipEntries,
    super.key,
  });

  final String filePath;

  /// Injection point for tests.
  final List<ArchiveEntryInfo> Function(String filePath) entryReader;

  @override
  State<ArchiveAttachmentView> createState() => _ArchiveAttachmentViewState();
}

class _ArchiveAttachmentViewState extends State<ArchiveAttachmentView> {
  List<ArchiveEntryInfo>? _entries;
  String? _error;

  @override
  void initState() {
    super.initState();
    _read();
  }

  void _read() {
    try {
      final entries = widget.entryReader(widget.filePath);
      setState(() {
        _entries = entries;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _entries = null;
        _error =
            'This archive could not be read. It may be corrupt, or protected '
            'with a password.';
      });
    }
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return Center(
        key: const Key('archive-attachment-error'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final entries = _entries;
    if (entries == null) {
      return const Center(
        key: Key('archive-attachment-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (entries.isEmpty) {
      return Center(
        key: const Key('archive-attachment-empty'),
        child: Text(AppLocalizations.of(context).attachmentArchiveEmpty),
      );
    }

    return ListView.builder(
      key: const Key('archive-attachment-list'),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          dense: true,
          leading: Icon(
            entry.isDirectory
                ? Icons.folder_outlined
                : Icons.description_outlined,
          ),
          title: Text(entry.name),
          subtitle: Text(entry.path),
          trailing: entry.isDirectory
              ? null
              : Text(_formatSize(entry.sizeBytes)),
        );
      },
    );
  }
}
