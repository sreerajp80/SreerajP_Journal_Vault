# Implementation Plan — Dynamic Build Metadata Generation

**Status:** Completed
**Date:** 2026-08-29
**Author:** AI Pair Programmer

## Problem Statement
Currently, the build date is hardcoded inside `assets/config/app_config.json` under `details` (`"Last Build": "24-08-2026"`), while `about_metadata.dart` falls back to "Build date unavailable". During Android builds (`flutter build apk ...`), build metadata is not automatically regenerated or printed to the console.

## Proposed Solution
1. Create `tool/generate_app_version.dart` to read `pubspec.yaml` and generate `lib/core/constants/app_version.g.dart`.
2. Create `tool/generate_build_date.dart` to capture today's date in `YYYY-MM-DD` format and generate `lib/core/constants/build_date.g.dart`.
3. Create `tool/refresh_build_metadata.ps1` for local manual refresh if needed.
4. Hook a Gradle task `generateBuildMetadata` into `android/app/build.gradle.kts` before `preBuild` and `compileFlutterBuild*`, so building the Android project automatically executes both generator scripts and prints:
   ```
   app_version.g.dart updated → <version>+<build>
   build_date.g.dart updated → <date>
   ```
5. Remove `"Last Build"` from `assets/config/app_config.json` `details` map.
6. Wire `kBuildDate` in `lib/features/about/application/about_metadata.dart` and support date strings (`YYYY-MM-DD`) in `formatBuildTimestamp`.
7. Update about screen and metadata tests to verify the dynamic build date integration.

## Proposed File Changes
- `tool/generate_app_version.dart` (New): Dart script to parse version from `pubspec.yaml` and write `lib/core/constants/app_version.g.dart`.
- `tool/generate_build_date.dart` (New): Dart script to write current ISO date (`YYYY-MM-DD`) to `lib/core/constants/build_date.g.dart`.
- `tool/refresh_build_metadata.ps1` (New): PowerShell helper to execute both scripts using Flutter's Dart executable.
- `android/app/build.gradle.kts` (Modify): Register `generateBuildMetadata` task dependent on `preBuild` and Flutter compile tasks.
- `assets/config/app_config.json` (Modify): Remove static `"Last Build"` entry from `details`.
- `lib/core/constants/app_version.g.dart` (New): Generated constant `kAppVersion`.
- `lib/core/constants/build_date.g.dart` (New): Generated constant `kBuildDate`.
- `lib/features/about/application/about_metadata.dart` (Modify): Import `build_date.g.dart` and supply `kBuildDate` to `aboutMetadataProvider`.
- `test/features/about/about_metadata_test.dart` (Modify): Update unit tests for `formatBuildTimestamp` and date validation.
- `test/features/about/about_screen_test.dart` (Modify): Update widget tests to verify build date rendering.

## Verification Plan
1. Run `dart run tool/generate_app_version.dart` and `dart run tool/generate_build_date.dart` and verify generated constant files.
2. Run `flutter analyze` to ensure zero static analysis warnings.
3. Run `flutter test` to ensure all unit and widget tests pass.
4. Run `flutter build apk --flavor prod --release --split-per-abi` (or `gradlew generateBuildMetadata`) to verify console output and artifact generation.
