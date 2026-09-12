# Change Log: Add App Screenshots to README.md

**Date:** 2026-09-12  
**Plan:** `plans/20260912_181500_add_screenshots_to_readme.md`

## Summary of Changes

Captured high-resolution, actual user interface screenshots from Android emulator `emulator-5554` and integrated an App Showcase gallery into `README.md`.

### Changes Details

1. **Installed and Configured App on Emulator**:
   - Installed the production-ready x86_64 build on `emulator-5554`.
   - Completed initial setup and configured device lock credentials.
   - Temporarily toggled off the "Block Screenshots" setting (`FLAG_SECURE`) to capture clean UI screenshots.

2. **Captured UI Screenshots** (stored in `docs/screenshots/`):
   - `home_screen.png`: Home dashboard showing journal collections and quick actions.
   - `editor_screen.png`: Rich text authoring editor with floating action bar, formatting toolbar, and stats bar.
   - `timeline_screen.png`: Timeline view and monthly calendar grid for tracking journal entries.
   - `insights_screen.png`: Insights dashboard displaying writing streak, mood trends, tag heatmap, memory recall, and weekly reflection.
   - `ritual_prompt_card.png`: Daily Journaling Ritual prompt card ("Your Swadharma" Sanathana Dharma theme).
   - `ritual_mode.png`: Centering breath contemplation screen.
   - `journal_detail_screen.png`: Journal detail screen with entry cards and filter/search bar.
   - `template_chooser.png`: Categorized modal template chooser.
   - `settings_screen.png`: Settings hub showcasing Material 3 modular cards.
   - `security_settings.png`: Security settings view with lock mode, auto-lock, and screenshot guard.
   - `lock_gate_screen.png`: App Lock Gate showing biometric and hardware-backed device lock.
   - `search_screen.png`: Full-text search screen.

3. **Updated README.md**:
   - Added an **App Showcase** section directly below **Key Highlights** displaying a curated 3x3 gallery of key app screens.
   - Used relative links to images stored under `docs/screenshots/`.

## Verification

- Verified all 12 screenshots are high resolution and render the real app UI accurately.
- Ran `tool/check_absolute_paths.sh` to confirm zero absolute paths or machine-specific details exist in `README.md`, the plan, or the change log.
