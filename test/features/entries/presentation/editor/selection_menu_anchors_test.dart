import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/selection_menu_anchors.dart';

/// Covers where the selection popup menu is anchored, so it never lands on
/// top of the formatting toolbar or off-screen.
void main() {
  // Visible band: the toolbar ends at 200, the keyboard starts at 700.
  const top = 200.0;
  const bottom = 700.0;

  TextSelectionToolbarAnchors clamp(double startY, double endY) {
    return clampSelectionMenuAnchors(
      TextSelectionToolbarAnchors(
        primaryAnchor: Offset(100, startY),
        secondaryAnchor: Offset(100, endY),
      ),
      visibleTop: top,
      visibleBottom: bottom,
    );
  }

  test('a selection in the middle keeps the menu above it', () {
    final anchors = clamp(400, 420);
    expect(anchors.primaryAnchor.dy, 400);
    expect(anchors.secondaryAnchor!.dy, 420);
  });

  test('a selection just under the toolbar puts the menu below it', () {
    final anchors = clamp(top + 10, top + 30);
    expect(anchors.primaryAnchor.dy, 0);
    expect(anchors.secondaryAnchor!.dy, top + 30);
  });

  test('select all with the end off-screen keeps the menu on screen', () {
    // Start just under the toolbar, end thousands of pixels below.
    final anchors = clamp(top + 10, 9000);
    expect(anchors.primaryAnchor.dy, 0);
    expect(anchors.secondaryAnchor!.dy, top);
  });

  test('a selection that starts above the screen keeps the menu on screen', () {
    final anchors = clamp(-3000, 9000);
    expect(anchors.primaryAnchor.dy, 0);
    expect(anchors.secondaryAnchor!.dy, top);
  });

  test('a selection that starts above but ends on screen uses its end', () {
    final anchors = clamp(-3000, 500);
    expect(anchors.primaryAnchor.dy, 0);
    expect(anchors.secondaryAnchor!.dy, 500);
  });
}
