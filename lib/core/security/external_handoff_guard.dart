import 'package:flutter_riverpod/flutter_riverpod.dart';

// Layer: core (security state).
//
// Some actions open a screen that belongs to Android or to another app: the
// system file picker, the camera, the gallery, the device-credential prompt,
// or another app that shows an attachment. Android then reports our app as
// paused, the same signal as pressing Home, so the lock gate would relock the
// app while the user is still working in it.
//
// Wrapping such an action in [ExternalHandoffGuard.run] marks that pause as
// expected. The lock gate still locks on any other pause, and locks on return
// if the user stayed away too long. See AppLockController.

/// Tracks hand-offs to system screens that the user started on purpose.
class ExternalHandoffGuard {
  ExternalHandoffGuard();

  /// The app-wide guard. Services that are not built through Riverpod use
  /// this directly; [externalHandoffGuardProvider] returns the same object.
  static final ExternalHandoffGuard instance = ExternalHandoffGuard();

  int _open = 0;

  /// True while at least one hand-off is in progress.
  bool get isActive => _open > 0;

  /// Runs [action], which opens a system screen, as one hand-off.
  ///
  /// The hand-off is closed in a `finally`, so an error cannot leave it open.
  Future<T> run<T>(Future<T> Function() action) async {
    _open++;
    try {
      return await action();
    } finally {
      _open--;
    }
  }
}

final externalHandoffGuardProvider = Provider<ExternalHandoffGuard>((ref) {
  return ExternalHandoffGuard.instance;
});
