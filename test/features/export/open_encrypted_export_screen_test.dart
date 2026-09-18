import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/core/security/vault_envelope.dart';
import 'package:sreerajp_journal_vault/features/export/presentation/open_encrypted_export_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

/// Drives the screen that unwraps a sealed export.
///
/// Argon2id runs on timers that a `testWidgets` fake-async zone never fires,
/// so the crypto itself is covered by the unit tests. What is checked here is
/// the part a user can get wrong: pressing the button with no file, and
/// picking a file that was never encrypted.
void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    PickedSealedFile? picks,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OpenEncryptedExportScreen(
          envelope: VaultEnvelope(
            kdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
            legacyKdf: const VaultKdfParameters(memoryKib: 64, iterations: 1),
          ),
          picker: () async => picks,
          saver:
              ({
                required String dialogTitle,
                required String fileName,
                required Uint8List bytes,
              }) async => 'saved/$fileName',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the open button is dead until a file is chosen', (tester) async {
    await pumpScreen(tester);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('open-encrypted-run')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('choosing a file names it and wakes the button up', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      picks: PickedSealedFile(
        fileName: 'journal_export_2026-08-18.jvenc',
        bytes: Uint8List.fromList(utf8.encode('not really sealed')),
      ),
    );

    await tester.tap(find.byKey(const Key('open-encrypted-pick-file')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('journal_export_2026-08-18.jvenc'),
      findsWidgets,
    );
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('open-encrypted-run')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a file that was never encrypted is named as such', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      picks: PickedSealedFile(
        fileName: 'my-entry.md',
        bytes: Uint8List.fromList(utf8.encode('# Just some markdown')),
      ),
    );

    await tester.tap(find.byKey(const Key('open-encrypted-pick-file')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-encrypted-run')));
    await tester.pumpAndSettle();

    // Told apart from a wrong password, because the two need different fixes.
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.errorOpenEncryptedErrorNotSealed), findsOneWidget);
  });
}
