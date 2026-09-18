import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/core/l10n/locale_controller.dart';
import 'package:sreerajp_journal_vault/core/theme/accent_color_controller.dart';
import 'package:sreerajp_journal_vault/core/theme/script_fonts.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/core/utils/date_formatters.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_template_chooser_dialog.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/template_manager_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsule_sealed_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/time_capsules_list_screen.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/time_capsule_providers.dart';
import 'package:sreerajp_journal_vault/features/entries/templates/entry_templates.dart';
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

part 'app_home_tab.dart';
part 'app_journal_card.dart';
part 'app_journal_detail.dart';
part 'app_lock_setup_screens.dart';
part 'app_lock_widgets.dart';
part 'app_search_tab.dart';

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
    final appLanguage = ref.watch(localeControllerProvider);

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
      onGenerateTitle: (context) => AppLocalizations.of(context).titleApp,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appThemeMode.toFlutterThemeMode(),
      // null follows the system language (standard §8.4). The delegate list
      // includes the Sanskrit framework fallbacks and the Quill fallback.
      locale: appLanguage.locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      localeResolutionCallback: resolveAppLocale,
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
    fontFamilyFallback: appScriptFontFallback,
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
