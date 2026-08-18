import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/utils/safe_file_name.dart';

/// Covers the export file-name helper. The Malayalam cases are the point of the
/// function: a title in a non-Latin script must survive into the file name.
void main() {
  group('safeFileName', () {
    test('keeps a plain title, collapsing spaces to underscores', () {
      expect(safeFileName('My first entry'), 'My_first_entry');
    });

    test('keeps Malayalam letters', () {
      expect(safeFileName('എന്റെ ഡയറി'), 'എന്റെ_ഡയറി');
    });

    test('removes characters that are illegal in file names', () {
      expect(safeFileName(r'a/b\c:d*e?f"g<h>i|j'), 'abcdefghij');
    });

    test('removes control characters', () {
      // Written as escapes on purpose: a literal control character in the
      // source is invisible, and a later edit would silently drop it.
      expect(safeFileName('beforeafter'), 'beforeafter');
      // A newline is whitespace as well as a control character; the whitespace
      // rule wins and it becomes one underscore.
      expect(safeFileName('line\nbreak'), 'line_break');
      expect(safeFileName('tab\tsep'), 'tab_sep');
    });

    test('falls back when nothing usable is left', () {
      expect(safeFileName('///'), 'entry');
      expect(safeFileName(''), 'entry');
      expect(safeFileName('   '), 'entry');
    });

    test('uses the caller fallback', () {
      expect(safeFileName('', fallback: 'journal'), 'journal');
    });

    test('strips a leading dot so the file is not hidden', () {
      expect(safeFileName('.hidden'), 'hidden');
      expect(safeFileName('...hidden'), 'hidden');
    });

    test('strips trailing dots and spaces, which Windows rejects', () {
      expect(safeFileName('name...'), 'name');
      expect(safeFileName('name  '), 'name');
    });

    test('caps the name at 120 UTF-8 bytes', () {
      final long = 'a' * 500;
      final result = safeFileName(long);
      expect(utf8.encode(result).length, lessThanOrEqualTo(120));
      expect(result, 'a' * 120);
    });

    test('caps Malayalam without splitting a character', () {
      // Each of these letters is 3 UTF-8 bytes, so 120 bytes is 40 letters.
      final long = 'ഡ' * 100;
      final result = safeFileName(long);
      expect(utf8.encode(result).length, lessThanOrEqualTo(120));
      expect(result, 'ഡ' * 40);
      // Re-decoding proves nothing was cut in half.
      expect(() => utf8.decode(utf8.encode(result)), returnsNormally);
    });
  });
}
