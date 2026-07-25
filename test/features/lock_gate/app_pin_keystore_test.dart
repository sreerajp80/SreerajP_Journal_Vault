import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannel channel;
  late MethodChannelAppPinKeystore keystore;
  late List<MethodCall> calls;
  Object? Function(MethodCall)? handler;

  setUp(() {
    channel = const MethodChannel('sreerajp.journal_vault/app_pin_lock');
    keystore = MethodChannelAppPinKeystore(channel: channel);
    calls = [];
    handler = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return handler?.call(call);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setCredential forwards salt, verifier, and iterations to the channel',
      () async {
    handler = (_) => null;

    await keystore.setCredential(
      saltBase64: 'AAAA',
      verifierBase64: 'BBBB',
      iterations: 1234,
    );

    expect(calls, hasLength(1));
    expect(calls.single.method, 'setAppPinCredential');
    expect(
      calls.single.arguments,
      <String, Object?>{
        'saltBase64': 'AAAA',
        'verifierBase64': 'BBBB',
        'iterations': 1234,
      },
    );
  });

  test('getCredential returns null when the platform reports no credential',
      () async {
    handler = (_) => null;

    expect(await keystore.getCredential(), isNull);
    expect(calls.single.method, 'getAppPinCredential');
  });

  test('getCredential parses the platform map into a payload', () async {
    handler = (_) => <String, Object?>{
          'saltBase64': 'salt',
          'verifierBase64': 'verifier',
          'iterations': 99,
        };

    final payload = await keystore.getCredential();

    expect(payload, isNotNull);
    expect(payload!.saltBase64, 'salt');
    expect(payload.verifierBase64, 'verifier');
    expect(payload.iterations, 99);
  });

  test('getCredential returns null when the platform map is malformed',
      () async {
    handler = (_) => <String, Object?>{
          'saltBase64': 'salt',
          // Missing verifierBase64 + iterations.
        };

    expect(await keystore.getCredential(), isNull);
  });

  test('clearCredential invokes clearAppPinCredential', () async {
    handler = (_) => null;

    await keystore.clearCredential();

    expect(calls.single.method, 'clearAppPinCredential');
  });

  test('platform errors propagate so callers can surface them', () async {
    handler = (_) => throw PlatformException(
          code: 'keystore_failure',
          message: 'boom',
        );

    expect(
      keystore.setCredential(
        saltBase64: 'a',
        verifierBase64: 'b',
        iterations: 1,
      ),
      throwsA(isA<PlatformException>()),
    );
  });
}
