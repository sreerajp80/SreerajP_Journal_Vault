import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/editor_toolbar.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Covers the order of the formatting toolbar: undo and redo come first and
/// stay visible on a narrow phone screen without scrolling.
void main() {
  Future<void> pumpToolbar(WidgetTester tester, QuillController controller) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: EditorToolbar(
              controller: controller,
              onInsertTable: () {},
              onScanText: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('undo and redo are visible without scrolling on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await pumpToolbar(tester, controller);

    final history = find.byType(QuillToolbarHistoryButton);
    expect(history, findsNWidgets(2));
    for (final element in history.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final left = box.localToGlobal(Offset.zero).dx;
      expect(left, greaterThanOrEqualTo(0));
      expect(left + box.size.width, lessThanOrEqualTo(360));
    }

    // Undo/redo sit before every other button, and outside the scroll view.
    final undoLeft = tester.getTopLeft(history.first).dx;
    final boldLeft = tester
        .getTopLeft(find.byType(QuillToolbarToggleStyleButton).first)
        .dx;
    expect(undoLeft, lessThan(boldLeft));
    expect(
      find.ancestor(of: history.first, matching: find.byType(Scrollable)),
      findsNothing,
    );
  });

  testWidgets('focus and distraction-free toggles are not on the toolbar', (
    tester,
  ) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await pumpToolbar(tester, controller);

    expect(
      find.byKey(const Key('editor-toggle-focus-paragraph')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('editor-toggle-distraction-free')),
      findsNothing,
    );
    expect(find.byKey(const Key('editor-insert-table')), findsOneWidget);
    expect(find.byKey(const Key('editor-scan-text')), findsOneWidget);
  });
}
