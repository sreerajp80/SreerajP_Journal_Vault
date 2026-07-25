import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/journal_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late AppLockController appLockController;
  late JournalLockController journalLockController;
  late JournalPasswordService passwordService;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    passwordService = JournalPasswordService(
      secretStore: _TestJournalSecretStore(),
    );
    appLockController = AppLockController(
      database: database,
      observeLifecycle: false,
    );
    journalLockController = JournalLockController(
      appLockController: appLockController,
      passwordService: passwordService,
    );
  });

  tearDown(() async {
    journalLockController.dispose();
    appLockController.dispose();
    await database.close();
  });

  test('clears unlocked journals when the app relocks', () async {
    await appLockController.ready();
    await appLockController.unlock();

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Locked', isLocked: const Value(true)),
    );
    final credential = await passwordService.createCredential(
      journalId: journalId,
      password: 'journal-secret',
    );
    await database.journalsDao.updateJournalById(
      journalId,
      JournalsCompanion(
        credentialReference: Value(credential.credentialReference),
        passwordSaltBase64: Value(credential.passwordSaltBase64),
        passwordVerifierBase64: Value(credential.passwordVerifierBase64),
        passwordIterations: Value(credential.passwordIterations),
      ),
    );
    final journal = await database.journalsDao.getJournalById(journalId);

    expect(
      await journalLockController.unlockJournal(
        journal: journal,
        password: 'journal-secret',
      ),
      isTrue,
    );
    expect(journalLockController.isUnlocked(journalId), isTrue);

    await appLockController.lock();

    expect(journalLockController.isUnlocked(journalId), isFalse);
  });
}

class _TestJournalSecretStore implements JournalSecretStore {
  final Map<String, List<int>> _secrets = <String, List<int>>{};

  @override
  Future<List<int>> createSecret(String credentialReference) async {
    final bytes = List<int>.generate(32, (index) => index + 1);
    _secrets[credentialReference] = bytes;
    return bytes;
  }

  @override
  Future<void> deleteSecret(String credentialReference) async {
    _secrets.remove(credentialReference);
  }

  @override
  Future<List<int>> loadSecret(String credentialReference) async {
    final bytes = _secrets[credentialReference];
    if (bytes == null) {
      throw JournalSecretUnavailableException(credentialReference);
    }
    return bytes;
  }
}
