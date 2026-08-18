import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/security/vault_payload.dart';

void main() {
  final fileBytes = Uint8List.fromList(utf8.encode('# My entry\n\nhello'));

  test('a wrapped payload comes back with its header and its bytes', () {
    final wrapped = wrapVaultPayload(
      bytes: fileBytes,
      header: VaultPayloadHeader(
        kind: vaultPayloadKindExport,
        fileName: '2026-08-18_my-entry.md',
        mimeType: 'text/markdown',
        createdAt: DateTime.utc(2026, 8, 18, 12),
      ),
    );

    final payload = unwrapVaultPayload(wrapped);

    expect(payload.header, isNotNull);
    expect(payload.header!.kind, vaultPayloadKindExport);
    expect(payload.header!.fileName, '2026-08-18_my-entry.md');
    expect(payload.header!.mimeType, 'text/markdown');
    expect(payload.header!.createdAt, DateTime.utc(2026, 8, 18, 12));
    expect(payload.bytes, fileBytes);
  });

  test('a Malayalam file name survives the round trip', () {
    final wrapped = wrapVaultPayload(
      bytes: fileBytes,
      header: const VaultPayloadHeader(
        kind: vaultPayloadKindExport,
        fileName: 'എന്റെ കുറിപ്പ്.md',
      ),
    );

    expect(unwrapVaultPayload(wrapped).header!.fileName, 'എന്റെ കുറിപ്പ്.md');
  });

  test('bytes with no header read back untouched', () {
    // This is every backup archive: a plain zip, sealed with no header.
    final payload = unwrapVaultPayload(fileBytes);

    expect(payload.header, isNull);
    expect(payload.bytes, fileBytes);
  });

  test('a header that claims more bytes than exist is ignored', () {
    final broken = Uint8List.fromList([
      ...vaultPayloadMagic,
      0xff, 0xff, // headerLen far past the end
      ...fileBytes,
    ]);

    final payload = unwrapVaultPayload(broken);

    expect(payload.header, isNull);
    expect(payload.bytes, broken);
  });

  test('a header that is not JSON is ignored', () {
    final body = utf8.encode('not json at all');
    final broken = Uint8List.fromList([
      ...vaultPayloadMagic,
      (body.length >> 8) & 0xff,
      body.length & 0xff,
      ...body,
      ...fileBytes,
    ]);

    final payload = unwrapVaultPayload(broken);

    expect(payload.header, isNull);
    expect(payload.bytes, broken);
  });
}
