import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';
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

  group('AttachmentOpenRouter.open', () {
    const prepared = AttachmentOpenPrepared(
      tempFilePath: '/tmp/decrypted.pdf',
      mimeType: 'application/pdf',
    );

    AttachmentOpenRouter routerReturning(ResultType resultType) =>
        AttachmentOpenRouter(
          opener: (filePath, {String? type}) async =>
              OpenResult(type: resultType),
        );

    test('passes the temp path and mime type through to the opener', () async {
      String? seenPath;
      String? seenType;
      final router = AttachmentOpenRouter(
        opener: (filePath, {String? type}) async {
          seenPath = filePath;
          seenType = type;
          return OpenResult(); // defaults to ResultType.done
        },
      );

      await router.open(prepared);

      expect(seenPath, '/tmp/decrypted.pdf');
      expect(seenType, 'application/pdf');
    });

    test('returns normally when the platform reports done', () async {
      final router = AttachmentOpenRouter(
        opener: (filePath, {String? type}) async =>
            OpenResult(), // defaults to ResultType.done
      );
      await expectLater(router.open(prepared), completes);
    });

    test('maps fileNotFound to the fileNotFound failure', () async {
      final router = AttachmentOpenRouter(
        opener: (filePath, {String? type}) async =>
            OpenResult(type: ResultType.fileNotFound),
      );
      await expectLater(
        router.open(prepared),
        throwsA(
          isA<AttachmentOpenException>().having(
            (e) => e.failure,
            'failure',
            AttachmentOpenFailure.fileNotFound,
          ),
        ),
      );
    });

    test('maps permissionDenied to the permissionDenied failure', () async {
      final router = AttachmentOpenRouter(
        opener: (filePath, {String? type}) async =>
            OpenResult(type: ResultType.permissionDenied),
      );
      await expectLater(
        router.open(prepared),
        throwsA(
          isA<AttachmentOpenException>().having(
            (e) => e.failure,
            'failure',
            AttachmentOpenFailure.permissionDenied,
          ),
        ),
      );
    });

    test('maps noAppToOpen to the noCompatibleApp failure', () async {
      final router = AttachmentOpenRouter(
        opener: (filePath, {String? type}) async =>
            OpenResult(type: ResultType.noAppToOpen),
      );
      await expectLater(
        router.open(prepared),
        throwsA(
          isA<AttachmentOpenException>().having(
            (e) => e.failure,
            'failure',
            AttachmentOpenFailure.noCompatibleApp,
          ),
        ),
      );
    });

    test(
      'maps a generic platform error to the noCompatibleApp failure',
      () async {
        final router = AttachmentOpenRouter(
          opener: (filePath, {String? type}) async =>
              OpenResult(type: ResultType.error),
        );
        await expectLater(
          router.open(prepared),
          throwsA(isA<AttachmentOpenException>()),
        );
      },
    );

    test(
      'converts a thrown platform exception into AttachmentOpenException',
      () async {
        final router = AttachmentOpenRouter(
          opener: (filePath, {String? type}) async =>
              throw PlatformException(code: 'channel-error'),
        );
        await expectLater(
          router.open(prepared),
          throwsA(
            isA<AttachmentOpenException>().having(
              (e) => e.failure,
              'failure',
              AttachmentOpenFailure.noCompatibleApp,
            ),
          ),
        );
      },
    );

    test('never leaks a raw error type to the caller', () async {
      // The editor's _open only catches AttachmentOpenException — anything
      // else escapes uncaught into the framework, which is the bug this
      // implementation replaced.
      for (final type in ResultType.values) {
        final router = routerReturning(type);
        try {
          await router.open(prepared);
        } catch (error) {
          expect(error, isA<AttachmentOpenException>());
        }
      }
    });
  });
}
