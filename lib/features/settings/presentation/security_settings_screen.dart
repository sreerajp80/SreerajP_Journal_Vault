import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/core/config/app_flavor_config.dart';
import 'package:sreerajp_journal_vault/core/security/keyboard_privacy_controller.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/entries/providers/ocr_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/app_lock_controller.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/auto_lock_profiles_screen.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/security_events_screen.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/tamper_alerts_screen.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/features/settings/presentation/locked_attachments_screen.dart';
import 'package:sreerajp_journal_vault/features/sync/presentation/conflict_resolution_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';
import 'package:sreerajp_journal_vault/core/security/keyboard_privacy_scope.dart';

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
      appBar: AppBar(title: Text(l10n.titleSettingsSectionSecurity)),
      body: ListView(
        key: const Key('settings-security-list'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.labelSettingsAppLockMode,
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
                  title: Text(l10n.labelLockModePhone),
                  subtitle: Text(l10n.descLockModePhone),
                ),
                RadioListTile<AppLockMode>(
                  key: const Key('settings-lock-mode-app'),
                  value: AppLockMode.appLock,
                  title: Text(l10n.labelLockModeApp),
                  subtitle: Text(l10n.descLockModeApp),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            key: const Key('settings-auto-lock-timeout'),
            title: Text(l10n.labelSettingsAutoLockTimeout),
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
            title: Text(l10n.titleLockedAttachments),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const LockedAttachmentsScreen(),
              ),
            ),
          ),
          const ScreenSecurityTile(),
          const KeyboardPrivacyTile(),
          const ScanCameraTile(),
          ListTile(
            key: const Key('settings-tamper-alerts'),
            title: Text(l10n.labelSettingsTamperAlerts),
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
              title: Text(l10n.labelSettingsSyncConflicts),
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
            title: Text(l10n.labelSettingsSecurityEvents),
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
        ? l10n.labelLockModeApp
        : l10n.labelLockModePhone;
    final disabledLabel = mode == AppLockMode.appLock
        ? l10n.labelLockModePhone
        : l10n.labelLockModeApp;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bodySettingsSwitchLock),
        content: Text(
          l10n.bodySettingsSwitchLockBody(modeLabel, disabledLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.actionCommonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.actionSettingsSwitch),
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

    // Switching locks the app straight away, and locking closes every open
    // screen, this one included (see JournalVaultApp), so this page does not
    // pop itself. The app-level messenger outlives this page, so it is taken
    // before the switch and the confirmation shows over the lock gate.
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(appLockProvider.notifier).switchLockMode(mode);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.descSettingsLockModeUpdated(modeLabel))),
    );
  }
}

/// Switch that decides which camera the editor's "Take photo" scan option
/// opens.
///
/// Off — the default — is the phone's own camera app, whose picture reads
/// best. A few camera apps also keep their own copy of the shot in the device
/// gallery, so turning this on keeps every scan inside the app instead.
class ScanCameraTile extends ConsumerWidget {
  const ScanCameraTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(ocrInAppCameraProvider);
    // While loading, or if the value could not be read, show the default.
    final enabled = state.value ?? false;

    return Semantics(
      toggled: enabled,
      label: l10n.labelSettingsScanInAppCamera,
      child: SwitchListTile(
        key: const Key('settings-scan-in-app-camera'),
        title: Text(l10n.labelSettingsScanInAppCamera),
        subtitle: Text(l10n.descSettingsScanInAppCamera),
        value: enabled,
        onChanged: state.isLoading
            ? null
            : (value) => ref
                  .read(ocrInAppCameraProvider.notifier)
                  .setUseInAppCamera(value),
      ),
    );
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
      label: l10n.labelSettingsScreenSecurity,
      child: SwitchListTile(
        key: const Key('settings-screen-security'),
        title: Text(l10n.labelSettingsScreenSecurity),
        subtitle: Text(l10n.descSettingsScreenSecurity),
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
          title: Text(l10n.bodySettingsScreenSecurityOff),
          content: Text(l10n.bodySettingsScreenSecurityOffBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.actionCommonCancel),
            ),
            TextButton(
              key: const Key('settings-screen-security-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.actionSettingsScreenSecurityOff),
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
          SnackBar(content: Text(l10n.errorSettingsScreenSecuritySave)),
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
                ? l10n.bodySettingsScreenSecurityUpdatedOn
                : l10n.bodySettingsScreenSecurityUpdatedOff,
          ),
        ),
      );
    }
  }
}

/// Switch that asks the keyboard not to learn from what is typed in the app.
///
/// On by default. The subtitle says what it is for. Turning it off asks for
/// confirmation first, because the keyboard may then remember journal words
/// and suggest them in other apps. A change applies the next time a text box
/// is tapped, when the keyboard connects again.
class KeyboardPrivacyTile extends ConsumerWidget {
  const KeyboardPrivacyTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(keyboardPrivacyProvider);

    return Semantics(
      toggled: enabled,
      label: l10n.labelSettingsKeyboardPrivacy,
      child: SwitchListTile(
        key: const Key('settings-keyboard-privacy'),
        title: Text(l10n.labelSettingsKeyboardPrivacy),
        subtitle: Text(l10n.descSettingsKeyboardPrivacy),
        value: enabled,
        onChanged: (value) => _setKeyboardPrivacy(context, ref, value),
      ),
    );
  }

  Future<void> _setKeyboardPrivacy(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (!enabled) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.bodySettingsKeyboardPrivacyOff),
          content: Text(l10n.bodySettingsKeyboardPrivacyOffBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.actionCommonCancel),
            ),
            TextButton(
              key: const Key('settings-keyboard-privacy-confirm'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.actionSettingsKeyboardPrivacyOff),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    try {
      await ref.read(keyboardPrivacyProvider.notifier).setEnabled(enabled);
    } on KeyboardPrivacyPersistenceException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSettingsKeyboardPrivacySave)),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? l10n.bodySettingsKeyboardPrivacyUpdatedOn
                : l10n.bodySettingsKeyboardPrivacyUpdatedOff,
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
      setState(() => _error = AppLocalizations.of(context).errorLockPin);
      return;
    }
    if (_pin.text != _confirm.text) {
      setState(
        () => _error = AppLocalizations.of(context).bodyLockPinsDoNotMatch,
      );
      return;
    }
    Navigator.pop(context, _pin.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.titleLockPinSetup),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('settings-pin-field'),
            enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(
              context,
            ),
            controller: _pin,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.labelLockPin),
          ),
          TextField(
            key: const Key('settings-pin-confirm-field'),
            enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(
              context,
            ),
            controller: _confirm,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.labelLockConfirmPin),
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
          child: Text(l10n.actionCommonCancel),
        ),
        TextButton(
          key: const Key('settings-pin-save-button'),
          onPressed: _save,
          child: Text(l10n.actionCommonSave),
        ),
      ],
    );
  }
}
