import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sreerajp_journal_vault/features/entries/services/speech_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(PluginSpeechEngine.channelName);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('listen always asks for on-device recognition', () async {
    const pluginChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');
    final listenCalls = <Map<Object?, Object?>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pluginChannel, (call) async {
          if (call.method == 'listen') {
            listenCalls.add(call.arguments as Map<Object?, Object?>);
          }
          return true;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pluginChannel, null),
    );
    final engine = PluginSpeechEngine(
      speech: stt.SpeechToText.withMethodChannel(),
    );

    await engine.initialize(onError: (_, _) {}, onStatus: (_) {});
    final started = await engine.listen(localeId: 'ml-IN', onResult: (_, _) {});

    expect(started, isTrue);
    expect(listenCalls, hasLength(1));
    expect(listenCalls.single['onDevice'], isTrue);
    expect(listenCalls.single['localeId'], 'ml-IN');
  });

  test('reads the on-device status from the platform channel', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'onDeviceSpeechStatus');
          return {
            'available': true,
            'installedLanguages': ['en-US'],
            'supportedLanguages': ['en-US', 'ml-IN'],
          };
        });

    final status = await PluginSpeechEngine().onDeviceStatus();

    expect(status.available, isTrue);
    expect(status.installedLanguages, ['en-US']);
    expect(status.supportedLanguages, ['en-US', 'ml-IN']);
  });

  test('treats a missing or failing channel as unavailable', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'boom');
        });
    expect((await PluginSpeechEngine().onDeviceStatus()).available, isFalse);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    expect((await PluginSpeechEngine().onDeviceStatus()).available, isFalse);
  });
}
