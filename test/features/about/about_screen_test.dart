import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_journal_vault/features/about/application/about_metadata.dart';
import 'package:sreerajp_journal_vault/features/about/presentation/about_screen.dart';

void main() {
  testWidgets('about error state retries and recovers metadata', (
    WidgetTester tester,
  ) async {
    final reader = _FailOncePackageInfoReader();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPackageInfoReaderProvider.overrideWithValue(reader),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: const AboutScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unable to load app metadata'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('SreerajP_Journal_Vault'), findsOneWidget);
    expect(find.text('1.0.0 (build 7)'), findsOneWidget);
    expect(find.text(missingBuildTimestampLabel), findsOneWidget);
  });
}

class _FailOncePackageInfoReader implements AppPackageInfoReader {
  int _calls = 0;

  @override
  Future<PackageMetadataSnapshot> load() async {
    _calls += 1;
    if (_calls == 1) {
      throw StateError('package metadata unavailable');
    }

    return const PackageMetadataSnapshot(
      appName: 'SreerajP_Journal_Vault',
      version: '1.0.0',
      buildNumber: '7',
    );
  }
}
