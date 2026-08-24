import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/template_token_engine.dart';

void main() {
  final fixedDate = DateTime(2026, 8, 23, 14, 30); // 2026-08-23 Sunday 14:30

  group('TemplateTokenEngine', () {
    test('getSupportedTokens returns complete list of descriptors', () {
      final tokens = TemplateTokenEngine.getSupportedTokens(now: fixedDate);
      final tags = tokens.map((t) => t.token).toSet();
      expect(
        tags,
        containsAll({
          '{{today}}',
          '{{weekday}}',
          '{{date}}',
          '{{time}}',
          '{{year}}',
          '{{month}}',
          '{{day}}',
        }),
      );
    });

    test('resolves single and multiple tokens in string', () {
      const input = 'Journal on {{today}} ({{weekday}}): Year {{year}}';
      final resolved = TemplateTokenEngine.resolveTokens(input, now: fixedDate);
      expect(resolved, 'Journal on 2026-08-23 (Sunday): Year 2026');
    });

    test('resolves tokens case-insensitively with flexible whitespace', () {
      const input = 'Today is {{ TODAY }} and {{   WeekDay  }}';
      final resolved = TemplateTokenEngine.resolveTokens(input, now: fixedDate);
      expect(resolved, 'Today is 2026-08-23 and Sunday');
    });

    test('preserves text without tokens intact', () {
      const input = 'Plain text with no tokens.';
      final resolved = TemplateTokenEngine.resolveTokens(input, now: fixedDate);
      expect(resolved, input);
    });

    test('resolves tokens inside Quill delta JSON structure safely', () {
      final delta = [
        {'insert': 'Standup for {{today}} ({{weekday}})\n'},
        {'insert': '1. Completed yesterday\n2. Focus for {{weekday}}\n'},
      ];
      final jsonStr = jsonEncode(delta);

      final resolvedJson = TemplateTokenEngine.resolveContentJsonTokens(
        jsonStr,
        now: fixedDate,
      );
      final decoded = jsonDecode(resolvedJson) as List;

      expect(decoded.length, 2);
      expect(decoded[0]['insert'], 'Standup for 2026-08-23 (Sunday)\n');
      expect(
        decoded[1]['insert'],
        '1. Completed yesterday\n2. Focus for Sunday\n',
      );
    });

    test('falls back gracefully on non-json delta string', () {
      const plain = 'Some non-json text with {{today}}';
      final res = TemplateTokenEngine.resolveContentJsonTokens(
        plain,
        now: fixedDate,
      );
      expect(res, 'Some non-json text with 2026-08-23');
    });
  });
}
