import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/about_screen.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/backup/presentation/backup_health_screen.dart';
import 'package:sreerajp_journal_vault/features/import/presentation/import_screen.dart';
import 'package:sreerajp_journal_vault/features/insights/presentation/insights_screen.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/presentation/permissions_screen.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/auto_lock_profiles_screen.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/security_events_screen.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/conflict_resolution_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_health_dashboard.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_status_widget.dart';
import 'package:sreerajp_journal_vault/features/timeline/presentation/timeline_screen.dart';

// ─── In-memory secret store (default; works in tests without platform Keystore) ──

class _InMemoryJournalSecretStore implements JournalSecretStore {
  final Map<String, List<int>> _map = {};

  @override
  Future<List<int>> createSecret(String ref) async {
    final rng = Random.secure();
    final bytes = List<int>.generate(32, (_) => rng.nextInt(256));
    _map[ref] = bytes;
    return bytes;
  }

  @override
  Future<List<int>> loadSecret(String ref) async {
    final s = _map[ref];
    if (s == null) throw JournalSecretUnavailableException(ref);
    return s;
  }

  @override
  Future<void> deleteSecret(String ref) async => _map.remove(ref);
}

// ─── Module-level providers ────────────────────────────────────────────────

class _ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;
  void set(ThemeMode v) => state = v;
}

class _SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

/// Set of journal IDs that have been session-unlocked by the user.
class _UnlockedJournalIdsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};
  void set(Set<int> v) => state = v;
}

final _themeModeProvider =
    NotifierProvider<_ThemeModeNotifier, ThemeMode>(_ThemeModeNotifier.new);
final _selectedTabProvider =
    NotifierProvider<_SelectedTabNotifier, int>(_SelectedTabNotifier.new);
final _unlockedJournalIdsProvider =
    NotifierProvider<_UnlockedJournalIdsNotifier, Set<int>>(
        _UnlockedJournalIdsNotifier.new);

/// Per-journal secret store. The default is an in-memory map suitable only
/// for tests; production must override this with a Keystore-backed
/// implementation in `main.dart`. If it is left as the default in production,
/// every locked journal will become inaccessible across app restarts because
/// the DEK lives only in memory.
final journalSecretStoreProvider = Provider<JournalSecretStore>((ref) {
  return _InMemoryJournalSecretStore();
});

final _journalPasswordServiceProvider = Provider<JournalPasswordService>((ref) {
  return JournalPasswordService(
    secretStore: ref.watch(journalSecretStoreProvider),
  );
});

// ─── App lock state ───────────────────────────────────────────────────────

class AppLockState {
  const AppLockState({
    required this.bootstrapped,
    required this.mode,
    required this.isLocked,
    required this.hasPin,
  });

  final bool bootstrapped;
  final AppLockMode? mode;
  final bool isLocked;
  final bool hasPin;

  AppLockState copyWith({
    bool? bootstrapped,
    AppLockMode? mode,
    bool clearMode = false,
    bool? isLocked,
    bool? hasPin,
  }) {
    return AppLockState(
      bootstrapped: bootstrapped ?? this.bootstrapped,
      mode: clearMode ? null : (mode ?? this.mode),
      isLocked: isLocked ?? this.isLocked,
      hasPin: hasPin ?? this.hasPin,
    );
  }
}

class AppLockNotifier extends Notifier<AppLockState> {
  AppLockController? _controller;
  bool _disposed = false;

  @visibleForTesting
  AppLockController? get controllerForTest => _controller;

  @override
  AppLockState build() {
    final db = ref.watch(appDatabaseProvider);
    final controller = AppLockController(database: db);
    _controller = controller;
    controller.addOnLockCallback(_onLocked);
    ref.onDispose(() {
      _disposed = true;
      controller.removeOnLockCallback(_onLocked);
      controller.dispose();
    });

    Future.microtask(_bootstrap);

    return const AppLockState(
      bootstrapped: false,
      mode: null,
      isLocked: true,
      hasPin: false,
    );
  }

  Future<void> _bootstrap() async {
    final controller = _controller;
    if (controller == null || _disposed) return;
    await controller.ready();
    bool hasPin;
    try {
      hasPin = await ref.read(appPinServiceProvider).hasPin();
    } on Exception {
      hasPin = false;
    }
    if (_disposed) return;
    state = AppLockState(
      bootstrapped: true,
      mode: controller.lockMode,
      isLocked: controller.lockMode != null && controller.isLocked,
      hasPin: hasPin,
    );
  }

  /// Unlocks via the device-credential prompt. Only succeeds if the platform
  /// authenticator returns success.
  Future<BiometricAuthResult> unlockWithBiometric() async {
    final controller = _controller;
    if (controller == null) return BiometricAuthResult.unavailable;
    final auth = ref.read(biometricAuthenticatorProvider);
    final result = await auth.authenticate(
      reason: 'Unlock SreerajP Journal Vault',
    );
    if (result == BiometricAuthResult.success) {
      await controller.unlock();
      if (!_disposed) {
        state = state.copyWith(isLocked: false);
      }
    }
    return result;
  }

  /// Verifies [pin] against the stored verifier and unlocks on match.
  Future<bool> unlockWithPin(String pin) async {
    final controller = _controller;
    if (controller == null) return false;
    final ok = await ref.read(appPinServiceProvider).verifyPin(pin);
    if (ok) {
      await controller.unlock();
      if (!_disposed) {
        state = state.copyWith(isLocked: false);
      }
    }
    return ok;
  }

  /// Persists [pin] to the keystore and updates [hasPin].
  Future<void> setPin(String pin) async {
    await ref.read(appPinServiceProvider).setPin(pin);
    if (!_disposed) {
      state = state.copyWith(hasPin: true);
    }
  }

  /// Clears the stored PIN credential.
  Future<void> clearPin() async {
    await ref.read(appPinServiceProvider).clearPin();
    if (!_disposed) {
      state = state.copyWith(hasPin: false);
    }
  }

