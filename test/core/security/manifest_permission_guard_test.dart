import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android Manifest Permission Guards', () {
    test(
      'main AndroidManifest.xml declares local sync permissions and removes WAKE_LOCK',
      () {
        final mainManifestFile = File(
          'android/app/src/main/AndroidManifest.xml',
        );
        expect(
          mainManifestFile.existsSync(),
          isTrue,
          reason: 'main AndroidManifest.xml must exist',
        );

        final content = mainManifestFile.readAsStringSync();

        expect(
          content,
          contains('xmlns:tools="http://schemas.android.com/tools"'),
          reason: 'Tools namespace must be declared on <manifest>',
        );

        // Check INTERNET is declared for local socket communication
        final internetMatch = RegExp(
          r'<uses-permission[^>]*android:name="android\.permission\.INTERNET"',
        ).hasMatch(content);
        expect(
          internetMatch,
          isTrue,
          reason:
              'android.permission.INTERNET must be declared for local socket sync',
        );

        // Check ACCESS_NETWORK_STATE is declared
        final accessNetworkMatch = RegExp(
          r'<uses-permission[^>]*android:name="android\.permission\.ACCESS_NETWORK_STATE"',
        ).hasMatch(content);
        expect(
          accessNetworkMatch,
          isTrue,
          reason: 'android.permission.ACCESS_NETWORK_STATE must be declared',
        );

        // Check WAKE_LOCK removal
        final wakeLockMatch = RegExp(
          r'<uses-permission[^>]*android:name="android\.permission\.WAKE_LOCK"[^>]*tools:node="remove"',
        ).hasMatch(content);
        expect(
          wakeLockMatch,
          isTrue,
          reason:
              'android.permission.WAKE_LOCK must be explicitly removed using tools:node="remove"',
        );
      },
    );

    test(
      'debug and profile AndroidManifest.xml declare tools:node="replace" for INTERNET',
      () {
        for (final variant in ['debug', 'profile']) {
          final manifestFile = File(
            'android/app/src/$variant/AndroidManifest.xml',
          );
          expect(
            manifestFile.existsSync(),
            isTrue,
            reason: '$variant AndroidManifest.xml must exist',
          );

          final content = manifestFile.readAsStringSync();
          expect(
            content,
            contains('xmlns:tools="http://schemas.android.com/tools"'),
            reason: '$variant AndroidManifest.xml must declare tools namespace',
          );

          final replaceMatch = RegExp(
            r'<uses-permission[^>]*android:name="android\.permission\.INTERNET"[^>]*tools:node="replace"',
          ).hasMatch(content);
          expect(
            replaceMatch,
            isTrue,
            reason:
                '$variant AndroidManifest.xml must declare tools:node="replace" on INTERNET',
          );
        }
      },
    );
  });
}
