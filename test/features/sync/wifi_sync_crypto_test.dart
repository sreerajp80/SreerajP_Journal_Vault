import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_constants.dart';
import 'package:sreerajp_journal_vault/features/sync/services/wifi_sync_crypto.dart';

void main() {
  group('WifiSyncCrypto', () {
    test('generatePairingCode generates valid 16-character code', () {
      final code = WifiSyncCrypto.generatePairingCode();
      expect(code.length, WifiSyncConstants.codeLength);
      expect(WifiSyncCrypto.isValidCode(code), isTrue);

      // Verify no ambiguous glyphs (0, O, 1, I, L)
      expect(code.contains('0'), isFalse);
      expect(code.contains('O'), isFalse);
      expect(code.contains('1'), isFalse);
      expect(code.contains('I'), isFalse);
      expect(code.contains('L'), isFalse);
    });

    test('normalizeCode and formatCode round-trip correctly', () {
      const original = '23456789ABCDEFGH';
      final formatted = WifiSyncCrypto.formatCode(original);
      expect(formatted, '2345-6789-ABCD-EFGH');
      expect(WifiSyncCrypto.normalizeCode(formatted), original);
      expect(
        WifiSyncCrypto.normalizeCode(' 2345 - 6789 - abcd - efgh \n'),
        original,
      );
    });

    test('buildQrUri and parseQrUri codec', () {
      const pairing = QrPairing(
        host: '192.168.1.10',
        port: 54321,
        code: '23456789ABCDEFGH',
      );

      final uri = WifiSyncCrypto.buildQrUri(pairing);
      expect(uri, contains('sreerajp-journal-vault-sync://pair'));
      expect(uri, contains('192.168.1.10'));
      expect(uri, contains('54321'));

      final parsed = WifiSyncCrypto.parseQrUri(uri);
      expect(parsed.isOk, isTrue);
      expect(parsed.pairing?.host, '192.168.1.10');
      expect(parsed.pairing?.port, 54321);
      expect(parsed.pairing?.code, '23456789ABCDEFGH');
    });

    test('parseQrUri rejects foreign or malformed URI gracefully', () {
      expect(WifiSyncCrypto.parseQrUri('https://google.com').isOk, isFalse);
      expect(
        WifiSyncCrypto.parseQrUri(
          'sreerajp-journal-vault-sync://pair?v=99&h=1.1.1.1&p=80&c=AAAA',
        ).isOk,
        isFalse,
      );
      expect(
        WifiSyncCrypto.parseQrUri(
          'sreerajp-journal-vault-sync://pair?v=1&h=1.1.1.1&p=999999&c=AAAA',
        ).isOk,
        isFalse,
      );
    });

    test('encryptWire and decryptWire round-trip with correct key', () async {
      final salt = WifiSyncCrypto.randomBytes(16);
      const code = '23456789ABCDEFGH';
      final key = await WifiSyncCrypto.deriveKey(code, salt);

      const plaintext = 'Secret journal payload with unicode: മലയാളം 🚀';
      final wire = await WifiSyncCrypto.encryptWire(key, plaintext);

      expect(wire.isNotEmpty, isTrue);

      final decrypted = await WifiSyncCrypto.decryptWire(key, wire);
      expect(decrypted, plaintext);
    });

    test('decryptWire fails when wrong key or wrong code is used', () async {
      final salt = WifiSyncCrypto.randomBytes(16);
      final keyA = await WifiSyncCrypto.deriveKey('23456789ABCDEFGH', salt);
      final keyB = await WifiSyncCrypto.deriveKey('JKMNPQRSTUVWXYZ2', salt);

      final wire = await WifiSyncCrypto.encryptWire(keyA, 'hello secure data');

      expect(
        () => WifiSyncCrypto.decryptWire(keyB, wire),
        throwsA(isA<WifiSyncCryptoException>()),
      );
    });
  });
}
