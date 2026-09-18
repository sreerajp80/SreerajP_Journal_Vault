import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/providers/attachment_providers.dart';
import 'package:sreerajp_journal_vault/features/attachments/services/attachment_picker_service.dart';
import 'package:sreerajp_journal_vault/features/entries/presentation/entry_editor_screen.dart';
import 'package:sreerajp_journal_vault/features/permissions/domain/app_permission_models.dart';
import 'package:sreerajp_journal_vault/features/permissions/presentation/permissions_screen.dart';
import 'package:sreerajp_journal_vault/features/permissions/providers/permissions_providers.dart';
import 'package:sreerajp_journal_vault/features/permissions/services/app_permissions_service.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('Permissions screen shows explicit and implicit status updates', (
    tester,
  ) async {
    final service = _FakeAppPermissionsService(
      currentState: AppPermissionState.denied,
      nextRequestState: AppPermissionState.granted,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appPermissionsServiceProvider.overrideWithValue(service)],
        child: const _TestApp(child: PermissionsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explicit permissions'), findsOneWidget);
    expect(find.text('Implicit permissions'), findsOneWidget);
    expect(find.text('File access'), findsOneWidget);
    expect(find.text('File picker'), findsOneWidget);
    expect(find.text('Denied'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('permission-request-attachmentImport')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Allowed'), findsOneWidget);
    expect(service.requestCount, 1);
  });

  testWidgets('Attachment import handles permanently denied permission', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final journalId = await database.journalsDao.createJournal(
      JournalsCompanion.insert(title: 'Secure'),
    );
    final service = _FakeAppPermissionsService(
      currentState: AppPermissionState.denied,
      nextRequestState: AppPermissionState.permanentlyDenied,
    );
    final picker = _TrackingAttachmentPickerService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appPermissionsServiceProvider.overrideWithValue(service),
          attachmentPickerServiceProvider.overrideWithValue(picker),
        ],
        child: _TestApp(child: EntryEditorScreen(journalId: journalId)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(
      find.byKey(const Key('entry-attachment-add-button')),
    );
    await tester.tap(find.byKey(const Key('entry-attachment-add-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Allow attachment import?'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Access blocked'), findsOneWidget);
    expect(find.text('Open system settings'), findsOneWidget);
    expect(picker.wasCalled, isFalse);

    await tester.tap(find.text('Open system settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(service.openSettingsCount, 1);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}

class _FakeAppPermissionsService implements AppPermissionsService {
  _FakeAppPermissionsService({
    required this._currentState,
    required this.nextRequestState,
  });

  AppPermissionState _currentState;
  final AppPermissionState nextRequestState;
  int requestCount = 0;
  int openSettingsCount = 0;

  @override
  Future<AppPermissionItem> getPermission(AppPermissionId id) async {
    return _buildSnapshot().permissionFor(id);
  }

  @override
  Future<PermissionsSnapshot> getSnapshot() async => _buildSnapshot();

  @override
  Future<bool> openSystemSettings() async {
    openSettingsCount += 1;
    return true;
  }

  @override
  Future<AppPermissionState> requestPermission(AppPermissionId id) async {
    requestCount += 1;
    _currentState = nextRequestState;
    return _currentState;
  }

  @override
  Future<bool> shouldShowRequestRationale(AppPermissionId id) async => true;

  PermissionsSnapshot _buildSnapshot() {
    return PermissionsSnapshot(
      explicitPermissions: <AppPermissionItem>[
        AppPermissionItem(
          id: AppPermissionId.attachmentImport,
          category: AppPermissionCategory.explicit,
          status: _currentState,
          isGrantedViaFilePicker: true,
          canRequestAgain: _currentState == AppPermissionState.denied,
          canOpenSystemSettings:
              _currentState == AppPermissionState.denied ||
              _currentState == AppPermissionState.permanentlyDenied,
        ),
      ],
      implicitPermissions: const <AppPermissionItem>[
        AppPermissionItem(
          id: AppPermissionId.documentPicker,
          category: AppPermissionCategory.implicit,
          status: AppPermissionState.userSelected,
        ),
      ],
    );
  }
}

class _TrackingAttachmentPickerService implements AttachmentPickerService {
  bool wasCalled = false;

  @override
  Future<PickedAttachmentData?> pickAttachment() async {
    wasCalled = true;
    return null;
  }
}
