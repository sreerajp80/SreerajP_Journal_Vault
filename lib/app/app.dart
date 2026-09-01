import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/l10n/quill_localizations_fallback.dart';
import 'package:sreerajp_journal_vault/core/theme/accent_color_controller.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/core/utils/date_formatters.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_template_chooser_dialog.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_manager_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_sealed_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsules_list_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
import 'package:sreerajp_journal_vault/features/export/export_strings.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/export_screen.dart';
import 'package:sreerajp_journal_vault/features/insights/presentation/insights_screen.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/providers/journal_lock_providers.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_password_service.dart';
import 'package:sreerajp_journal_vault/features/journal_lock/services/journal_secret_store.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/ritual/presentation/ritual_screen.dart';
import 'package:sreerajp_journal_vault/features/settings/presentation/settings_tab.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/conflict_resolution_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/sync_status_widget.dart';
import 'package:sreerajp_journal_vault/features/tags/domain/tag_colors.dart';
import 'package:sreerajp_journal_vault/features/tags/presentation/tag_manager_screen.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/domain/shared_intent_payload.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/presentation/quick_capture_share_dialog.dart';
import 'package:sreerajp_journal_vault/features/share_receiver/providers/share_receiver_providers.dart';
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

class _SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

final _selectedTabProvider = NotifierProvider<_SelectedTabNotifier, int>(
  _SelectedTabNotifier.new,
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

// ─── Helpers ──────────────────────────────────────────────────────────────

String _fmtDate(DateTime d) => formatShortDate(d);

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
  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);
    final appThemeMode = ref.watch(appThemeModeProvider);
    final accentColor = ref.watch(accentColorProvider);

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

    final lightTheme = switch (appThemeMode) {
      AppThemeMode.sepia => _appTheme(
        Brightness.light,
        accentColor,
        AppThemeMode.sepia,
      ),
      _ => _appTheme(Brightness.light, accentColor),
    };

    final darkTheme = switch (appThemeMode) {
      AppThemeMode.oled => _appTheme(
        Brightness.dark,
        accentColor,
        AppThemeMode.oled,
      ),
      _ => _appTheme(Brightness.dark, accentColor, AppThemeMode.dark),
    };

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appThemeMode.toFlutterThemeMode(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // Wrapped, not the package delegate itself: flutter_quill has no
        // Malayalam translation, and a missing Quill delegate makes the editor
        // throw and render as a grey box. See the fallback delegate's doc.
        quillLocalizationsFallbackDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }
}