  /// Persists [mode] and immediately locks the app. Caller is responsible for
  /// setting up a PIN before switching to [AppLockMode.appLock].
  Future<void> switchLockMode(AppLockMode mode) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.switchLockMode(mode);
    if (!_disposed) {
      state = state.copyWith(mode: mode, isLocked: true);
    }
  }

  /// Completes initial mode + credential selection on first launch and leaves
  /// the app unlocked for the current session.
  Future<void> completeFirstLaunchSetup({
    required AppLockMode mode,
    String? pin,
  }) async {
    final controller = _controller;
    if (controller == null) return;
    if (mode == AppLockMode.appLock) {
      if (pin == null || pin.isEmpty) {
        throw ArgumentError('PIN is required when selecting app_lock mode.');
      }
      await ref.read(appPinServiceProvider).setPin(pin);
    }
    await controller.switchLockMode(mode);
    await controller.unlock();
    if (!_disposed) {
      state = AppLockState(
        bootstrapped: true,
        mode: mode,
        isLocked: false,
        hasPin: mode == AppLockMode.appLock,
      );
    }
  }

  void _onLocked() {
    if (_disposed) return;
    // Clear any session-unlocked journals when the app re-locks.
    ref.read(_unlockedJournalIdsProvider.notifier).set(const {});
    state = state.copyWith(isLocked: true);
  }
}

final appLockProvider =
    NotifierProvider<AppLockNotifier, AppLockState>(AppLockNotifier.new);

// ─── Helpers ──────────────────────────────────────────────────────────────

String _fmtDate(DateTime d) {
  final l = d.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
}

// ─── JournalVaultAppHost ─────────────────────────────────────────────────

/// Wraps [JournalVaultApp] in a [ProviderScope] with the given [database].
///
/// Pass [themeModeStore] and optional [overrides] for testing.
class JournalVaultAppHost extends StatelessWidget {
  const JournalVaultAppHost({
    super.key,
    required this.database,
    this.themeModeStore,
    this.overrides = const [],
  });

  final AppDatabase database;
  final ThemeModeStore? themeModeStore;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        if (themeModeStore != null)
          themeModeStoreProvider.overrideWithValue(themeModeStore!),
        ...overrides,
      ],
      child: const JournalVaultApp(),
    );
  }
}

// ─── JournalVaultApp ─────────────────────────────────────────────────────

class JournalVaultApp extends ConsumerStatefulWidget {
  const JournalVaultApp({super.key});

  @override
  ConsumerState<JournalVaultApp> createState() => _JournalVaultAppState();
}

class _JournalVaultAppState extends ConsumerState<JournalVaultApp> {
  bool _themeRestored = false;

  void _restoreThemeIfNeeded() {
    if (_themeRestored) return;
    _themeRestored = true;
    try {
      final store = ref.read(themeModeStoreProvider);
      final mode = store.read();
      ref.read(_themeModeProvider.notifier).set(mode);
    } catch (_) {
      // No store provided → keep default.
    }
  }

  @override
  Widget build(BuildContext context) {
    _restoreThemeIfNeeded();
    final lockState = ref.watch(appLockProvider);
    final themeMode = ref.watch(_themeModeProvider);

    Widget home;
    if (!lockState.bootstrapped) {
      home = const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (lockState.mode == null) {
      home = const _FirstLaunchSetupScreen();
    } else if (lockState.mode == AppLockMode.appLock && !lockState.hasPin) {
      // App-lock mode active but no PIN set (e.g. user switched modes via
      // settings then aborted). Force PIN setup before continuing.
      home = const _AppLockPinSetupScreen();
    } else if (lockState.isLocked) {
      home = const _LockGateScreen();
    } else {
      home = const _MainShell();
    }

    return MaterialApp(
      title: 'Journal Vault',
      theme: _appTheme(Brightness.light),
      darkTheme: _appTheme(Brightness.dark),
      themeMode: themeMode,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: home,
    );
  }
}

ThemeData _appTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF9C5F2B),
    brightness: brightness,
  );

  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 22, vertical: 14);
  const buttonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    fontSize: 14,
  );
  const buttonAnimationDuration = Duration(milliseconds: 150);

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    splashFactory: InkSparkle.splashFactory,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
        elevation: 1,
        shadowColor: colorScheme.primary.withValues(alpha: 0.25),
        animationDuration: buttonAnimationDuration,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
        elevation: 1,
        shadowColor: colorScheme.primary.withValues(alpha: 0.25),
        animationDuration: buttonAnimationDuration,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1.2,
        ),
        animationDuration: buttonAnimationDuration,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: buttonTextStyle,
        animationDuration: buttonAnimationDuration,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        animationDuration: buttonAnimationDuration,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      elevation: 2,
      highlightElevation: 4,
    ),
  );
}

// ─── First-launch setup ──────────────────────────────────────────────────

class _FirstLaunchSetupScreen extends ConsumerStatefulWidget {
  const _FirstLaunchSetupScreen();

  @override
  ConsumerState<_FirstLaunchSetupScreen> createState() =>
      _FirstLaunchSetupScreenState();
}

