import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fails when an icon-only control on screen has no tooltip.
///
/// Engineering standard §7.8: every `IconButton`, `FloatingActionButton` and
/// `PopupMenuButton` needs a localized tooltip. Call this from a screen's
/// widget test, in each of the three locales.
void expectAllIconButtonsHaveTooltips(WidgetTester tester) {
  for (final button in tester.widgetList<IconButton>(find.byType(IconButton))) {
    expect(
      button.tooltip != null && button.tooltip!.trim().isNotEmpty,
      isTrue,
      reason: 'IconButton with icon ${button.icon} has no tooltip',
    );
  }
  for (final fab in tester.widgetList<FloatingActionButton>(
    find.byType(FloatingActionButton),
  )) {
    expect(
      fab.tooltip?.trim().isNotEmpty ?? false,
      isTrue,
      reason: 'FloatingActionButton has no tooltip',
    );
  }
  for (final menu in tester.widgetList<PopupMenuButton<Object?>>(
    find.byWidgetPredicate((widget) => widget is PopupMenuButton),
  )) {
    expect(
      menu.tooltip?.trim().isNotEmpty ?? false,
      isTrue,
      reason: 'PopupMenuButton has no tooltip',
    );
  }
}
