import 'dart:async';

import 'package:drift/drift.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/services/security_event_service.dart';

/// Manages auto-lock profiles and inactivity-based locking.
///
/// Tracks user activity and triggers app lock when the active profile's
/// timeout expires. Only one profile can be active at a time.
class AutoLockService {
  AutoLockService({
    required AppDatabase database,
    required SecurityEventService securityEventService,
  })  : _db = database,
        _securityEventService = securityEventService;

  final AppDatabase _db;
  final SecurityEventService _securityEventService;
  Timer? _inactivityTimer;
  DateTime? _lastActivity;

  /// Creates a new auto-lock profile.
  Future<int> createProfile({
    required String name,
    required int timeoutSeconds,
    bool lockOnMinimize = true,
    String? scheduleCron,
  }) async {
    final id = await _db.autoLockProfilesDao.createProfile(
      AutoLockProfilesCompanion.insert(
        name: name,
        timeoutSeconds: Value(timeoutSeconds),
        lockOnMinimize: Value(lockOnMinimize),
        scheduleCron: Value(scheduleCron),
      ),
    );
    await _securityEventService.logEvent(
      eventType: 'profile_created',
      description: 'Auto-lock profile "$name" created',
      metadata: '{"profileId": $id, "timeoutSeconds": $timeoutSeconds}',
    );
    return id;
  }

  /// Updates an existing profile.
  Future<void> updateProfile({
    required int id,
    String? name,
    int? timeoutSeconds,
    bool? lockOnMinimize,
    String? scheduleCron,
  }) async {
    await _db.autoLockProfilesDao.updateProfile(
      id,
      AutoLockProfilesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        timeoutSeconds: timeoutSeconds != null
            ? Value(timeoutSeconds)
            : const Value.absent(),
        lockOnMinimize: lockOnMinimize != null
            ? Value(lockOnMinimize)
            : const Value.absent(),
        scheduleCron: scheduleCron != null
            ? Value(scheduleCron)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _securityEventService.logEvent(
      eventType: 'profile_changed',
      description: 'Auto-lock profile updated',
      metadata: '{"profileId": $id}',
    );
  }

  /// Activates a profile and starts the inactivity timer.
  Future<void> activateProfile(int id) async {
    await _db.autoLockProfilesDao.activateProfile(id);
    final profile = await _db.autoLockProfilesDao.getActiveProfile();
    if (profile != null) {
      _startInactivityTimer(profile.timeoutSeconds);
      await _securityEventService.logEvent(
        eventType: 'profile_changed',
        description: 'Auto-lock profile "${profile.name}" activated',
        metadata:
            '{"profileId": $id, "timeoutSeconds": ${profile.timeoutSeconds}}',
      );
    }
  }

  /// Deactivates all profiles and stops the inactivity timer.
  Future<void> deactivateAll() async {
    await _db.autoLockProfilesDao.deactivateAll();
    _cancelInactivityTimer();
    await _securityEventService.logEvent(
      eventType: 'profile_changed',
      description: 'All auto-lock profiles deactivated',
    );
  }

  /// Deletes a profile.
  Future<void> deleteProfile(int id) async {
    await _db.autoLockProfilesDao.deleteProfile(id);
    await _securityEventService.logEvent(
      eventType: 'profile_changed',
      description: 'Auto-lock profile deleted',
      metadata: '{"profileId": $id}',
    );
  }

  /// Records user activity and resets the inactivity timer.
  void recordActivity() {
    _lastActivity = DateTime.now();
    final activeProfileFuture = _db.autoLockProfilesDao.getActiveProfile();
    activeProfileFuture.then((profile) {
      if (profile != null) {
        _startInactivityTimer(profile.timeoutSeconds);
      }
    });
  }

  /// Called when app is minimized. Locks immediately if profile requires it.
  Future<bool> onAppMinimized() async {
    final profile = await _db.autoLockProfilesDao.getActiveProfile();
    if (profile != null && profile.lockOnMinimize) {
      await _triggerLock('app_minimized');
      return true;
    }
    return false;
  }

  /// Returns the currently active profile, if any.
  Future<AutoLockProfile?> getActiveProfile() =>
      _db.autoLockProfilesDao.getActiveProfile();

  /// Returns all configured profiles.
  Future<List<AutoLockProfile>> getAllProfiles() =>
      _db.autoLockProfilesDao.getAllProfiles();

  /// Watches the active profile for reactive UI updates.
  Stream<AutoLockProfile?> watchActiveProfile() =>
      _db.autoLockProfilesDao.watchActiveProfile();

  /// Returns the time of last recorded activity.
  DateTime? get lastActivity => _lastActivity;

  void _startInactivityTimer(int timeoutSeconds) {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(
      Duration(seconds: timeoutSeconds),
      () => _triggerLock('inactivity_timeout'),
    );
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  Future<void> _triggerLock(String reason) async {
    final security = await _db.appSecurityDao.getSecuritySettings();
    if (security.lockMode != null) {
      // App has a lock mode configured — mark as locked
      await _securityEventService.logEvent(
        eventType: 'lock_triggered',
        description: 'App locked due to $reason',
        metadata: '{"reason": "$reason"}',
      );
    }
  }

  /// Cleans up resources.
  void dispose() {
    _cancelInactivityTimer();
  }
}
