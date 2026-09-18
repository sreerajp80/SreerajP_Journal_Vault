import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/app/app.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/providers/lock_gate_providers.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/app_pin_keystore.dart';
import 'package:sreerajp_journal_vault/features/lock_gate/services/biometric_authenticator.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/app_permissions_service.dart';

/// Verifies Slice C1: 5-tab bottom navigation renders and switches without
/// crashes or missing-provider errors.
void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
    await database.appSecurityDao.updateLockState(
      const AppSecurityCompanion(
        lockMode: Value('phone_lock'),
        isLocked: Value(true),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpAndUnlock(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      JournalVaultAppHost(
        database: database,
        overrides: <Override>[
          biometricAuthenticatorProvider.overrideWithValue(
            _AlwaysSuccessBiometric(),
          ),
          appPinKeystoreProvider.overrideWithValue(_InMemoryPinKeystore()),
          appPermissionsServiceProvider.overrideWithValue(
            _FakePermissionsService(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('phone-lock-unlock-button')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders all 5 tabs in plan order', (tester) async {
    await pumpAndUnlock(tester);

    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(nav.destinations.map((d) => (d as NavigationDestination).label), [
      'Home',
      'Search',
      'Timeline',
      'Insights',
      'Settings',
    ]);
  });

  Finder navItem(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('Timeline tab opens TimelineScreen', (tester) async {
    await pumpAndUnlock(tester);

    await tester.tap(navItem('Timeline'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Timeline'), findsOneWidget);
  });

  testWidgets('Insights tab opens InsightsScreen without crashing', (
    tester,
  ) async {
    await pumpAndUnlock(tester);

    await tester.tap(navItem('Insights'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Insights'), findsOneWidget);
  });

  testWidgets('every tab is reachable in sequence without provider errors', (
    tester,
  ) async {
    await pumpAndUnlock(tester);

    for (final label in const [
      'Search',
      'Timeline',
      'Insights',
      'Settings',
      'Home',
    ]) {
      await tester.tap(navItem(label));
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
  });
}

class _AlwaysSuccessBiometric implements BiometricAuthenticator {
  @override
  Future<bool> canAuthenticate() async => true;

  @override
  Future<BiometricAuthResult> authenticate({required String reason}) async =>
      BiometricAuthResult.success;
}

class _InMemoryPinKeystore implements AppPinKeystore {
  AppPinCredentialPayload? _stored;

  @override
  Future<AppPinCredentialPayload?> getCredential() async => _stored;

  @override
  Future<void> setCredential({
    required String saltBase64,
    required String verifierBase64,
    required int iterations,
  }) async {
    _stored = AppPinCredentialPayload(
      saltBase64: saltBase64,
      verifierBase64: verifierBase64,
      iterations: iterations,
    );
  }

  @override
  Future<void> clearCredential() async {
    _stored = null;
  }
}

class _FakePermissionsService implements AppPermissionsService {
  @override
  Future<AppPermissionItem> getPermission(AppPermissionId id) async =>
      _itemFor(id);

  @override
  Future<PermissionsSnapshot> getSnapshot() async {
    return PermissionsSnapshot(
      explicitPermissions: [_itemFor(AppPermissionId.attachmentImport)],
      implicitPermissions: [_itemFor(AppPermissionId.documentPicker)],
    );
  }

  @override
  Future<AppPermissionState> requestPermission(AppPermissionId id) async =>
      AppPermissionState.granted;

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionId id) async => false;

  @override
  Future<bool> openSystemSettings() async => true;

  AppPermissionItem _itemFor(AppPermissionId id) {
    return AppPermissionItem(
      id: id,
      category: AppPermissionCategory.explicit,
      status: AppPermissionState.granted,
    );
  }
}
