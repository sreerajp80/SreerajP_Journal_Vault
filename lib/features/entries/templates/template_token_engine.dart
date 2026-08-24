import 'dart:convert';
import 'package:intl/intl.dart';

/// Information about a dynamic date token supported in entry templates.
class TemplateTokenInfo {
  const TemplateTokenInfo({
    required this.token,
    required this.label,
    required this.description,
    required this.example,
  });

  /// The token tag as written in templates, e.g. `{{today}}`.
  final String token;

  /// Short human-readable label for UI chips.
  final String label;

  /// Detailed description for tooltips and help text.
  final String description;

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
    return [
      TemplateTokenInfo(
        token: '{{today}}',
        label: 'Today',
        description: 'Standard date (YYYY-MM-DD)',
        example: DateFormat('yyyy-MM-dd', locale).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{weekday}}',
        label: 'Weekday',
        description: 'Full day of week (e.g. Monday)',
        example: DateFormat('EEEE', locale).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{date}}',
        label: 'Full Date',
        description: 'Formatted full date (e.g. August 23, 2026)',
        example: DateFormat.yMMMMd(locale).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{time}}',
        label: 'Time',
        description: 'Current time (e.g. 2:30 PM)',
        example: DateFormat.jm(locale).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{year}}',
        label: 'Year',
        description: '4-digit year (e.g. 2026)',
        example: DateFormat('yyyy', locale).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{month}}',
        label: 'Month',
        description: 'Full month name (e.g. August)',
        example: DateFormat('MMMM', locale).format(dt),
      ),
      TemplateTokenInfo(
        token: '{{day}}',
        label: 'Day',
        description: 'Day of month (1-31)',
        example: DateFormat('d', locale).format(dt),
      ),
    ];
  }

  /// Replaces all supported date and time tokens in a plain text string.
  static String resolveTokens(String input, {DateTime? now, String? locale}) {
    if (input.isEmpty || !input.contains('{{')) return input;

    final dt = now ?? DateTime.now();

    final todayStr = DateFormat('yyyy-MM-dd', locale).format(dt);
    final weekdayStr = DateFormat('EEEE', locale).format(dt);
    final dateStr = DateFormat.yMMMMd(locale).format(dt);
    final timeStr = DateFormat.jm(locale).format(dt);
    final yearStr = DateFormat('yyyy', locale).format(dt);
    final monthStr = DateFormat('MMMM', locale).format(dt);
    final dayStr = DateFormat('d', locale).format(dt);

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
