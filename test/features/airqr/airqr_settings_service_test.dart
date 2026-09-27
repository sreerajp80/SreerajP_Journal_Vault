import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/providers/airqr_providers.dart';
import 'package:sreerajp_journal_vault/features/airqr/services/airqr_constants.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late InMemoryScreenSecurityStore screenSecurity;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    screenSecurity = InMemoryScreenSecurityStore();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        screenSecurityStoreProvider.overrideWithValue(screenSecurity),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  AirqrPayload templatesPayload(List<Map<String, dynamic>> templates) =>
      AirqrPayload(
        kind: AirqrConstants.kindSettings,
        title: 'settings',
        timestamp: DateTime(2026, 9, 27),
        data: {'templates': templates},
      );

  test('a template without a name gets the name passed in', () async {
    await container
        .read(airqrSettingsServiceProvider)
        .applySettings(
          templatesPayload([
            {'contentJson': '[]'},
            {'name': '   ', 'contentJson': '[]'},
            {'name': 'Gratitude', 'contentJson': '[]'},
          ]),
          fallbackTemplateName: 'ഇറക്കുമതി ചെയ്ത മാതൃക',
        );

    final names = [
      for (final t in await db.userTemplatesDao.getAllUserTemplates()) t.name,
    ]..sort();
    expect(names, [
      'Gratitude',
      'ഇറക്കുമതി ചെയ്ത മാതൃക',
      'ഇറക്കുമതി ചെയ്ത മാതൃക',
    ]);
  });

  test('a received screenshot setting is ignored', () async {
    await container
        .read(airqrSettingsServiceProvider)
        .applySettings(
          AirqrPayload(
            kind: AirqrConstants.kindSettings,
            title: 'settings',
            timestamp: DateTime(2026, 9, 27),
            // What an older app version sends.
            data: const {'isScreenSecurityEnabled': false},
          ),
          fallbackTemplateName: 'x',
        );

    expect(screenSecurity.enabled, isTrue);
    expect(screenSecurity.liveEnabled, isTrue);
  });

  test('sent settings carry no screenshot setting', () async {
    screenSecurity.enabled = false;

    final payload = await container
        .read(airqrSettingsServiceProvider)
        .exportCurrentSettings();

    expect(payload.data.containsKey('isScreenSecurityEnabled'), isFalse);
  });
}
