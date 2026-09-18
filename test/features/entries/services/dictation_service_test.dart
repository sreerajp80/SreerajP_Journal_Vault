import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/services/dictation_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/speech_engine.dart';

import '../../../helpers/fake_speech_engine.dart';

void main() {
  late FakeSpeechEngine engine;
  late DictationService service;

  setUp(() {
    engine = FakeSpeechEngine();
    service = DictationService(
      engine,
      restartDelay: const Duration(milliseconds: 1),
      finalResultWait: const Duration(milliseconds: 20),
    );
  });

  tearDown(() => service.dispose());

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 10));

  group('on-device guard', () {
    test(
      'never initialises or listens when offline recognition is missing',
      () async {
        engine.status = OnDeviceSpeechStatus.unavailable;

        final state = await service.prepare();
        await service.start('en-US');

        expect(state.status, DictationStatus.error);
        expect(state.error, DictationError.offlineUnavailable);
        expect(engine.initializeCalls, 0);
        expect(engine.listenLocales, isEmpty);
      },
    );

    test('reports a refused microphone permission', () async {
      engine.initializeResult = false;

      final state = await service.prepare();

      expect(state.error, DictationError.permissionDenied);
      expect(engine.listenLocales, isEmpty);
    });

    test('network errors stop dictation and are not retried', () async {
      await service.prepare();
      await service.start('en-US');

      engine.error('error_network');
      await settle();

      expect(service.state.status, DictationStatus.error);
      expect(service.state.error, DictationError.failed);
      expect(engine.listenLocales, hasLength(1));
    });
  });

  test('prepare lists the installed offline languages', () async {
    final state = await service.prepare();

    expect(state.status, DictationStatus.ready);
    expect(state.languages, ['en-US', 'ml-IN']);
  });

  test('final results join, partial results show as a guess', () async {
    await service.prepare();
    await service.start('ml-IN');

    engine.partial('hello');
    expect(service.state.partialText, 'hello');
    engine.finalResult('hello there');
    engine.partial('how are');

    expect(service.state.committedText, 'hello there');
    expect(service.state.fullText, 'hello there how are');
    expect(engine.listenLocales, ['ml-IN']);
  });

  test('a new session starts after silence, until the user stops', () async {
    await service.prepare();
    await service.start('en-US');

    engine.finalResult('one');
    engine.done();
    await settle();
    engine.error('error_no_match');
    await settle();

    expect(engine.listenLocales, hasLength(3));
    expect(service.state.status, DictationStatus.listening);
  });

  test('pause keeps the text and does not restart', () async {
    await service.prepare();
    await service.start('en-US');
    engine.finalResult('kept');

    await service.pause();
    engine.done();
    await settle();

    expect(service.state.status, DictationStatus.paused);
    expect(service.state.committedText, 'kept');
    expect(engine.listenLocales, hasLength(1));

    await service.resume();
    expect(service.state.status, DictationStatus.listening);
    expect(engine.listenLocales, hasLength(2));
  });

  test('finish waits for the final words and returns all text', () async {
    await service.prepare();
    await service.start('en-US');
    engine.finalResult('first part');
    engine.partial('second guess');

    final finishing = service.finish();
    await Future<void>.delayed(Duration.zero);
    engine.finalResult('second part');
    final text = await finishing;

    expect(text, 'first part second part');
    expect(service.state.status, DictationStatus.stopped);
    expect(engine.stopCalls, 1);

    // A result arriving after finishing is ignored.
    engine.finalResult('late');
    expect(service.state.committedText, 'first part second part');
  });

  test('finish keeps the last guess when no final result comes', () async {
    await service.prepare();
    await service.start('en-US');
    engine.partial('only a guess');

    expect(await service.finish(), 'only a guess');
  });

  test('discard clears the text and closes the microphone', () async {
    await service.prepare();
    await service.start('en-US');
    engine.finalResult('some words');

    await service.discard();
    engine.finalResult('more');

    expect(service.state.fullText, isEmpty);
    expect(engine.cancelCalls, 1);
  });

  test('a missing language model is reported', () async {
    await service.prepare();
    await service.start('sa-IN');

    engine.error('error_language_unavailable');

    expect(service.state.error, DictationError.languageUnavailable);
  });

  test('busy errors are retried a few times, then give up', () async {
    await service.prepare();
    await service.start('en-US');

    for (var i = 0; i < DictationService.maxRetries; i++) {
      engine.error('error_busy');
      await settle();
    }
    expect(service.state.status, DictationStatus.listening);

    engine.error('error_busy');
    expect(service.state.status, DictationStatus.error);
  });

  test('a listen call that fails to start is an error', () async {
    engine.listenResult = false;
    await service.prepare();
    await service.start('en-US');

    expect(service.state.error, DictationError.failed);
  });

  test('the state stream reports progress', () async {
    final seen = <DictationStatus>[];
    final subscription = service.states.listen((s) => seen.add(s.status));
    await service.prepare();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(
      seen,
      containsAllInOrder([DictationStatus.preparing, DictationStatus.ready]),
    );
  });

  group('joinDictatedText', () {
    test('adds one space and trims', () {
      expect(joinDictatedText(' a ', ' b'), 'a b');
      expect(joinDictatedText('', 'b'), 'b');
      expect(joinDictatedText('a', ''), 'a');
    });
  });

  group('pickDictationLanguage', () {
    const languages = ['en-US', 'ml-IN', 'hi-IN'];

    test('prefers the saved choice', () {
      expect(
        pickDictationLanguage(
          languages: languages,
          saved: 'hi-IN',
          appLanguageCode: 'ml',
        ),
        'hi-IN',
      );
    });

    test('then the app language, then English', () {
      expect(
        pickDictationLanguage(
          languages: languages,
          saved: 'fr-FR',
          appLanguageCode: 'ml',
        ),
        'ml-IN',
      );
      expect(
        pickDictationLanguage(
          languages: languages,
          saved: null,
          appLanguageCode: 'sa',
        ),
        'en-US',
      );
    });

    test('returns null for an empty list', () {
      expect(
        pickDictationLanguage(
          languages: const [],
          saved: null,
          appLanguageCode: 'en',
        ),
        isNull,
      );
    });
  });
}