class _FirstLaunchSetupScreenState
    extends ConsumerState<_FirstLaunchSetupScreen> {
  AppLockMode _selected = AppLockMode.phoneLock;
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_busy) return;
    setState(() => _error = null);

    if (_selected == AppLockMode.appLock) {
      if (_pin.text.length < 4) {
        setState(() => _error = 'PIN must be at least 4 characters.');
        return;
      }
      if (_pin.text != _confirm.text) {
        setState(() => _error = 'PINs do not match.');
        return;
      }
    }

    setState(() => _busy = true);
    try {
      await ref.read(appLockProvider.notifier).completeFirstLaunchSetup(
            mode: _selected,
            pin: _selected == AppLockMode.appLock ? _pin.text : null,
          );
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Could not save lock setup: $error';
          _busy = false;
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAppLock = _selected == AppLockMode.appLock;
    return Scaffold(
      appBar: AppBar(title: const Text('Set up app lock')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how SreerajP Journal Vault should lock when it is sent '
              'to the background.',
            ),
            const SizedBox(height: 16),
            RadioGroup<AppLockMode>(
              groupValue: _selected,
              onChanged: (v) {
                if (v != null) setState(() => _selected = v);
              },
              child: const Column(
                children: [
                  RadioListTile<AppLockMode>(
                    key: Key('first-launch-mode-phone'),
                    value: AppLockMode.phoneLock,
                    title: Text('Phone Lock'),
                    subtitle: Text(
                      'Use the device biometric or PIN/pattern/password.',
                    ),
                  ),
                  RadioListTile<AppLockMode>(
                    key: Key('first-launch-mode-app'),
                    value: AppLockMode.appLock,
                    title: Text('Separate App Lock'),
                    subtitle: Text(
                      'Use a dedicated PIN that is verified inside the app.',
                    ),
                  ),
                ],
              ),
            ),
            if (isAppLock) ...[
              const SizedBox(height: 8),
              TextField(
                key: const Key('first-launch-pin-field'),
                controller: _pin,
                obscureText: true,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(labelText: 'PIN'),
              ),
              TextField(
                key: const Key('first-launch-pin-confirm-field'),
                controller: _confirm,
                obscureText: true,
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('first-launch-continue-button'),
              onPressed: _busy ? null : _continue,
              child: Text(_busy ? 'Setting up...' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Force-set PIN when app_lock has no credential ───────────────────────

// ─── Locked attachments overview (Slice D4) ───────────────────────────────

class _LockedAttachmentsScreen extends ConsumerStatefulWidget {
  const _LockedAttachmentsScreen();

  @override
  ConsumerState<_LockedAttachmentsScreen> createState() =>
      _LockedAttachmentsScreenState();
}

class _LockedAttachmentsScreenState
    extends ConsumerState<_LockedAttachmentsScreen> {
  List<(AttachmentLock, Attachment)>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final svc = ref.read(attachmentLockServiceProvider);
    final locks = await svc.getLockedAttachments();
    final pairs = <(AttachmentLock, Attachment)>[];
    for (final l in locks) {
      try {
        final a = await db.attachmentsDao.getAttachmentById(l.attachmentId);
        pairs.add((l, a));
      } catch (_) {/* attachment missing — skip */}
    }
    if (mounted) setState(() => _entries = pairs);
  }

  Future<void> _remove(int attachmentId) async {
    final svc = ref.read(attachmentLockServiceProvider);
    await svc.removeLock(attachmentId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    return Scaffold(
      appBar: AppBar(title: const Text('Attachment-Level Lock')),
      body: entries == null
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No attachments are locked yet. Open an entry and use '
                      'the lock button on an attachment to require '
                      're-authentication before opening it.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final (lock, attachment) = entries[i];
                    return ListTile(
                      key: Key('locked-attachment-${attachment.id}'),
                      leading: const Icon(Icons.lock),
                      title: Text(attachment.fileName),
                      subtitle: Text('Locked ${_fmtDate(lock.lockedAt)}'),
                      trailing: TextButton(
                        key: Key('locked-attachment-remove-${attachment.id}'),
                        onPressed: () => _remove(attachment.id),
                        child: const Text('Remove lock'),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AppLockPinSetupScreen extends ConsumerStatefulWidget {
  const _AppLockPinSetupScreen();

  @override
  ConsumerState<_AppLockPinSetupScreen> createState() =>
      _AppLockPinSetupScreenState();
}

class _AppLockPinSetupScreenState
    extends ConsumerState<_AppLockPinSetupScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (_pin.text.length < 4) {
      setState(() => _error = 'PIN must be at least 4 characters.');
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(appLockProvider.notifier).setPin(_pin.text);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Could not save PIN: $error';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set app-lock PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Separate App Lock requires a PIN. Set one to continue.',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('pin-setup-field'),
              controller: _pin,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            TextField(
              key: const Key('pin-setup-confirm-field'),
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('pin-setup-save-button'),
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lock gate ────────────────────────────────────────────────────────────

class _LockGateScreen extends ConsumerStatefulWidget {
  const _LockGateScreen();

  @override
  ConsumerState<_LockGateScreen> createState() => _LockGateScreenState();
}

class _LockGateScreenState extends ConsumerState<_LockGateScreen> {
  final _pinController = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _unlockBiometric() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result =
        await ref.read(appLockProvider.notifier).unlockWithBiometric();
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case BiometricAuthResult.success:
          _error = null;
          break;
        case BiometricAuthResult.failed:
          _error = 'Authentication failed. Please try again.';
          break;
        case BiometricAuthResult.unavailable:
          _error =
              'Device authentication is not available. Configure a PIN/biometric in system settings.';
          break;
      }
    });
  }

  Future<void> _unlockPin() async {
    if (_busy) return;
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() => _error = 'Enter your PIN.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref.read(appLockProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) {
        _error = 'Incorrect PIN.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);
    final isAppLock = lockState.mode == AppLockMode.appLock;
    final modeLabel = isAppLock ? 'Separate App Lock' : 'Phone Lock';

    return Scaffold(
      appBar: AppBar(title: const Text('App Lock Gate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(modeLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            if (isAppLock) ...[
              TextField(
                key: const Key('app-lock-pin-field'),
                controller: _pinController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _unlockPin(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('app-lock-unlock-button'),
                onPressed: _busy ? null : _unlockPin,
                child: const Text('Unlock'),
              ),
            ] else ...[
              ElevatedButton(
                key: const Key('phone-lock-unlock-button'),
                onPressed: _busy ? null : _unlockBiometric,
                child: const Text('Unlock with Phone Lock'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Main shell with bottom navigation ────────────────────────────────────

class _MainShell extends ConsumerWidget {
  const _MainShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_selectedTabProvider);
    const tabs = [
      _HomeTab(),
      _SearchTab(),
      TimelineScreen(),
      InsightsScreen(),
      _SettingsTab(),
    ];
    return Scaffold(
      body: tabs[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(_selectedTabProvider.notifier).set(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.saved_search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOME TAB
// ═══════════════════════════════════════════════════════════════════════════

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _JournalSummary {
  const _JournalSummary({
    required this.journal,
    required this.tags,
    required this.entryCount,
    required this.lastUpdatedAt,
  });

  final Journal journal;
  final List<Tag> tags;
  final int entryCount;
  final DateTime? lastUpdatedAt;
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  List<_JournalSummary>? _journals;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    final items = <_JournalSummary>[];
    for (final j in journals) {
      final tags = await db.journalTagsDao.getTagsForJournal(j.id);
      final entries = await db.entriesDao.getEntriesForJournal(j.id);
      DateTime? lastUpdated;
      for (final e in entries) {
        if (lastUpdated == null || e.updatedAt.isAfter(lastUpdated)) {
          lastUpdated = e.updatedAt;
        }
      }
      lastUpdated ??= j.updatedAt;
      items.add(_JournalSummary(
        journal: j,
        tags: tags,
        entryCount: entries.length,
        lastUpdatedAt: lastUpdated,
      ));
    }
    if (mounted) setState(() => _journals = items);
  }

  Future<void> _openForm({Journal? journal, List<Tag> initialTags = const []}) async {
    final result = await showDialog<({
      String title,
      String desc,
      String tags,
      bool locked,
      String? password,
    })>(
      context: context,
      builder: (_) => _JournalFormDialog(
        journal: journal,
        initialTags: initialTags,
      ),
    );
    if (result == null || !mounted) return;

    final db = ref.read(appDatabaseProvider);
    int journalId;

    if (journal == null) {
      journalId = await db.journalsDao.createJournal(
        JournalsCompanion.insert(
          title: result.title,
          description: Value(result.desc.isEmpty ? null : result.desc),
        ),
      );
      // Create tags
      final tagNames = result.tags
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);
      for (final name in tagNames) {
        final tagId = await db.tagsDao.getOrCreateTag(name);
        await db.journalTagsDao.addTagToJournal(journalId, tagId);
      }
      // Lock if requested
      if (result.locked && result.password != null && result.password!.isNotEmpty) {
        final svc = ref.read(_journalPasswordServiceProvider);
        final cred = await svc.createCredential(
          journalId: journalId,
          password: result.password!,
        );
        await db.journalsDao.updateJournalById(
          journalId,
          JournalsCompanion(
            isLocked: const Value(true),
            credentialReference: Value(cred.credentialReference),
            passwordSaltBase64: Value(cred.passwordSaltBase64),
            passwordVerifierBase64: Value(cred.passwordVerifierBase64),
            passwordIterations: Value(cred.passwordIterations),
          ),
        );
      }
    } else {
      journalId = journal.id;
      await db.journalsDao.updateJournalById(
        journalId,
        JournalsCompanion(
          title: Value(result.title),
          description: Value(result.desc.isEmpty ? null : result.desc),
        ),
      );
    }
    await _load();
  }

  Future<void> _deleteJournal(Journal journal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete journal?'),
        content: Text('Delete "${journal.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final db = ref.read(appDatabaseProvider);
    // Remove journal_tags (no cascade on journalId FK)
    final tags = await db.journalTagsDao.getTagsForJournal(journal.id);
    for (final tag in tags) {
      await db.journalTagsDao.removeTagFromJournal(journal.id, tag.id);
    }
    // Remove entries (no cascade on journalId FK)
    final entries = await db.entriesDao.getEntriesForJournal(journal.id);
    for (final entry in entries) {
      await db.entriesDao.deleteEntryById(entry.id);
    }
    await db.journalsDao.deleteJournalById(journal.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final journals = _journals;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          SyncStatusWidget(
            showLabel: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ConflictResolutionScreen(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: journals == null
          ? const Center(child: CircularProgressIndicator())
          : journals.isEmpty
              ? const _HomeEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: journals.length,
                    itemBuilder: (_, i) {
                      final summary = journals[i];
                      return _JournalCard(
                        summary: summary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                _JournalDetailScreen(journal: summary.journal),
                          ),
                        ).then((_) => _load()),
                        onEdit: () => _openForm(
                          journal: summary.journal,
                          initialTags: summary.tags,
                        ),
                        onDelete: () => _deleteJournal(summary.journal),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'New journal',
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New journal'),
      ),
    );
  }
}

// ─── Home empty state ──────────────────────────────────────────────────────

class _HomeEmptyState extends StatelessWidget {
  const _HomeEmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No journals yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap “New journal” to start writing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Journal card ──────────────────────────────────────────────────────────

const List<Color> _kJournalCoverPalette = [
  Color(0xFFB39DDB), // soft purple
  Color(0xFF90CAF9), // soft blue
  Color(0xFFA5D6A7), // mint
  Color(0xFFFFCC80), // peach
  Color(0xFFF48FB1), // pink
  Color(0xFF80CBC4), // teal
  Color(0xFFFFAB91), // coral
  Color(0xFFCE93D8), // lilac
];

Color _coverColorForJournal(int journalId) =>
    _kJournalCoverPalette[journalId.abs() % _kJournalCoverPalette.length];

String _formatRelativeDate(DateTime when) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final whenDay = DateTime(when.year, when.month, when.day);
  final diffDays = today.difference(whenDay).inDays;
  if (diffDays <= 0) return 'Today';
  if (diffDays == 1) return 'Yesterday';
  if (diffDays < 7) return '${diffDays}d ago';
  if (diffDays < 30) return '${(diffDays / 7).floor()}w ago';
  if (diffDays < 365) return '${(diffDays / 30).floor()}mo ago';
  return '${(diffDays / 365).floor()}y ago';
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.summary,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final _JournalSummary summary;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final journal = summary.journal;
    final cover = _coverColorForJournal(journal.id);
    final initial = journal.title.isEmpty
        ? '?'
        : journal.title.characters.first.toUpperCase();
    final visibleTags = summary.tags.take(2).toList();
    final lastUpdated = summary.lastUpdatedAt;
    final metaParts = <String>[
      '${summary.entryCount} ${summary.entryCount == 1 ? 'entry' : 'entries'}',
      if (lastUpdated != null) _formatRelativeDate(lastUpdated),
    ];

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover with big faded initial + lock badge
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cover.withValues(alpha: 0.85),
                          cover.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -8,
                    bottom: -22,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 110,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  if (journal.isLocked)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body: title, meta, tags, actions
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (visibleTags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: -8,
                        children: [
                          for (final tag in visibleTags)
                            Text(
                              '#${tag.name}',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            tooltip: 'Edit journal',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: onEdit,
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            tooltip: 'Delete journal',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: onDelete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Journal form dialog ──────────────────────────────────────────────────

class _JournalFormDialog extends StatefulWidget {
  const _JournalFormDialog({this.journal, this.initialTags = const []});

  final Journal? journal;
  final List<Tag> initialTags;

  @override
  State<_JournalFormDialog> createState() => _JournalFormDialogState();
}

class _JournalFormDialogState extends State<_JournalFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _tags;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  bool _lockJournal = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.journal?.title ?? '');
    _desc = TextEditingController(
        text: widget.journal?.description ?? '');
    _tags = TextEditingController(
        text: widget.initialTags.map((t) => t.name).join(', '));
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _tags.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.journal != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit journal' : 'New journal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            if (!isEdit) ...[
              TextFormField(
                controller: _tags,
                decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)'),
              ),
              SwitchListTile(
                title: const Text('Lock journal'),
                value: _lockJournal,
                onChanged: (v) => setState(() => _lockJournal = v),
              ),
              if (_lockJournal) ...[
                TextFormField(
                  key: const Key('journal-password-field'),
                  controller: _password,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Password'),
                ),
                TextFormField(
                  key: const Key('journal-password-confirm-field'),
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm password'),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            (
              title: _title.text,
              desc: _desc.text,
              tags: _tags.text,
              locked: _lockJournal,
              password: _password.text.isEmpty ? null : _password.text,
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ─── Journal detail ───────────────────────────────────────────────────────

class _JournalDetailScreen extends ConsumerStatefulWidget {
  const _JournalDetailScreen({required this.journal});

  final Journal journal;

  @override
  ConsumerState<_JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState
    extends ConsumerState<_JournalDetailScreen> {
  List<Entry>? _entries;
  String? _unlockError;
  final _passwordController = TextEditingController();

  bool get _isSessionUnlocked {
    final ids = ref.read(_unlockedJournalIdsProvider);
    return ids.contains(widget.journal.id);
  }

  bool get _isAccessible =>
      !widget.journal.isLocked || _isSessionUnlocked;

  @override
  void initState() {
    super.initState();
    if (_isAccessible) _loadEntries();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final entries =
        await db.entriesDao.getEntriesForJournal(widget.journal.id);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _tryUnlock() async {
    final password = _passwordController.text;
    final svc = ref.read(_journalPasswordServiceProvider);
    final ok = await svc.verifyPassword(
        journal: widget.journal, password: password);
    if (!mounted) return;
    if (ok) {
      final current = ref.read(_unlockedJournalIdsProvider);
      ref.read(_unlockedJournalIdsProvider.notifier).set({
        ...current,
        widget.journal.id,
      });
      setState(() => _unlockError = null);
      await _loadEntries();
    } else {
      setState(() => _unlockError = 'Incorrect password.');
    }
  }

  Future<void> _openEntryScreen({Entry? entry}) async {
    EntryTemplateId? templateId;
    if (entry == null) {
      // For new entries, ask the user to pick a starter template first.
      final selected = await showDialog<EntryTemplate>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _EntryTemplateChooserDialog(),
      );
      if (!mounted) return;
      if (selected == null) return; // User dismissed somehow.
      templateId = selected.id;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EntryEditorScreen(
          journalId: widget.journal.id,
          entryId: entry?.id,
          initialTemplateId: templateId,
        ),
      ),
    );
    if (mounted) await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_unlockedJournalIdsProvider); // Rebuild on unlock change
    final accessible = _isAccessible;

    return Scaffold(
      appBar: AppBar(title: Text(widget.journal.title)),
      floatingActionButton: accessible
          ? FloatingActionButton.extended(
              onPressed: () => _openEntryScreen(),
              icon: const Icon(Icons.add),
              label: const Text('Add entry'),
            )
          : null,
      body: accessible ? _buildEntries() : _buildLocked(),
    );
  }

  Widget _buildLocked() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Journal is locked'),
          const SizedBox(height: 16),
          TextField(
            key: const Key('journal-unlock-password-field'),
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          if (_unlockError != null) ...[
            const SizedBox(height: 8),
            Text(_unlockError!,
                style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('journal-unlock-button'),
            onPressed: _tryUnlock,
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntries() {
    final entries = _entries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Unlocked'),
        ),
        Expanded(
          child: entries == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final entry = entries[i];
                    final date = entry.entryDate ?? entry.createdAt;
                    return ListTile(
                      title: Text(entry.title ?? 'Untitled'),
                      subtitle: Text(_fmtDate(date)),
                      onTap: () => _openEntryScreen(entry: entry),
                    );
                  },
                ),
        ),
      ],
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════════
// SETTINGS TAB
// ═══════════════════════════════════════════════════════════════════════════

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockProvider);
    final lockMode = lockState.mode;
    final themeMode = ref.watch(_themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        key: const Key('settings-list'),
        children: [
          // ── Section 1: Security ──────────────────────────────────────
          const _SectionHeader('Security'),
          const ListTile(title: Text('App Lock Mode')),
          ListTile(
            title: const Text('Phone Lock'),
            selected: lockMode != AppLockMode.appLock,
            onTap: lockMode != AppLockMode.appLock
                ? null
                : () => _switchLock(context, ref, AppLockMode.phoneLock),
          ),
          ListTile(
            title: const Text('Separate App Lock'),
            selected: lockMode == AppLockMode.appLock,
            onTap: lockMode == AppLockMode.appLock
                ? null
                : () => _switchLock(context, ref, AppLockMode.appLock),
          ),
          ListTile(
            key: const Key('settings-auto-lock-timeout'),
            title: const Text('Auto-Lock Timeout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AutoLockProfilesScreen(),
              ),
            ),
          ),
          ListTile(
            key: const Key('settings-attachment-level-lock'),
            title: const Text('Attachment-Level Lock'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const _LockedAttachmentsScreen(),
              ),
            ),
          ),
          const _ComingSoonTile(title: 'Tamper Alerts'),
          ListTile(
            key: const Key('settings-sync-conflicts'),
            title: const Text('Sync Conflicts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ConflictResolutionScreen(),
              ),
            ),
          ),
          ListTile(
            key: const Key('settings-security-events'),
            title: const Text('Security Events'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SecurityEventsScreen(),
              ),
            ),
          ),

          // ── Section 2: Appearance ────────────────────────────────────
          const _SectionHeader('Appearance'),
          const ListTile(
            title: Text('Theme'),
            subtitle:
                Text('Choose how SreerajP_Journal_Vault looks.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final (label, mode) in [
                  ('Light', ThemeMode.light),
                  ('Dark', ThemeMode.dark),
                ])
                  ChoiceChip(
                    key: Key('settings-theme-chip-${mode.name}'),
                    label: Text(label),
                    selected: themeMode == mode,
                    onSelected: (_) =>
                        _switchTheme(context, ref, mode),
                  ),
              ],
            ),
          ),

          // ── Section 3: Storage ───────────────────────────────────────
          const _SectionHeader('Storage'),
          const _StorageSection(),

          // ── Section 4: Permissions ───────────────────────────────────
          const _SectionHeader('Permissions'),
          const _PermissionsSection(),

          // ── Section 5: About ─────────────────────────────────────────
          const _SectionHeader('About'),
          ListTile(
            title: const Text('About this app'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AboutScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchLock(
      BuildContext context, WidgetRef ref, AppLockMode mode) async {
    final modeLabel =
        mode == AppLockMode.appLock ? 'Separate App Lock' : 'Phone Lock';
    final disabledLabel =
        mode == AppLockMode.appLock ? 'Phone Lock' : 'Separate App Lock';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Switch lock mode?'),
        content: Text(
          'This will switch app protection to $modeLabel and disable $disabledLabel. Continue?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Switch')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    // When switching to app_lock, require setting a PIN before persisting.
    if (mode == AppLockMode.appLock) {
      final pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _PinSetupDialog(),
      );
      if (!context.mounted) return;
      if (pin == null || pin.isEmpty) {
        // User cancelled — leave mode unchanged.
        return;
      }
      await ref.read(appLockProvider.notifier).setPin(pin);
    }

    await ref.read(appLockProvider.notifier).switchLockMode(mode);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Lock mode updated: $modeLabel is now active.')),
      );
    }
  }

  Future<void> _switchTheme(
      BuildContext context, WidgetRef ref, ThemeMode mode) async {
    final prev = ref.read(_themeModeProvider);
    ref.read(_themeModeProvider.notifier).set(mode);

    bool failed = false;
    try {
      final store = ref.read(themeModeStoreProvider);
      await store.save(mode);
    } on ThemeModePersistenceException {
      failed = true;
    } catch (_) {/* No store or other error → treat as success */}

    if (!context.mounted) return;

    if (failed) {
      ref.read(_themeModeProvider.notifier).set(prev);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Could not save theme setting. Please try again.')),
      );
    } else {
      final label = switch (mode) {
        ThemeMode.dark => 'Dark',
        ThemeMode.light => 'Light',
        ThemeMode.system => 'System',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Theme updated: $label mode is now active.')),
      );
    }
  }
}

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog();

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (_pin.text.length < 4) {
      setState(() => _error = 'PIN must be at least 4 characters.');
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    Navigator.pop(context, _pin.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set app-lock PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('settings-pin-field'),
            controller: _pin,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'PIN'),
          ),
          TextField(
            key: const Key('settings-pin-confirm-field'),
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm PIN'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          key: const Key('settings-pin-save-button'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Text('Coming soon'),
      enabled: false,
    );
  }
}

// ─── Storage section ──────────────────────────────────────────────────────

class _StorageSection extends ConsumerStatefulWidget {
  const _StorageSection();

  @override
  ConsumerState<_StorageSection> createState() => _StorageSectionState();
}

class _StorageSectionState extends ConsumerState<_StorageSection> {
  AppSetting? _settings;
  int? _totalBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final settings = await db.appSettingsDao.getSettings();
    final attachments = await db.attachmentsDao.getAllAttachments();
    final total =
        attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _totalBytes = total;
    });
  }

  String _locationLabel(AppSetting s) {
    final loc = AttachmentStorageLocation.fromSettingsValue(
      s.attachmentStorageLocation,
    );
    return loc == AttachmentStorageLocation.sdCard
        ? 'SD Card${s.attachmentStorageTreeLabel != null ? ' (${s.attachmentStorageTreeLabel})' : ''}'
        : 'App Private';
  }

  String _migrationStatusLabel(AppSetting s) {
    switch (s.attachmentMigrationStatus) {
      case 'running':
        return 'Migrating ${s.attachmentMigrationProcessedCount} of ${s.attachmentMigrationTotalCount}…';
      case 'failed':
        return s.attachmentMigrationFailure ?? 'Migration failed.';
      default:
        return 'Idle';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> _changeLocation(AttachmentStorageLocation target) async {
    final settings = _settings;
    if (settings == null) return;

    String? treeUri;
    String? treeLabel;
    if (target == AttachmentStorageLocation.sdCard) {
      final picker = ref.read(attachmentStoragePickerProvider);
      final selection = await picker.pickStorageTree();
      if (selection == null) return;
      treeUri = selection.treeUri;
      treeLabel = selection.displayName;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Migrate attachments?'),
        content: Text(
          'All attachments will be moved to ${target == AttachmentStorageLocation.sdCard ? "SD Card" : "App Private storage"}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Migrate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runMigration(target: target, treeUri: treeUri, treeLabel: treeLabel);
  }

  Future<void> _runMigration({
    required AttachmentStorageLocation target,
    String? treeUri,
    String? treeLabel,
  }) async {
    final controller = _MigrationProgressController();

    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MigrationProgressDialog(controller: controller),
    );

    final service = ref.read(attachmentStorageMigrationServiceProvider);
    String? errorMessage;
    var cancelled = false;
    try {
      await service.migrateTo(
        targetLocation: target,
        targetTreeUri: treeUri,
        targetTreeLabel: treeLabel,
        onProgress: controller.update,
        isCancelled: () => controller.cancelRequested,
      );
    } catch (e) {
      cancelled = controller.cancelRequested;
      if (!cancelled) errorMessage = e.toString();
    }

    controller.complete();
    await dialogFuture;

    await _load();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (cancelled) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Migration cancelled.')),
      );
    } else if (errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Migration failed: $errorMessage')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Migration complete.')),
      );
    }
  }

  Future<void> _retryMigration() async {
    final settings = _settings;
    if (settings == null) return;
    final target = AttachmentStorageLocation.fromSettingsValue(
      settings.attachmentMigrationTarget ?? settings.attachmentStorageLocation,
    );
    await _runMigration(
      target: target,
      treeUri: settings.attachmentStorageTreeUri,
      treeLabel: settings.attachmentStorageTreeLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final canRetry = settings.attachmentMigrationStatus == 'failed';

    return Column(
      children: [
        ListTile(
          key: const Key('settings-attachment-storage-location'),
          title: const Text('Attachment Storage Location'),
          subtitle: Text(_locationLabel(settings)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final selection = await showDialog<AttachmentStorageLocation>(
              context: context,
              builder: (_) => SimpleDialog(
                title: const Text('Storage location'),
                children: [
                  SimpleDialogOption(
                    key: const Key('storage-location-app-private'),
                    onPressed: () => Navigator.pop(
                      context,
                      AttachmentStorageLocation.appPrivate,
                    ),
                    child: const Text('App Private'),
                  ),
                  SimpleDialogOption(
                    key: const Key('storage-location-sd-card'),
                    onPressed: () => Navigator.pop(
                      context,
                      AttachmentStorageLocation.sdCard,
                    ),
                    child: const Text('SD Card'),
                  ),
                ],
              ),
            );
            if (selection != null) await _changeLocation(selection);
          },
        ),
        ListTile(
          key: const Key('settings-migrate-storage'),
          title: const Text('Migrate Storage'),
          subtitle: Text(_migrationStatusLabel(settings)),
          trailing: canRetry
              ? TextButton(
                  key: const Key('settings-migrate-storage-retry'),
                  onPressed: _retryMigration,
                  child: const Text('Retry'),
                )
              : null,
        ),
        ListTile(
          key: const Key('settings-storage-usage'),
          title: const Text('Storage Usage'),
          subtitle: Text(
            _totalBytes == null ? '—' : _formatBytes(_totalBytes!),
          ),
        ),
        ListTile(
          key: const Key('settings-backup-health'),
          title: const Text('Backup Health'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const BackupHealthScreen(),
            ),
          ),
        ),
        ListTile(
          key: const Key('settings-import-data'),
          title: const Text('Import Data'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickImportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-sync-health'),
          title: const Text('Sync Health'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Sync Health')),
                body: const SyncHealthDashboard(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImportTarget(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!context.mounted) return;
    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a journal first to import into.'),
        ),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Import into journal'),
        children: [
          for (final j in journals)
            SimpleDialogOption(
              key: Key('import-target-journal-${j.id}'),
              onPressed: () => Navigator.pop(context, j),
              child: Text(j.title),
            ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ImportScreen(
          journalId: selected.id,
          journalTitle: selected.title,
        ),
      ),
    );
  }
}

class _MigrationProgressController extends ChangeNotifier {
  int _processed = 0;
  int _total = 0;
  bool _cancelRequested = false;
  bool _completed = false;

  int get processed => _processed;
  int get total => _total;
  bool get cancelRequested => _cancelRequested;
  bool get completed => _completed;

  void update(int processed, int total) {
    _processed = processed;
    _total = total;
    notifyListeners();
  }

  void cancel() {
    if (_cancelRequested) return;
    _cancelRequested = true;
    notifyListeners();
  }

  void complete() {
    if (_completed) return;
    _completed = true;
    notifyListeners();
  }
}

class _MigrationProgressDialog extends StatefulWidget {
  const _MigrationProgressDialog({required this.controller});

  final _MigrationProgressController controller;

  @override
  State<_MigrationProgressDialog> createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<_MigrationProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    if (!mounted) return;
    if (widget.controller.completed) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final progress = c.total == 0 ? null : c.processed / c.total;
    return AlertDialog(
      title: const Text('Migrating attachments'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Text(
            c.cancelRequested
                ? 'Cancelling…'
                : '${c.processed} of ${c.total == 0 ? '?' : c.total}',
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('migration-cancel-button'),
          onPressed: c.cancelRequested ? null : c.cancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ─── Permissions section ──────────────────────────────────────────────────

class _PermissionsSection extends ConsumerStatefulWidget {
  const _PermissionsSection();

  @override
  ConsumerState<_PermissionsSection> createState() =>
      _PermissionsSectionState();
}

class _PermissionsSectionState extends ConsumerState<_PermissionsSection> {
  PermissionsSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final service = ref.read(appPermissionsServiceProvider);
      final snapshot = await service.getSnapshot();
      if (mounted) setState(() => _snapshot = snapshot);
    } catch (_) {
      // No permissions service overridden (e.g. some tests). Show "—".
    }
  }

  String _summary() {
    final s = _snapshot;
    if (s == null) return '—';
    final all = [...s.explicitPermissions, ...s.implicitPermissions];
    final granted =
        all.where((p) => p.status == AppPermissionState.granted).length;
    return '$granted of ${all.length} granted';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          key: const Key('settings-permissions-status'),
          title: const Text('Permission Status'),
          subtitle: Text(_summary()),
        ),
        ListTile(
          key: const Key('settings-manage-permissions'),
          title: const Text('Manage Permissions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const PermissionsScreen(),
              ),
            );
            await _load();
          },
        ),
        ListTile(
          key: const Key('settings-open-system-settings'),
          title: const Text('Open System Settings'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () async {
            try {
              await ref
                  .read(appPermissionsServiceProvider)
                  .openSystemSettings();
            } catch (_) {/* permissions service not available */}
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH TAB
// ═══════════════════════════════════════════════════════════════════════════

class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _queryCtrl = TextEditingController();
  String _query = '';
  bool _filterEntries = false;
  List<Journal>? _journalResults;
  List<FtsSearchResult>? _entryResults;
  List<SearchPreset>? _presets;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final presets = await db.searchPresetsDao.getAllPresets();
    if (mounted) setState(() => _presets = presets);
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _query = '';
        _journalResults = null;
        _entryResults = null;
      });
      return;
    }
    setState(() => _query = trimmed);

    final db = ref.read(appDatabaseProvider);
    final unlockedIds = ref.read(_unlockedJournalIdsProvider);

    final allJournals = await db.journalsDao.getAllJournals();
    final journalMap = {for (final j in allJournals) j.id: j};

    final journalResults = allJournals
        .where((j) =>
            j.title.toLowerCase().contains(trimmed.toLowerCase()))
        .toList();

    final ftsResults = await db.searchEntries(trimmed);
    final entryResults = ftsResults.where((r) {
      final journal = journalMap[r.journalId];
      if (journal == null) return false;
      return !journal.isLocked || unlockedIds.contains(r.journalId);
    }).toList();

    if (mounted) {
      setState(() {
        _journalResults = journalResults;
        _entryResults = entryResults;
      });
    }
  }

  Future<void> _applyPreset(SearchPreset preset) async {
    _queryCtrl.text = preset.query;
    setState(() {
      _query = preset.query;
      _filterEntries = preset.resultType == 'entries';
    });
    await _runSearch(preset.query);
  }

  Future<void> _savePreset() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _SavePresetDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;
    final db = ref.read(appDatabaseProvider);
    await db.searchPresetsDao.createPreset(
      SearchPresetsCompanion.insert(
        name: name,
        query: _query,
        resultType: Value(_filterEntries ? 'entries' : null),
      ),
    );
    await _loadPresets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search-query-field'),
          controller: _queryCtrl,
          decoration: const InputDecoration(
            hintText: 'Search journals & entries...',
            border: InputBorder.none,
          ),
          onChanged: _runSearch,
        ),
        actions: [
          if (_query.isNotEmpty) ...[
            IconButton(
              key: const Key('search-filter-entries'),
              icon: Icon(_filterEntries
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined),
              onPressed: () =>
                  setState(() => _filterEntries = !_filterEntries),
            ),
            IconButton(
              key: const Key('search-save-preset-button'),
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: _savePreset,
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preset chips
          if (_presets != null && _presets!.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                children: [
                  for (final preset in _presets!)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(preset.name),
                        onPressed: () => _applyPreset(preset),
                      ),
                    ),
                ],
              ),
            ),
          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_query.isEmpty) {
      return const Center(child: Text('Type to search'));
    }

    final journals = _journalResults ?? [];
    final entries = _entryResults ?? [];

    if (_filterEntries) {
      if (entries.isEmpty) {
        return const Center(
            child: Text('No matches found for this filter.'));
      }
      return ListView(
        children: [
          Container(
            key: const Key('search-section-entries'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                    title: Text('Entries',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                for (final e in entries)
                  ListTile(title: Text(e.title ?? 'Untitled')),
              ],
            ),
          ),
        ],
      );
    }

    if (journals.isEmpty && entries.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      children: [
        if (journals.isNotEmpty)
          Container(
            key: const Key('search-section-journals'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                    title: Text('Journals',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                for (final j in journals)
                  ListTile(title: Text(j.title)),
              ],
            ),
          ),
        if (entries.isNotEmpty)
          Container(
            key: const Key('search-section-entries'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                    title: Text('Entries',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                for (final e in entries)
                  ListTile(title: Text(e.title ?? 'Untitled')),
              ],
            ),
          ),
      ],
    );
  }
}

class _EntryTemplateChooserDialog extends StatelessWidget {
  const _EntryTemplateChooserDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = entryTemplatesByCategory;
    // SimpleDialog already wraps `children` in a SingleChildScrollView, so the
    // (now long) list scrolls without any custom sizing.
    return SimpleDialog(
      key: const Key('entry-template-chooser'),
      title: const Text('Choose a template'),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Text(
              entry.key.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          for (final template in entry.value)
            SimpleDialogOption(
              key: Key('entry-template-${template.id.name}'),
              onPressed: () => Navigator.pop(context, template),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(template.label),
                subtitle: Text(template.description),
              ),
            ),
        ],
      ],
    );
  }
}

class _SavePresetDialog extends StatefulWidget {
  const _SavePresetDialog();

  @override
  State<_SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<_SavePresetDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save search preset'),
      content: TextField(
        key: const Key('search-preset-name-field'),
        controller: _ctrl,
        decoration: const InputDecoration(labelText: 'Preset name'),
      ),
      actions: [
        TextButton(
          key: const Key('search-save-preset-confirm-button'),
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

