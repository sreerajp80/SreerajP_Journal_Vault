# Settings — Appearance, Features, and Help Cards

**Plan:** `plans/20260821_205800_settings_appearance_features_help.md`

## Summary

Added dedicated **Appearance**, **Features**, and **Help** cards and screens under Settings, matching the modern card design and modular structure of the reference app while tailoring all content to SreerajP Journal Vault.

## What changed

1. **Theme & Custom Accent Color System**:
   - Created `lib/core/theme/accent_color_controller.dart` with `AppAccentColors`, `AccentColorStore`, `SharedPreferencesAccentColorStore`, and `accentColorProvider`.
   - Updated `lib/core/theme/theme_mode_controller.dart` with `ThemeModeNotifier` and `themeModeProvider`.
   - Connected `JournalVaultApp` in `lib/app/app.dart` to dynamically build `ThemeData` using `ColorScheme.fromSeed` with the chosen accent color.

2. **Appearance Hub & Settings Screens**:
   - Created `lib/features/appearance/presentation/appearance_screen.dart` featuring navigation cards for Theme Mode and Accent Color.
   - Created `lib/features/appearance/presentation/theme_mode_settings_screen.dart` with Light, Dark, and System mode segmented controls and preview.
   - Created `lib/features/appearance/presentation/accent_color_settings_screen.dart` featuring an interactive live UI preview card, 8 preset swatches, a custom HSV color wheel, saturation/value slider, and one-tap reset button.

3. **Features Catalog**:
   - Created `lib/features/features_catalog/presentation/features_screen.dart` categorizing all vault features into 4 domains:
     - *Journaling & Rich Text Editor*
     - *Privacy, Encryption & Vault Security*
     - *Search, Timeline & Insights*
     - *Storage, Backups & Multi-Format Export*
   - Includes header summary, category badges, icons, detailed feature descriptions, and highlight tags.

4. **Help Center & Knowledge Base**:
   - Created `lib/features/help/presentation/help_components.dart` providing reusable layout components (`HelpIntro`, `HelpSection`, `HelpBullet`, `HelpFooter`).
   - Created `lib/features/help/presentation/help_home_screen.dart` with 13 topic guide cards across 5 categories.
   - Created 13 dedicated help screens:
     - `journal_organization_help_screen.dart`
     - `attachments_ocr_help_screen.dart`
     - `tags_help_screen.dart`
     - `encryption_security_help_screen.dart`
     - `biometrics_pin_help_screen.dart`
     - `journal_locks_help_screen.dart`
     - `screenshot_audit_help_screen.dart`
     - `search_timeline_help_screen.dart`
     - `insights_help_screen.dart`
     - `storage_migration_help_screen.dart`
     - `backup_restore_help_screen.dart`
     - `export_formats_help_screen.dart`
     - `faq_troubleshooting_help_screen.dart`

5. **Settings Tab Wiring & Modern Styling**:
   - Updated `_SettingsTab` in `lib/app/app.dart` to display all 7 cards in order: Security, Appearance, Storage, Features, Permissions, Help, and About.
   - Upgraded `_SettingsSectionCard` styling with rounded containers, primary-tinted icon backgrounds, bold titles, and chevron trailing icons.

6. **Localization**:
   - Added all necessary strings and `@key` descriptions in `lib/l10n/app_en.arb` and regenerated `AppLocalizations`.

7. **Tests & Documentation**:
   - Added comprehensive tests in `test/features/appearance/appearance_screen_test.dart`, `test/features/features_catalog/features_screen_test.dart`, and `test/features/help/help_screens_test.dart`.
   - Updated `test/features/settings/settings_tab_test.dart` and `test/widget_test.dart`.
   - Updated `docs/features.md`.

## Verification

- `flutter analyze` completed with 0 errors and 0 warnings.
- `flutter test` passed all 618 tests cleanly.
- `dart format lib test integration_test` formatted cleanly.
