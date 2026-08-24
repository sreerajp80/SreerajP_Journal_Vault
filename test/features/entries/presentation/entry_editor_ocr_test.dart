import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/image_edit_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/ocr_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/services/image_edit_service.dart';
import 'package:sreerajp_journal_vault/features/entries/services/ocr_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class _FakeImagePicker extends Fake implements ImagePicker {
  _FakeImagePicker({this.fileToReturn});

  final XFile? fileToReturn;
  ImageSource? lastSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    return fileToReturn;
  }
}

class _FakeOcrService implements OcrService {
  _FakeOcrService({this.textToReturn = '', this.shouldThrow = false});

  final String textToReturn;
  final bool shouldThrow;
  String? lastProcessedPath;

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    lastProcessedPath = imagePath;
    if (shouldThrow) {
      throw Exception('OCR extraction failed');
    }
    return textToReturn;
  }
}

/// Fake that skips the native crop UI and returns the source path unchanged.
class _FakeImageEditService implements ImageEditService {
  String? lastSourcePath;

  @override
  Future<String?> cropAndRotate({
    required String sourcePath,
    required String toolbarTitle,
    required Color toolbarColor,
    required Color toolbarWidgetColor,
    required Brightness statusBarBrightness,
    required Color activeControlColor,
  }) async {
    lastSourcePath = sourcePath;
    return sourcePath;
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    );
  }
}

void main() {
  late AppDatabase database;
  late Directory tempDir;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    tempDir = Directory.systemTemp.createTempSync('ocr_test_');
  });

  tearDown(() async {
    await database.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('OCR scan extracts text and inserts into editor document', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'OCR Test Journal'),
    );

    final dummyImageFile = File('${tempDir.path}/photo.jpg');
    dummyImageFile.writeAsStringSync('fake_image_content');

    final fakePicker = _FakeImagePicker(
      fileToReturn: XFile(dummyImageFile.path),
    );
    final fakeOcr = _FakeOcrService(
      textToReturn: 'Extracted journal note text',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ocrServiceProvider.overrideWithValue(fakeOcr),
          imageEditServiceProvider.overrideWithValue(_FakeImageEditService()),
        ],
        child: _TestApp(
          child: EntryEditorScreen(
            journalId: journalId,
            imagePicker: fakePicker,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Find and tap the OCR scan button in the toolbar
    final toolbarOcrButton = find.byKey(const Key('editor-scan-text'));
    await tester.ensureVisible(toolbarOcrButton);
    await tester.pumpAndSettle();
    expect(toolbarOcrButton, findsOneWidget);
    await tester.tap(toolbarOcrButton);
    await tester.pumpAndSettle();

    // Bottom sheet source chooser appears
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);

    // Tap "Take photo"
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(fakePicker.lastSource, ImageSource.camera);
    expect(fakeOcr.lastProcessedPath, dummyImageFile.path);

    // Verify text is now present in the Quill editor
    expect(
      find.textContaining('Extracted journal note text', findRichText: true),
      findsWidgets,
    );
  });

  testWidgets('OCR scan shows message when no text is detected', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'OCR Test Journal'),
    );

    final dummyImageFile = File('${tempDir.path}/blank.jpg');
    dummyImageFile.writeAsStringSync('blank_image');

    final fakePicker = _FakeImagePicker(
      fileToReturn: XFile(dummyImageFile.path),
    );
    final fakeOcr = _FakeOcrService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ocrServiceProvider.overrideWithValue(fakeOcr),
          imageEditServiceProvider.overrideWithValue(_FakeImageEditService()),
        ],
        child: _TestApp(
          child: EntryEditorScreen(
            journalId: journalId,
            imagePicker: fakePicker,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap bottom action bar OCR button
    final bottomOcrButton = find.byKey(const Key('entry-ocr-scan-button'));
    await tester.ensureVisible(bottomOcrButton);
    await tester.pumpAndSettle();
    expect(bottomOcrButton, findsOneWidget);
    await tester.tap(bottomOcrButton);
    await tester.pumpAndSettle();

    // Tap "Choose from gallery"
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(fakePicker.lastSource, ImageSource.gallery);
    expect(find.text('No text was detected in the image.'), findsOneWidget);
  });

  testWidgets('OCR scan handles error gracefully', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'OCR Test Journal'),
    );

    final dummyImageFile = File('${tempDir.path}/corrupt.jpg');
    dummyImageFile.writeAsStringSync('corrupt_image');

    final fakePicker = _FakeImagePicker(
      fileToReturn: XFile(dummyImageFile.path),
    );
    final fakeOcr = _FakeOcrService(shouldThrow: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ocrServiceProvider.overrideWithValue(fakeOcr),
          imageEditServiceProvider.overrideWithValue(_FakeImageEditService()),
        ],
        child: _TestApp(
          child: EntryEditorScreen(
            journalId: journalId,
            imagePicker: fakePicker,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final toolbarOcrButton = find.byKey(const Key('editor-scan-text'));
    await tester.ensureVisible(toolbarOcrButton);
    await tester.pumpAndSettle();
    await tester.tap(toolbarOcrButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to scan text from image.'), findsOneWidget);
  });
}
