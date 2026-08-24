import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/auto_lock_profiles_screen.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/security_events_screen.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/tamper_alerts_screen.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/features/settings/presentation/locked_attachments_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/conflict_resolution_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lockState = ref.watch(appLockProvider);
    final lockMode = lockState.mode;
    final selectedMode = lockMode == AppLockMode.appLock
        ? AppLockMode.appLock
        : AppLockMode.phoneLock;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSectionSecurity)),
      body: ListView(
        key: const Key('settings-security-list'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.settingsAppLockMode,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          RadioGroup<AppLockMode>(
            groupValue: selectedMode,
            onChanged: (value) {
              if (value == null || value == selectedMode) return;
              _switchLock(context, ref, value);
            },
            child: Column(
              children: [
                RadioListTile<AppLockMode>(
                  key: const Key('settings-lock-mode-phone'),
                  value: AppLockMode.phoneLock,
                  title: Text(l10n.lockModePhone),
                  subtitle: Text(l10n.lockModePhoneHint),
                ),
                RadioListTile<AppLockMode>(
                  key: const Key('settings-lock-mode-app'),
                  value: AppLockMode.appLock,
                  title: Text(l10n.lockModeApp),
                  subtitle: Text(l10n.lockModeAppHint),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
                builder: (_) => const LockedAttachmentsScreen(),
              ),
            ),
          ),
          const ScreenSecurityTile(),
          ListTile(
            key: const Key('settings-tamper-alerts'),
            title: Text(l10n.settingsTamperAlerts),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TamperAlertsScreen(),
              ),
            ),
          ),
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
            ),
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
        builder: (_) => const PinSetupDialog(),
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
      // Switching locks the app straight away. The lock gate replaces the
      // shell underneath, so this pushed page must close — otherwise it
      // would keep sitting on top of the gate.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsLockModeUpdated(modeLabel))),
      );
    }
  }
}

/// Switch that turns FLAG_SECURE screenshot blocking on or off.
///
/// Protection is the default. Turning it off asks for confirmation first,
/// because it lets screenshots, screen recorders and the recent apps preview
/// capture journal content.
class ScreenSecurityTile extends ConsumerWidget {
  const ScreenSecurityTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(screenSecurityProvider);
    // While loading, or if the value could not be read, show it as protected —
    // that is what the window itself is doing.
    final enabled = state.value ?? true;

    return Semantics(
      toggled: enabled,
      label: l10n.settingsScreenSecurity,
      child: SwitchListTile(
        key: const Key('settings-screen-security'),
        title: Text(l10n.settingsScreenSecurity),
        subtitle: Text(l10n.settingsScreenSecuritySubtitle),
        value: enabled,
        onChanged: state.isLoading
            ? null
            : (value) => _setScreenSecurity(context, ref, value),
      ),
    );
  }

  Future<void> _setScreenSecurity(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (!enabled) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.settingsScreenSecurityOffTitle),
          content: Text(l10n.settingsScreenSecurityOffBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              key: const Key('settings-screen-security-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.settingsScreenSecurityOffAction),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    try {
      await ref.read(screenSecurityProvider.notifier).setEnabled(enabled);
    } on ScreenSecurityPersistenceException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsScreenSecuritySaveFailed)),
        );
      }
      return;
    }

    // The audit trail must not block the setting itself.
    try {
      await ref
          .read(securityEventServiceProvider)
          .logScreenSecurityChanged(enabled: enabled);
    } catch (_) {
      /* Logging failure is not worth interrupting the user for. */
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? l10n.settingsScreenSecurityUpdatedOn
                : l10n.settingsScreenSecurityUpdatedOff,
          ),
        ),
      );
    }
  }
}

class PinSetupDialog extends StatefulWidget {
  const PinSetupDialog({super.key});

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
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
