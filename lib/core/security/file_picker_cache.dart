// Layer: service (core). Removes the copies the system file picker leaves in
// the app's cache. Never logs a file name.

import 'package:file_picker/file_picker.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Deletes the picker's copies of the files the user picked.
///
/// On Android, `file_picker` copies every chosen file into
/// `cache/file_picker/<time>/<name>` and never deletes it. The copy is the
/// user's file in the clear — an attachment, a document being imported, a
/// backup — so it must go as soon as the bytes have been read. Call this after
/// every pick, once the result is no longer needed. Never throws.
Future<void> clearFilePickerCache() async {
  try {
    await FilePicker.clearTemporaryFiles();
  } catch (_) {
    // No plugin (tests) or nothing to clear; the startup sweep catches the
    // rest.
    AppLogger.debug('File picker cache: nothing cleared');
  }
}
