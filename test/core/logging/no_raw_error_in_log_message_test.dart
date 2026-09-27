import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A log call must pass an error as `error:`, never inside the message text.
///
/// `AppLogger` logs only an error's type. An error put into the message with
/// `$e` skips that filter, and its text can hold a file name, a path or other
/// journal data (CLAUDE.md hard rule 3).
void main() {
  test('no AppLogger message puts an error object into its text', () {
    final call = RegExp(r'AppLogger\.\w+\(([^;]*)\);');
    final rawError = RegExp(
      r'\$\{?(e|error|err|ex|exception)\b(?!\.runtimeType)'
      r'|\.message\b|\.toString\(\)',
    );

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final match in call.allMatches(source)) {
        if (rawError.hasMatch(match.group(1)!)) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length;
          offenders.add('${file.path}:${line + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Pass the error as `error: e` instead of `\$e` in the message.',
    );
  });
}
