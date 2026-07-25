import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';

/// Tracks which journals have been unlocked in the current session.
///
/// Registers a listener on [AppLockController] so that all unlocked journals
/// are cleared whenever the app locks.
class JournalLockController {
  JournalLockController({
    required AppLockController appLockController,
    required JournalPasswordService passwordService,
  })  : _appLockController = appLockController,
        _passwordService = passwordService {
    _appLockController.addOnLockCallback(_clearUnlocked);
  }

  final AppLockController _appLockController;
  final JournalPasswordService _passwordService;
  final Set<int> _unlockedJournalIds = {};

  /// Returns true if the journal with [journalId] has been unlocked this session.
  bool isUnlocked(int journalId) => _unlockedJournalIds.contains(journalId);

  /// Attempts to unlock [journal] using [password].
  ///
  /// Returns true on success and tracks the journal as unlocked.
  Future<bool> unlockJournal({
    required Journal journal,
    required String password,
  }) async {
    if (!journal.isLocked) {
      _unlockedJournalIds.add(journal.id);
      return true;
    }
    final verified = await _passwordService.verifyPassword(
      journal: journal,
      password: password,
    );
    if (verified) {
      _unlockedJournalIds.add(journal.id);
    }
    return verified;
  }

  /// Removes the listener and clears session state.
  void dispose() {
    _appLockController.removeOnLockCallback(_clearUnlocked);
    _unlockedJournalIds.clear();
  }

  void _clearUnlocked() => _unlockedJournalIds.clear();
}
