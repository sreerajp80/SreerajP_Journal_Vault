import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/presentation/permissions_screen.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class PermissionsSettingsScreen extends StatelessWidget {
  const PermissionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleSettingsSectionPermissions)),
      body: ListView(
        key: const Key('settings-permissions-list'),
        children: const [PermissionsSection()],
      ),
    );
  }
}

class PermissionsSection extends ConsumerStatefulWidget {
  const PermissionsSection({super.key});

  @override
  ConsumerState<PermissionsSection> createState() => _PermissionsSectionState();
}

class _PermissionsSectionState extends ConsumerState<PermissionsSection> {
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
    if (s == null) return l10n.bodyStorageUnknown;
    final all = [...s.explicitPermissions, ...s.implicitPermissions];
    final granted = all
        .where((p) => p.status == AppPermissionState.granted)
        .length;
    return l10n.descPermissionsGranted(granted, all.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ListTile(
          key: const Key('settings-permissions-status'),
          title: Text(l10n.labelPermissionStatusRow),
          subtitle: Text(_summary(l10n)),
        ),
        ListTile(
          key: const Key('settings-manage-permissions'),
          title: Text(l10n.labelPermissionsManage),
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
          title: Text(l10n.labelPermissionsOpenSystem),
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
