import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryAppPinKeystore keystore;
  late AppPinService service;

  setUp(() {
    keystore = _InMemoryAppPinKeystore();
    service = AppPinService(keystore: keystore);
  });

  test('hasPin is false before any PIN is set', () async {
    expect(await service.hasPin(), isFalse);
  });

  test('setPin stores derived salt + verifier and never the raw PIN',
      () async {
    await service.setPin('1234');

    final stored = keystore.lastStored!;
    expect(stored.saltBase64, isNot(contains('1234')));
    expect(stored.verifierBase64, isNot(contains('1234')));
    expect(stored.iterations, greaterThanOrEqualTo(50000));
    expect(await service.hasPin(), isTrue);
  });

  test('verifyPin returns true for the original PIN', () async {
    await service.setPin('correct-horse');
    expect(await service.verifyPin('correct-horse'), isTrue);
  });

  test('verifyPin returns false for a wrong PIN', () async {
    await service.setPin('correct-horse');
    expect(await service.verifyPin('battery-staple'), isFalse);
  });

  test('verifyPin returns false when no credential is stored', () async {
    expect(await service.verifyPin('anything'), isFalse);
  });

  test('clearPin removes the stored credential', () async {
    await service.setPin('1234');
    await service.clearPin();
    expect(await service.hasPin(), isFalse);
    expect(await service.verifyPin('1234'), isFalse);
  });

  test('setPin twice rotates the verifier so the old PIN no longer works',
      () async {
    await service.setPin('first');
    await service.setPin('second');
    expect(await service.verifyPin('first'), isFalse);
    expect(await service.verifyPin('second'), isTrue);
  });

  test('setPin rejects an empty PIN', () async {
    expect(() => service.setPin(''), throwsArgumentError);
  });

  test('two services backed by the same keystore agree on verification',
      () async {
    await service.setPin('shared');

    final reopened = AppPinService(keystore: keystore);
    expect(await reopened.verifyPin('shared'), isTrue);
    expect(await reopened.verifyPin('wrong'), isFalse);
  });
}

class _InMemoryAppPinKeystore implements AppPinKeystore {
  AppPinCredentialPayload? lastStored;

  @override
  Future<AppPinCredentialPayload?> getCredential() async => lastStored;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    lastStored = AppPinCredentialPayload(
      saltBase64: saltBase64,
      verifierBase64: verifierBase64,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    lastStored = null;
  }
}
