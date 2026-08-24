import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/attachments/presentation/pdf_attachment_view.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pdf_view_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('shows missing state when file does not exist', (tester) async {
    final missingPath = '${tempDir.path}${Platform.pathSeparator}missing.pdf';

    await tester.pumpWidget(host(PdfAttachmentView(filePath: missingPath)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pdf-attachment-missing')), findsOneWidget);
    expect(find.byKey(const Key('pdf-attachment-viewer')), findsNothing);
  });

  testWidgets('renders PdfViewer when file exists', (tester) async {
    final samplePath = '${tempDir.path}${Platform.pathSeparator}sample.pdf';
    File(samplePath).writeAsBytesSync(const [0x25, 0x50, 0x44, 0x46]);

    await tester.pumpWidget(host(PdfAttachmentView(filePath: samplePath)));
    // Note: avoid pumpAndSettle if pdfrx native rendering uses timers/streams
    await tester.pump();

    expect(find.byKey(const Key('pdf-attachment-viewer')), findsOneWidget);
    expect(find.byKey(const Key('pdf-attachment-missing')), findsNothing);
  });
}
