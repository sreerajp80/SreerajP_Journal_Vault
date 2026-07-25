import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/import/services/import_service.dart';

final importServiceProvider = Provider<ImportService>((ref) {
  final db = ref.read(appDatabaseProvider);
  return ImportService(db);
});
