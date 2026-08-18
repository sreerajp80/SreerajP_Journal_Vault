import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';

/// Argon2id at its real settings takes seconds per call in pure Dart. These
/// tests use the smallest legal settings; the format is identical either way,
/// because a version 2 file records the settings it was written with.
VaultEnvelope _envelope() => VaultEnvelope(
  kdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
  legacyKdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
);

const String _password = 'correct-horse-battery';

void main() {
  final plain = utf8.encode('a private journal entry');

  test('a sealed file opens again with the same password', () async {
    final envelope = _envelope();
    final sealed = await envelope.seal(plainBytes: plain, password: _password);

    expect(VaultEnvelope.detectVersion(sealed), vaultEnvelopeVersion);
    expect(VaultEnvelope.isSealed(sealed), isTrue);
    expect(
      await envelope.open(sealedBytes: sealed, password: _password),
      plain,
    );
  });

  test('the same password gives different bytes every time', () async {
    final envelope = _envelope();
    final first = await envelope.seal(plainBytes: plain, password: _password);
    final second = await envelope.seal(plainBytes: plain, password: _password);

    // Version 1 derived its key from a fixed salt, so two files of the same
    // data under the same password shared a key. Version 2 does not.
    expect(first, isNot(second));
  });

  test('a wrong password is refused', () async {
    final envelope = _envelope();
    final sealed = await envelope.seal(plainBytes: plain, password: _password);

    expect(
      () => envelope.open(sealedBytes: sealed, password: 'not-the-password'),
      throwsA(
        isA<VaultCorruptedException>().having(
          (e) => e.isWrongPassword,
          'isWrongPassword',
          isTrue,
        ),
      ),
    );
  });

  test('a flipped byte is refused', () async {
    final envelope = _envelope();
    final sealed = await envelope.seal(plainBytes: plain, password: _password);
    sealed[sealed.length - 1] ^= 0xff;

    expect(
      () => envelope.open(sealedBytes: sealed, password: _password),
      throwsA(isA<VaultCorruptedException>()),
    );
  });

  test('a version 1 file still opens', () async {
    final envelope = _envelope();
    final legacy = await envelope.sealLegacyV1(
      plainBytes: plain,
      password: _password,
    );

    expect(VaultEnvelope.detectVersion(legacy), 1);
    expect(VaultEnvelope.isSealed(legacy), isFalse);
    expect(
      await envelope.open(sealedBytes: legacy, password: _password),
      plain,
    );
  });

  test('a file from a newer envelope is refused, not misread', () async {
    final envelope = _envelope();
    final sealed = await envelope.seal(plainBytes: plain, password: _password);
    // Byte 3 is the envelope version.
    sealed[3] = vaultEnvelopeVersion + 1;

    expect(
      () => envelope.open(sealedBytes: sealed, password: _password),
      throwsA(
        isA<VaultVersionTooNewException>().having(
          (e) => e.fileVersion,
          'fileVersion',
          vaultEnvelopeVersion + 1,
        ),
      ),
    );
  });

  test('a short password cannot seal anything', () async {
    expect(
      () => _envelope().seal(plainBytes: plain, password: 'short'),
      throwsA(isA<VaultPasswordException>()),
    );
  });

  test('random bytes are reported as a damaged file', () async {
    expect(
      () => _envelope().open(
        sealedBytes: List<int>.generate(64, (i) => i),
        password: _password,
      ),
      throwsA(isA<VaultCorruptedException>()),
    );
  });

  test('an unsealed file is recognised as unsealed', () {
    expect(
      VaultEnvelope.isSealed(utf8.encode('# Just some markdown')),
      isFalse,
    );
    expect(VaultEnvelope.isSealed(const []), isFalse);
  });
}
