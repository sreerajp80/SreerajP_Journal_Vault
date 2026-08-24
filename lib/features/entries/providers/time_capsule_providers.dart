import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/platform_notification_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/time_capsule_service.dart';

/// Provider for [TimeCapsuleService].
final timeCapsuleServiceProvider = Provider<TimeCapsuleService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TimeCapsuleService(db);
});

/// Provider for [PlatformNotificationService].
final platformNotificationServiceProvider =
    Provider<PlatformNotificationService>((ref) {
      return PlatformNotificationService();
    });

/// Watches the [TimeCapsule] associated with a given [entryId].
final timeCapsuleForEntryProvider = StreamProvider.autoDispose
    .family<TimeCapsule?, int>((ref, entryId) {
      final service = ref.watch(timeCapsuleServiceProvider);
      return service.watchCapsuleForEntry(entryId);
    });

/// Watches all time capsules across all journals.
final allTimeCapsulesProvider = StreamProvider.autoDispose<List<TimeCapsule>>((
  ref,
) {
  final service = ref.watch(timeCapsuleServiceProvider);
  return service.watchAllCapsules();
});

/// Watches the list of time capsules that are ready to open right now.
final readyToOpenCapsulesProvider =
    FutureProvider.autoDispose<List<TimeCapsule>>((ref) async {
      final service = ref.watch(timeCapsuleServiceProvider);
      return service.getReadyToOpenCapsules();
    });
