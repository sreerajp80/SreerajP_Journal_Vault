import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/tags/domain/tag_colors.dart';

Tag makeTag(String name, {int? colorArgb}) => Tag(
  id: 1,
  name: name,
  colorArgb: colorArgb,
  createdAt: DateTime(2026, 8, 16),
  updatedAt: DateTime(2026, 8, 16),
);

void main() {
  group('colorForTag', () {
    test('uses the stored colour when there is one', () {
      final tag = makeTag('work', colorArgb: 0xFF123456);

      expect(colorForTag(tag), const Color(0xFF123456));
    });

    test('falls back to a palette colour when none is stored', () {
      final tag = makeTag('work');

      expect(kTagPalette, contains(colorForTag(tag)));
    });

    test('gives the same tag name the same colour every time', () {
      expect(colorForTag(makeTag('holiday')), colorForTag(makeTag('holiday')));
    });

    test('is not affected by case or surrounding spaces', () {
      expect(colorForTag(makeTag('  Work ')), colorForTag(makeTag('work')));
    });

    test('spreads different names across the palette', () {
      const names = [
        'work',
        'health',
        'travel',
        'family',
        'money',
        'reading',
        'ideas',
        'garden',
      ];

      final used = names.map((n) => colorForTag(makeTag(n))).toSet();

      // Collisions are allowed — the palette is smaller than the name space —
      // but a hash that lumps everything onto one colour would defeat the
      // point of colouring tags at all.
      expect(used.length, greaterThan(1));
    });

    test('handles an empty name without throwing', () {
      expect(colorForTag(makeTag('   ')), kTagPalette.first);
    });
  });

  group('hasCustomColor', () {
    test('is false for an automatic colour', () {
      expect(hasCustomColor(makeTag('work')), isFalse);
    });

    test('is true once a colour is stored', () {
      expect(hasCustomColor(makeTag('work', colorArgb: 0xFF123456)), isTrue);
    });
  });
}
