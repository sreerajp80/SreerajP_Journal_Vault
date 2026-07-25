import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:sreerajp_journal_vault/core/config/app_config.dart';

/// Loads the About-screen config asset.
///
/// Required by guideline.md section 1.5. The class name and [assetPath] are
/// fixed across apps — do not rename them.
class ConfigService {
  ConfigService({Future<String> Function(String path)? loadAsset})
      : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const String assetPath = 'assets/config/app_config.json';

  final Future<String> Function(String path) _loadAsset;

  /// Returns [AppConfig.fallback] on any error — missing asset, bad JSON, or
  /// wrong shape. Never throws.
  Future<AppConfig> load() async {
    try {
      final text = await _loadAsset(assetPath);
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return AppConfig.fallback;
      return AppConfig.fromJson(decoded);
    } catch (_) {
      return AppConfig.fallback;
    }
  }

  /// Same as [load], but additionally warns in debug builds when the version or
  /// build in the config has drifted from the actual build.
  ///
  /// The drift check is a diagnostic only, so it deliberately does NOT block
  /// the returned config. `PackageInfo.fromPlatform()` waits on a platform
  /// channel that never answers in a widget test — awaiting it here would
  /// leave the About screen stuck on its spinner forever.
  Future<AppConfig> loadAndVerify({PackageInfo? packageInfo}) async {
    final config = await load();
    if (kDebugMode) {
      unawaited(_warnOnVersionDrift(config, packageInfo));
    }
    return config;
  }

  Future<void> _warnOnVersionDrift(
    AppConfig config,
    PackageInfo? packageInfo,
  ) async {
    try {
      final info = packageInfo ?? await PackageInfo.fromPlatform();
      final mismatch =
          info.version != config.version || info.buildNumber != config.build;
      if (mismatch) {
        debugPrint(
          'ConfigService: version/build in app_config.json '
          '(${config.version}+${config.build}) does not match the build '
          '(${info.version}+${info.buildNumber}).',
        );
      }
    } catch (_) {
      // Package info unavailable (e.g. plain unit test) — ignore.
    }
  }
}
