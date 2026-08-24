import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/providers/journal_lock_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';

/// Platform Keystore-backed app PIN storage. Override in tests with an
/// in-memory fake.
final appPinKeystoreProvider = Provider<AppPinKeystore>((ref) {
  return MethodChannelAppPinKeystore();
});

final appPinServiceProvider = Provider<AppPinService>((ref) {
  return AppPinService(keystore: ref.watch(appPinKeystoreProvider));
});

/// Device-credential / biometric authenticator. Override in tests with a fake
/// that returns [BiometricAuthResult.success].
final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>((ref) {
  return LocalAuthBiometricAuthenticator();
});

/// Immutable state of the app lock subsystem.
@immutable
class AppLockState {
  const AppLockState({
    required this.bootstrapped,
    required this.mode,
    required this.isLocked,
    required this.hasPin,
  });

  /// False until the persisted lock mode and PIN state have been loaded from
  /// the database and keystore. The app gate shows a spinner while false.
  final bool bootstrapped;

  /// The active lock mode, or null if unconfigured (triggers first-launch setup).
  final AppLockMode? mode;

  /// True when the lock gate is actively shielding the app content.
  final bool isLocked;

  /// True when a PIN is configured in the keystore.
  final bool hasPin;

  AppLockState copyWith({
    bool? bootstrapped,
    AppLockMode? mode,
    bool clearMode = false,
    bool? isLocked,
    bool? hasPin,
  }) {
    return AppLockState(
      bootstrapped: bootstrapped ?? this.bootstrapped,
      mode: clearMode ? null : (mode ?? this.mode),
      isLocked: isLocked ?? this.isLocked,
      hasPin: hasPin ?? this.hasPin,
    );
  }
}

class AppLockNotifier extends Notifier<AppLockState> {
  AppLockController? _controller;
  bool _disposed = false;

  @visibleForTesting
  AppLockController? get controllerForTest => _controller;

  @override
  AppLockState build() {
    final db = ref.watch(appDatabaseProvider);
    final controller = AppLockController(database: db);
    _controller = controller;
    controller.addOnLockCallback(_onLocked);
    ref.onDispose(() {
      _disposed = true;
      controller.removeOnLockCallback(_onLocked);
      controller.dispose();
    });

    Future.microtask(_bootstrap);

    return const AppLockState(
      bootstrapped: false,
      mode: null,
      isLocked: true,
      hasPin: false,
    );
  }

  Future<void> _bootstrap() async {
    final controller = _controller;
    if (controller == null || _disposed) return;
    await controller.ready();
    bool hasPin;
    try {
      hasPin = await ref.read(appPinServiceProvider).hasPin();
    } on Exception {
      hasPin = false;
    }
    if (_disposed) return;
    state = AppLockState(
      bootstrapped: true,
      mode: controller.lockMode,
      isLocked: controller.lockMode != null && controller.isLocked,
      hasPin: hasPin,
    );
  }

  /// Unlocks via the device-credential prompt. Only succeeds if the platform
  /// authenticator returns success.
  Future<BiometricAuthResult> unlockWithBiometric() async {
    final controller = _controller;
    if (controller == null) return BiometricAuthResult.unavailable;
    final auth = ref.read(biometricAuthenticatorProvider);
    final result = await auth.authenticate(
      reason: 'Unlock SreerajP Journal Vault',
    );
    if (result == BiometricAuthResult.success) {
      await controller.unlock();
      if (!_disposed) {
        state = state.copyWith(isLocked: false);
      }
    }
    return result;
  }

  /// Verifies [pin] against the stored verifier and unlocks on match.
  Future<bool> unlockWithPin(String pin) async {
    final controller = _controller;
    if (controller == null) return false;
    final ok = await ref.read(appPinServiceProvider).verifyPin(pin);
    if (ok) {
      await controller.unlock();
      if (!_disposed) {
        state = state.copyWith(isLocked: false);
      }
    }
    return ok;
  }

  /// Persists [pin] to the keystore and updates [hasPin].
  Future<void> setPin(String pin) async {
    await ref.read(appPinServiceProvider).setPin(pin);
    if (!_disposed) {
      state = state.copyWith(hasPin: true);
    }
  }

  /// Clears the stored PIN credential.
  Future<void> clearPin() async {
    await ref.read(appPinServiceProvider).clearPin();
    if (!_disposed) {
      state = state.copyWith(hasPin: false);
    }
  }

  /// Persists [mode] and immediately locks the app. Caller is responsible for
  /// setting up a PIN before switching to [AppLockMode.appLock].
  Future<void> switchLockMode(AppLockMode mode) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.switchLockMode(mode);
    if (!_disposed) {
      state = state.copyWith(mode: mode, isLocked: true);
    }
  }

  /// Completes initial mode + credential selection on first launch and leaves
  /// the app unlocked for the current session.
  Future<void> completeFirstLaunchSetup({
    required AppLockMode mode,
    String? pin,
  }) async {
    final controller = _controller;
    if (controller == null) return;
    if (mode == AppLockMode.appLock) {
      if (pin == null || pin.isEmpty) {
        throw ArgumentError('PIN is required when selecting app_lock mode.');
      }
      await ref.read(appPinServiceProvider).setPin(pin);
    }
    await controller.switchLockMode(mode);
    await controller.unlock();
    if (!_disposed) {
      state = AppLockState(
        bootstrapped: true,
        mode: mode,
        isLocked: false,
        hasPin: mode == AppLockMode.appLock,
      );
    }
  }

  void _onLocked() {
    if (_disposed) return;
    // Clear any session-unlocked journals when the app re-locks.
    ref.read(unlockedJournalIdsProvider.notifier).set(const {});
    state = state.copyWith(isLocked: true);
  }
}

final appLockProvider = NotifierProvider<AppLockNotifier, AppLockState>(
  AppLockNotifier.new,
);
