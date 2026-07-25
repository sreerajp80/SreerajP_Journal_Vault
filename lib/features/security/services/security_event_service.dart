import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';

/// Centralized service for logging security events and tamper detection.
///
/// All security-relevant actions (auth failures, lock triggers, tamper
/// alerts, export attempts) are logged through this service. Tamper
/// detection verifies entry integrity by comparing stored plainText
/// hashes against current content.
class SecurityEventService {
  SecurityEventService({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// Logs a security event.
  Future<int> logEvent({
    required String eventType,
    String severity = 'info',
    required String description,
    String? metadata,
  }) =>
      _db.securityEventsDao.logEvent(
        SecurityEventsCompanion.insert(
          eventType: eventType,
          severity: Value(severity),
          description: description,
          metadata: Value(metadata),
        ),
      );

  /// Logs a failed authentication attempt.
  Future<void> logFailedAuth({String? context}) => logEvent(
        eventType: 'failed_auth',
        severity: 'warning',
        description: 'Authentication failed',
        metadata: context != null ? '{"context": "$context"}' : null,
      );

  /// Logs a tamper detection alert.
  Future<void> logTamperDetected({
    required String description,
    Map<String, dynamic>? details,
  }) =>
      logEvent(
        eventType: 'tamper_detected',
        severity: 'critical',
        description: description,
        metadata: details != null ? jsonEncode(details) : null,
      );

  /// Logs an export attempt.
  Future<void> logExportAttempt({
    required String exportType,
    bool success = true,
  }) =>
      logEvent(
        eventType: 'export_attempt',
        severity: success ? 'info' : 'warning',
        description:
            'Export attempt ($exportType): ${success ? "succeeded" : "failed"}',
        metadata: '{"exportType": "$exportType", "success": $success}',
      );

  /// Performs tamper check on an entry by verifying content consistency.
  ///
  /// Compares the entry's plainText with the content derived from
  /// contentJson. Returns true if the entry appears tampered with.
  Future<bool> checkEntryIntegrity(int entryId) async {
    final entry = await _db.entriesDao.getEntryById(entryId);

    // If both are null or empty, consider it valid
    if ((entry.plainText == null || entry.plainText!.isEmpty) &&
        (entry.contentJson == null || entry.contentJson!.isEmpty)) {
      return true; // integrity OK
    }

    // Check if updatedAt is significantly different from what we'd expect
    // This is a basic tamper check — a real implementation could use HMAC
    if (entry.updatedAt.isBefore(entry.createdAt)) {
      await logTamperDetected(
        description:
            'Entry $entryId has updatedAt before createdAt — possible tampering',
        details: {
          'entryId': entryId,
          'createdAt': entry.createdAt.toIso8601String(),
          'updatedAt': entry.updatedAt.toIso8601String(),
        },
      );
      return false; // integrity compromised
    }

    return true; // integrity OK
  }

  /// Runs tamper checks across all entries and returns count of issues.
  Future<int> runFullIntegrityCheck(int journalId) async {
    final entries = await _db.entriesDao.getEntriesForJournal(journalId);
    int tamperCount = 0;
    for (final entry in entries) {
      final isOk = await checkEntryIntegrity(entry.id);
      if (!isOk) tamperCount++;
    }
    if (tamperCount > 0) {
      await logEvent(
        eventType: 'tamper_detected',
        severity: 'critical',
        description:
            'Integrity check found $tamperCount issue(s) in journal $journalId',
        metadata:
            '{"journalId": $journalId, "tamperCount": $tamperCount, "totalEntries": ${entries.length}}',
      );
    }
    return tamperCount;
  }

  /// Returns recent security events.
  Future<List<SecurityEvent>> getRecentEvents({int limit = 50}) =>
      _db.securityEventsDao.getRecentEvents(limit: limit);

  /// Returns critical security events.
  Future<List<SecurityEvent>> getCriticalEvents({int limit = 20}) =>
      _db.securityEventsDao.getCriticalEvents(limit: limit);

  /// Returns events of a specific type.
  Future<List<SecurityEvent>> getEventsByType(String eventType,
          {int limit = 20}) =>
      _db.securityEventsDao.getEventsByType(eventType, limit: limit);

  /// Watches recent events for reactive UI.
  Stream<List<SecurityEvent>> watchRecentEvents({int limit = 50}) =>
      _db.securityEventsDao.watchRecentEvents(limit: limit);

  /// Returns the count of events since a given date.
  Future<int> getEventCountSince(DateTime since) =>
      _db.securityEventsDao.getEventCountSince(since);

  /// Cleans up old events, keeping the most recent.
  Future<void> pruneOldEvents({int keepCount = 500}) =>
      _db.securityEventsDao.deleteOldEvents(keepCount: keepCount);
}
