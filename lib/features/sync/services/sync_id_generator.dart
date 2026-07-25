import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

/// Generates deterministic sync IDs for records using UUID v5.
///
/// A sync ID is derived from `deviceId + tableName + localId`, ensuring the
/// same record on the same device always maps to the same UUID regardless of
/// when the ID is generated. This makes sync operations idempotent.
class SyncIdGenerator {
  static const _uuid = Uuid();

  /// The UUID v5 namespace used for all sync IDs in this app.
  /// Generated from URL namespace + 'sreerajp_journal_vault'.
  static const _namespace = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';

  /// Generates a deterministic UUID v5 for a local database record.
  ///
  /// The combination of [deviceId], [table], and [localId] guarantees
  /// uniqueness across devices while remaining stable for the same record.
  static String generate({
    required String deviceId,
    required String table,
    required int localId,
  }) {
    final input = '$deviceId:$table:$localId';
    return _uuid.v5(_namespace, input);
  }

  /// Generates a device-unique identifier.
  ///
  /// Uses a SHA-256 hash of device-specific properties to produce a
  /// stable, privacy-safe device fingerprint.
  static Future<String> generateDeviceId({
    required String androidId,
    String? buildFingerprint,
  }) async {
    final input = '$androidId:${buildFingerprint ?? 'unknown'}';
    final hash = await Sha256().hash(utf8.encode(input));
    return hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .substring(0, 32);
  }
}
