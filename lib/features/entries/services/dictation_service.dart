import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';
import 'package:sreerajp_journal_vault/features/entries/services/speech_engine.dart';

/// Where a dictation session is.
enum DictationStatus {
  /// Nothing started yet.
  idle,

  /// Checking the recogniser and the microphone permission.
  preparing,

  /// Ready to listen; the language list is known.
  ready,

  /// The microphone is open.
  listening,

  /// The user paused. The text so far is kept.
  paused,

  /// The user finished. The text can be edited and inserted.
  stopped,

  /// Dictation cannot continue. See [DictationState.error].
  error,
}

/// Why dictation stopped with [DictationStatus.error].
enum DictationError {
  /// The device has no on-device recogniser. Dictation never goes online.
  offlineUnavailable,

  /// The microphone permission was refused.
  permissionDenied,

  /// The chosen language has no offline model on this device.
  languageUnavailable,

  /// Anything else the recogniser reported.
  failed,
}

/// A snapshot of the dictation session for the UI.
class DictationState {
  const DictationState({
    this.status = DictationStatus.idle,
    this.committedText = '',
    this.partialText = '',
    this.error,
    this.languages = const [],
  });

  final DictationStatus status;

  /// Text the recogniser has finished with.
  final String committedText;

  /// The recogniser's current guess for the words still being spoken.
  final String partialText;

  final DictationError? error;

  /// Offline language tags the user can pick from. Empty means "device
  /// default" (Android 12, which does not list them).
  final List<String> languages;

  /// Everything heard so far, including the current guess.
  String get fullText => joinDictatedText(committedText, partialText);

  DictationState copyWith({
    DictationStatus? status,
    String? committedText,
    String? partialText,
    DictationError? error,
    List<String>? languages,
  }) {
    return DictationState(
      status: status ?? this.status,
      committedText: committedText ?? this.committedText,
      partialText: partialText ?? this.partialText,
      error: error ?? this.error,
      languages: languages ?? this.languages,
    );
  }
}

/// Joins two pieces of dictated text with one space between them.
String joinDictatedText(String first, String second) {
  final a = first.trim();
  final b = second.trim();
  if (a.isEmpty) return b;
  if (b.isEmpty) return a;
  return '$a $b';
}

/// Turns speech into text, on the device only.
///
/// Android ends a listening session after a short silence. This service starts
/// a new one straight away until the user pauses or finishes, so the user can
/// speak for as long as they like.
///
/// Layer: services. It never logs what was said — only statuses and error
/// codes.
class DictationService {
  DictationService(
    this._engine, {
    this.restartDelay = const Duration(milliseconds: 250),
    this.finalResultWait = const Duration(milliseconds: 1500),
  });

  final SpeechEngine _engine;

  /// Pause before a new listening session starts after the last one ended.
  final Duration restartDelay;

  /// How long [finish] waits for the last final result.
  final Duration finalResultWait;

  /// How many "busy" or client errors in a row are retried before giving up.
  static const int maxRetries = 3;

  static const Set<String> _silenceErrors = {
    'error_no_match',
    'error_speech_timeout',
  };
  static const Set<String> _retryErrors = {'error_busy', 'error_client'};
  static const Set<String> _languageErrors = {
    'error_language_not_supported',
    'error_language_unavailable',
  };

  final StreamController<DictationState> _states =
      StreamController<DictationState>.broadcast();
  DictationState _state = const DictationState();

  String? _localeId;
  int _session = 0;
  int _retries = 0;
  Timer? _restartTimer;
  Completer<void>? _onSettled;
  bool _disposed = false;

  DictationState get state => _state;
  Stream<DictationState> get states => _states.stream;

  /// Checks that offline recognition exists and the microphone may be used.
  ///
  /// Ends in [DictationStatus.ready] or [DictationStatus.error].
  Future<DictationState> prepare() async {
    _emit(const DictationState(status: DictationStatus.preparing));

    // The on-device check comes first: without it the plugin would quietly
    // use the online recogniser.
    final before = await _engine.onDeviceStatus();
    if (!before.available) {
      AppLogger.info('Dictation: on-device recognition unavailable');
      return _fail(DictationError.offlineUnavailable);
    }

    final initialised = await _engine.initialize(
      onError: _handleError,
      onStatus: _handleStatus,
    );
    if (!initialised) {
      AppLogger.info('Dictation: recogniser not initialised');
      return _fail(DictationError.permissionDenied);
    }

    // Asked again now that the permission is granted, which the language list
    // needs.
    final after = await _engine.onDeviceStatus();
    if (!after.available) return _fail(DictationError.offlineUnavailable);

    return _emit(
      _state.copyWith(
        status: DictationStatus.ready,
        languages: after.installedLanguages,
      ),
    );
  }

  /// Starts listening in [localeId] (null = device default).
  Future<void> start(String? localeId) async {
    if (_state.status != DictationStatus.ready &&
        _state.status != DictationStatus.paused &&
        _state.status != DictationStatus.stopped) {
      return;
    }
    _localeId = localeId;
    _retries = 0;
    await _listen();
  }

  /// Stops listening and keeps what was heard.
  Future<void> pause() async {
    if (_state.status != DictationStatus.listening) return;
    _restartTimer?.cancel();
    _emit(_state.copyWith(status: DictationStatus.paused));
    await _engine.stop();
  }

