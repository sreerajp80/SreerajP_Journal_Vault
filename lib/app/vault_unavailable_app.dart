import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sreerajp_journal_vault/core/database/database_open_failure.dart';
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
  const VaultUnavailableApp({super.key, required this.failure});

  final DatabaseOpenFailure failure;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9C5F2B)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C5F2B),
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
                    l10n.vaultUnavailableTitle,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_reason(l10n), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(
                  l10n.vaultUnavailableDataIntact,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.vaultUnavailableNextSteps,
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
    DatabaseOpenFailureKind.keyUnavailable => l10n.vaultUnavailableKeyMissing,
    DatabaseOpenFailureKind.cipherUnavailable =>
      l10n.vaultUnavailableCipherMissing,
    DatabaseOpenFailureKind.conversionFailed =>
      l10n.vaultUnavailableConversionFailed,
    DatabaseOpenFailureKind.openFailed => l10n.vaultUnavailableFileUnreadable,
  };
}
