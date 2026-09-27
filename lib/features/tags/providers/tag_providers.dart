import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/tags/services/tag_service.dart';

/// Renames, recolours and deletes tags, and tags entries.
final tagServiceProvider = Provider<TagService>((ref) {
  return TagService(ref.watch(appDatabaseProvider));
});
