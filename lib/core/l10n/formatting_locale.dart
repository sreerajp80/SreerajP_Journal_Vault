import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

// Layer: core (localization helpers).
//
// intl has no Sanskrit ('sa') date or number data, so DateFormat(..., 'sa')
// throws. Dates and numbers are formatted with English patterns instead, while
// the text around them stays Sanskrit. Never fall back to Hindi.
// Engineering standard §8.3.2 and §8.9.

/// The locale tag to hand to `intl` for [locale].
String formattingLocale(Locale locale) =>
    formattingLocaleTag(locale.toLanguageTag()) ?? 'en';

/// Same as [formattingLocale], for code that holds a locale tag string.
///
/// A null [tag] stays null, which means "use intl's default locale".
String? formattingLocaleTag(String? tag) {
  if (tag == null) return null;
  return DateFormat.localeExists(tag) ? tag : 'en';
}
