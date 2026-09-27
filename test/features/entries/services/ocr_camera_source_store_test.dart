import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_camera_source_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesOcrCameraSourceStore', () {
    test('uses the phone camera app when nothing is saved', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = SharedPreferencesOcrCameraSourceStore();
      expect(await store.read(), OcrCameraSourceStore.defaultUseInAppCamera);
      expect(await store.read(), isFalse);
    });

    test('saves and reads back the in-app camera choice', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = SharedPreferencesOcrCameraSourceStore();
      await store.save(true);
      expect(await store.read(), isTrue);
    });

    test('reads a value saved by an earlier run', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        OcrCameraSourceStore.prefKey: true,
      });
      const store = SharedPreferencesOcrCameraSourceStore();
      expect(await store.read(), isTrue);
    });

    test('turns the choice back off', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        OcrCameraSourceStore.prefKey: true,
      });
      const store = SharedPreferencesOcrCameraSourceStore();
      await store.save(false);
      expect(await store.read(), isFalse);
    });
  });

  group('InMemoryOcrCameraSourceStore', () {
    test('starts on the default and remembers what is saved', () async {
      final store = InMemoryOcrCameraSourceStore();
      expect(await store.read(), OcrCameraSourceStore.defaultUseInAppCamera);
      await store.save(true);
      expect(await store.read(), isTrue);
    });
  });
}
