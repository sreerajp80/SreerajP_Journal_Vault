import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/sync/services/sync_encryption_service.dart';

void main() {
  late SyncEncryptionService service;

  setUp(() {
    service = SyncEncryptionService();
  });

  group('encryptRecord / decryptRecord round-trip', () {
    test('round-trips a simple JSON map', () async {
      final salt = List<int>.generate(16, (i) => i);
      final key = await service.deriveKey('correct horse', salt);

      final original = {
        'title': 'Hello',
        'count': 42,
        'tags': ['a', 'b'],
        'nested': {'deep': true},
      };
      final encrypted = await service.encryptRecord(original, key);
      final decrypted = await service.decryptRecord(encrypted, key);

      expect(decrypted, original);
    });

    test(
      'produces different ciphertext for the same plaintext (random nonce)',
      () async {
        final salt = List<int>.generate(16, (i) => i);
        final key = await service.deriveKey('p', salt);
        final data = {'a': 1};

        final first = await service.encryptRecord(data, key);
        final second = await service.encryptRecord(data, key);

        expect(first, isNot(second));
      },
    );

    test('decryption with the wrong key fails', () async {
      final salt = List<int>.generate(16, (i) => i);
      final correctKey = await service.deriveKey('right', salt);
      final wrongKey = await service.deriveKey('wrong', salt);

      final encrypted = await service.encryptRecord({'a': 1}, correctKey);
      expect(
        () => service.decryptRecord(encrypted, wrongKey),
        throwsA(anything),
      );
    });

    test('decryption with a tampered ciphertext fails', () async {
      final salt = List<int>.generate(16, (i) => i);
      final key = await service.deriveKey('p', salt);
      final encrypted = await service.encryptRecord({'a': 1}, key);

      // Flip the last character to corrupt the ciphertext.
      final tampered = '${encrypted.substring(0, encrypted.length - 2)}AA';
      expect(() => service.decryptRecord(tampered, key), throwsA(anything));
    });
  });

  group('deriveKey determinism', () {
    test('same password + salt produce equivalent keys', () async {
      final salt = List<int>.generate(16, (i) => i);
      final keyA = await service.deriveKey('pass', salt);
      final keyB = await service.deriveKey('pass', salt);

      // Encrypt with A, decrypt with B.
      final cipher = await service.encryptRecord({'x': 1}, keyA);
      final decrypted = await service.decryptRecord(cipher, keyB);
      expect(decrypted, {'x': 1});
    });
  });

  group('computeChecksum', () {
    test('is deterministic for identical inputs', () async {
      final a = await service.computeChecksum(['x', 'y', 'z']);
      final b = await service.computeChecksum(['x', 'y', 'z']);
      expect(a, b);
    });

    test('changes when any record changes', () async {
      final a = await service.computeChecksum(['x', 'y', 'z']);
      final b = await service.computeChecksum(['x', 'y', 'Z']);
      expect(a, isNot(b));
    });

    test('is order-sensitive', () async {
      final a = await service.computeChecksum(['x', 'y']);
      final b = await service.computeChecksum(['y', 'x']);
      expect(a, isNot(b));
    });
  });
}
