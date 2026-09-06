import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_image_preprocessor.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';

/// Builds a [TextLine] with just the fields the assembler reads.
TextLine _line(String text, Rect rect) => TextLine(
  text: text,
  elements: const [],
  boundingBox: rect,
  recognizedLanguages: const [],
  cornerPoints: const <Point<int>>[],
  confidence: null,
  angle: null,
);

/// Builds a single-line [TextBlock], the shape ML Kit returns for a lone
/// symbol such as `=`.
TextBlock _block(List<TextLine> lines) => TextBlock(
  text: lines.map((l) => l.text).join(' '),
  lines: lines,
  boundingBox: lines.first.boundingBox,
  recognizedLanguages: const [],
  cornerPoints: const <Point<int>>[],
);

RecognizedText _recognized(List<TextBlock> blocks) =>
    RecognizedText(text: '', blocks: blocks);

/// A preprocessor that hands back a fixed path, so the two-pass behaviour can
/// be driven from a test.
class _FakePreprocessor implements OcrImagePreprocessor {
  _FakePreprocessor(this.preparedPath);

  final String? preparedPath;
  final calledWith = <String>[];

  @override
  Future<String?> prepare(String imagePath) async {
    calledWith.add(imagePath);
    return preparedPath;
  }
}

/// Builds the raw channel reply the ML Kit plugin parses, with one block of
/// one line holding [text].
Map<Object?, Object?> _channelReply(String text) => <Object?, Object?>{
  'text': text,
  'blocks': <Object?>[
    if (text.isNotEmpty)
      <Object?, Object?>{
        'text': text,
        'rect': _rect,
        'points': <Object?>[],
        'recognizedLanguages': <Object?>[],
        'lines': <Object?>[
          <Object?, Object?>{
            'text': text,
            'rect': _rect,
            'points': <Object?>[],
            'recognizedLanguages': <Object?>[],
            'confidence': null,
            'angle': null,
            'elements': <Object?>[],
          },
        ],
      },
  ],
};

const _rect = <Object?, Object?>{
  'left': 0,
  'top': 0,
  'right': 100,
  'bottom': 30,
};

class _FakeOcrService implements OcrService {
  _FakeOcrService({this.textToReturn = '', this.shouldThrow = false});

  final String textToReturn;
  final bool shouldThrow;
  String? lastProcessedPath;

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    lastProcessedPath = imagePath;
    if (shouldThrow) {
      throw Exception('OCR extraction failed');
    }
    return textToReturn;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OcrService', () {
    test('extracts text from image correctly', () async {
      final service = _FakeOcrService(textToReturn: 'Recognized journal text');
      final result = await service.extractTextFromImage('/tmp/test_image.jpg');

      expect(result, 'Recognized journal text');
      expect(service.lastProcessedPath, '/tmp/test_image.jpg');
    });

    test('returns empty string when no text found', () async {
      final service = _FakeOcrService();
      final result = await service.extractTextFromImage('/tmp/blank_image.jpg');

      expect(result, isEmpty);
    });

    test('throws when extraction fails', () async {
      final service = _FakeOcrService(shouldThrow: true);

      expect(
        () => service.extractTextFromImage('/tmp/corrupted.jpg'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('assembleRecognizedText', () {
    test('keeps a lone `=` on the same line as the words beside it', () {
      // ML Kit hands back `x`, `=` and `5` as three separate blocks, all
      // sitting on one visual row.
      final recognized = _recognized([
        _block([_line('x', const Rect.fromLTRB(10, 100, 30, 130))]),
        _block([_line('=', const Rect.fromLTRB(40, 108, 60, 122))]),
        _block([_line('5', const Rect.fromLTRB(70, 100, 90, 130))]),
      ]);

      expect(assembleRecognizedText(recognized), 'x = 5');
    });

    test('orders rows top to bottom and columns left to right', () {
      final recognized = _recognized([
        _block([_line('second', const Rect.fromLTRB(10, 200, 80, 230))]),
        _block([_line('right', const Rect.fromLTRB(200, 100, 260, 130))]),
        _block([_line('left', const Rect.fromLTRB(10, 100, 70, 130))]),
      ]);

      expect(assembleRecognizedText(recognized), 'left right\nsecond');
    });

    test('splits lines that do not overlap vertically', () {
      final recognized = _recognized([
        _block([
          _line('3.14', const Rect.fromLTRB(10, 100, 80, 130)),
          _line('a, b; c', const Rect.fromLTRB(10, 140, 90, 170)),
        ]),
      ]);

      expect(assembleRecognizedText(recognized), '3.14\na, b; c');
    });

    test('drops blank lines and returns empty for no blocks', () {
      final recognized = _recognized([
        _block([
          _line('kept', const Rect.fromLTRB(10, 100, 60, 130)),
          _line('   ', const Rect.fromLTRB(10, 140, 60, 170)),
        ]),
      ]);

      expect(assembleRecognizedText(recognized), 'kept');
      expect(assembleRecognizedText(_recognized([])), isEmpty);
    });
  });

  group('MlKitOcrService two-pass recognition', () {
    const channel = MethodChannel('google_mlkit_text_recognizer');
    late Map<String, String> textByPath;
    late List<String> scannedPaths;

    setUp(() {
      textByPath = <String, String>{};
      scannedPaths = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method != 'vision#startTextRecognizer') return null;
            final imageData =
                (call.arguments as Map)['imageData'] as Map<dynamic, dynamic>;
            final path = imageData['path'] as String;
            scannedPaths.add(path);
            return _channelReply(textByPath[path] ?? '');
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('reads the prepared image and does not touch the original', () async {
      textByPath['/tmp/prepared.png'] = 'x = 5';
      final preprocessor = _FakePreprocessor('/tmp/prepared.png');
      final service = MlKitOcrService(
        recognizer: TextRecognizer(),
        preprocessor: preprocessor,
      );

      final result = await service.extractTextFromImage('/tmp/photo.jpg');

      expect(result, 'x = 5');
      expect(preprocessor.calledWith, ['/tmp/photo.jpg']);
      expect(scannedPaths, ['/tmp/prepared.png']);
    });

    test(
      'falls back to the original when the prepared image reads blank',
      () async {
        textByPath['/tmp/prepared.png'] = '';
        textByPath['/tmp/photo.jpg'] = 'fallback text';
        final service = MlKitOcrService(
          recognizer: TextRecognizer(),
          preprocessor: _FakePreprocessor('/tmp/prepared.png'),
        );

        final result = await service.extractTextFromImage('/tmp/photo.jpg');

        expect(result, 'fallback text');
        expect(scannedPaths, ['/tmp/prepared.png', '/tmp/photo.jpg']);
      },
    );

    test('scans the original when preparation was skipped', () async {
      textByPath['/tmp/photo.jpg'] = 'plain text';
      final service = MlKitOcrService(
        recognizer: TextRecognizer(),
        preprocessor: _FakePreprocessor(null),
      );

      final result = await service.extractTextFromImage('/tmp/photo.jpg');

      expect(result, 'plain text');
      expect(scannedPaths, ['/tmp/photo.jpg']);
    });
  });
}
