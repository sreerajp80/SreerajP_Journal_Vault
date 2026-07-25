import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/features/security/presentation/auto_lock_profiles_screen.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(home: AutoLockProfilesScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('initial empty state shows the placeholder copy', (tester) async {
    await pumpScreen(tester);
    expect(
      find.textContaining('No auto-lock profiles yet'),
      findsOneWidget,
    );
  });

  testWidgets('user can create a profile via the form', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('auto-lock-add-profile')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('auto-lock-profile-name-field')),
      'Strict',
    );
    await tester.enterText(
      find.byKey(const Key('auto-lock-profile-timeout-field')),
      '60',
    );
    await tester.tap(find.byKey(const Key('auto-lock-profile-save-button')));
    await tester.pumpAndSettle();

    final profiles = await database.autoLockProfilesDao.getAllProfiles();
    expect(profiles, hasLength(1));
    expect(profiles.single.timeoutSeconds, 60);
    expect(profiles.single.name, 'Strict');

    expect(find.text('Strict'), findsOneWidget);
  });

  testWidgets('activating one profile deactivates the others on screen',
      (tester) async {
    await pumpScreen(tester);

    Future<void> create(String name, String seconds) async {
      await tester.tap(find.byKey(const Key('auto-lock-add-profile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('auto-lock-profile-name-field')),
        name,
      );
      await tester.enterText(
        find.byKey(const Key('auto-lock-profile-timeout-field')),
        seconds,
      );
      await tester.tap(
        find.byKey(const Key('auto-lock-profile-save-button')),
      );
      await tester.pumpAndSettle();
    }

    await create('A', '60');
    await create('B', '120');

    final profiles = await database.autoLockProfilesDao.getAllProfiles();
    final aId = profiles.firstWhere((p) => p.name == 'A').id;
    final bId = profiles.firstWhere((p) => p.name == 'B').id;

    await tester.tap(find.byKey(Key('auto-lock-profile-toggle-$aId')));
    await tester.pumpAndSettle();

    var stored = await database.autoLockProfilesDao.getAllProfiles();
    expect(stored.firstWhere((p) => p.id == aId).isActive, isTrue);
    expect(stored.firstWhere((p) => p.id == bId).isActive, isFalse);

    await tester.tap(find.byKey(Key('auto-lock-profile-toggle-$bId')));
    await tester.pumpAndSettle();

    stored = await database.autoLockProfilesDao.getAllProfiles();
    expect(stored.firstWhere((p) => p.id == aId).isActive, isFalse);
    expect(stored.firstWhere((p) => p.id == bId).isActive, isTrue);
  });
}
