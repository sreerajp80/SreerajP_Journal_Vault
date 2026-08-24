import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sreerajp_journal_vault/core/database/app_database.dart';
import 'package:sreerajp_journal_vault/core/database/database_providers.dart';
import 'package:sreerajp_journal_vault/core/security/screen_security_controller.dart';
import 'package:sreerajp_journal_vault/core/theme/accent_color_controller.dart';
import 'package:sreerajp_journal_vault/core/theme/theme_mode_controller.dart';
import 'package:sreerajp_journal_vault/core/theme/typography_controller.dart';
import 'package:sreerajp_journal_vault/features/airqr/domain/airqr_payload.dart';
import 'package:sreerajp_journal_vault/features/ritual/providers/ritual_providers.dart';
import 'package:sreerajp_journal_vault/features/ritual/services/ritual_service.dart';

/// Helper service for extracting and applying settings via AirQR.
class AirqrSettingsService {
  final Ref _ref;

  AirqrSettingsService(this._ref);

  /// Assembles current device settings and preferences into an [AirqrPayload].
  Future<AirqrPayload> exportCurrentSettings() async {
    final themeMode = _ref.read(themeModeProvider);
    final appThemeMode = _ref.read(appThemeModeProvider);
    final typography = _ref.read(typographyProvider);
    final accentColor = _ref.read(accentColorProvider);
    final screenSecStore = _ref.read(screenSecurityStoreProvider);
    final isSecEnabled = await screenSecStore.read();
    final ritualService = _ref.read(ritualServiceProvider);

    final db = _ref.read(appDatabaseProvider);
    final templates = await db.userTemplatesDao.getAllUserTemplates();
    final templateMaps = templates
        .map(
          (t) => {
            'name': t.name,
            'description': t.description,
            'defaultTitle': t.defaultTitle,
            'contentJson': t.contentJson,
          },
        )
        .toList();

    final tags = await db.tagsDao.getAllTags();
    final tagMaps = tags
        .map((t) => {'name': t.name, 'colorArgb': t.colorArgb})
        .toList();

    final themeStr = switch (themeMode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };

    return AirqrPayload.settings(
      themeMode: themeStr,
      appThemeMode: appThemeMode.name,
      fontFamily: typography.fontFamily.name,
      fontSize: typography.fontSize,
      accentColorArgb: accentColor.toARGB32(),
      accentPresetName: null,
      isScreenSecurityEnabled: isSecEnabled,
      ritualLaunchOnStartup: ritualService?.getLaunchOnStartup() ?? false,
      ritualBreathTechnique:
          ritualService?.getBreathTechnique().name ?? 'boxBreathing',
      ritualBreathCycles: ritualService?.getBreathCycles() ?? 2,
      templates: templateMaps,
      tags: tagMaps,
    );
  }

  /// Imports and applies settings from a received [AirqrPayload].
  Future<void> applySettings(AirqrPayload payload) async {
    final data = payload.data;

    // 1. Theme Mode / Reading Theme
    final appThemeStr = data['appThemeMode'] as String?;
    if (appThemeStr != null) {
      final appMode = switch (appThemeStr) {
        'sepia' => AppThemeMode.sepia,
        'oled' => AppThemeMode.oled,
        'dark' => AppThemeMode.dark,
        'light' => AppThemeMode.light,
        _ => AppThemeMode.system,
      };
      await _ref.read(appThemeModeProvider.notifier).setAppThemeMode(appMode);
    } else {
      final themeStr = data['themeMode'] as String?;
      if (themeStr != null) {
        final mode = switch (themeStr) {
          'dark' => ThemeMode.dark,
          'light' => ThemeMode.light,
          _ => ThemeMode.system,
        };
        await _ref.read(themeModeProvider.notifier).setMode(mode);
      }
    }

    // 1.1 Reading Typography
    final fontFamilyStr = data['fontFamily'] as String?;
    if (fontFamilyStr != null) {
      final family = switch (fontFamilyStr) {
        'serif' => EntryFontFamily.serif,
        'monospace' => EntryFontFamily.monospace,
        _ => EntryFontFamily.sans,
      };
      await _ref.read(typographyProvider.notifier).updateFontFamily(family);
    }
    final fontSizeVal = (data['fontSize'] as num?)?.toDouble();
    if (fontSizeVal != null) {
      await _ref.read(typographyProvider.notifier).updateFontSize(fontSizeVal);
    }

    // 2. Accent Color
    final accentArgb = data['accentColorArgb'] as int?;
    if (accentArgb != null) {
      await _ref.read(accentColorProvider.notifier).set(Color(accentArgb));
    }

    // 3. Screen Security
    final isSecEnabled = data['isScreenSecurityEnabled'] as bool?;
    if (isSecEnabled != null) {
      await _ref.read(screenSecurityProvider.notifier).setEnabled(isSecEnabled);
    }

    // 4. Ritual Settings
    final ritualService = _ref.read(ritualServiceProvider);
    if (ritualService != null) {
      final launchOnStartup = data['ritualLaunchOnStartup'] as bool?;
      if (launchOnStartup != null) {
        await ritualService.setLaunchOnStartup(launchOnStartup);
      }

      final techStr = data['ritualBreathTechnique'] as String?;
      if (techStr != null) {
        final match = BreathTechnique.values.where((b) => b.name == techStr);
        if (match.isNotEmpty) {
          await ritualService.setBreathTechnique(match.first);
        }
      }

      final cycles = data['ritualBreathCycles'] as int?;
      if (cycles != null) {
        await ritualService.setBreathCycles(cycles);
      }
    }

    // 5. Templates & Tags
    final db = _ref.read(appDatabaseProvider);
    final rawTemplates = data['templates'] as List<dynamic>? ?? [];
    for (final t in rawTemplates) {
      if (t is Map<String, dynamic>) {
        final name = t['name'] as String? ?? 'Custom Template';
        final contentJson = t['contentJson'] as String? ?? '';
        final description = t['description'] as String?;
        final defaultTitle = t['defaultTitle'] as String?;

        await db.userTemplatesDao.createUserTemplate(
          UserTemplatesCompanion.insert(
            name: name,
            description: Value(description),
            defaultTitle: Value(defaultTitle),
            contentJson: contentJson,
          ),
        );
      }
    }

    final rawTags = data['tags'] as List<dynamic>? ?? [];
    for (final tag in rawTags) {
      if (tag is Map<String, dynamic>) {
        final name = tag['name'] as String? ?? '';
        final colorArgb = tag['colorArgb'] as int?;
        if (name.isNotEmpty) {
          await db.tagsDao.createTag(
            TagsCompanion.insert(name: name, colorArgb: Value(colorArgb)),
          );
        }
      }
    }
  }
}

final airqrSettingsServiceProvider = Provider<AirqrSettingsService>((ref) {
  return AirqrSettingsService(ref);
});
