import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// What the device's on-device speech recogniser can do.
class OnDeviceSpeechStatus {
  const OnDeviceSpeechStatus({
    required this.available,
    this.installedLanguages = const [],
    this.supportedLanguages = const [],
  });

  /// True only when speech can be recognised without a network.
  final bool available;

  /// BCP-47 tags (for example `en-US`, `ml-IN`) whose offline models are
  /// already on the device. Empty on Android 12 and older, where the platform
  /// does not report them.
  final List<String> installedLanguages;

  /// Tags the recogniser could handle offline once a model is downloaded.
  final List<String> supportedLanguages;

  static const OnDeviceSpeechStatus unavailable = OnDeviceSpeechStatus(
    available: false,
  );
}

/// The speech recogniser, as the dictation service sees it.
///
/// Exists so [DictationService] can be tested with a fake. Implementations
/// must recognise speech on the device only.
abstract class SpeechEngine {
  /// Asks the platform whether on-device recognition is available.
  Future<OnDeviceSpeechStatus> onDeviceStatus();

  /// Prepares the recogniser, asking for the microphone permission if needed.
  ///
  /// Returns false when the permission is refused or no recogniser exists.
  /// [onError] receives the platform error code (for example `error_no_match`)
  /// and whether the error is permanent. [onStatus] receives `listening`,
  /// `notListening` or `done`.
  Future<bool> initialize({
    required void Function(String code, bool permanent) onError,
    required void Function(String status) onStatus,
  });

  /// Starts one listening session in [localeId] (null = device default).
  ///
  /// [onResult] gets the recognised words and whether they are final.
  Future<bool> listen({
    required String? localeId,
    required void Function(String words, bool isFinal) onResult,
  });

  /// Ends the session and delivers a final result.
  Future<void> stop();

  /// Ends the session and drops any result.
  Future<void> cancel();
}

/// [SpeechEngine] backed by the `speech_to_text` plugin plus the app's own
/// on-device check in `MainActivity`.
///
/// [listen] always asks for on-device recognition. The plugin falls back to
/// the online recogniser when on-device recognition is missing, so callers
/// must check [onDeviceStatus] first — [DictationService] does.
class PluginSpeechEngine implements SpeechEngine {
  PluginSpeechEngine({stt.SpeechToText? speech, MethodChannel? channel})
    : _speech = speech ?? stt.SpeechToText(),
      _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'sreerajp.journal_vault/speech';

  final stt.SpeechToText _speech;
  final MethodChannel _channel;

  // The plugin keeps the listeners from its first initialize call only, so
  // they forward to whatever the latest caller registered.
  void Function(String code, bool permanent)? _onError;
  void Function(String status)? _onStatus;

  @override
  Future<OnDeviceSpeechStatus> onDeviceStatus() async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(
        'onDeviceSpeechStatus',
      );
      if (raw == null) return OnDeviceSpeechStatus.unavailable;
      List<String> tags(Object? value) =>
          (value as List<Object?>? ?? const []).whereType<String>().toList();
      return OnDeviceSpeechStatus(
        available: raw['available'] == true,
        installedLanguages: tags(raw['installedLanguages']),
        supportedLanguages: tags(raw['supportedLanguages']),
      );
    } on PlatformException {
      return OnDeviceSpeechStatus.unavailable;
    } on MissingPluginException {
      return OnDeviceSpeechStatus.unavailable;
    }
  }

  @override
  Future<bool> initialize({
    required void Function(String code, bool permanent) onError,
    required void Function(String status) onStatus,
  }) async {
    _onError = onError;
    _onStatus = onStatus;
    try {
      return await _speech.initialize(
        onError: (error) => _onError?.call(error.errorMsg, error.permanent),
        onStatus: (status) => _onStatus?.call(status),
      );
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> listen({
    required String? localeId,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    try {
      await _speech.listen(
        onResult: (result) =>
            onResult(result.recognizedWords, result.finalResult),
        listenOptions: stt.SpeechListenOptions(
          onDevice: true,
          localeId: localeId,
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 5),
        ),
      );
      return true;
    } on PlatformException {
      return false;
    } on stt.SpeechToTextNotInitializedException {
      return false;
    } on stt.ListenFailedException {
      return false;
    } on stt.ListenNotStartedException {
      return false;
    }
  }

  @override
  Future<void> stop() => _speech.stop();

  @override
  Future<void> cancel() => _speech.cancel();
}
