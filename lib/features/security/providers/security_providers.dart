import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/security/services/attachment_lock_service.dart';
import 'package:sreerajp_journal_vault/features/security/services/auto_lock_service.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';

// ──────────────── Services ────────────────

final securityEventServiceProvider = Provider<SecurityEventService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return SecurityEventService(database: db);
});

final autoLockServiceProvider = Provider<AutoLockService>((ref) {
  final db = ref.read(appDatabaseProvider);
  final securityEventService = ref.read(securityEventServiceProvider);
  final service = AutoLockService(
    database: db,
    securityEventService: securityEventService,
  );
  ref.onDispose(service.dispose);
  return service;
});

final attachmentLockServiceProvider = Provider<AttachmentLockService>((ref) {
  final db = ref.read(appDatabaseProvider);
  final securityEventService = ref.read(securityEventServiceProvider);
  return AttachmentLockService(
    database: db,
    securityEventService: securityEventService,
  );
});

// ──────────────── Auto-lock profiles ────────────────

final autoLockProfilesProvider =
    FutureProvider<List<AutoLockProfile>>((ref) async {
  final service = ref.read(autoLockServiceProvider);
  return service.getAllProfiles();
});

final activeAutoLockProfileProvider =
    StreamProvider<AutoLockProfile?>((ref) {
  final service = ref.read(autoLockServiceProvider);
  return service.watchActiveProfile();
});

// ──────────────── Security events ────────────────

final recentSecurityEventsProvider =
    StreamProvider<List<SecurityEvent>>((ref) {
  final service = ref.read(securityEventServiceProvider);
  return service.watchRecentEvents();
});

final criticalSecurityEventsProvider =
    FutureProvider<List<SecurityEvent>>((ref) async {
  final service = ref.read(securityEventServiceProvider);
  return service.getCriticalEvents();
});

final securityEventCountProvider =
    FutureProvider.family<int, DateTime>((ref, since) async {
  final service = ref.read(securityEventServiceProvider);
  return service.getEventCountSince(since);
});

// ──────────────── Attachment locks ────────────────

final attachmentLockStatusProvider =
    FutureProvider.family<bool, int>((ref, attachmentId) async {
  final service = ref.read(attachmentLockServiceProvider);
  return service.isLocked(attachmentId);
});

final lockedAttachmentsProvider =
    FutureProvider<List<AttachmentLock>>((ref) async {
  final service = ref.read(attachmentLockServiceProvider);
  return service.getLockedAttachments();
});
