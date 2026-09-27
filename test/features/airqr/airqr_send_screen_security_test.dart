import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/airqr/presentation/airqr_send_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// The send screen shows the pairing secret, so it blocks screenshots while
/// it is open — without saving over the user's own choice.
void main() {
  testWidgets('holds blocking on while open, then restores the choice', (
    tester,
  ) async {
    final store = InMemoryScreenSecurityStore(enabled: false);
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [screenSecurityStoreProvider.overrideWithValue(store)],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: const Scaffold(body: Text('HOME')),
        ),
      ),
    );

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => AirqrSendScreen(
          payload: AirqrPayload.settings(
            themeMode: 'dark',
            accentColorArgb: null,
            accentPresetName: null,
            ritualLaunchOnStartup: false,
            ritualBreathTechnique: 'box',
            ritualBreathCycles: 4,
            templates: const [],
            tags: const [],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(store.liveEnabled, isTrue, reason: 'protected while open');
    expect(store.enabled, isFalse, reason: 'the saved choice is untouched');

    navigatorKey.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(store.liveEnabled, isFalse, reason: 'the user\'s choice is back');
    expect(store.enabled, isFalse);

    // Let the frame animation timers stop.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
