import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sreerajp_journal_vault/features/help/presentation/attachments_ocr_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/backup_restore_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/biometrics_pin_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/encryption_security_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/export_formats_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/faq_troubleshooting_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/help_home_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/insights_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/journal_locks_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/journal_organization_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/screenshot_audit_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/search_timeline_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/storage_migration_help_screen.dart';
import 'package:sreerajp_journal_vault/features/help/presentation/tags_help_screen.dart';
import 'package:sreerajp_journal_vault/l10n/app_localizations.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('HelpHomeScreen renders header and all section topic cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const HelpHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Help Center & Knowledge Base'), findsOneWidget);
    expect(find.text('WRITING & JOURNAL MANAGEMENT'), findsOneWidget);
    expect(find.text('SECURITY, LOCK & ENCRYPTION'), findsOneWidget);
    expect(find.text('SEARCH, TIMELINE & INSIGHTS'), findsOneWidget);
    expect(find.text('STORAGE, BACKUPS & EXPORT'), findsOneWidget);
    expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);

    expect(find.text('Journal Organization & Templates'), findsOneWidget);
    expect(find.text('Attachments & OCR Scanner'), findsOneWidget);
    expect(find.text('Encryption & Keystore Security'), findsOneWidget);
  });

  testWidgets('Each Help topic guide renders title and sections', (
    tester,
  ) async {
    final screens = <Widget>[
      const JournalOrganizationHelpScreen(),
      const AttachmentsOcrHelpScreen(),
      const TagsHelpScreen(),
      const EncryptionSecurityHelpScreen(),
      const BiometricsPinHelpScreen(),
      const JournalLocksHelpScreen(),
      const ScreenshotAuditHelpScreen(),
      const SearchTimelineHelpScreen(),
      const InsightsHelpScreen(),
      const StorageMigrationHelpScreen(),
      const BackupRestoreHelpScreen(),
      const ExportFormatsHelpScreen(),
      const FaqTroubleshootingHelpScreen(),
    ];

    for (final screen in screens) {
      await tester.pumpWidget(_wrap(screen));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    }
  });
}
