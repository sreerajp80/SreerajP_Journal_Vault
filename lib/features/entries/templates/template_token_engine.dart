import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:sreerajp_journal_vault/core/l10n/formatting_locale.dart';

/// Information about a dynamic date token supported in entry templates.
///
/// It carries no words of its own. The token tag is code, the example is a
/// formatted date, and the sentence that explains the token lives in
/// `TemplateTokenText` in the presentation layer, so this engine stays free of
/// user-visible text.
class TemplateTokenInfo {
  const TemplateTokenInfo({required this.token, required this.example});

  /// The token tag as written in templates, e.g. `{{today}}`.
  final String token;

  /// Example output formatted for the current date/time.
  final String example;
}

/// Dynamic token substitution engine for entry templates.
///
/// Replaces tokens such as `{{today}}` and `{{weekday}}` with current date and
/// time values at the moment an entry is created from a template.
class TemplateTokenEngine {
  TemplateTokenEngine._();

  /// List of all supported tokens and their descriptions.
  static List<TemplateTokenInfo> getSupportedTokens({
    DateTime? now,
    String? locale,
  }) {
    final dt = now ?? DateTime.now();
    // intl has no Sanskrit data; format with English patterns instead.
    final fmt = formattingLocaleTag(locale);
    return [
      TemplateTokenInfo(
        token: '{{today}}',
        example: DateFormat('yyyy-MM-dd', fmt).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{weekday}}',
        example: DateFormat('EEEE', fmt).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{date}}',
        example: DateFormat.yMMMMd(fmt).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{time}}',
        example: DateFormat.jm(fmt).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{year}}',
        example: DateFormat('yyyy', fmt).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{month}}',
        example: DateFormat('MMMM', fmt).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{day}}',
        example: DateFormat('d', fmt).format(dt),
      ),
    ];
  }

  /// Replaces all supported date and time tokens in a plain text string.
  static String resolveTokens(String input, {DateTime? now, String? locale}) {
    if (input.isEmpty || !input.contains('{{')) return input;

    final dt = now ?? DateTime.now();
    // intl has no Sanskrit data; format with English patterns instead.
    final fmt = formattingLocaleTag(locale);

    final todayStr = DateFormat('yyyy-MM-dd', fmt).format(dt);
    final weekdayStr = DateFormat('EEEE', fmt).format(dt);
    final dateStr = DateFormat.yMMMMd(fmt).format(dt);
    final timeStr = DateFormat.jm(fmt).format(dt);
    final yearStr = DateFormat('yyyy', fmt).format(dt);
    final monthStr = DateFormat('MMMM', fmt).format(dt);
    final dayStr = DateFormat('d', fmt).format(dt);

    var result = input;
    result = result.replaceAll(
      RegExp(r'\{\{\s*today\s*\}\}', caseSensitive: false),
      todayStr,
    );
    result = result.replaceAll(
      RegExp(r'\{\{\s*weekday\s*\}\}', caseSensitive: false),
      weekdayStr,
    );
    result = result.replaceAll(
      RegExp(r'\{\{\s*date\s*\}\}', caseSensitive: false),
      dateStr,
    );
    result = result.replaceAll(
      RegExp(r'\{\{\s*time\s*\}\}', caseSensitive: false),
      timeStr,
    );
    result = result.replaceAll(
      RegExp(r'\{\{\s*year\s*\}\}', caseSensitive: false),
      yearStr,
    );
    result = result.replaceAll(
      RegExp(r'\{\{\s*month\s*\}\}', caseSensitive: false),
      monthStr,
    );
    result = result.replaceAll(
      RegExp(r'\{\{\s*day\s*\}\}', caseSensitive: false),
      dayStr,
    );

    return result;
  }

  /// Replaces tokens inside Quill Delta JSON content safely without corrupting
  /// the JSON document tree.
  static String resolveContentJsonTokens(
    String contentJson, {
    DateTime? now,
    String? locale,
  }) {
    if (contentJson.isEmpty || !contentJson.contains('{{')) return contentJson;

    try {
      final decoded = jsonDecode(contentJson);
      if (decoded is List) {
        final updatedOps = <Map<String, dynamic>>[];
        for (final op in decoded) {
          if (op is Map<String, dynamic>) {
            final copy = Map<String, dynamic>.from(op);
            final insert = copy['insert'];
            if (insert is String) {
              copy['insert'] = resolveTokens(insert, now: now, locale: locale);
            }
            updatedOps.add(copy);
          } else if (op is Map) {
            final copy = Map<String, dynamic>.from(op);
            final insert = copy['insert'];
            if (insert is String) {
              copy['insert'] = resolveTokens(insert, now: now, locale: locale);
            }
            updatedOps.add(copy);
          }
        }
        return jsonEncode(updatedOps);
      }
    } catch (_) {
      // If decoding fails, fall back to string replacement.
    }

    return resolveTokens(contentJson, now: now, locale: locale);
  }
}
