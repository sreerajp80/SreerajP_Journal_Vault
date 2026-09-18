import 'package:sreerajp_journal_vault/features/entries/services/speech_engine.dart';

/// A [SpeechEngine] the test drives by hand.
class FakeSpeechEngine implements SpeechEngine {
  FakeSpeechEngine({
    this.status = const OnDeviceSpeechStatus(
      available: true,
      installedLanguages: ['en-US', 'ml-IN'],
    ),
    this.initializeResult = true,
    this.listenResult = true,
  });

  OnDeviceSpeechStatus status;
  bool initializeResult;
  bool listenResult;

  int initializeCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  final List<String?> listenLocales = [];

  void Function(String code, bool permanent)? _onError;
  void Function(String status)? _onStatus;
  void Function(String words, bool isFinal)? _onResult;

  @override
  Future<OnDeviceSpeechStatus> onDeviceStatus() async => status;

  @override
  Future<bool> initialize({
    required void Function(String code, bool permanent) onError,
    required void Function(String status) onStatus,
  }) async {
    initializeCalls++;
    _onError = onError;
    _onStatus = onStatus;
    return initializeResult;
  }

  @override
  Future<bool> listen({
    required String? localeId,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    listenLocales.add(localeId);
    _onResult = onResult;
    return listenResult;
  }

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> cancel() async => cancelCalls++;

  void partial(String words) => _onResult?.call(words, false);
  void finalResult(String words) => _onResult?.call(words, true);
  void error(String code, {bool permanent = false}) =>
      _onError?.call(code, permanent);
  void done() => _onStatus?.call('done');
}
