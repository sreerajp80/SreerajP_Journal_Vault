/// Optical Air-Gap Sync (AirQR) constants and limits.
class AirqrConstants {
  AirqrConstants._();

  // --- Protocol -------------------------------------------------------------

  /// URI scheme for every frame. A foreign QR with a different scheme is
  /// rejected by the parser before anything else is read.
  static const String scheme = 'sreerajp-journal-vault-airqr';

  /// Host segment of a manifest frame (`sreerajp-journal-vault-airqr://m?...`).
  static const String hostManifest = 'm';

  /// Host segment of a data frame (`sreerajp-journal-vault-airqr://f?...`).
  static const String hostFrame = 'f';

  /// Frame format version.
  static const int protocolVersion = 1;

  // --- Frame query keys -----------------------------------------------------
  static const String keyVersion = 'v';
  static const String keyIndex = 'i';
  static const String keyTotal = 'n';
  static const String keyData = 'd';
  static const String keyKind = 'k';
  static const String keySalt = 's';
  static const String keyDigest = 'h';
  static const String keyGzip = 'z';
  static const String keyEncrypted = 'e';

  // --- Frame budget ---------------------------------------------------------
  /// Payload bytes carried by one data frame, before base64url expansion.
  static const int frameChunkBytes = 1100;
  static const int minChunkBytes = 400;
  static const int maxChunkBytes = 2200;

  /// Frame rate settings for animated QR display.
  static const int defaultFps = 5;
  static const int minFps = 2;
  static const int maxFps = 12;

  // --- Payload caps ---------------------------------------------------------
  /// Under this size a transfer starts with no warning at all.
  static const int softCapBytes = 256 * 1024; // 256 KB

  /// Above this size the user gets an estimated time and an offer to use LAN sync instead.
  static const int warnCapBytes = 1024 * 1024; // 1 MB

  /// Above this size the optical transfer is refused, directing to LAN sync.
  static const int hardCapBytes = 4 * 1024 * 1024; // 4 MB

  /// Most frames we will ever accept in one transfer.
  static const int maxFrames = 10000;

  /// Longest single scanned string we will even look at.
  static const int maxRawFrameLength = 8 * 1024;

  /// Estimated optical transfer rate in bytes per second for duration estimation.
  static const int estimatedBytesPerSecond = 12 * 1024; // ~12 KB/s

  // --- Payload Kinds --------------------------------------------------------
  static const String kindSettings = 'settings';
  static const String kindEntry = 'entry';
  static const String kindJournal = 'journal';
  static const String kindSnapshot = 'snapshot';

  // --- Session Code Alphabet ------------------------------------------------
  /// 31 characters: excludes ambiguous glyphs 0, O, 1, I, L.
  static const String codeAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  static const int codeLength = 16;
  static const int saltBytes = 16;
  static const int pbkdf2Iterations = 200000;
}
