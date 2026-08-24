# Plan: Reading Themes and Entry Body Typography (A6.7)

**Status:** Completed  
**Created:** 2026-08-24 14:42:00 IST  
**Scope:** `lib/core/theme/`, `lib/features/appearance/`, `lib/features/entries/`, `lib/app/app.dart`, `lib/features/airqr/`, `lib/l10n/`, `docs/`, `test/`

---

## 1. Problem & Motivation

In journal writing, the feel of the writing surface and readability of the text directly impact daily use and focus. Currently, the app only supports standard Light, Dark, and System modes with accent colors.

Users need:
1. **Paper / Sepia reading theme:** A warm, eye-friendly parchment background (`#F8F3E6`) with warm espresso text (`#2C221E`) for relaxed long-form reading and writing.
2. **True Black (OLED) theme:** A pitch black (`#000000`) background that saves battery on AMOLED displays and eliminates glow in dark environments.
3. **Adjustable Entry Typography:** Body font family selection (Sans-serif, Serif/Book, Monospace/Typewriter) and adjustable body font size (12pt – 24pt) with live preview.

---

## 2. Proposed Changes

### Core Theme & Typography Architecture (`lib/core/theme/`)
- **`lib/core/theme/theme_mode_controller.dart`**:
  - Extend theme mode controller with `AppThemeMode` enum: `system`, `light`, `sepia`, `dark`, `oled`.
  - Maintain backwards compatibility with standard Flutter `ThemeMode` (`readThemeMode()` helper returns `ThemeMode.light`, `ThemeMode.dark`, `ThemeMode.system`).
  - Add theme metadata, display names, descriptions, and color token helpers.
- **`lib/core/theme/typography_controller.dart`** [NEW]:
  - `EntryFontFamily` enum: `sans` (Modern Sans), `serif` (Book / Literary), `monospace` (Typewriter / Monospace).
  - `TypographySettings` state with `fontFamily` and `fontSize` (default `16.0`, range `12.0`–`24.0`).
  - `TypographyStore` with `SharedPreferencesTypographyStore` and `InMemoryTypographyStore`.
  - Riverpod `typographyProvider` for reactive updates across the entire app.

### Application Shell & Theming (`lib/app/app.dart`)
- Update `_appTheme` to generate tailored Material 3 `ThemeData` for `AppThemeMode.light`, `AppThemeMode.sepia`, `AppThemeMode.dark`, and `AppThemeMode.oled`.
  - Sepia: `#F8F3E6` scaffold/surface background, `#EFE7D5` containers, `#2C221E` onSurface text, warm borders.
  - OLED: `#000000` pitch black scaffold/surface, `#0E0E10` surface containers, crisp high-contrast text.
- Connect `JournalVaultApp` to `typographyProvider`.

### Entry Editor & Viewer Styling (`lib/features/entries/`)
- **`lib/features/entries/presentation/entry_editor_screen.dart`**:
  - Configure `QuillEditorConfig` and custom text styling to apply the user's selected font family and body font size.
- **`lib/features/entries/presentation/version_history_screen.dart`** & **`template_editor_screen.dart`**:
  - Apply typography settings in editor and history viewers.

### Appearance Settings Screens (`lib/features/appearance/`)
- **`lib/features/appearance/presentation/appearance_screen.dart`**:
  - Add navigation card for **Reading Typography** alongside Theme Mode and Accent Color.
- **`lib/features/appearance/presentation/theme_mode_settings_screen.dart`**:
  - Modernize screen to display all 5 reading theme modes (System, Light, Sepia/Paper, Dark, OLED/True Black) with interactive selection cards, theme preview chips, and descriptions.
- **`lib/features/appearance/presentation/typography_settings_screen.dart`** [NEW]:
  - Live interactive sample journal entry preview reacting instantly to typography changes.
  - Font family selector with visual font preview chips (Sans-serif, Book Serif, Monospace).
  - Font size slider and preset quick-buttons (Small, Default, Medium, Large, Extra Large).
  - Reset to default typography button.

### Cross-Device Sync (`lib/features/airqr/`)
- Update `AirqrSettingsService` to export and import `appThemeMode`, `fontFamily`, and `fontSize` via encrypted AirQR payloads.

### Localization (`lib/l10n/`)
- Add user-visible strings to `lib/l10n/app_en.arb` with `@description` metadata for all theme and typography options.
- Run `flutter gen-l10n`.

### Documentation (`docs/`)
- Update `docs/enhancement_ideas.md` marking A6.7 as completed with link to plan and change log.

---

## 3. Verification Plan

### Automated Tests
- `test/features/appearance/typography_settings_screen_test.dart` [NEW] — Tests typography store, notifier, slider, chips, and live preview.
- `test/features/appearance/appearance_screen_test.dart` — Verify new theme modes and typography card navigation.
- `test/widget_test.dart` — Verify theme persistence, OLED/Sepia mode switching, and app startup theme restoration.
- `flutter test` — Run full test suite (758+ tests) to ensure 100% pass rate.
- `flutter analyze` — Static analysis must be 100% clean with zero warnings.

---

## 4. Approval Gate

No code changes will be made until explicit user approval is received.
