import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_sender.dart';

void main() {
  group('AirqrSendController', () {
    test('starts and produces encoded frames', () async {
      final payload = AirqrPayload.settings(
        themeMode: 'dark',
        accentColorArgb: null,
        accentPresetName: null,
        isScreenSecurityEnabled: true,
        ritualLaunchOnStartup: false,
        ritualBreathTechnique: 'box',
        ritualBreathCycles: 4,
        templates: [],
        tags: [],
      );

      final controller = AirqrSendController(
        payload: payload,
        pairingCode: '23456789ABCDEFGH',
        fps: 10,
      );

      await controller.start();

      expect(controller.encoded, isNotNull);
      expect(controller.currentFrame, isNotNull);
      expect(controller.isManifestFrame, isTrue);

      controller.setFps(6);
      expect(controller.fps, 6);

      controller.dispose();
    });
  });
}