ThemeData _appTheme(
  Brightness brightness, [
  Color seedColor = const Color(0xFF9C5F2B),
  AppThemeMode mode = AppThemeMode.light,
]) {
  ColorScheme colorScheme;

  if (mode == AppThemeMode.sepia) {
    final baseScheme = ColorScheme.fromSeed(seedColor: seedColor);
    colorScheme = baseScheme.copyWith(
      surface: const Color(0xFFF8F3E6),
      onSurface: const Color(0xFF2C221E),
      surfaceContainerLowest: const Color(0xFFFAF6EE),
      surfaceContainerLow: const Color(0xFFF2ECE0),
      surfaceContainer: const Color(0xFFEBE4D6),
      surfaceContainerHigh: const Color(0xFFE3DCCB),
      surfaceContainerHighest: const Color(0xFFDBD3C1),
      onSurfaceVariant: const Color(0xFF5C4D44),
      outline: const Color(0xFF8D7B6F),
      outlineVariant: const Color(0xFFD6CABA),
    );
  } else if (mode == AppThemeMode.oled) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    colorScheme = baseScheme.copyWith(
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFF4F4F5),
      surfaceContainerLowest: const Color(0xFF000000),
      surfaceContainerLow: const Color(0xFF09090B),
      surfaceContainer: const Color(0xFF111113),
      surfaceContainerHigh: const Color(0xFF18181B),
      surfaceContainerHighest: const Color(0xFF222226),
      onSurfaceVariant: const Color(0xFFA1A1AA),
      outline: const Color(0xFF52525B),
      outlineVariant: const Color(0xFF27272A),
    );
  } else {
    colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
  }

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
    scaffoldBackgroundColor: colorScheme.surface,
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
  bool _pinVisible = false;

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final lockState = ref.watch(appLockProvider);
    final isAppLock = lockState.mode == AppLockMode.appLock;
    final modeLabel = isAppLock ? l10n.lockModeApp : l10n.lockModePhone;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(
                colors.primary.withValues(alpha: 0.10),
                colors.surface,
              ),
              colors.surface,
              Color.alphaBlend(
                colors.primary.withValues(alpha: 0.06),
                colors.surfaceContainerHighest,
              ),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _LockGateEntrance(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LockBadge(),
                        const SizedBox(height: 28),
                        Text(
                          l10n.lockGateHeadline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.lockGateSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          child: _LockModeChip(
                            label: modeLabel,
                            icon: isAppLock
                                ? Icons.pin_rounded
                                : Icons.phonelink_lock_rounded,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _LockCard(
                          child: isAppLock
                              ? _buildAppLockControls(context, l10n)
                              : _buildPhoneLockControls(context, l10n),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _error == null
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: _LockErrorPill(message: _error!),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLockControls(BuildContext context, AppLocalizations l10n) {
    return _LockActionButton(
      buttonKey: const Key('phone-lock-unlock-button'),
      icon: Icons.fingerprint_rounded,
      label: l10n.lockUnlockWithPhone,
      busy: _busy,
      onPressed: _unlockBiometric,
    );
  }

  Widget _buildAppLockControls(BuildContext context, AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('app-lock-pin-field'),
          controller: _pinController,
          obscureText: !_pinVisible,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            letterSpacing: _pinVisible ? 6 : 10,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: l10n.lockPinLabel,
            filled: true,
            fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            suffixIcon: IconButton(
              tooltip: _pinVisible
                  ? l10n.lockGateHidePin
                  : l10n.lockGateShowPin,
              icon: Icon(
                _pinVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onPressed: () => setState(() => _pinVisible = !_pinVisible),
            ),
          ),
          onSubmitted: (_) => _unlockPin(),
        ),
        const SizedBox(height: 16),
        _LockActionButton(
          buttonKey: const Key('app-lock-unlock-button'),
          icon: Icons.lock_open_rounded,
          label: l10n.commonUnlock,
          busy: _busy,
          onPressed: _unlockPin,
        ),
      ],
    );
  }
}

/// One-shot fade and rise played when the lock screen appears.
class _LockGateEntrance extends StatelessWidget {
  const _LockGateEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Circular lock icon with a soft ring — the focal point of the lock screen.
class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: l10n.lockGateBadgeSemantics,
      child: Center(
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 42,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill naming the active lock mode.
class _LockModeChip extends StatelessWidget {
  const _LockModeChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded surface holding the unlock controls.
class _LockCard extends StatelessWidget {
  const _LockCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Full-width unlock button that shows progress while an unlock is running.
class _LockActionButton extends StatelessWidget {
  const _LockActionButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: 54,
        child: FilledButton.icon(
          key: buttonKey,
          onPressed: busy ? null : onPressed,
          icon: busy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}

/// Themed error message shown under the unlock card.
class _LockErrorPill extends StatelessWidget {
  const _LockErrorPill({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: colors.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main shell with bottom navigation ────────────────────────────────────

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPendingShare();
    });
  }

  void _checkInitialPendingShare() {
    final payload = ref.read(pendingSharePayloadProvider);
    if (payload != null && !_dialogShowing && mounted) {
      _showShareDialog(payload);
    }
  }

  void _showShareDialog(SharedIntentPayload payload) {
    if (_dialogShowing || !mounted) return;
    _dialogShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => QuickCaptureShareDialog(
        payload: payload,
        onDismissed: () {
          _dialogShowing = false;
          ref.read(pendingSharePayloadProvider.notifier).consumePayload();
        },
      ),
    ).then((_) {
      _dialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SharedIntentPayload?>(pendingSharePayloadProvider, (prev, next) {
      if (next != null && !_dialogShowing && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showShareDialog(next);
        });
      }
    });

    final l10n = AppLocalizations.of(context);
    final index = ref.watch(_selectedTabProvider);
    const tabs = [
      _HomeTab(),
      _SearchTab(),
      TimelineScreen(),
      InsightsScreen(),
      SettingsTab(),
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
          IconButton(
            key: const Key('home-ritual-mode-button'),
            tooltip: l10n.ritualScreenTitle,
            icon: const Icon(Icons.self_improvement_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const RitualScreen()),
            ).then((_) => _load()),
          ),
          IconButton(
            key: const Key('home-manage-templates-button'),
            tooltip: l10n.journalManageTemplates,
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TemplateManagerScreen(),
              ),
            ),
          ),
          IconButton(
            key: const Key('home-time-capsules-button'),
            tooltip: l10n.timeCapsuleTitle,
            icon: const Icon(Icons.hourglass_bottom_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TimeCapsulesListScreen(),
              ),
            ).then((_) => _load()),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final readyAsync = ref.watch(readyToOpenCapsulesProvider);
              final readyCount = readyAsync.asData?.value.length ?? 0;
              if (readyCount == 0) return const SizedBox.shrink();
              final theme = Theme.of(context);
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.timeCapsuleBannerTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            readyCount == 1
                                ? l10n.timeCapsuleBannerBody(readyCount)
                                : l10n.timeCapsuleBannerBodyPlural(readyCount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      key: const Key('home-ready-capsule-open-button'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const TimeCapsulesListScreen(),
                        ),
                      ).then((_) => _load()),
                      child: Text(l10n.timeCapsuleReadyToOpen),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: journals == null
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
                              builder: (_) => _JournalDetailScreen(
                                journal: summary.journal,
                              ),
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
          ),
        ],
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
  Map<int, TimeCapsule> _capsules = {};
  String? _unlockError;
  final _passwordController = TextEditingController();

