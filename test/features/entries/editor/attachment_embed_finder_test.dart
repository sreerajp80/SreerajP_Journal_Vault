import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/attachment_embed_finder.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/drawing_embed.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/editor/image_embed.dart';

void main() {
  Document build() {
    final doc = Document()..insert(0, 'ab\n');
    // "ab\n" is offsets 0-2, so the first embed lands at 3.
    doc.insert(3, VaultImageEmbed.create(attachmentId: 7, fileName: 'a.jpg'));
    doc.insert(4, '\ncd\n');
    doc.insert(8, DrawingEmbed.create(attachmentId: 7, fileName: 'd.png'));
    doc.insert(9, '\n');
    doc.insert(10, VaultImageEmbed.create(attachmentId: 8, fileName: 'b.jpg'));
    return doc;
  }

  test('finds every picture and drawing of one attachment', () {
    expect(attachmentEmbedOffsets(build(), 7), [3, 8]);
    expect(attachmentEmbedOffsets(build(), 8), [10]);
  });

  test('returns nothing for an attachment with no picture', () {
    expect(attachmentEmbedOffsets(build(), 99), isEmpty);
  });

  test('removing from the end leaves the other pictures intact', () {
    final doc = build();
    for (final offset in attachmentEmbedOffsets(doc, 7).reversed) {
      doc.delete(offset, 1);
    }
    expect(attachmentEmbedOffsets(doc, 7), isEmpty);
    expect(attachmentEmbedOffsets(doc, 8), hasLength(1));
    expect(doc.toPlainText(), contains('ab'));
    expect(doc.toPlainText(), contains('cd'));
  });
}
