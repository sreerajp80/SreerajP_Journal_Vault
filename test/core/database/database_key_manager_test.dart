import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/database_key_manager.dart';

/// Contract tests for the Keystore channel.
///
/// The platform side is Kotlin, so what can be pinned down here is the Dart
/// half of the agreement: the arguments sent, and how each answer is read. The
/// `createIfMissing` flag matters most — passing it wrongly is the difference
/// between "open the user's vault" and "quietly start an empty one".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('sreerajp.journal_vault/database_key');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final keyBytes = Uint8List.fromList(
    List<int>.generate(32, (i) => (i * 5 + 1) % 256),
  );
  late List<MethodCall> calls;

  void respondWith(Future<Object?> Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return handler(call);
    });
  }

  setUp(() => calls = <MethodCall>[]);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('asks the platform for the key and decodes it', () async {
    respondWith((_) async => base64.encode(keyBytes));

    final key = await const PlatformDatabaseKeyManager(
      channel: channel,
    ).obtainKey(createIfMissing: true);

    expect(key, isNotNull);
    expect(key!.bytes, keyBytes);
    expect(calls.single.method, 'getDatabaseKey');
    expect(calls.single.arguments, {'createIfMissing': true});
  });

  test('passes createIfMissing through untouched', () async {
    respondWith((_) async => base64.encode(keyBytes));

    await const PlatformDatabaseKeyManager(
      channel: channel,
    ).obtainKey(createIfMissing: false);

    expect(calls.single.arguments, {'createIfMissing': false});
  });

  test('returns null when the platform has no key yet', () async {
    respondWith((_) async => throw PlatformException(code: 'missing_key'));

    expect(
      await const PlatformDatabaseKeyManager(
        channel: channel,
      ).obtainKey(createIfMissing: false),
      isNull,
    );
  });

  test('returns null for an empty answer rather than a broken key', () async {
    respondWith((_) async => '');

    expect(
      await const PlatformDatabaseKeyManager(
        channel: channel,
      ).obtainKey(createIfMissing: false),
      isNull,
    );
  });

  test('reports a Keystore failure without repeating its message', () async {
    respondWith(
      (_) async => throw PlatformException(
        code: 'keystore_failure',
        message: 'a message that could quote anything',
      ),
    );

    await expectLater(
      const PlatformDatabaseKeyManager(
        channel: channel,
      ).obtainKey(createIfMissing: true),
      throwsA(
        isA<DatabaseKeyUnavailableException>()
            .having((e) => e.reasonCode, 'reasonCode', 'keystore_failure')
            .having(
              (e) => e.toString(),
              'toString',
              isNot(contains('could quote anything')),
            ),
      ),
    );
  });

  test('reports a missing platform side instead of hanging', () async {
    // No mock handler at all: this is what a non-Android host looks like.
    await expectLater(
      const PlatformDatabaseKeyManager(
        channel: channel,
      ).obtainKey(createIfMissing: true),
      throwsA(isA<DatabaseKeyUnavailableException>()),
    );
  });
}