  bool get _isSessionUnlocked {
    final ids = ref.read(unlockedJournalIdsProvider);
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
    final allCapsules = await db.timeCapsulesDao.getAllCapsules();
    final capsulesMap = {for (final c in allCapsules) c.entryId: c};
    if (mounted) {
      setState(() {
        _entries = entries;
        _capsules = capsulesMap;
      });
    }
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
      final current = ref.read(unlockedJournalIdsProvider);
      ref.read(unlockedJournalIdsProvider.notifier).set({
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
    EntryTemplate? template;
    if (entry == null) {
      // For new entries, ask the user to pick a starter template first.
      final selected = await showDialog<EntryTemplate>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const EntryTemplateChooserDialog(),
      );
      if (!mounted) return;
      if (selected == null) return; // User dismissed somehow.
      template = selected;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EntryEditorScreen(
          journalId: widget.journal.id,
          entryId: entry?.id,
          initialTemplateId: template?.id,
          initialTemplate: template,
        ),
      ),
    );
    if (mounted) await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(unlockedJournalIdsProvider); // Rebuild on unlock change
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
                    final capsule = _capsules[entry.id];
                    final isCapsule = capsule != null;
                    final isSealed = isCapsule && !capsule.isOpened;
                    final isReady =
                        isSealed &&
                        !DateTime.now().isBefore(capsule.unlockDate);

                    Widget? leading;
                    Widget subtitle;
                    if (isSealed) {
                      leading = Icon(
                        isReady
                            ? Icons.lock_open_rounded
                            : Icons.hourglass_bottom_rounded,
                        color: isReady
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      );
                      subtitle = Text(
                        isReady
                            ? l10n.timeCapsuleReadyToOpen
                            : l10n.timeCapsuleSealedUntil(
                                _fmtDate(capsule.unlockDate),
                              ),
                        style: TextStyle(
                          color: isReady
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          fontWeight: isReady
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    } else {
                      subtitle = Text(_fmtDate(date));
                    }

                    return ListTile(
                      leading: leading,
                      title: Text(entry.title ?? l10n.commonUntitled),
                      subtitle: subtitle,
                      onTap: () {
                        if (isSealed) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => TimeCapsuleSealedScreen(
                                entryId: entry.id,
                                journalId: widget.journal.id,
                              ),
                            ),
                          ).then((_) => _loadEntries());
                        } else {
                          _openEntryScreen(entry: entry);
                        }
                      },
                    );
                  },
                ),
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
    final unlockedIds = ref.read(unlockedJournalIdsProvider);

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
