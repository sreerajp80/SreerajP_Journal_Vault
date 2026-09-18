import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:sreerajp_journal_vault/core/l10n/formatting_locale.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ml');
  });

  test('Sanskrit formats with English patterns, never Hindi', () {
    expect(formattingLocale(const Locale('sa')), 'en');
    expect(formattingLocaleTag('sa'), 'en');
  });

  test('languages intl knows keep their own data', () {
    expect(formattingLocale(const Locale('ml')), 'ml');
    expect(formattingLocale(const Locale('en')), 'en');
  });

  test('a null tag stays null, meaning intl default', () {
    expect(formattingLocaleTag(null), isNull);
  });

  test('DateFormat does not throw for the Sanskrit fallback', () {
    final date = DateTime(2026, 9, 15);
    expect(
      DateFormat.yMMMMd(formattingLocale(const Locale('sa'))).format(date),
      'September 15, 2026',
    );
  });
}
