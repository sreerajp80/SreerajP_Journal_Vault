# Change Log — Dynamic Build Metadata Generation

**Plan Reference:** [plans/20260829_221000_dynamic_build_metadata.md](plans/20260829_221000_dynamic_build_metadata.md)
**Date:** 2026-08-29

## Summary
Added automatic build metadata generation during project builds. The build process now dynamically generates `kAppVersion` and `kBuildDate` constants and prints them during builds. The About screen displays the current build date automatically without hardcoding it in the asset configuration.

## Key Changes
- Created `tool/generate_app_version.dart` to read `pubspec.yaml` and generate `lib/core/constants/app_version.g.dart`.
- Created `tool/generate_build_date.dart` to generate `lib/core/constants/build_date.g.dart` with today's date in `YYYY-MM-DD` format.
- Created `tool/refresh_build_metadata.ps1` for local manual generation using the Flutter Dart SDK.
- Updated `android/app/build.gradle.kts` with task `generateBuildMetadata` hooked to `preBuild` and `compileFlutterBuild*` tasks.
- Removed hardcoded `"Last Build"` entry from `assets/config/app_config.json`.
- Updated `lib/features/about/application/about_metadata.dart` to use `kBuildDate` from `lib/core/constants/build_date.g.dart` as the default build date and support `YYYY-MM-DD` date formatting.
- Updated unit and widget tests in `test/features/about/about_metadata_test.dart` and `test/features/about/about_screen_test.dart`.

## Verification
- Verified generation scripts:
  - `app_version.g.dart updated → 1.5.1+8`
  - `build_date.g.dart updated → 2026-08-29`
- Ran Gradle task `generateBuildMetadata` successfully.
- Ran `flutter analyze`: passed with 0 issues.
- Ran `flutter test`: all 777 unit and widget tests passed.
- Ran `tool/check_absolute_paths.sh --all`: clean.
