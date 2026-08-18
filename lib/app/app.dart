import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/about_screen.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_crypto_storage.dart';
import 'package:sreerajp_journal_vault/features/backup/presentation/backup_health_screen.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/open_encrypted_export_screen.dart';
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
import 'package:sreerajp_journal_vault/features/tags/domain/tag_colors.dart';
import 'package:sreerajp_journal_vault/features/tags/presentation/tag_manager_screen.dart';
import 'package:sreerajp_journal_vault/features/timeline/presentation/timeline_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

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

final _themeModeProvider = NotifierProvider<_ThemeModeNotifier, ThemeMode>(
  _ThemeModeNotifier.new,
);
final _selectedTabProvider = NotifierProvider<_SelectedTabNotifier, int>(
  _SelectedTabNotifier.new,
);
final _unlockedJournalIdsProvider =
    NotifierProvider<_UnlockedJournalIdsNotifier, Set<int>>(
      _UnlockedJournalIdsNotifier.new,
    );

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

final appLockProvider = NotifierProvider<AppLockNotifier, AppLockState>(
  AppLockNotifier.new,
);

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
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: _appTheme(Brightness.light),
      darkTheme: _appTheme(Brightness.dark),
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
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
        setState(() => _error = AppLocalizations.of(context).lockPinTooShort);
        return;
      }
      if (_pin.text != _confirm.text) {
        setState(
          () => _error = AppLocalizations.of(context).lockPinsDoNotMatch,
        );
        return;
      }
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(appLockProvider.notifier)
          .completeFirstLaunchSetup(
            mode: _selected,
            pin: _selected == AppLockMode.appLock ? _pin.text : null,
          );
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(
            context,
          ).lockSetupSaveFailed(error.toString());
          _busy = false;
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAppLock = _selected == AppLockMode.appLock;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockSetupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.lockSetupBody),
            const SizedBox(height: 16),
            RadioGroup<AppLockMode>(
              groupValue: _selected,
              onChanged: (v) {
                if (v != null) setState(() => _selected = v);
              },
              child: Column(
                children: [
                  RadioListTile<AppLockMode>(
                    key: const Key('first-launch-mode-phone'),
                    value: AppLockMode.phoneLock,
                    title: Text(l10n.lockModePhone),
                    subtitle: Text(l10n.lockModePhoneHint),
                  ),
                  RadioListTile<AppLockMode>(
                    key: const Key('first-launch-mode-app'),
                    value: AppLockMode.appLock,
                    title: Text(l10n.lockModeApp),
                    subtitle: Text(l10n.lockModeAppHint),
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
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(labelText: l10n.lockPinLabel),
              ),
              TextField(
                key: const Key('first-launch-pin-confirm-field'),
                controller: _confirm,
                obscureText: true,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  labelText: l10n.lockConfirmPinLabel,
                ),
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
              child: Text(_busy ? l10n.lockSettingUp : l10n.commonContinue),
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
      } catch (_) {
        /* attachment missing — skip */
      }
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
    final l10n = AppLocalizations.of(context);
    final entries = _entries;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockedAttachmentsTitle)),
      body: entries == null
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.lockedAttachmentsEmpty,
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
                  subtitle: Text(
                    l10n.lockedAttachmentSince(_fmtDate(lock.lockedAt)),
                  ),
                  trailing: TextButton(
                    key: Key('locked-attachment-remove-${attachment.id}'),
                    onPressed: () => _remove(attachment.id),
                    child: Text(l10n.lockedAttachmentRemove),
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
      setState(() => _error = AppLocalizations.of(context).lockPinTooShort);
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = AppLocalizations.of(context).lockPinsDoNotMatch);
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
          _error = AppLocalizations.of(
            context,
          ).lockPinSaveFailed(error.toString());
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockPinSetupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.lockPinSetupBody),
            const SizedBox(height: 16),
            TextField(
              key: const Key('pin-setup-field'),
              controller: _pin,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.lockPinLabel),
            ),
            TextField(
              key: const Key('pin-setup-confirm-field'),
              controller: _confirm,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.lockConfirmPinLabel),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('pin-setup-save-button'),
              onPressed: _busy ? null : _save,
              child: Text(_busy ? l10n.commonSaving : l10n.commonSave),
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
    final result = await ref
        .read(appLockProvider.notifier)
        .unlockWithBiometric();
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case BiometricAuthResult.success:
          _error = null;
          break;
        case BiometricAuthResult.failed:
          _error = AppLocalizations.of(context).lockAuthFailed;
          break;
        case BiometricAuthResult.unavailable:
          _error = AppLocalizations.of(context).lockAuthUnavailable;
          break;
      }
    });
  }

  Future<void> _unlockPin() async {
    if (_busy) return;
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).lockEnterPin);
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
        _error = AppLocalizations.of(context).lockIncorrectPin;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lockState = ref.watch(appLockProvider);
    final isAppLock = lockState.mode == AppLockMode.appLock;
    final modeLabel = isAppLock ? l10n.lockModeApp : l10n.lockModePhone;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockGateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(modeLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            if (isAppLock) ...[
              TextField(
                key: const Key('app-lock-pin-field'),
                controller: _pinController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.lockPinLabel,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _unlockPin(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('app-lock-unlock-button'),
                onPressed: _busy ? null : _unlockPin,
                child: Text(l10n.commonUnlock),
              ),
            ] else ...[
              ElevatedButton(
                key: const Key('phone-lock-unlock-button'),
                onPressed: _busy ? null : _unlockBiometric,
                child: Text(l10n.lockUnlockWithPhone),
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
    final l10n = AppLocalizations.of(context);
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: const Icon(Icons.saved_search_rounded),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.navTimeline,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_graph_outlined),
            selectedIcon: const Icon(Icons.auto_graph_rounded),
            label: l10n.navInsights,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
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
      items.add(
        _JournalSummary(
          journal: j,
          tags: tags,
          entryCount: entries.length,
          lastUpdatedAt: lastUpdated,
        ),
      );
    }
    if (mounted) setState(() => _journals = items);
  }

  Future<void> _openForm({
    Journal? journal,
    List<Tag> initialTags = const [],
  }) async {
    final result =
        await showDialog<
          ({
            String title,
            String desc,
            String tags,
            bool locked,
            String? password,
          })
        >(
          context: context,
          builder: (_) =>
              _JournalFormDialog(journal: journal, initialTags: initialTags),
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
      await _applyJournalTags(db, journalId, result.tags);
      // Lock if requested
      if (result.locked &&
          result.password != null &&
          result.password!.isNotEmpty) {
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
      await _applyJournalTags(db, journalId, result.tags);
    }
    await _load();
  }

  /// Makes the journal's tags match [tagsText], a comma separated list.
  ///
  /// Only the difference is written: tags already on the journal are left
  /// alone, names that were removed from the text are unlinked, and new names
  /// are created if they do not exist yet. Unlinking never deletes the tag
  /// itself — tags are global and may be in use elsewhere.
  Future<void> _applyJournalTags(
    AppDatabase db,
    int journalId,
    String tagsText,
  ) async {
    final wanted = tagsText
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    final current = await db.journalTagsDao.getTagsForJournal(journalId);
    final currentNames = {for (final tag in current) tag.name: tag};

    for (final tag in current) {
      if (!wanted.contains(tag.name)) {
        await db.journalTagsDao.removeTagFromJournal(journalId, tag.id);
      }
    }
    for (final name in wanted) {
      if (currentNames.containsKey(name)) continue;
      final tagId = await db.tagsDao.getOrCreateTag(name);
      await db.journalTagsDao.addTagToJournal(journalId, tagId);
    }
  }

  Future<void> _deleteJournal(Journal journal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.journalDeleteTitle),
          content: Text(l10n.journalDeleteBody(journal.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
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
    final l10n = AppLocalizations.of(context);
    final journals = _journals;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: [
          if (AppFlavorConfig.instance.enableSyncUi) ...[
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
          IconButton(
            tooltip: l10n.journalManageTags,
            icon: const Icon(Icons.sell_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const TagManagerScreen()),
            ).then((_) => _load()),
          ),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        tooltip: l10n.journalNew,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.journalNew),
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
            Text(
              AppLocalizations.of(context).journalEmptyTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).journalEmptyBody,
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
                                color: colorForTag(tag),
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
                            tooltip: AppLocalizations.of(context).journalEdit,
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
                            tooltip: AppLocalizations.of(context).journalDelete,
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
    _desc = TextEditingController(text: widget.journal?.description ?? '');
    _tags = TextEditingController(
      text: widget.initialTags.map((t) => t.name).join(', '),
    );
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
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.journal != null;
    return AlertDialog(
      title: Text(isEdit ? l10n.journalEdit : l10n.journalNew),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.journalTitleLabel),
            ),
            TextFormField(
              controller: _desc,
              decoration: InputDecoration(
                labelText: l10n.journalDescriptionLabel,
              ),
            ),
            TextFormField(
              controller: _tags,
              decoration: InputDecoration(labelText: l10n.journalTagsLabel),
            ),
            // Locking is only offered at creation time — changing the password
            // of an existing journal is a separate flow.
            if (!isEdit) ...[
              SwitchListTile(
                title: Text(l10n.journalLockSwitch),
                value: _lockJournal,
                onChanged: (v) => setState(() => _lockJournal = v),
              ),
              if (_lockJournal) ...[
                TextFormField(
                  key: const Key('journal-password-field'),
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.commonPassword),
                ),
                TextFormField(
                  key: const Key('journal-password-confirm-field'),
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.journalConfirmPasswordLabel,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, (
            title: _title.text,
            desc: _desc.text,
            tags: _tags.text,
            locked: _lockJournal,
            password: _password.text.isEmpty ? null : _password.text,
          )),
          child: Text(l10n.commonSave),
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

class _JournalDetailScreenState extends ConsumerState<_JournalDetailScreen> {
  List<Entry>? _entries;
  String? _unlockError;
  final _passwordController = TextEditingController();

  bool get _isSessionUnlocked {
    final ids = ref.read(_unlockedJournalIdsProvider);
    return ids.contains(widget.journal.id);
  }

  bool get _isAccessible => !widget.journal.isLocked || _isSessionUnlocked;

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
    final entries = await db.entriesDao.getEntriesForJournal(widget.journal.id);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _tryUnlock() async {
    final password = _passwordController.text;
    final svc = ref.read(_journalPasswordServiceProvider);
    final ok = await svc.verifyPassword(
      journal: widget.journal,
      password: password,
    );
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
      setState(
        () => _unlockError = AppLocalizations.of(
          context,
        ).journalIncorrectPassword,
      );
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
      appBar: AppBar(
        title: Text(widget.journal.title),
        actions: [
          // Only once the journal is open. A locked journal must be unlocked
          // before any of it can be written out.
          if (accessible)
            IconButton(
              key: const Key('journal-export-button'),
              icon: const Icon(Icons.ios_share),
              tooltip: ExportStrings.exportJournalTooltip,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ExportScreen(
                    journalId: widget.journal.id,
                    journalTitle: widget.journal.title,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: accessible
          ? FloatingActionButton.extended(
              onPressed: () => _openEntryScreen(),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).journalAddEntry),
            )
          : null,
      body: accessible ? _buildEntries() : _buildLocked(),
    );
  }

  Widget _buildLocked() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.journalIsLocked),
          const SizedBox(height: 16),
          TextField(
            key: const Key('journal-unlock-password-field'),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.commonPassword),
          ),
          if (_unlockError != null) ...[
            const SizedBox(height: 8),
            Text(_unlockError!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('journal-unlock-button'),
            onPressed: _tryUnlock,
            child: Text(l10n.commonUnlock),
          ),
        ],
      ),
    );
  }

  Widget _buildEntries() {
    final l10n = AppLocalizations.of(context);
    final entries = _entries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.journalUnlocked),
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
                      title: Text(entry.title ?? l10n.commonUntitled),
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
    final l10n = AppLocalizations.of(context);
    final lockState = ref.watch(appLockProvider);
    final lockMode = lockState.mode;
    final themeMode = ref.watch(_themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        key: const Key('settings-list'),
        children: [
          // ── Section 1: Security ──────────────────────────────────────
          _SectionHeader(l10n.settingsSectionSecurity),
          ListTile(title: Text(l10n.settingsAppLockMode)),
          ListTile(
            title: Text(l10n.lockModePhone),
            selected: lockMode != AppLockMode.appLock,
            onTap: lockMode != AppLockMode.appLock
                ? null
                : () => _switchLock(context, ref, AppLockMode.phoneLock),
          ),
          ListTile(
            title: Text(l10n.lockModeApp),
            selected: lockMode == AppLockMode.appLock,
            onTap: lockMode == AppLockMode.appLock
                ? null
                : () => _switchLock(context, ref, AppLockMode.appLock),
          ),
          ListTile(
            key: const Key('settings-auto-lock-timeout'),
            title: Text(l10n.settingsAutoLockTimeout),
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
            title: Text(l10n.lockedAttachmentsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const _LockedAttachmentsScreen(),
              ),
            ),
          ),
          _ComingSoonTile(title: l10n.settingsTamperAlerts),
          // Sync has no transport yet — see AppFlavorConfig.enableSyncUi.
          if (AppFlavorConfig.instance.enableSyncUi)
            ListTile(
              key: const Key('settings-sync-conflicts'),
              title: Text(l10n.settingsSyncConflicts),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const ConflictResolutionScreen(),
                ),
              ),
            )
          else
            _ComingSoonTile(title: l10n.settingsSyncConflicts),
          ListTile(
            key: const Key('settings-security-events'),
            title: Text(l10n.settingsSecurityEvents),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SecurityEventsScreen(),
              ),
            ),
          ),

          // ── Section 2: Appearance ────────────────────────────────────
          _SectionHeader(l10n.settingsSectionAppearance),
          ListTile(
            title: Text(l10n.settingsTheme),
            subtitle: Text(l10n.settingsThemeSubtitle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final (label, mode) in [
                  (l10n.settingsThemeLight, ThemeMode.light),
                  (l10n.settingsThemeDark, ThemeMode.dark),
                ])
                  ChoiceChip(
                    key: Key('settings-theme-chip-${mode.name}'),
                    label: Text(label),
                    selected: themeMode == mode,
                    onSelected: (_) => _switchTheme(context, ref, mode),
                  ),
              ],
            ),
          ),

          // ── Section 3: Storage ───────────────────────────────────────
          _SectionHeader(l10n.settingsSectionStorage),
          const _StorageSection(),

          // ── Section 4: Permissions ───────────────────────────────────
          _SectionHeader(l10n.settingsSectionPermissions),
          const _PermissionsSection(),

          // ── Section 5: About ─────────────────────────────────────────
          _SectionHeader(l10n.settingsSectionAbout),
          ListTile(
            title: Text(l10n.settingsAbout),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchLock(
    BuildContext context,
    WidgetRef ref,
    AppLockMode mode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final modeLabel = mode == AppLockMode.appLock
        ? l10n.lockModeApp
        : l10n.lockModePhone;
    final disabledLabel = mode == AppLockMode.appLock
        ? l10n.lockModePhone
        : l10n.lockModeApp;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsSwitchLockTitle),
        content: Text(l10n.settingsSwitchLockBody(modeLabel, disabledLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.settingsSwitchAction),
          ),
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
        SnackBar(content: Text(l10n.settingsLockModeUpdated(modeLabel))),
      );
    }
  }

  Future<void> _switchTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final prev = ref.read(_themeModeProvider);
    ref.read(_themeModeProvider.notifier).set(mode);

    bool failed = false;
    try {
      final store = ref.read(themeModeStoreProvider);
      await store.save(mode);
    } on ThemeModePersistenceException {
      failed = true;
    } catch (_) {
      /* No store or other error → treat as success */
    }

    if (!context.mounted) return;

    if (failed) {
      ref.read(_themeModeProvider.notifier).set(prev);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsThemeSaveFailed)));
    } else {
      final label = switch (mode) {
        ThemeMode.dark => l10n.settingsThemeDark,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.system => l10n.settingsThemeSystem,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsThemeUpdated(label))));
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
      setState(() => _error = AppLocalizations.of(context).lockPinTooShort);
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(() => _error = AppLocalizations.of(context).lockPinsDoNotMatch);
      return;
    }
    Navigator.pop(context, _pin.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.lockPinSetupTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('settings-pin-field'),
            controller: _pin,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.lockPinLabel),
          ),
          TextField(
            key: const Key('settings-pin-confirm-field'),
            controller: _confirm,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.lockConfirmPinLabel),
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
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          key: const Key('settings-pin-save-button'),
          onPressed: _save,
          child: Text(l10n.commonSave),
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
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
      trailing: Text(AppLocalizations.of(context).settingsComingSoon),
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
    final total = attachments.fold<int>(0, (sum, a) => sum + a.sizeBytes);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _totalBytes = total;
    });
  }

  String _locationLabel(AppLocalizations l10n, AppSetting s) {
    final loc = AttachmentStorageLocation.fromSettingsValue(
      s.attachmentStorageLocation,
    );
    if (loc != AttachmentStorageLocation.sdCard) return l10n.storageAppPrivate;
    final label = s.attachmentStorageTreeLabel;
    return label == null ? l10n.storageSdCard : l10n.storageSdCardNamed(label);
  }

  /// `attachmentMigrationStatus` is a database code, not text for the user.
  String _migrationStatusLabel(AppLocalizations l10n, AppSetting s) {
    switch (s.attachmentMigrationStatus) {
      case 'running':
        return l10n.storageMigrationRunning(
          s.attachmentMigrationProcessedCount,
          s.attachmentMigrationTotalCount,
        );
      case 'failed':
        return s.attachmentMigrationFailure ?? l10n.storageMigrationFailedShort;
      default:
        return l10n.storageMigrationIdle;
    }
  }

  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 1024) return l10n.storageBytes(bytes);
    if (bytes < 1024 * 1024) {
      return l10n.storageKilobytes((bytes / 1024).toStringAsFixed(1));
    }
    if (bytes < 1024 * 1024 * 1024) {
      return l10n.storageMegabytes((bytes / (1024 * 1024)).toStringAsFixed(1));
    }
    return l10n.storageGigabytes(
      (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2),
    );
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
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.storageMigrateTitle),
          content: Text(
            l10n.storageMigrateBody(
              target == AttachmentStorageLocation.sdCard
                  ? l10n.storageSdCard
                  : l10n.storageAppPrivate,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.storageMigrateAction),
            ),
          ],
        );
      },
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
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (cancelled) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageMigrationCancelled)),
      );
    } else if (errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageMigrationFailed(errorMessage))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.storageMigrationComplete)),
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
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        ListTile(
          key: const Key('settings-attachment-storage-location'),
          title: Text(l10n.storageLocationTitle),
          subtitle: Text(_locationLabel(l10n, settings)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final selection = await showDialog<AttachmentStorageLocation>(
              context: context,
              builder: (dialogContext) {
                final l10n = AppLocalizations.of(dialogContext);
                return SimpleDialog(
                  title: Text(l10n.storageLocationDialogTitle),
                  children: [
                    SimpleDialogOption(
                      key: const Key('storage-location-app-private'),
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        AttachmentStorageLocation.appPrivate,
                      ),
                      child: Text(l10n.storageAppPrivate),
                    ),
                    SimpleDialogOption(
                      key: const Key('storage-location-sd-card'),
                      onPressed: () => Navigator.pop(
                        dialogContext,
                        AttachmentStorageLocation.sdCard,
                      ),
                      child: Text(l10n.storageSdCard),
                    ),
                  ],
                );
              },
            );
            if (selection != null) await _changeLocation(selection);
          },
        ),
        ListTile(
          key: const Key('settings-migrate-storage'),
          title: Text(l10n.storageMigrateRow),
          subtitle: Text(_migrationStatusLabel(l10n, settings)),
          trailing: canRetry
              ? TextButton(
                  key: const Key('settings-migrate-storage-retry'),
                  onPressed: _retryMigration,
                  child: Text(l10n.commonRetry),
                )
              : null,
        ),
        ListTile(
          key: const Key('settings-storage-usage'),
          title: Text(l10n.storageUsage),
          subtitle: Text(
            _totalBytes == null
                ? l10n.storageUnknown
                : _formatBytes(l10n, _totalBytes!),
          ),
        ),
        ListTile(
          key: const Key('settings-backup-health'),
          title: Text(l10n.storageBackupHealth),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const BackupHealthScreen()),
          ),
        ),
        ListTile(
          key: const Key('settings-import-data'),
          title: Text(l10n.storageImportData),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickImportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-export-data'),
          title: const Text(ExportStrings.exportDataTile),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _pickExportTarget(context, ref),
        ),
        ListTile(
          key: const Key('settings-open-encrypted-export'),
          title: Text(l10n.settingsOpenEncryptedExport),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const OpenEncryptedExportScreen(),
            ),
          ),
        ),
        // Sync has no transport yet — see AppFlavorConfig.enableSyncUi.
        if (AppFlavorConfig.instance.enableSyncUi)
          ListTile(
            key: const Key('settings-sync-health'),
            title: Text(l10n.storageSyncHealth),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (routeContext) => Scaffold(
                  appBar: AppBar(
                    title: Text(
                      AppLocalizations.of(routeContext).storageSyncHealth,
                    ),
                  ),
                  body: const SyncHealthDashboard(),
                ),
              ),
            ),
          )
        else
          _ComingSoonTile(title: l10n.storageSyncHealth),
      ],
    );
  }

  Future<void> _pickImportTarget(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!context.mounted) return;
    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).storageImportNeedsJournal),
        ),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(
          AppLocalizations.of(dialogContext).storageImportChooseJournal,
        ),
        children: [
          for (final j in journals)
            SimpleDialogOption(
              key: Key('import-target-journal-${j.id}'),
              onPressed: () => Navigator.pop(dialogContext, j),
              child: Text(j.title),
            ),
        ],
      ),
    );
    if (selected == null || !context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            ImportScreen(journalId: selected.id, journalTitle: selected.title),
      ),
    );
  }

  /// Asks which journal to export from, then opens the export screen.
  ///
  /// **Locked journals are not offered here.** The journal detail screen is
  /// where a lock is opened; a journal the user has not unlocked this session
  /// must not be exportable from a settings menu that never asked for the
  /// password. If every journal is locked, the user is told to open one first
  /// rather than being shown an empty list.
  Future<void> _pickExportTarget(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final journals = await db.journalsDao.getAllJournals();
    if (!context.mounted) return;

    if (journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ExportStrings.noJournalsToExport)),
      );
      return;
    }

    final unlockedIds = ref.read(_unlockedJournalIdsProvider);
    final available = journals
        .where((j) => !j.isLocked || unlockedIds.contains(j.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ExportStrings.allJournalsLocked)),
      );
      return;
    }

    final selected = await showDialog<Journal>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text(ExportStrings.chooseJournalToExport),
        children: [
          for (final j in available)
            SimpleDialogOption(
              key: Key('export-target-journal-${j.id}'),
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
        builder: (_) =>
            ExportScreen(journalId: selected.id, journalTitle: selected.title),
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
    final l10n = AppLocalizations.of(context);
    final c = widget.controller;
    final progress = c.total == 0 ? null : c.processed / c.total;
    return AlertDialog(
      title: Text(l10n.migrationDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          Text(
            c.cancelRequested
                ? l10n.migrationCancelling
                : l10n.migrationProgress(
                    '${c.processed}',
                    c.total == 0 ? l10n.migrationUnknownTotal : '${c.total}',
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('migration-cancel-button'),
          onPressed: c.cancelRequested ? null : c.cancel,
          child: Text(l10n.commonCancel),
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

  String _summary(AppLocalizations l10n) {
    final s = _snapshot;
    if (s == null) return l10n.storageUnknown;
    final all = [...s.explicitPermissions, ...s.implicitPermissions];
    final granted = all
        .where((p) => p.status == AppPermissionState.granted)
        .length;
    return l10n.permissionsGrantedSummary(granted, all.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ListTile(
          key: const Key('settings-permissions-status'),
          title: Text(l10n.permissionStatusRow),
          subtitle: Text(_summary(l10n)),
        ),
        ListTile(
          key: const Key('settings-manage-permissions'),
          title: Text(l10n.permissionsManage),
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
          title: Text(l10n.permissionsOpenSystem),
          trailing: const Icon(Icons.open_in_new),
          onTap: () async {
            try {
              await ref
                  .read(appPermissionsServiceProvider)
                  .openSystemSettings();
            } catch (_) {
              /* permissions service not available */
            }
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
        .where((j) => j.title.toLowerCase().contains(trimmed.toLowerCase()))
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const Key('search-query-field'),
          controller: _queryCtrl,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _runSearch,
        ),
        actions: [
          if (_query.isNotEmpty) ...[
            IconButton(
              key: const Key('search-filter-entries'),
              icon: Icon(
                _filterEntries ? Icons.filter_alt : Icons.filter_alt_outlined,
              ),
              onPressed: () => setState(() => _filterEntries = !_filterEntries),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  for (final preset in _presets!)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
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
    final l10n = AppLocalizations.of(context);
    if (_query.isEmpty) {
      return Center(child: Text(l10n.searchTypeToSearch));
    }

    final journals = _journalResults ?? [];
    final entries = _entryResults ?? [];

    if (_filterEntries) {
      if (entries.isEmpty) {
        return Center(child: Text(l10n.searchNoFilterMatches));
      }
      return ListView(
        children: [
          Container(
            key: const Key('search-section-entries'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    l10n.searchSectionEntries,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final e in entries)
                  ListTile(title: Text(e.title ?? l10n.commonUntitled)),
              ],
            ),
          ),
        ],
      );
    }

    if (journals.isEmpty && entries.isEmpty) {
      return Center(child: Text(l10n.searchNoResults));
    }

    return ListView(
      children: [
        if (journals.isNotEmpty)
          Container(
            key: const Key('search-section-journals'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    l10n.searchSectionJournals,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final j in journals) ListTile(title: Text(j.title)),
              ],
            ),
          ),
        if (entries.isNotEmpty)
          Container(
            key: const Key('search-section-entries'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    l10n.searchSectionEntries,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final e in entries)
                  ListTile(title: Text(e.title ?? l10n.commonUntitled)),
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
      title: Text(AppLocalizations.of(context).templateChooserTitle),
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.searchSavePresetTitle),
      content: TextField(
        key: const Key('search-preset-name-field'),
        controller: _ctrl,
        decoration: InputDecoration(labelText: l10n.searchPresetNameLabel),
      ),
      actions: [
        TextButton(
          key: const Key('search-save-preset-confirm-button'),
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
