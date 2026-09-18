import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Holds the three ARB files to the same shape.
///
/// Engineering standard section 8.7. This app ships English, Malayalam and
/// Sanskrit, and a key that exists in one file but not another is a screen
/// that silently falls back to English for some readers. These tests fail
/// before that reaches a device.
void main() {
  late Map<String, dynamic> en;
  late Map<String, dynamic> ml;
  late Map<String, dynamic> sa;

  Map<String, dynamic> readArb(String name) {
    final file = File('lib/l10n/$name');
    expect(file.existsSync(), isTrue, reason: '$name must exist');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  /// The message keys, without the `@key` metadata entries.
  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  setUpAll(() {
    en = readArb('app_en.arb');
    ml = readArb('app_ml.arb');
    sa = readArb('app_sa.arb');
  });

  test('every language has exactly the same keys', () {
    final enKeys = messageKeys(en);

    expect(
      messageKeys(ml).difference(enKeys),
      isEmpty,
      reason: 'app_ml.arb has keys that app_en.arb does not',
    );
    expect(
      enKeys.difference(messageKeys(ml)),
      isEmpty,
      reason: 'these keys are missing from app_ml.arb',
    );
    expect(
      messageKeys(sa).difference(enKeys),
      isEmpty,
      reason: 'app_sa.arb has keys that app_en.arb does not',
    );
    expect(
      enKeys.difference(messageKeys(sa)),
      isEmpty,
      reason: 'these keys are missing from app_sa.arb',
    );
  });

  test('every English message has an @key description', () {
    final missing = messageKeys(en).where((key) {
      final meta = en['@$key'];
      if (meta is! Map) return true;
      final description = meta['description'];
      return description is! String || description.trim().isEmpty;
    }).toList();

    expect(
      missing,
      isEmpty,
      reason: 'these keys need an @key description in app_en.arb',
    );
  });

  test('placeholders match across the three languages', () {
    // Matches a real placeholder — `{name}` or the `{name, plural,` header —
    // and nothing else. A looser pattern would also match the text inside a
    // plural branch, such as the "1" in `=1{1 file imported}`, and then a
    // translation whose branch starts with a word would look mismatched.
    final placeholder = RegExp(r'\{([a-zA-Z]\w*)\s*(?:\}|,)');

    // Compared as a sorted list: Dart's `==` on sets is identity, not
    // contents, so two equal sets would still look different.
    String namesIn(Object? value) {
      if (value is! String) return '';
      final names =
          placeholder.allMatches(value).map((m) => m.group(1)!).toSet().toList()
            ..sort();
      return names.join(',');
    }

    final mismatched = <String>[];
    for (final key in messageKeys(en)) {
      final expected = namesIn(en[key]);
      if (namesIn(ml[key]) != expected) mismatched.add('$key (ml)');
      if (namesIn(sa[key]) != expected) mismatched.add('$key (sa)');
    }

    expect(
      mismatched,
      isEmpty,
      reason: 'these translations use different placeholders than English',
    );
  });

  test('no translation is left as the English text', () {
    // Some strings are the same in every language on purpose: the app's own
    // name, unit symbols, format names, and strings that are nothing but
    // placeholders and punctuation. Everything else must be translated.
    const sameInEveryLanguage = {
      // The app's name and the language names, which are written in their own
      // script in every language.
      'titleApp',
      'labelLanguageEnglish',
      'labelLanguageMalayalam',
      'labelLanguageSanskrit',
      'labelOcrLanguageAll',
      'labelOcrLanguageEnglish',
      'labelOcrLanguageMalayalam',
      // Format and font names that are used as-is everywhere.
      'labelExportFormatMarkdown',
      'labelExportFormatPdf',
      'labelImportFormatMarkdown',
      'labelAppearanceFontFamilySans',
      // Unit symbols and counters.
      'labelBackupBytes',
      'labelBackupKilobytes',
      'labelBackupMegabytes',
      'labelStorageBytes',
      'labelStorageKilobytes',
      'labelStorageMegabytes',
      'labelStorageGigabytes',
      'labelTypographyPoints',
      'descTypographyFamilyAndSize',
      'labelTimelineDayCountOverflow',
      'labelEntryTableDimensionHelp',
      'labelLockPin',
      // Nothing but placeholders, punctuation or symbols.
      'labelInsightsStreakStat',
      'labelInsightsTag',
      'labelInsightsDateRange',
      'labelInsightsMoodOutOfFive',
      'labelInsightsYearsAgo',
      'descAutoLock',
      'descEntryStats',
      'labelEntryMood',
      'bodyCommonEllipsis',
      'bodyStorageUnknown',
      'descMigrationUnknownTotal',
      'actionEditorGotoLineStart',
      'actionEditorGotoLineEnd',
      // Format masks that show a shape, not words.
      'labelSyncPairingCodeHint',
    };

    final untranslatedMl = <String>[];
    final untranslatedSa = <String>[];
    for (final key in messageKeys(en)) {
      if (sameInEveryLanguage.contains(key)) continue;
      if (ml[key] == en[key]) untranslatedMl.add(key);
      if (sa[key] == en[key]) untranslatedSa.add(key);
    }

    expect(
      untranslatedMl,
      isEmpty,
      reason: 'these Malayalam values are still the English text',
    );
    expect(
      untranslatedSa,
      isEmpty,
      reason: 'these Sanskrit values are still the English text',
    );
  });
}
