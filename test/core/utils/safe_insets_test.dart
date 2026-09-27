import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/utils/safe_insets.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/tags_help_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Height of the fake system navigation bar used in these tests.
const _navBar = 48.0;

/// Builds [home] as if the phone had a navigation bar [bottom] pixels high.
Widget _app(Widget home, {double bottom = _navBar}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: EdgeInsets.only(bottom: bottom)),
      child: child!,
    ),
    home: home,
  );
}

/// Records what [withSafeBottom] returns for [padding].
class _Probe extends StatelessWidget {
  const _Probe(this.padding, this.onResult);

  final EdgeInsets padding;
  final ValueChanged<EdgeInsets> onResult;

  @override
  Widget build(BuildContext context) {
    onResult(padding.withSafeBottom(context));
    return const SizedBox.shrink();
  }
}

void main() {
  group('withSafeBottom', () {
    testWidgets('adds the navigation bar height to the bottom only', (
      tester,
    ) async {
      EdgeInsets? result;
      await tester.pumpWidget(
        _app(
          _Probe(
            const EdgeInsets.fromLTRB(1, 2, 3, 4),
            (value) => result = value,
          ),
        ),
      );

      expect(result, const EdgeInsets.fromLTRB(1, 2, 3, 4 + _navBar));
    });

    testWidgets('adds nothing when there is no navigation bar', (tester) async {
      EdgeInsets? result;
      await tester.pumpWidget(
        _app(
          _Probe(const EdgeInsets.all(16), (value) => result = value),
          bottom: 0,
        ),
      );

      expect(result, const EdgeInsets.all(16));
    });
  });

  testWidgets('a help screen can scroll its last line clear of the bar', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const TagsHelpScreen()));
    await tester.pumpAndSettle();

    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.padding, isNotNull);
    // The screen's own 40 of end space, plus the bar.
    expect(list.padding!.resolve(TextDirection.ltr).bottom, 40 + _navBar);
  });
}
