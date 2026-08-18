/// Turns an entry or journal title into a safe file name for exports.
///
/// Keeps Unicode letters and digits, so a Malayalam title survives and becomes
/// the file name. Only characters that are actually illegal in file names on
/// Android and iOS are removed: `\ / : * ? " < > |` and control characters.
/// Whitespace collapses to a single `_`. An empty result falls back to
/// [fallback], so a blank or symbol-only title never breaks the export path.
///
/// Ported from `SreerajP_lyricchord/lib/core/utils/safe_file_name.dart`.
///
/// The length cap matters here in a way it did not there: an export bundles
/// many entries, and a long first line used as a title can overflow the 255-byte
/// name limit most file systems have. The cap counts UTF-8 bytes, not
/// characters, because a Malayalam letter costs three bytes.
String safeFileName(String title, {String fallback = 'entry'}) {
  final cleaned = title
      .trim()
      // Whitespace collapses FIRST, before control characters are dropped.
      // Newlines and tabs are both whitespace and control characters, and a
      // title pasted from two lines reads better as "line_break" than as
      // "linebreak". Doing this the other way round deletes the gap between
      // the words. (This is the one place this helper differs from the
      // lyricchord original, which only ever saw single-line song titles.)
      .replaceAll(RegExp(r'\s+'), '_')
      // Drop file-system illegal characters and any remaining control
      // characters. Everything else (including Malayalam letters) is kept.
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '')
      // A leading dot hides the file on Unix-like systems and confuses the
      // extension. A trailing dot or space is illegal on Windows.
      .replaceAll(RegExp(r'^\.+'), '')
      .replaceAll(RegExp(r'[. ]+$'), '');

  final capped = _capUtf8Bytes(cleaned, 120);
  return capped.isEmpty ? fallback : capped;
}

/// Cuts [value] so its UTF-8 encoding is at most [maxBytes], never splitting a
/// character in half.
String _capUtf8Bytes(String value, int maxBytes) {
  var bytes = 0;
  // Walk runes, not code units, so a surrogate pair is never cut apart.
  final kept = StringBuffer();
  for (final rune in value.runes) {
    final size = _utf8Length(rune);
    if (bytes + size > maxBytes) break;
    bytes += size;
    kept.writeCharCode(rune);
  }
  return kept.toString();
}

/// How many UTF-8 bytes the code point [rune] takes.
int _utf8Length(int rune) {
  if (rune <= 0x7f) return 1;
  if (rune <= 0x7ff) return 2;
  if (rune <= 0xffff) return 3;
  return 4;
}
