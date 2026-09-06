import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';

void main() {
  // Quill's plain text always ends with a newline, so the fixtures do too.
  const text = 'first line\nsecond line\n\nlast line\n';

  group('lineStartOffset', () {
    test('returns 0 anywhere on the first line', () {
      expect(lineStartOffset(text, 0), 0);
      expect(lineStartOffset(text, 5), 0);
      expect(lineStartOffset(text, 10), 0);
    });

    test('returns the offset just after the previous newline', () {
      expect(lineStartOffset(text, 11), 11);
      expect(lineStartOffset(text, 18), 11);
      expect(lineStartOffset(text, 22), 11);
    });

    test('handles an empty line', () {
      expect(lineStartOffset(text, 23), 23);
    });

    test('handles the last line', () {
      expect(lineStartOffset(text, 30), 24);
    });

    test('clamps an out-of-range offset', () {
      expect(lineStartOffset(text, -5), 0);
      // The fixture ends with a newline, so the clamped caret sits on the
      // empty line after it, which starts at the very end of the text.
      expect(lineStartOffset(text, text.length + 99), text.length);
    });
  });

  group('lineEndOffset', () {
    test('returns the next newline on the first line', () {
      expect(lineEndOffset(text, 0), 10);
      expect(lineEndOffset(text, 10), 10);
    });

    test('returns the next newline on a middle line', () {
      expect(lineEndOffset(text, 11), 22);
      expect(lineEndOffset(text, 22), 22);
    });

    test('handles an empty line', () {
      expect(lineEndOffset(text, 23), 23);
    });

    test('handles the last line', () {
      expect(lineEndOffset(text, 24), 33);
      expect(lineEndOffset(text, 33), 33);
    });

    test('returns the text length when there is no trailing newline', () {
      expect(lineEndOffset('no newline', 3), 10);
    });

    test('clamps an out-of-range offset', () {
      expect(lineEndOffset(text, -5), 10);
      expect(lineEndOffset(text, text.length + 99), text.length);
    });
  });
}
