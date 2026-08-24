import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';

void main() {
  group('AirqrPayload', () {
    test('settings payload serializes and deserializes', () {
      final payload = AirqrPayload.settings(
        themeMode: 'system',
        accentColorArgb: 0xFFFF5722,
        accentPresetName: 'Sunset',
        isScreenSecurityEnabled: false,
        ritualLaunchOnStartup: true,
        ritualBreathTechnique: 'relax',
        ritualBreathCycles: 6,
        templates: [
          {'name': 'Gratitude', 'category': 'Mindfulness'},
        ],
        tags: [
          {'name': 'Idea', 'colorArgb': 0xFF9C27B0},
        ],
      );

      final bytes = payload.toBytes();
      expect(bytes.isNotEmpty, isTrue);

      final restored = AirqrPayload.fromBytes(bytes);
      expect(restored.kind, AirqrConstants.kindSettings);
      expect(restored.data['themeMode'], 'system');
      expect(restored.data['accentPresetName'], 'Sunset');
      expect(restored.data['ritualBreathTechnique'], 'relax');
      expect(restored.data['ritualBreathCycles'], 6);
      expect((restored.data['templates'] as List).length, 1);
      expect((restored.data['tags'] as List).length, 1);
    });

    test('entry payload serializes and deserializes', () {
      final payload = AirqrPayload.entry(
        title: 'Morning Run',
        contentJson: '{"ops":[{"insert":"5 km completed"}]}',
        plainText: '5 km completed',
        mood: 'energized',
        tags: ['Fitness', 'Health'],
      );

      final bytes = payload.toBytes();
      final restored = AirqrPayload.fromBytes(bytes);

      expect(restored.kind, AirqrConstants.kindEntry);
      expect(restored.data['title'], 'Morning Run');
      expect(restored.data['plainText'], '5 km completed');
      expect(restored.data['mood'], 'energized');
      expect((restored.data['tags'] as List).length, 2);
    });

    test('journal payload serializes and deserializes', () {
      final payload = AirqrPayload.journal(
        title: 'Ideas Vault',
        description: 'Brainstorming',
        entries: [
          {'title': 'App concept', 'plainText': 'Optical Sync'},
        ],
        tags: [
          {'name': 'Tech', 'colorArgb': 0xFF009688},
        ],
      );

      final bytes = payload.toBytes();
      final restored = AirqrPayload.fromBytes(bytes);

      expect(restored.kind, AirqrConstants.kindJournal);
      expect(restored.data['title'], 'Ideas Vault');
      expect((restored.data['entries'] as List).length, 1);
      expect((restored.data['tags'] as List).length, 1);
    });
  });
}
