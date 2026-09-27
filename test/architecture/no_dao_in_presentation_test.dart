import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Widgets must not read or write the database directly
/// (presentation → providers → services → database).
///
/// Fails when a file under `lib/**/presentation/` or `lib/app/` calls a DAO
/// or reads `appDatabaseProvider`. The one allowed use is the start-up
/// override of that provider in `lib/app/app.dart`.
void main() {
  test('no widget file uses a DAO or appDatabaseProvider', () {
    final forbidden = RegExp(r'\w+Dao\.|appDatabaseProvider');
    const allowedLine = 'appDatabaseProvider.overrideWithValue(';

    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
        .where((f) {
          final path = f.path.replaceAll(r'\', '/');
          return path.contains('/presentation/') || path.startsWith('lib/app/');
        });
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (line.contains(allowedLine)) continue;
        if (forbidden.hasMatch(line)) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Read and write through a service exposed by a provider.',
    );
  });
}
