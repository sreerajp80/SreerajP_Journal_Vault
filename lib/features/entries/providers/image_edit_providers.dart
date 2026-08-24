import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';

final imageEditServiceProvider = Provider<ImageEditService>((ref) {
  return const CropperImageEditService();
});
