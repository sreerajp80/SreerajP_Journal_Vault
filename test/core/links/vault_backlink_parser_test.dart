import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlink_parser.dart';
import 'package:sreerajp_journal_vault/core/links/vault_backlinks.dart';

void main() {
  test('returns no targets for empty or null input', () {
    expect(VaultBacklinkParser.parse(null), isEmpty);
    expect(VaultBacklinkParser.parse(''), isEmpty);
    expect(VaultBacklinkParser.parse('plain text with no links'), isEmpty);
  });

  test('parses a single journal link', () {
    final targets = VaultBacklinkParser.parse('see [[journal:42]] later');
    expect(targets, hasLength(1));
    expect(targets.single.type, VaultBacklinkTargetType.journal);
    expect(targets.single.targetId, 42);
  });

  test('parses a single entry link', () {
    final targets = VaultBacklinkParser.parse('refer to [[entry:7]]');
    expect(targets.single.type, VaultBacklinkTargetType.entry);
    expect(targets.single.targetId, 7);
  });

  test('parses multiple distinct links in order of first occurrence', () {
    final targets = VaultBacklinkParser.parse(
      'A [[entry:1]] then [[journal:2]] and [[entry:3]].',
    );
    expect(targets, hasLength(3));
    expect(targets[0],
        const TypeMatcher<VaultBacklinkTarget>().having((t) => t.targetId, 'id', 1));
    expect(targets[1].targetId, 2);
    expect(targets[1].type, VaultBacklinkTargetType.journal);
    expect(targets[2].targetId, 3);
  });

  test('deduplicates repeated occurrences of the same target', () {
    final targets = VaultBacklinkParser.parse(
      '[[entry:1]] and again [[entry:1]] and [[journal:1]]',
    );
    expect(targets, hasLength(2));
    expect(
      targets.map((t) => '${t.type.name}:${t.targetId}').toList(),
      ['entry:1', 'journal:1'],
    );
  });

  test('ignores malformed link syntax', () {
    expect(VaultBacklinkParser.parse('[entry:1] not double bracket'), isEmpty);
    expect(VaultBacklinkParser.parse('[[entry:abc]]'), isEmpty);
    expect(VaultBacklinkParser.parse('[[unknown:1]]'), isEmpty);
    expect(VaultBacklinkParser.parse('[[entry:]]'), isEmpty);
  });
}
