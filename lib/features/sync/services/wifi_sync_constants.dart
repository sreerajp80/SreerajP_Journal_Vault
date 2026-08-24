/// Protocol and security constants for peer-to-peer Wi-Fi sync.
class WifiSyncConstants {
  WifiSyncConstants._();

  /// App ID identifier to ensure payload compatibility across devices.
  static const String appId = 'in.sreerajp.sreerajp_journal_vault';

  /// Protocol version for pairing URI and wire payloads.
  static const int protocolVersion = 1;

  /// Custom URI scheme for the pairing QR code.
  static const String qrScheme = 'sreerajp-journal-vault-sync';
  static const String qrHost = 'pair';

  /// Pairing code configuration.
  /// 31 characters without ambiguous glyphs (0, O, 1, I, L).
  static const String codeAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  static const int codeLength = 16;
  static const int codeDisplayGroup = 4;

  /// Cryptographic constants.
  static const int saltLength = 16;
  static const int keyLengthBytes = 32; // AES-256
  static const int gcmNonceLength = 12;
  static const int pbkdf2Iterations = 300000;

  /// Bounded line reader caps (hostile-peer hardening).
  static const int handshakeLineCap = 8 * 1024; // 8 KB
  static const int payloadLineCap =
      150 * 1024 * 1024; // 150 MB for rich attachments

  /// Timeouts.
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration socketTimeout = Duration(seconds: 15);
  static const Duration payloadWaitTimeout = Duration(seconds: 120);

  /// Handshake wire tokens.
  static const String helloSync = 'HELLO_SYNC_V1';
  static const String acceptSync = 'ACCEPT_SYNC_V1';
  static const String denied = 'DENIED';
}
