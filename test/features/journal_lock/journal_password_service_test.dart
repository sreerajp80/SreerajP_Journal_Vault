import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late _InMemoryJournalSecretStore secretStore;
  late JournalPasswordService service;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    secretStore = _InMemoryJournalSecretStore();
    service = JournalPasswordService(secretStore: secretStore);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores journal verifier metadata without plaintext password', () async {
    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Private'),
    );

    final credential = await service.createCredential(
      journalId: journalId,
      password: 'vault-pass-123',
    );

    expect(credential.credentialReference, isNotEmpty);
    expect(credential.passwordSaltBase64, isNot(contains('vault-pass-123')));
    expect(
      credential.passwordVerifierBase64,
      isNot(contains('vault-pass-123')),
    );
    expect(secretStore.secrets[credential.credentialReference], isNotNull);
    expect(
      utf8.decode(secretStore.secrets[credential.credentialReference]!),
      isNot('vault-pass-123'),
    );

    await database.journalsDao.updateJournalById(
      journalId,
      JournalsCompanion(
        isLocked: const Value(true),
        credentialReference: Value(credential.credentialReference),
        passwordSaltBase64: Value(credential.passwordSaltBase64),
        passwordVerifierBase64: Value(credential.passwordVerifierBase64),
        passwordIterations: Value(credential.passwordIterations),
      ),
    );

    final journal = await database.journalsDao.getJournalById(journalId);
    expect(journal, isNotNull);
    expect(
      await service.verifyPassword(
        journal: journal,
        password: 'vault-pass-123',
      ),
      isTrue,
    );
    expect(
      await service.verifyPassword(journal: journal, password: 'wrong-pass'),
      isFalse,
    );

    await service.deleteCredential(journal);
    expect(secretStore.secrets, isEmpty);
  });
}

class _InMemoryJournalSecretStore implements JournalSecretStore {
  final Map<String, List<int>> secrets = <String, List<int>>{};

  @override
  Future<List<int>> createSecret(String credentialReference) async {
    final bytes = List<int>.generate(32, (index) => index + 11);
    secrets[credentialReference] = bytes;
    return bytes;
  }

  @override
  Future<void> deleteSecret(String credentialReference) async {
    secrets.remove(credentialReference);
  }

  @override
  Future<List<int>> loadSecret(String credentialReference) async {
    final bytes = secrets[credentialReference];
    if (bytes == null) {
      throw JournalSecretUnavailableException(credentialReference);
    }
    return bytes;
  }
}
