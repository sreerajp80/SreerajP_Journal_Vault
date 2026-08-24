import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  return const MlKitOcrService();
});
