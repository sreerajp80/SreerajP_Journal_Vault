import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_canvas_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing/drawing_models.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _buildScreen({String? initialStrokeJson}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: DrawingCanvasScreen(initialStrokeJson: initialStrokeJson),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DrawingCanvasScreen', () {
    testWidgets('renders initial tools and UI elements', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Drawing & Sketch'), findsOneWidget);
      expect(find.byKey(const Key('drawing-save-button')), findsOneWidget);
      expect(find.text('Pen'), findsOneWidget);
      expect(find.text('Highlighter'), findsOneWidget);
      expect(find.text('Eraser'), findsOneWidget);
    });

    testWidgets('drawing a stroke enables undo and clear', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final canvasFinder = find.byType(CustomPaint).first;
      final canvasCenter = tester.getCenter(canvasFinder);

      final gesture = await tester.startGesture(canvasCenter);
      await gesture.moveBy(const Offset(50, 50));
      await gesture.moveBy(const Offset(50, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Undo button should now be clickable
      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);
    });

    testWidgets('clearing canvas with confirmation empties strokes', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final canvasFinder = find.byType(CustomPaint).first;
      final canvasCenter = tester.getCenter(canvasFinder);

      final gesture = await tester.startGesture(canvasCenter);
      await gesture.moveBy(const Offset(20, 20));
      await gesture.up();
      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Clear the entire drawing?'), findsOneWidget);
      await tester.tap(find.text('Clear canvas'));
      await tester.pumpAndSettle();

      // Clear button should be disabled again
      final clearButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
      );
      expect(clearButton.onPressed, isNull);
    });

    testWidgets('switching tools changes selected segment', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Highlighter'));
      await tester.pumpAndSettle();

      final segmentedButton = tester.widget<SegmentedButton<DrawingTool>>(
        find.byType(SegmentedButton<DrawingTool>),
      );
      expect(segmentedButton.selected, {DrawingTool.highlighter});
    });

    testWidgets('loads initial stroke JSON in edit mode', (tester) async {
      const initial = DrawingCanvasState(
        strokes: [
          DrawingStroke(
            points: [DrawingPoint(x: 10, y: 10), DrawingPoint(x: 20, y: 20)],
            color: Colors.red,
            strokeWidth: 4.0,
            tool: DrawingTool.pen,
          ),
        ],
        backgroundStyle: DrawingBackgroundStyle.ruled,
      );

      await tester.pumpWidget(
        _buildScreen(initialStrokeJson: initial.encode()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Drawing'), findsOneWidget);

      final clearButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
      );
      expect(clearButton.onPressed, isNotNull);
    });

    testWidgets('saving returns DrawingCanvasResult', (tester) async {
      DrawingCanvasResult? savedResult;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  savedResult = await Navigator.push<DrawingCanvasResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DrawingCanvasScreen(),
                    ),
                  );
                },
                child: const Text('Open Canvas'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Canvas'));
      await tester.pumpAndSettle();

      // Draw a line
      final canvasFinder = find.byType(CustomPaint).first;
      final canvasCenter = tester.getCenter(canvasFinder);
      final gesture = await tester.startGesture(canvasCenter);
      await gesture.moveBy(const Offset(30, 30));
      await gesture.up();
      await tester.pumpAndSettle();

      // Tap Save
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('drawing-save-button')));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.pngBytes, isNotEmpty);
      expect(savedResult!.strokeJson, contains('"strokes":'));
    });
  });
}
