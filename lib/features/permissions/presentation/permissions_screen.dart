import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  PermissionsSnapshot? _snapshot;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final service = ref.read(appPermissionsServiceProvider);
    final snapshot = await service.getSnapshot();
    if (mounted) setState(() => _snapshot = snapshot);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snapshot = _snapshot;
    if (snapshot == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.permissionsTitle)),
      body: ListView(
        children: [
          if (snapshot.explicitPermissions.isNotEmpty) ...[
            _SectionHeader(title: l10n.permissionsExplicitHeader),
            ...snapshot.explicitPermissions.map(
              (p) => _PermissionTile(
                item: p,
                onRequest: () => _requestPermission(p.id),
                onOpenSettings: () => _openSettings(),
              ),
            ),
          ],
          if (snapshot.implicitPermissions.isNotEmpty) ...[
            _SectionHeader(title: l10n.permissionsImplicitHeader),
            ...snapshot.implicitPermissions.map(
              (p) => _PermissionTile(
                item: p,
                onRequest: () => _requestPermission(p.id),
                onOpenSettings: () => _openSettings(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestPermission(AppPermissionId id) async {
    final service = ref.read(appPermissionsServiceProvider);
    await service.requestPermission(id);
    await _loadPermissions();
  }

  Future<void> _openSettings() async {
    final service = ref.read(appPermissionsServiceProvider);
    await service.openSystemSettings();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.item,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final AppPermissionItem item;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  String _statusLabel(AppLocalizations l10n) {
    switch (item.status) {
      case AppPermissionState.granted:
        return l10n.permissionStatusAllowed;
      case AppPermissionState.denied:
        return l10n.permissionStatusDenied;
      case AppPermissionState.permanentlyDenied:
        return l10n.permissionStatusPermanentlyDenied;
      case AppPermissionState.userSelected:
        return l10n.permissionStatusUserSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(item.title),
      subtitle: Text(_statusLabel(l10n)),
      trailing: item.canRequestAgain
          ? TextButton(
              key: Key('permission-request-${item.id.name}'),
              onPressed: onRequest,
              child: Text(l10n.permissionsRequest),
            )
          : item.canOpenSystemSettings
          ? TextButton(
              key: Key('permission-settings-${item.id.name}'),
              onPressed: onOpenSettings,
              child: Text(l10n.permissionsOpenSettings),
            )
          : null,
    );
  }
}
