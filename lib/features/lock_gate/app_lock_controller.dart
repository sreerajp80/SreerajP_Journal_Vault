import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/security/external_handoff_guard.dart';

/// The two mutually exclusive app-level lock modes.
enum AppLockMode {
  /// The app manages locking internally (locks on pause, requires in-app PIN/password).
  appLock,

  /// The device's own biometric or PIN is used; the app does not lock independently.
  phoneLock,
}

/// Controls the app-level lock gate.
///
/// Call [ready] after construction to load persisted state from the database.
/// When [observeLifecycle] is true the controller registers with [WidgetsBinding]
/// and relocks automatically when the app is paused.
///
/// A pause caused by a system screen the app opened itself (see
/// [ExternalHandoffGuard]) does not lock, unless the user stays away longer
/// than [handoffGracePeriod].
class AppLockController with WidgetsBindingObserver {
  AppLockController({
    required this._database,
    this._observeLifecycle = true,
    ExternalHandoffGuard? handoffGuard,
    DateTime Function()? clock,
  }) : _handoffGuard = handoffGuard ?? ExternalHandoffGuard.instance,
       _clock = clock ?? DateTime.now {
    if (_observeLifecycle) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  /// How long the user may stay on a system screen the app opened before the
  /// app locks on return.
  static const Duration handoffGracePeriod = Duration(minutes: 2);

  final AppDatabase _database;
  final bool _observeLifecycle;
  final ExternalHandoffGuard _handoffGuard;
  final DateTime Function() _clock;

  AppLockMode? _lockMode;
  bool _isLocked = false;

  /// When the app was paused during a hand-off, or null if it was not.
  DateTime? _handoffPausedAt;
  final List<void Function()> _onLockCallbacks = [];

  /// The currently active lock mode, or null if no lock is configured.
  AppLockMode? get lockMode => _lockMode;

  /// Whether the app is currently locked.
  bool get isLocked => _isLocked;

  /// Loads persisted lock state from the database.
  ///
  /// A cold launch always starts locked when a mode is configured, regardless
  /// of the persisted `isLocked` flag — that flag only governs the in-session
  /// state. This prevents an unlocked process kill from reopening as
  /// already-unlocked.
  Future<void> ready() async {
    final settings = await _database.appSecurityDao.getSecuritySettings();
    _lockMode = _parseLockMode(settings.lockMode);
    _isLocked = _lockMode != null;
  }

  /// Switches to [mode], persists the choice, and immediately locks the app.
  Future<void> switchLockMode(AppLockMode mode) async {
    _lockMode = mode;
    _isLocked = true;
    await _database.appSecurityDao.updateLockState(
      AppSecurityCompanion(
        lockMode: Value(_lockModeString(mode)),
        isLocked: const Value(true),
      ),
    );
    _notifyLock();
  }

  /// Unlocks the app and persists the new state to the database, so that a
  /// cold restart reflects the latest unlock when the app is in the
  /// foreground.
  Future<void> unlock() async {
    _isLocked = false;
    // A fresh unlock starts clean: a hand-off pause recorded before it (for
    // example the device-credential prompt itself) must not relock later.
    _handoffPausedAt = null;
    await _database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(isLocked: Value(false)),
    );
  }

  /// Locks the app, persists the new state to the database, and notifies all
  /// registered listeners. Persisting ensures a cold restart that follows a
  /// pause-induced lock still presents the lock gate.
  Future<void> lock() async {
    _isLocked = true;
    await _database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(isLocked: Value(true)),
    );
    _notifyLock();
  }

  /// Registers a callback invoked whenever the app transitions to locked.
  void addOnLockCallback(void Function() callback) {
    _onLockCallbacks.add(callback);
  }

  /// Removes a previously registered lock callback.
  void removeOnLockCallback(void Function() callback) {
    _onLockCallbacks.remove(callback);
  }

  /// Cleans up resources and removes the lifecycle observer if registered.
  void dispose() {
    if (_observeLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _onLockCallbacks.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (_handoffGuard.isActive) {
          // The app opened a system screen on purpose. Keep the first time
          // stamp if Android reports more than one pause.
          _handoffPausedAt ??= _clock();
        } else {
          _handoffPausedAt = null;
          lock();
        }
      case AppLifecycleState.resumed:
        final pausedAt = _handoffPausedAt;
        _handoffPausedAt = null;
        if (pausedAt != null &&
            _clock().difference(pausedAt) > handoffGracePeriod) {
          lock();
        }
      default:
        break;
    }
  }

  void _notifyLock() {
    for (final cb in List<void Function()>.from(_onLockCallbacks)) {
      cb();
    }
  }

  static AppLockMode? _parseLockMode(String? raw) => switch (raw) {
    'app_lock' => AppLockMode.appLock,
    'phone_lock' => AppLockMode.phoneLock,
    _ => null,
  };

  static String _lockModeString(AppLockMode mode) => switch (mode) {
    AppLockMode.appLock => 'app_lock',
    AppLockMode.phoneLock => 'phone_lock',
  };
}
