import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Thrown when an unseal attempt is made before the time capsule unlock date.
class TimeCapsuleLockedException implements Exception {
  final DateTime unlockDate;
  const TimeCapsuleLockedException(this.unlockDate);

  @override
  String toString() =>
      'TimeCapsuleLockedException: this entry is cryptographically sealed until $unlockDate.';
}

/// Thrown when device clock rollback is detected during time capsule access.
class TimeCapsuleClockTamperException implements Exception {
  final String message;
  const TimeCapsuleClockTamperException([
    this.message =
        'Device clock rollback detected. The capsule cannot be unlocked while device time is behind the recorded seal timestamp.',
  ]);

  @override
  String toString() => 'TimeCapsuleClockTamperException: $message';
}

/// Thrown when time capsule ciphertext or key data is corrupt or missing.
class TimeCapsuleCorruptedException implements Exception {
  final String message;
  const TimeCapsuleCorruptedException([
    this.message = 'Time capsule data is damaged.',
  ]);

  @override
  String toString() => 'TimeCapsuleCorruptedException: $message';
}

/// Service managing the cryptographic lifecycle of sealed time capsule entries.
///
/// Features:
/// - AES-256-GCM symmetric encryption for entry contents upon sealing.
/// - Cleartext wiping from `Entries` table (`plainText` and `contentJson` become null).
/// - Cryptographic date-gated release: decryption is refused if `now < unlockDate`.
/// - Monotonic high-water mark clock tracking to prevent rollback tampering.
/// - Unsealing and restoration of entry contents once the date arrives.
class TimeCapsuleService {
  TimeCapsuleService(this._db, {this.prefs, Random? random})
    : _random = random ?? Random.secure();

  final AppDatabase _db;
  SharedPreferences? prefs;
  final Random _random;

  final AesGcm _algorithm = AesGcm.with256bits();

  static const String _highWaterMarkKey = 'time_capsule_high_water_mark_ms';

  Future<SharedPreferences> _getPrefs() async {
    return prefs ??= await SharedPreferences.getInstance();
  }

  /// Records and updates the latest seen monotonic timestamp to prevent clock rollback.
  Future<void> recordTimestamp([DateTime? timestamp]) async {
    final nowMs = (timestamp ?? DateTime.now()).millisecondsSinceEpoch;
    try {
      final prefs = await _getPrefs();
      final currentHighWater = prefs.getInt(_highWaterMarkKey) ?? 0;
      if (nowMs > currentHighWater) {
        await prefs.setInt(_highWaterMarkKey, nowMs);
      }
    } catch (_) {}
  }

  /// Verifies that the given [now] timestamp does not violate monotonic clock integrity.
  Future<void> _verifyClockIntegrity(DateTime now, DateTime sealedAt) async {
    final nowMs = now.millisecondsSinceEpoch;
    final sealedAtMs = sealedAt.millisecondsSinceEpoch;

    // Reject if current time is strictly earlier than when it was sealed (with 60s tolerance for slight clock skew)
    if (nowMs < sealedAtMs - 60000) {
      AppLogger.warning(
        'TimeCapsule: clock rollback detected — current time is before seal timestamp',
      );
      throw const TimeCapsuleClockTamperException();
    }

    try {
      final prefs = await _getPrefs();
      final highWaterMark = prefs.getInt(_highWaterMarkKey) ?? 0;
      // If we previously observed a timestamp substantially ahead of now, the clock was wound backwards
      if (highWaterMark > 0 && nowMs < highWaterMark - 120000) {
        AppLogger.warning(
          'TimeCapsule: clock rollback detected — current time ($nowMs) is behind high-water mark ($highWaterMark)',
        );
        throw const TimeCapsuleClockTamperException();
      }

      if (nowMs > highWaterMark) {
        await prefs.setInt(_highWaterMarkKey, nowMs);
      }
    } catch (e) {
      if (e is TimeCapsuleClockTamperException) rethrow;
    }
  }

  /// Seals an existing entry into a Time Capsule until [unlockDate].
  ///
  /// Encrypts entry content, wipes cleartext from `entries`, and inserts
  /// a record in `time_capsules`.
  Future<TimeCapsule> sealEntry({
    required int entryId,
    required DateTime unlockDate,
    String? teaserMessage,
    DateTime? sealedAt,
  }) async {
    final now = sealedAt ?? DateTime.now();
    if (!unlockDate.isAfter(now)) {
      throw ArgumentError('Unlock date must be in the future.');
    }

    final entry = await _db.entriesDao.getEntryById(entryId);

    // Prepare payload dictionary
    final payloadMap = {
      'title': entry.title,
      'contentJson': entry.contentJson ?? '[]',
      'plainText': entry.plainText ?? '',
      'entryDate': entry.entryDate?.toIso8601String(),
    };
    final payloadBytes = utf8.encode(jsonEncode(payloadMap));

    // Generate dedicated 256-bit AES key
    final rawKey = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      rawKey[i] = _random.nextInt(256);
    }
    final secretKey = SecretKey(rawKey);

    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      payloadBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    final ciphertextBase64 = base64.encode(secretBox.cipherText);
    final ivBase64 = base64.encode(secretBox.nonce);
    final macBase64 = base64.encode(secretBox.mac.bytes);
    final keyBase64 = base64.encode(rawKey);