  /// Carries on listening after [pause].
  Future<void> resume() async {
    if (_state.status != DictationStatus.paused) return;
    _retries = 0;
    await _listen();
  }

  /// Stops listening and returns everything heard, ready to edit.
  ///
  /// Waits up to [finalResultWait] for the recogniser's final words, which are
  /// usually a little better than its last guess.
  Future<String> finish() async {
    _restartTimer?.cancel();
    if (_state.status == DictationStatus.listening) {
      _emit(_state.copyWith(status: DictationStatus.paused));
      final settled = Completer<void>();
      _onSettled = settled;
      await _engine.stop();
      if (_state.partialText.isNotEmpty && !settled.isCompleted) {
        await settled.future.timeout(finalResultWait, onTimeout: () {});
      }
      _onSettled = null;
    }
    // A new session number drops any result that arrives after this point.
    _session++;
    _emit(
      _state.copyWith(
        status: DictationStatus.stopped,
        committedText: _state.fullText,
        partialText: '',
      ),
    );
    return _state.committedText;
  }

  /// Throws away everything and closes the microphone.
  Future<void> discard() async {
    _restartTimer?.cancel();
    _session++;
    final wasListening = _state.status == DictationStatus.listening;
    _emit(
      _state.copyWith(
        status: DictationStatus.stopped,
        committedText: '',
        partialText: '',
      ),
    );
    if (wasListening) await _engine.cancel();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _restartTimer?.cancel();
    _session++;
    if (_state.status == DictationStatus.listening) await _engine.cancel();
    _disposed = true;
    await _states.close();
  }

  Future<void> _listen() async {
    final session = ++_session;
    _emit(_state.copyWith(status: DictationStatus.listening));
    final started = await _engine.listen(
      localeId: _localeId,
      onResult: (words, isFinal) => _handleResult(session, words, isFinal),
    );
    if (!started && session == _session) {
      AppLogger.warning('Dictation: listen did not start');
      _fail(DictationError.failed);
    }
  }

  void _handleResult(int session, String words, bool isFinal) {
    if (session != _session || _disposed) return;
    if (isFinal) {
      _retries = 0;
      _emit(
        _state.copyWith(
          committedText: joinDictatedText(_state.committedText, words),
          partialText: '',
        ),
      );
      _settle();
    } else {
      _emit(_state.copyWith(partialText: words));
    }
  }

  void _handleStatus(String status) {
    if (_disposed || status != 'done') return;
    // Keep a guess the recogniser never confirmed.
    if (_state.partialText.isNotEmpty) {
      _emit(_state.copyWith(committedText: _state.fullText, partialText: ''));
    }
    _settle();
    if (_state.status == DictationStatus.listening) _scheduleRestart();
  }

  void _settle() {
    final settled = _onSettled;
    if (settled != null && !settled.isCompleted) settled.complete();
  }

  void _handleError(String code, bool permanent) {
    if (_disposed) return;
    AppLogger.info('Dictation: recogniser error $code');
    _settle();
    if (_state.status != DictationStatus.listening) return;

    if (_silenceErrors.contains(code)) {
      _scheduleRestart();
    } else if (_retryErrors.contains(code) && _retries < maxRetries) {
      _retries++;
      _scheduleRestart();
    } else if (_languageErrors.contains(code)) {
      _fail(DictationError.languageUnavailable);
    } else if (code == 'error_permission') {
      _fail(DictationError.permissionDenied);
    } else {
      // Includes every network or server error. Those should never happen on
      // the on-device recogniser, and are never retried.
      _fail(DictationError.failed);
    }
  }

  void _scheduleRestart() {
    _restartTimer?.cancel();
    _restartTimer = Timer(restartDelay, () {
      if (_disposed || _state.status != DictationStatus.listening) return;
      _listen();
    });
  }

  DictationState _fail(DictationError error) {
    _restartTimer?.cancel();
    _session++;
    return _emit(
      DictationState(
        status: DictationStatus.error,
        error: error,
        committedText: _state.fullText,
        languages: _state.languages,
      ),
    );
  }

  DictationState _emit(DictationState next) {
    _state = next;
    if (!_disposed) _states.add(next);
    return next;
  }
}

/// Remembers the dictation language the user picked last.
class DictationLanguageStore {
  const DictationLanguageStore();

  /// SharedPreferences key. Value: a BCP-47 tag such as `ml-IN`.
  static const String prefKey = 'dictation_language';

  Future<String?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(prefKey);
    } catch (e) {
      AppLogger.warning('Dictation: could not read language preference');
      return null;
    }
  }

  Future<void> save(String languageTag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKey, languageTag);
    } catch (e) {
      AppLogger.warning('Dictation: could not save language preference');
    }
  }
}

/// Picks the starting language from the offline [languages].
///
/// Order: the saved choice, then one matching the app language code, then
/// English, then the first one. Returns null when the list is empty.
String? pickDictationLanguage({
  required List<String> languages,
  required String? saved,
  required String appLanguageCode,
}) {
  if (languages.isEmpty) return null;
  if (saved != null && languages.contains(saved)) return saved;
  String? byCode(String code) {
    for (final tag in languages) {
      if (tag.toLowerCase().split(RegExp('[-_]')).first == code) return tag;
    }
    return null;
  }

  return byCode(appLanguageCode) ?? byCode('en') ?? languages.first;
}
