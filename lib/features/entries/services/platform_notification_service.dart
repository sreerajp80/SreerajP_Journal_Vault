import 'package:flutter/services.dart';
import 'package:sreerajp_journal_vault/core/logging/app_logger.dart';

/// Service interfacing with platform notification facilities to notify users
/// when time capsules reach their unlock dates.
class PlatformNotificationService {
  static const MethodChannel _channel = MethodChannel(
    'sreerajp.journal_vault/notifications',
  );

  /// Triggers a local notification immediately when a capsule is unlocked.
  Future<void> showCapsuleUnlockedNotification({
    required int entryId,
    required String title,
    required String message,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'id': entryId,
        'title': title,
        'message': message,
        'channelId': 'time_capsules',
        'channelName': 'Time Capsules',
      });
    } catch (e) {
      AppLogger.warning(
        'PlatformNotificationService: showNotification failed: $e',
      );
    }
  }

  /// Cancels any pending notification for the specified capsule entry.
  Future<void> cancelCapsuleNotification({required int entryId}) async {
    try {
      await _channel.invokeMethod('cancelNotification', {'id': entryId});
    } catch (e) {
      AppLogger.warning(
        'PlatformNotificationService: cancelNotification failed: $e',
      );
    }
  }
}
