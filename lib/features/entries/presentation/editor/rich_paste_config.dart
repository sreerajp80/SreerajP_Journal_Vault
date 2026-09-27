import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
// The clipboard service is what flutter_quill's own paste uses to read HTML
// on Android. Marked experimental, but the vendored copy cannot change.
// ignore: experimental_member_use
import 'package:flutter_quill/internal.dart' show ClipboardServiceProvider;
import 'package:flutter_quill/quill_delta.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/services/html_to_delta.dart';

/// Rich paste for the entry, template and table-cell editors.
///
/// When the clipboard holds HTML (a copy from a browser, Google Docs, Word,
/// Gmail…), Paste keeps its formatting, links and tables, cleaned by
/// [HtmlToJournalDelta]. When it holds none, Paste works exactly as before:
/// flutter_quill's own handling of images and plain text runs.
///
/// Pasted content is never logged.
class RichPaste {
  const RichPaste._();

  /// A controller config whose Paste keeps formatting.
  ///
  /// [controller] is read when Paste happens, so the config can be built
  /// before the controller exists. With [inlineOnly] (a table cell), only
  /// inline formatting is kept.
  static QuillControllerConfig controllerConfig(
    QuillController Function() controller, {
    bool inlineOnly = false,
  }) {
    return QuillControllerConfig(
      // Experimental in flutter_quill, but it is the hook for replacing the
      // paste; the vendored copy in third_party/ cannot change under us.
      // ignore: experimental_member_use
      clipboardConfig: QuillClipboardConfig(
        // ignore: experimental_member_use
        onClipboardPaste: () => pasteHtml(controller(), inlineOnly: inlineOnly),
      ),
    );
  }

  /// Pastes the clipboard's HTML into [controller], replacing the selection.
  /// One Undo removes it.
  ///
  /// Returns false — so the normal paste runs — when the clipboard holds no
  /// HTML or nothing usable could be made of it.
  static Future<bool> pasteHtml(
    QuillController controller, {
    bool inlineOnly = false,
  }) async {
    if (controller.readOnly) return false;

    final String? html;
    try {
      // ignore: experimental_member_use
      html = await ClipboardServiceProvider.instance.getHtmlText();
    } on Object catch (error) {
      AppLogger.warning(
        'Reading HTML from the clipboard failed (${error.runtimeType})',
      );
      return false;
    }
    if (html == null || html.trim().isEmpty) return false;

    final ops = const HtmlToJournalDelta().convert(
      html,
      inlineOnly: inlineOnly,
    );
    if (ops == null) {
      AppLogger.info('HTML paste fell back to plain text');
      return false;
    }
    insertOps(controller, ops);
    return true;
  }

  /// Inserts delta [ops] at [controller]'s selection, replacing it.
  ///
  /// Like a normal paste, no line break is added after the last line unless
  /// it carries a line style (a list item or heading, say).
  static void insertOps(
    QuillController controller,
    List<Map<String, dynamic>> ops,
  ) {
    final trimmed = List<Map<String, dynamic>>.of(ops);
    final last = trimmed.last;
    final lastInsert = last['insert'];
    if (lastInsert is String &&
        lastInsert.endsWith('\n') &&
        last['attributes'] == null) {
      final text = lastInsert.substring(0, lastInsert.length - 1);
      if (text.isEmpty) {
        trimmed.removeLast();
      } else {
        trimmed[trimmed.length - 1] = {'insert': text};
      }
    }
    if (trimmed.isEmpty) return;

    final delta = Delta.fromJson(trimmed);
    final selection = controller.selection;
    final start = selection.start;
    controller.replaceText(
      start,
      selection.end - start,
      delta,
      TextSelection.collapsed(offset: start + delta.length),
    );
  }
}
