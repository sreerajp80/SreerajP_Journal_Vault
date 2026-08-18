/// Abstraction over the transport layer for sync operations.
///
/// Concrete implementations can target different backends (e.g. a REST API,
/// WebSocket server, peer-to-peer Bluetooth, or local file-based sync for
/// testing). The engine is agnostic to the transport.
abstract class SyncProtocol {
  /// Pushes local changes to the remote.
  ///
  /// Returns a [SyncPushResult] indicating how many records were accepted,
  /// rejected, or resulted in conflicts.
  Future<SyncPushResult> push(SyncPayload payload);

  /// Pulls remote changes since [lastSyncTimestamp].
  ///
  /// Returns a [SyncPullResult] containing the remote records and the new
  /// high-water mark timestamp.
  Future<SyncPullResult> pull(DateTime? lastSyncTimestamp, String deviceId);

  /// Checks whether the remote endpoint is reachable.
  Future<bool> isAvailable();

  /// Returns metadata about the remote (e.g. server version, device count).
  Future<SyncRemoteInfo> getRemoteInfo();
}

// ─────────────────────── Payload & Result Models ───────────────────────

/// A batch of local changes destined for the remote.
class SyncPayload {
  final String deviceId;
  final DateTime timestamp;
  final List<SyncRecord> records;
  final String encryptedChecksum;

  const SyncPayload({
    required this.deviceId,
    required this.timestamp,
    required this.records,
    required this.encryptedChecksum,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'records': records.map((r) => r.toJson()).toList(),
    'encryptedChecksum': encryptedChecksum,
  };

  factory SyncPayload.fromJson(Map<String, dynamic> json) => SyncPayload(
    deviceId: json['deviceId'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    records: (json['records'] as List)
        .map((r) => SyncRecord.fromJson(r as Map<String, dynamic>))
        .toList(),
    encryptedChecksum: json['encryptedChecksum'] as String,
  );
}

/// A single record within a sync payload.
class SyncRecord {
  final String syncId;
  final String recordTable;
  final int version;
  final String deviceId;
  final bool isDeleted;
  final DateTime lastModifiedAt;

  /// The encrypted JSON representation of the record data.
  final String encryptedData;

  const SyncRecord({
    required this.syncId,
    required this.recordTable,
    required this.version,
    required this.deviceId,
    required this.isDeleted,
    required this.lastModifiedAt,
    required this.encryptedData,
  });

  Map<String, dynamic> toJson() => {
    'syncId': syncId,
    'recordTable': recordTable,
    'version': version,
    'deviceId': deviceId,
    'isDeleted': isDeleted,
    'lastModifiedAt': lastModifiedAt.toIso8601String(),
    'encryptedData': encryptedData,
  };

  factory SyncRecord.fromJson(Map<String, dynamic> json) => SyncRecord(
    syncId: json['syncId'] as String,
    recordTable: json['recordTable'] as String,
    version: json['version'] as int,
    deviceId: json['deviceId'] as String,
    isDeleted: json['isDeleted'] as bool,
    lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
    encryptedData: json['encryptedData'] as String,
  );
}

/// Result of pushing local changes to the remote.
class SyncPushResult {
  final int accepted;
  final int rejected;
  final int conflicts;
  final List<SyncRecord> conflictRecords;

  const SyncPushResult({
    required this.accepted,
    required this.rejected,
    required this.conflicts,
    this.conflictRecords = const [],
  });
}

/// Result of pulling remote changes.
class SyncPullResult {
  final List<SyncRecord> records;
  final DateTime? newHighWaterMark;
  final bool hasMore;

  const SyncPullResult({
    required this.records,
    this.newHighWaterMark,
    this.hasMore = false,
  });
}

/// Information about the remote sync endpoint.
class SyncRemoteInfo {
  final String serverVersion;
  final int connectedDevices;
  final DateTime? lastActivity;

  const SyncRemoteInfo({
    required this.serverVersion,
    required this.connectedDevices,
    this.lastActivity,
  });
}
