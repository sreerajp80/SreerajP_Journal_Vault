import 'package:flutter/material.dart';

import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
import 'package:sreerajp_journal_vault/core/l10n/app_locales.dart';
import 'package:sreerajp_journal_vault/core/theme/script_fonts.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Shown instead of the app when the encrypted vault cannot be opened.
///
/// Layer: presentation. It is a whole app of its own because it runs before
/// anything else exists — there is no database, so there are no providers and
/// no navigation shell to hang a screen on.
///
/// It deliberately offers nothing to press. Every action that would "fix" the
/// problem from here means deleting the vault, and a wrong guess by the app
/// would destroy a journal that a reinstall, a backup, or a repaired Keystore
/// might still recover.
class VaultUnavailableApp extends StatelessWidget {
  const VaultUnavailableApp({super.key, required this.failure, this.locale});

  final DatabaseOpenFailure failure;

  /// The user's saved language, read before the vault was opened. `null`
  /// follows the system language.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).titleApp,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9C5F2B)),
        fontFamilyFallback: appScriptFontFallback,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C5F2B),
          brightness: Brightness.dark,
        ),
        fontFamilyFallback: appScriptFontFallback,
      ),
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      localeResolutionCallback: resolveAppLocale,
      home: VaultUnavailableScreen(failure: failure),
    );
  }
}

/// The body of [VaultUnavailableApp], separated so a widget test can pump it.
class VaultUnavailableScreen extends StatelessWidget {
  const VaultUnavailableScreen({super.key, required this.failure});

  final DatabaseOpenFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.titleVaultUnavailable,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_reason(l10n), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  l10n.descVaultUnavailableDataIntact,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.descVaultUnavailableNextSteps,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _reason(AppLocalizations l10n) => switch (failure.kind) {
    DatabaseOpenFailureKind.keyUnavailable =>
      l10n.descVaultUnavailableKeyMissing,
    DatabaseOpenFailureKind.cipherUnavailable =>
      l10n.descVaultUnavailableCipherMissing,
    DatabaseOpenFailureKind.conversionFailed =>
      l10n.errorVaultUnavailableConversion,
    DatabaseOpenFailureKind.openFailed =>
      l10n.descVaultUnavailableFileUnreadable,
  };
}