    // Save capsule record in DB
    await _db.timeCapsulesDao.createCapsule(
      TimeCapsulesCompanion.insert(
        entryId: entryId,
        unlockDate: unlockDate,
        sealedAt: Value(now),
        sealedCiphertext: ciphertextBase64,
        ivBase64: ivBase64,
        macBase64: macBase64,
        sealedKeyCiphertext: Value(keyBase64),
        teaserMessage: Value(
          teaserMessage?.trim().isEmpty ?? true ? null : teaserMessage!.trim(),
        ),
      ),
    );

    // Wipe cleartext body from the entries table so FTS5 and queries cannot read it
    await _db.entriesDao.updateEntryById(
      entryId,
      EntriesCompanion(
        contentJson: const Value(null),
        plainText: const Value(null),
        updatedAt: Value(now),
      ),
    );

    await recordTimestamp(now);

    AppLogger.info('TimeCapsule: entry $entryId sealed until $unlockDate');

    return (await _db.timeCapsulesDao.getCapsuleForEntry(entryId))!;
  }

  /// Unseals a time capsule entry, decrypting its payload and restoring cleartext to `entries`.
  ///
  /// Throws [TimeCapsuleLockedException] if `now < unlockDate`.
  /// Throws [TimeCapsuleClockTamperException] if clock rollback is detected.
  Future<Entry> unsealEntry(int entryId, {DateTime? customNow}) async {
    final capsule = await _db.timeCapsulesDao.getCapsuleForEntry(entryId);
    if (capsule == null) {
      throw const TimeCapsuleCorruptedException(
        'No time capsule found for this entry.',
      );
    }

    final now = customNow ?? DateTime.now();

    // Verify clock integrity
    await _verifyClockIntegrity(now, capsule.sealedAt);

    // If still locked, refuse to release key or decrypt
    if (now.isBefore(capsule.unlockDate)) {
      throw TimeCapsuleLockedException(capsule.unlockDate);
    }

    // Decrypt payload
    final keyBase64 = capsule.sealedKeyCiphertext;
    if (keyBase64 == null || keyBase64.isEmpty) {
      throw const TimeCapsuleCorruptedException(
        'Missing capsule decryption key.',
      );
    }

    final rawKey = base64.decode(keyBase64);
    final secretKey = SecretKey(rawKey);
    final nonce = base64.decode(capsule.ivBase64);
    final mac = Mac(base64.decode(capsule.macBase64));
    final ciphertext = base64.decode(capsule.sealedCiphertext);

    List<int> clearBytes;
    try {
      clearBytes = await _algorithm.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: mac),
        secretKey: secretKey,
      );
    } catch (_) {
      throw const TimeCapsuleCorruptedException(
        'Decryption failed. Capsule ciphertext is invalid.',
      );
    }

    final payloadJson = utf8.decode(clearBytes);
    final payloadMap = jsonDecode(payloadJson) as Map<String, dynamic>;

    final title = payloadMap['title'] as String?;
    final contentJson = payloadMap['contentJson'] as String?;
    final plainText = payloadMap['plainText'] as String?;

    // Restore to entries table
    await _db.entriesDao.updateEntryById(
      entryId,
      EntriesCompanion(
        title: Value(title),
        contentJson: Value(contentJson),
        plainText: Value(plainText),
        updatedAt: Value(now),
      ),
    );

    // Mark capsule opened
    await _db.timeCapsulesDao.markOpened(capsule.id, now);

    AppLogger.info('TimeCapsule: entry $entryId successfully unsealed.');

    return _db.entriesDao.getEntryById(entryId);
  }

  /// Gets the capsule associated with an entry, if any.
  Future<TimeCapsule?> getCapsuleForEntry(int entryId) =>
      _db.timeCapsulesDao.getCapsuleForEntry(entryId);

  /// Watches capsule for an entry.
  Stream<TimeCapsule?> watchCapsuleForEntry(int entryId) =>
      _db.timeCapsulesDao.watchCapsuleForEntry(entryId);

  /// Gets all time capsules.
  Future<List<TimeCapsule>> getAllCapsules() =>
      _db.timeCapsulesDao.getAllCapsules();

  /// Watches all time capsules.
  Stream<List<TimeCapsule>> watchAllCapsules() =>
      _db.timeCapsulesDao.watchAllCapsules();

  /// Gets capsules that have reached their unlock date but have not yet been opened.
  Future<List<TimeCapsule>> getReadyToOpenCapsules([DateTime? now]) =>
      _db.timeCapsulesDao.getReadyToOpenCapsules(now ?? DateTime.now());

  /// Calculates whether a capsule is ready to open right now.
  bool isReadyToOpen(TimeCapsule capsule, [DateTime? now]) {
    if (capsule.isOpened) return false;
    final current = now ?? DateTime.now();
    return !current.isBefore(capsule.unlockDate);
  }

  /// Returns the remaining duration until unlock, or [Duration.zero] if already reached.
  Duration timeRemaining(TimeCapsule capsule, [DateTime? now]) {
    final current = now ?? DateTime.now();
    if (!current.isBefore(capsule.unlockDate)) {
      return Duration.zero;
    }
    return capsule.unlockDate.difference(current);
  }
}
