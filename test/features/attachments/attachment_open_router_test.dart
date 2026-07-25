import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_models.dart';
import 'package:sreerajp_journal_vault/features/attachments/domain/attachment_open_router.dart';

void main() {
  group('AttachmentOpenRouter', () {
    final router = AttachmentOpenRouter();

    test('routes PDF to in-app viewer', () {
      final decision = router.resolve(
        fileName: 'notes.pdf',
        mimeType: 'application/pdf',
      );
      expect(decision.kind, AttachmentOpenKind.inAppPdf);
    });

    test('routes audio by mime first', () {
      final decision = router.resolve(
        fileName: 'voice.bin',
        mimeType: 'audio/mpeg',
      );
      expect(decision.kind, AttachmentOpenKind.inAppAudio);
    });

    test('routes ZIP to in-app archive preview', () {
      final decision = router.resolve(
        fileName: 'backup.zip',
        mimeType: 'application/zip',
      );
      expect(decision.kind, AttachmentOpenKind.inAppArchive);
    });

    test('routes 7z to external-only fallback', () {
      final decision = router.resolve(
        fileName: 'bundle.7z',
        mimeType: 'application/x-7z-compressed',
      );
      expect(decision.kind, AttachmentOpenKind.externalOnly);
    });

    test('falls back to unsupported type deterministically', () {
      final decision = router.resolve(fileName: 'report.docx', mimeType: '');
      expect(decision.kind, AttachmentOpenKind.unsupported);
    });
  });
}
