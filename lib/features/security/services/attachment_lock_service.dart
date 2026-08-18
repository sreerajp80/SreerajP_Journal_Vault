import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';

/// Manages per-attachment locks for fine-grained access control.
///
/// When an attachment is locked, re-authentication is required to view
/// or export the decrypted content.
class AttachmentLockService {
  AttachmentLockService({
    required this._database,
    required this._securityEventService,
  });

  final AppDatabase _database;
  final SecurityEventService _securityEventService;

  /// Locks an attachment, optionally storing a credential reference.
  Future<void> lockAttachment({
    required int attachmentId,
    String? credentialReference,
  }) async {
    await _database.attachmentLocksDao.lockAttachment(
      AttachmentLocksCompanion.insert(
        attachmentId: attachmentId,
        credentialReference: Value(credentialReference),
      ),
    );
    await _securityEventService.logEvent(
      eventType: 'attachment_locked',
      description: 'Attachment locked',
      metadata: '{"attachmentId": $attachmentId}',
    );
  }

  /// Unlocks an attachment after successful authentication.
  Future<void> unlockAttachment(int attachmentId) async {
    await _database.attachmentLocksDao.unlockAttachment(attachmentId);
    await _securityEventService.logEvent(
      eventType: 'attachment_unlocked',
      description: 'Attachment unlocked',
      metadata: '{"attachmentId": $attachmentId}',
    );
  }

  /// Re-locks a previously unlocked attachment.
  Future<void> relockAttachment(int attachmentId) async {
    await _database.attachmentLocksDao.relockAttachment(attachmentId);
    await _securityEventService.logEvent(
      eventType: 'attachment_locked',
      description: 'Attachment re-locked',
      metadata: '{"attachmentId": $attachmentId}',
    );
  }

  /// Removes the lock entirely from an attachment.
  Future<void> removeLock(int attachmentId) async {
    await _database.attachmentLocksDao.removeLock(attachmentId);
    await _securityEventService.logEvent(
      eventType: 'attachment_unlocked',
      description: 'Attachment lock removed',
      metadata: '{"attachmentId": $attachmentId}',
    );
  }

  /// Checks whether an attachment is currently locked.
  Future<bool> isLocked(int attachmentId) =>
      _database.attachmentLocksDao.isAttachmentLocked(attachmentId);

  /// Returns the lock record for an attachment, if any.
  Future<AttachmentLock?> getLock(int attachmentId) =>
      _database.attachmentLocksDao.getLockForAttachment(attachmentId);

  /// Returns all currently locked attachments.
  Future<List<AttachmentLock>> getLockedAttachments() =>
      _database.attachmentLocksDao.getLockedAttachments();
}
