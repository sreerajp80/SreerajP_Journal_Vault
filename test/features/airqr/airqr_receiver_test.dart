import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_codec.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_receiver.dart';

void main() {
  group('AirqrReceiveController', () {
    test('collects frames out of order and reassembles payload', () async {
      final controller = AirqrReceiveController();
      expect(controller.phase, AirqrReceivePhase.scanning);

      final payload = AirqrPayload.entry(
        title: 'Test Note',
        contentJson: '{"ops":[{"insert":"Hello World"}]}',
        plainText: 'Hello World',
      );

      const pairingCode = '23456789ABCDEFGH';
      final encoded = await AirqrCodec.encode(
        payload: payload,
        pairingCode: pairingCode,
        chunkBytes: 150, // creates multiple frames
      );

      expect(encoded.totalFrames, greaterThan(1));

      // 1. Scan data frame out of order before manifest
      controller.onScan(encoded.dataFrames.last);
      expect(controller.phase, AirqrReceivePhase.scanning);

      // 2. Scan manifest
      controller.onScan(encoded.manifestFrame);
      expect(controller.totalFrames, encoded.totalFrames);
      expect(controller.receivedCount, 0);

      // 3. Scan remaining frames out of order
      for (final frame in encoded.dataFrames.reversed) {
        controller.onScan(frame);
      }

      // 4. All frames received -> transitions to needCode
      expect(controller.phase, AirqrReceivePhase.needCode);
      expect(controller.progress, 1.0);

      // 5. Submit code -> decrypts and transitions to done
      await controller.submitCode(pairingCode);

      expect(controller.phase, AirqrReceivePhase.done);
      expect(controller.result, isNotNull);
      expect(controller.result!.title, 'Test Note');
    });

    test('reset clears all state for a new scan', () async {
      final controller = AirqrReceiveController();
      controller.onScan(
        'sreerajp-journal-vault-airqr://m?v=1&n=5&k=settings&h=0000000000000000000000000000000000000000000000000000000000000000&z=1&e=0',
      );

      expect(controller.totalFrames, 5);

      controller.reset();
      expect(controller.phase, AirqrReceivePhase.scanning);
      expect(controller.totalFrames, isNull);
      expect(controller.receivedCount, 0);
    });
  });
}
