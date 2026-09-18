import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/presentation/quick_capture_share_dialog.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';

class _FakeAttachmentCryptoStorage implements AttachmentCryptoStorage {
  @override
  Future<void> cleanupMigrationArtifacts({
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) async {}

  @override
  Future<void> deleteStoredFile(String encryptedPath) async {}

  @override
  Future<AttachmentTempFileHandle> decryptToTempFile({
    required String encryptedPath,
    required String nonceBase64,
    required String keyReference,
    required String fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StoredAttachmentPayload> encryptAndStore({
    required List<int> sourceBytes,
    required String sourceFileName,
  }) async {
    return StoredAttachmentPayload(
      encryptedPath: 'docs/attachments/file.enc',
      nonceBase64: 'nonce==',
      keyReference: 'android_keystore_wrapped_v1',
      sizeBytes: sourceBytes.length,
    );
  }

  @override
  bool isStoredInLocation({
    required String encryptedPath,
    required AttachmentStorageLocation location,
  }) {
    return false;
  }

  @override
  Future<String> migrateStoredFile({
    required String encryptedPath,
    required String fileName,
    required AttachmentStorageLocation targetLocation,
    String? targetTreeUri,
  }) {
    throw UnimplementedError();
  }
}

Widget _buildTestApp({
  required AppDatabase database,
  required SharedIntentPayload payload,
  required VoidCallback onDismissed,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      attachmentCryptoStorageProvider.overrideWithValue(
        _FakeAttachmentCryptoStorage(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (_) => QuickCaptureShareDialog(
                  payload: payload,
                  onDismissed: onDismissed,
                ),
              );
            },
            child: const Text('Open Quick Capture'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'My Thoughts'),
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('QuickCaptureShareDialog opens and displays pre-populated text', (
    tester,
  ) async {
    bool dismissed = false;
    const payload = SharedIntentPayload(
      type: SharedPayloadType.text,
      text: 'Remember to check out this book: Clean Architecture',
      subject: 'Book Recommendation',
    );

    await tester.pumpWidget(
      _buildTestApp(
        database: database,
        payload: payload,
        onDismissed: () => dismissed = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Quick Capture'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Capture'), findsOneWidget);
    expect(find.text('Book Recommendation'), findsOneWidget);
    expect(
      find.text('Remember to check out this book: Clean Architecture'),
      findsOneWidget,
    );

    // Save directly to journal
    await tester.tap(find.text('Save to Journal'));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);

    final journals = await database.journalsDao.getAllJournals();
    final entries = await database.entriesDao.getEntriesForJournal(
      journals.first.id,
    );
    expect(entries.length, 1);
    expect(entries.first.title, 'Book Recommendation');
    expect(entries.first.contentJson, contains('Clean Architecture'));
  });

  testWidgets('QuickCaptureShareDialog displays attachments and saves them', (
    tester,
  ) async {
    bool dismissed = false;
    final bytes = Uint8List.fromList(utf8.encode('image-bytes'));
    final payload = SharedIntentPayload(
      type: SharedPayloadType.media,
      text: 'Screenshot note',
      mediaItems: [
        SharedMediaItem(
          fileName: 'capture.png',
          mimeType: 'image/png',
          bytes: bytes,
        ),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        database: database,
        payload: payload,
        onDismissed: () => dismissed = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Quick Capture'));
    await tester.pumpAndSettle();

    expect(find.text('Attachments (1)'), findsOneWidget);
    expect(find.textContaining('capture.png'), findsOneWidget);

    await tester.tap(find.text('Save to Journal'));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
    final journals = await database.journalsDao.getAllJournals();
    final entries = await database.entriesDao.getEntriesForJournal(
      journals.first.id,
    );
    expect(entries.length, 1);
  });

  testWidgets('QuickCaptureShareDialog handles sealed files correctly', (
    tester,
  ) async {
    bool dismissed = false;
    final payload = SharedIntentPayload(
      type: SharedPayloadType.sealedFile,
      mediaItems: [
        SharedMediaItem(
          fileName: 'journal_backup.jvbk',
          mimeType: 'application/octet-stream',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        database: database,
        payload: payload,
        onDismissed: () => dismissed = true,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Quick Capture'));
    await tester.pumpAndSettle();

    expect(find.text('Encrypted file'), findsOneWidget);
    expect(find.text('journal_backup.jvbk'), findsOneWidget);
    expect(find.text('Open Encrypted File'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(dismissed, isTrue);
  });
}
