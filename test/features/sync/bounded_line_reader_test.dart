import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/sync/services/bounded_line_reader.dart';

void main() {
  group('BoundedLineReader', () {
    test('reads single newline-delimited line', () async {
      final controller = StreamController<List<int>>();
      final reader = BoundedLineReader(controller.stream, maxLineBytes: 1024);

      controller.add(utf8.encode('hello world\n'));

      final line = await reader.readLine();
      expect(line, 'hello world');

      await reader.dispose();
      await controller.close();
    });

    test('strips trailing carriage return (CRLF)', () async {
      final controller = StreamController<List<int>>();
      final reader = BoundedLineReader(controller.stream, maxLineBytes: 1024);

      controller.add(utf8.encode('windows newline\r\n'));

      final line = await reader.readLine();
      expect(line, 'windows newline');

      await reader.dispose();
      await controller.close();
    });

    test('handles fragmented chunk stream', () async {
      final controller = StreamController<List<int>>();
      final reader = BoundedLineReader(controller.stream, maxLineBytes: 1024);

      controller.add(utf8.encode('frag'));
      controller.add(utf8.encode('mented\n'));

      final line = await reader.readLine();
      expect(line, 'fragmented');

      await reader.dispose();
      await controller.close();
    });

    test('throws LineTooLongException when buffer exceeds limit', () async {
      final controller = StreamController<List<int>>();
      final reader = BoundedLineReader(controller.stream, maxLineBytes: 10);

      final readFuture = reader.readLine();
      controller.add(
        Uint8List.fromList(List.filled(15, 65)),
      ); // 15 'A's without newline

      await expectLater(readFuture, throwsA(isA<LineTooLongException>()));

      await reader.dispose();
      await controller.close();
    });

    test('times out when line is not completed in time', () async {
      final controller = StreamController<List<int>>();
      final reader = BoundedLineReader(controller.stream, maxLineBytes: 1024);

      controller.add(utf8.encode('incomplete line'));

      await expectLater(
        reader.readLineWithTimeout(const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );

      await reader.dispose();
      await controller.close();
    });
  });
}
