import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/journals/services/journal_service.dart';

/// Reads and writes journals and their tags.
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(ref.watch(appDatabaseProvider));
});
