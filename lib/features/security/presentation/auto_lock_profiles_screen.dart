import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/security/providers/security_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// CRUD screen for the [AutoLockProfiles] table. Surfaces the active
/// profile and lets the user create / edit / delete profiles. Activating a
/// profile deactivates all others via [AutoLockService.activateProfile].
class AutoLockProfilesScreen extends ConsumerStatefulWidget {
  const AutoLockProfilesScreen({super.key});

  @override
  ConsumerState<AutoLockProfilesScreen> createState() =>
      _AutoLockProfilesScreenState();
}

class _AutoLockProfilesScreenState
    extends ConsumerState<AutoLockProfilesScreen> {
  List<AutoLockProfile>? _profiles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final service = ref.read(autoLockServiceProvider);
    final profiles = await service.getAllProfiles();
    if (mounted) setState(() => _profiles = profiles);
  }

  Future<void> _activate(int id) async {
    final service = ref.read(autoLockServiceProvider);
    await service.activateProfile(id);
    await _load();
  }

  Future<void> _deactivate() async {
    final service = ref.read(autoLockServiceProvider);
    await service.deactivateAll();
    await _load();
  }

  Future<void> _delete(int id) async {
    final service = ref.read(autoLockServiceProvider);
    await service.deleteProfile(id);
    await _load();
  }

  Future<void> _openForm({AutoLockProfile? existing}) async {
    final result = await showDialog<_ProfileFormResult>(
      context: context,
      builder: (_) => _AutoLockProfileFormDialog(existing: existing),
    );
    if (result == null || !mounted) return;

    final service = ref.read(autoLockServiceProvider);
    if (existing == null) {
      await service.createProfile(
        name: result.name,
        timeoutSeconds: result.timeoutSeconds,
        lockOnMinimize: result.lockOnMinimize,
      );
    } else {
      await service.updateProfile(
        id: existing.id,
        name: result.name,
        timeoutSeconds: result.timeoutSeconds,
        lockOnMinimize: result.lockOnMinimize,
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profiles = _profiles;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleAutoLock)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('auto-lock-add-profile'),
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.actionAutoLockNewProfile),
      ),
      body: profiles == null
          ? const Center(child: CircularProgressIndicator())
          : profiles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.emptyAutoLock, textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              itemCount: profiles.length,
              itemBuilder: (_, i) {
                final p = profiles[i];
                return ListTile(
                  key: Key('auto-lock-profile-${p.id}'),
                  title: Text(p.name),
                  subtitle: Text(
                    l10n.descAutoLock(
                      _formatTimeout(l10n, p.timeoutSeconds),
                      p.lockOnMinimize
                          ? l10n.labelAutoLockSuffixLockOnMinimize
                          : '',
                      p.isActive ? l10n.labelAutoLockSuffixActive : '',
                    ),
                  ),
                  leading: Icon(
                    p.isActive ? Icons.lock_clock : Icons.lock_clock_outlined,
                    color: p.isActive
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        key: Key('auto-lock-profile-edit-${p.id}'),
                        icon: const Icon(Icons.edit),
                        tooltip: l10n.tooltipAutoLockEditProfile,
                        onPressed: () => _openForm(existing: p),
                      ),
                      IconButton(
                        key: Key('auto-lock-profile-delete-${p.id}'),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.tooltipAutoLockDeleteProfile,
                        onPressed: () => _delete(p.id),
                      ),
                      IconButton(
                        key: Key('auto-lock-profile-toggle-${p.id}'),
                        icon: Icon(
                          p.isActive ? Icons.toggle_on : Icons.toggle_off,
                        ),
                        tooltip: p.isActive
                            ? l10n.tooltipAutoLockDeactivate
                            : l10n.tooltipAutoLockActivate,
                        onPressed: () =>
                            p.isActive ? _deactivate() : _activate(p.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatTimeout(AppLocalizations l10n, int seconds) {
    if (seconds < 60) return l10n.labelAutoLockTimeoutSeconds(seconds);
    if (seconds < 3600) {
      return l10n.labelAutoLockTimeoutMinutes((seconds / 60).round());
    }
    return l10n.labelAutoLockTimeoutHours((seconds / 3600).toStringAsFixed(1));
  }
}

class _ProfileFormResult {
  const _ProfileFormResult({
    required this.name,
    required this.timeoutSeconds,
    required this.lockOnMinimize,
  });

  final String name;
  final int timeoutSeconds;
  final bool lockOnMinimize;
}

class _AutoLockProfileFormDialog extends StatefulWidget {
  const _AutoLockProfileFormDialog({this.existing});

  final AutoLockProfile? existing;

  @override
  State<_AutoLockProfileFormDialog> createState() =>
      _AutoLockProfileFormDialogState();
}

class _AutoLockProfileFormDialogState
    extends State<_AutoLockProfileFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _timeout;
  late bool _lockOnMinimize;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _timeout = TextEditingController(
      text: (widget.existing?.timeoutSeconds ?? 300).toString(),
    );
    _lockOnMinimize = widget.existing?.lockOnMinimize ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _timeout.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final timeout = int.tryParse(_timeout.text.trim());
    if (name.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).errorAutoLockName);
      return;
    }
    if (timeout == null || timeout <= 0) {
      setState(
        () => _error = AppLocalizations.of(context).errorAutoLockTimeout,
      );
      return;
    }
    Navigator.pop(
      context,
      _ProfileFormResult(
        name: name,
        timeoutSeconds: timeout,
        lockOnMinimize: _lockOnMinimize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.actionAutoLockNewProfile
            : l10n.tooltipAutoLockEditProfile,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('auto-lock-profile-name-field'),
            controller: _name,
            decoration: InputDecoration(labelText: l10n.labelAutoLockName),
          ),
          TextField(
            key: const Key('auto-lock-profile-timeout-field'),
            controller: _timeout,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.labelAutoLockTimeout),
          ),
          SwitchListTile(
            key: const Key('auto-lock-profile-lock-on-minimize'),
            title: Text(l10n.labelAutoLockLockOnMinimize),
            value: _lockOnMinimize,
            onChanged: (v) => setState(() => _lockOnMinimize = v),
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
          key: const Key('auto-lock-profile-save-button'),
          onPressed: _save,
          child: Text(l10n.actionCommonSave),
        ),
      ],
    );
  }
}
