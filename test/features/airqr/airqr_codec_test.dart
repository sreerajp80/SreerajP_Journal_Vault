import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';

void main() {
  group('AirqrCodec', () {
    test('generatePairingCode generates valid 16-character code', () {
      final code = AirqrCodec.generatePairingCode();
      expect(code.length, AirqrConstants.codeLength);
      expect(code.contains('0'), isFalse);
      expect(code.contains('O'), isFalse);
      expect(code.contains('1'), isFalse);
      expect(code.contains('I'), isFalse);
      expect(code.contains('L'), isFalse);
    });

    test('formatCode and normalizeCode round-trip', () {
      const code = '23456789ABCDEFGH';
      final formatted = AirqrCodec.formatCode(code);
      expect(formatted, '2345-6789-ABCD-EFGH');
      expect(AirqrCodec.normalizeCode(formatted), code);
      expect(AirqrCodec.normalizeCode(' 2345 - 6789 - abcd - efgh \n'), code);
    });

    test('encode and decodePayload full round-trip with encryption', () async {
      final payload = AirqrPayload.settings(
        themeMode: 'dark',
        accentColorArgb: 0xFF1E88E5,
        accentPresetName: 'Ocean',
        isScreenSecurityEnabled: true,
        ritualLaunchOnStartup: true,
        ritualBreathTechnique: 'box',
        ritualBreathCycles: 4,
        templates: [
          {'name': 'Daily Reflection', 'category': 'Daily'},
        ],
        tags: [
          {'name': 'Work', 'colorArgb': 0xFF4CAF50},
        ],
      );

      const pairingCode = '23456789ABCDEFGH';
      final encoded = await AirqrCodec.encode(
        payload: payload,
        pairingCode: pairingCode,
        chunkBytes: 200, // force multiple frames
      );

      expect(encoded.totalFrames, greaterThan(1));
      expect(encoded.allFrames.length, encoded.totalFrames + 1);

      // Parse manifest
      final parsedManifest = AirqrCodec.parseFrame(encoded.manifestFrame);
      expect(parsedManifest.isManifest, isTrue);
      final manifest = parsedManifest.manifest!;
      expect(manifest.totalFrames, encoded.totalFrames);
      expect(manifest.encrypted, isTrue);

      // Parse all data frames
      final chunks = List<Uint8List?>.filled(manifest.totalFrames, null);
      for (final frameStr in encoded.dataFrames) {
        final parsedFrame = AirqrCodec.parseFrame(frameStr);
        expect(parsedFrame.isManifest, isFalse);
        final dataFrame = parsedFrame.data!;
        chunks[dataFrame.index] = dataFrame.bytes;
      }

      // Reassemble and decode
      final decoded = await AirqrCodec.decodePayload(
        manifest: manifest,
        chunks: chunks,
        pairingCode: pairingCode,
      );

      expect(decoded.kind, 'settings');
      expect(decoded.data['themeMode'], 'dark');
      expect(decoded.data['accentColorArgb'], 0xFF1E88E5);
      expect(decoded.data['ritualBreathTechnique'], 'box');
      expect((decoded.data['templates'] as List).length, 1);
      expect((decoded.data['tags'] as List).length, 1);
    });

    test('decodePayload fails with incorrect pairing code', () async {
      final payload = AirqrPayload.entry(
        title: 'Secret Entry',
        contentJson: '{"ops":[{"insert":"Confidential"}]}',
        plainText: 'Confidential',
      );

      const correctCode = '23456789ABCDEFGH';
      const wrongCode = '9999888877776666';

      final encoded = await AirqrCodec.encode(
        payload: payload,
        pairingCode: correctCode,
      );

      final manifest = AirqrCodec.parseFrame(encoded.manifestFrame).manifest!;
      final chunks = encoded.dataFrames
          .map((f) => AirqrCodec.parseFrame(f).data!.bytes)
          .toList();

      expect(
        () => AirqrCodec.decodePayload(
          manifest: manifest,
          chunks: chunks,
          pairingCode: wrongCode,
        ),
        throwsA(isA<AirqrFrameException>()),
      );
    });

    test('parseFrame rejects non-AirQR URIs', () {
      expect(
        () => AirqrCodec.parseFrame('https://example.com'),
        throwsA(isA<AirqrFrameException>()),
      );
      expect(
        () =>
            AirqrCodec.parseFrame('sreerajp-journal-vault-airqr://m?v=99&n=1'),
        throwsA(isA<AirqrFrameException>()),
      );
    });
  });
}
