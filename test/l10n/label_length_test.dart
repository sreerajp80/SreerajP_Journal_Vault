import 'dart:convert';
import 'dart:io';

import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps menu, button, label, tab and tooltip strings short enough to fit.
///
/// Engineering standard section 8.6. A key's prefix says what it is: an
/// `action`, `label`, `title`, `tab`, `nav` or `tooltip` string sits in the
/// app's chrome and has to fit there in every language. `desc`, `help`,
/// `empty`, `error`, `body` and `aboutDetail` strings are sentences and are
/// not measured.
///
/// Length is counted in visible characters (grapheme clusters), not code
/// units: a Malayalam or Devanagari conjunct is one character to a reader even
/// though it is several code points.
void main() {
  const shortPrefixes = ['action', 'label', 'title', 'tab', 'nav', 'tooltip'];
  const limits = {'en': 20, 'ml': 22, 'sa': 22};

  /// Strings that are allowed to run long, and why.
  ///
  /// The app's own name cannot be shortened, and the feature catalogue's
  /// titles are rows of content in a scrolling list rather than chrome — they
  /// wrap, and cutting them down would lose what the feature actually is.
  const allowedToRunLong = {'titleApp', 'titleFeaturesHeader'};
  const allowedPrefixes = ['titleFeature', 'labelFeaturesCategory'];

  bool isExempt(String key) =>
      allowedToRunLong.contains(key) || allowedPrefixes.any(key.startsWith);

  /// The words a reader sees: placeholders removed, and a plural measured by
  /// its longest branch.
  String visibleText(String raw) {
    var text = raw;
    final branches = RegExp(
      r'(?:=\d+|zero|one|two|few|many|other)\s*\{([^{}]*)\}',
    ).allMatches(text).map((m) => m.group(1)!).toList();
    if (text.contains(', plural,') && branches.isNotEmpty) {
      branches.sort((a, b) => b.characters.length - a.characters.length);
      text = branches.first;
    }
    text = text.replaceAll(RegExp(r'\{[^{}]*\}'), '');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Map<String, dynamic> readArb(String lang) =>
      jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;

  for (final entry in limits.entries) {
    final lang = entry.key;
    final limit = entry.value;

    test('$lang labels fit in $limit visible characters', () {
      final arb = readArb(lang);
      final tooLong = <String>[];

      for (final key in arb.keys) {
        if (key.startsWith('@')) continue;
        if (!shortPrefixes.any(key.startsWith)) continue;
        if (isExempt(key)) continue;

        final value = arb[key];
        if (value is! String) continue;

        final visible = visibleText(value);
        final length = visible.characters.length;
        if (length > limit) {
          tooLong.add('$key [$length] $visible');
        }
      }

      expect(
        tooLong,
        isEmpty,
        reason:
            'these $lang strings are longer than $limit visible characters. '
            'Shorten them, or move the wording to a desc/body key.',
      );
    });
  }
}
