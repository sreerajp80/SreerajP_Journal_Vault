import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/method_channel_journal_secret_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannel channel;
  late MethodChannelJournalSecretStore store;
  late List<MethodCall> calls;
  Object? Function(MethodCall)? handler;

  setUp(() {
    channel = const MethodChannel('sreerajp.journal_vault/journal_lock');
    store = MethodChannelJournalSecretStore(channel: channel);
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

  test(
    'createSecret returns 32 random bytes and stores them base64-encoded',
    () async {
      handler = (_) => null;

      final bytes = await store.createSecret('cred-1');

      expect(bytes, hasLength(32));
      expect(calls.single.method, 'storeJournalSecret');
      final args = calls.single.arguments as Map;
      expect(args['credentialReference'], 'cred-1');
      expect(args['secretBase64'], base64.encode(bytes));
    },
  );

  test(
    'createSecret produces independent random bytes per invocation',
    () async {
      handler = (_) => null;

      final a = await store.createSecret('cred-a');
      final b = await store.createSecret('cred-b');

      expect(a, isNot(equals(b)));
    },
  );

  test('loadSecret decodes the platform-returned base64 string', () async {
    final bytes = List<int>.generate(32, (i) => i);
    handler = (call) {
      expect(call.method, 'loadJournalSecret');
      expect((call.arguments as Map)['credentialReference'], 'cred-load');
      return base64.encode(bytes);
    };

    final loaded = await store.loadSecret('cred-load');
    expect(loaded, bytes);
  });

  test('loadSecret throws JournalSecretUnavailableException when '
      'platform reports missing_secret', () async {
    handler = (_) =>
        throw PlatformException(code: 'missing_secret', message: 'gone');

    expect(
      store.loadSecret('cred-missing'),
      throwsA(isA<JournalSecretUnavailableException>()),
    );
  });

  test('loadSecret throws JournalSecretUnavailableException when platform '
      'returns null', () async {
    handler = (_) => null;

    expect(
      store.loadSecret('cred-missing'),
      throwsA(isA<JournalSecretUnavailableException>()),
    );
  });

  test('loadSecret rethrows non-missing platform errors', () async {
    handler = (_) =>
        throw PlatformException(code: 'keystore_failure', message: 'boom');

    expect(store.loadSecret('cred-broken'), throwsA(isA<PlatformException>()));
  });

  test(
    'deleteSecret invokes deleteJournalSecret with the credential ref',
    () async {
      handler = (_) => null;

      await store.deleteSecret('cred-del');

      expect(calls.single.method, 'deleteJournalSecret');
      expect(
        (calls.single.arguments as Map)['credentialReference'],
        'cred-del',
      );
    },
  );
}
