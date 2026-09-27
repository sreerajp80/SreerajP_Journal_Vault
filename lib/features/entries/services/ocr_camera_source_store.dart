import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

// Layer: service. Remembers which camera the "Take photo" scan option uses.
//
// The phone's own camera app gives the better picture, and so the better text,
// but a few camera apps keep their own copy of the shot in the device gallery.
// Someone photographing something private can turn this on and keep every scan
// inside the app.
//
// The value is a single true/false flag, never journal content.

/// Where the choice of scan camera is kept.
abstract class OcrCameraSourceStore {
  /// SharedPreferences key.
  static const String prefKey = 'ocr_use_in_app_camera';

  /// The phone's own camera app is used when nothing has been saved yet.
  static const bool defaultUseInAppCamera = false;

  /// `true` when scans must use the camera built into this app.
  Future<bool> read();

  /// Saves [useInAppCamera].
  Future<void> save(bool useInAppCamera);
}

/// [OcrCameraSourceStore] backed by [SharedPreferences].
class SharedPreferencesOcrCameraSourceStore implements OcrCameraSourceStore {
  const SharedPreferencesOcrCameraSourceStore();

  @override
  Future<bool> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(OcrCameraSourceStore.prefKey);
      if (value != null) return value;
    } catch (e) {
      AppLogger.warning('OcrCameraSourceStore: read failed', error: e);
    }
    return OcrCameraSourceStore.defaultUseInAppCamera;
  }

  @override
  Future<void> save(bool useInAppCamera) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(OcrCameraSourceStore.prefKey, useInAppCamera);
    } catch (e) {
      AppLogger.warning('OcrCameraSourceStore: save failed', error: e);
    }
  }
}

/// [OcrCameraSourceStore] that forgets on restart. Used by tests.
class InMemoryOcrCameraSourceStore implements OcrCameraSourceStore {
  InMemoryOcrCameraSourceStore([
    this._useInAppCamera = OcrCameraSourceStore.defaultUseInAppCamera,
  ]);

  bool _useInAppCamera;

  @override
  Future<bool> read() async => _useInAppCamera;

  @override
  Future<void> save(bool useInAppCamera) async {
    _useInAppCamera = useInAppCamera;
  }
}
