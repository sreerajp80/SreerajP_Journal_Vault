# Add App Screenshots to README.md Using Emulator

**Status:** completed

## The issue

The `README.md` file currently describes the app and its features with text, but lacks visual screenshots showing the actual user interface (such as the Journal library home screen, rich text editor with embeds, timeline/calendar, insights dashboard, and ritual mode).

## The proposed fix

1. Build and install the dev flavor APK onto `emulator-5554`.
2. Launch the app and complete setup on `emulator-5554`.
3. Disable screen security (screenshot blocking) in Settings so `adb screencap` can capture crisp UI screens without a black `FLAG_SECURE` mask.
4. Capture high-quality screenshots of key app screens:
   - `home_screen.png`: Home screen with journal cards.
   - `editor_screen.png`: Rich text entry editor with formatting toolbar and custom embeds.
   - `timeline_calendar.png`: Timeline view and monthly calendar heatmaps.
   - `insights_dashboard.png`: Insights dashboard with mood trends, streaks, and memories.
   - `ritual_mode.png`: Daily Journaling Ritual screen with thought prompt cards.
   - `settings_security.png`: Modular Settings and Security hub.
5. Save the screenshots in `docs/screenshots/`.
6. Update `README.md` to display these screenshots in a clean showcase/gallery section highlighting the UI.

## Files to change

- `docs/screenshots/*` (new image files)
- `README.md` (modify to add screenshot gallery)

## Verification plan

- Verify that screenshots are clear and accurately represent the app on `emulator-5554`.
- Verify that `README.md` renders images cleanly with relative paths (`docs/screenshots/...`).
- Run `tool/check_absolute_paths.sh` to ensure no local paths or machine details are introduced.
