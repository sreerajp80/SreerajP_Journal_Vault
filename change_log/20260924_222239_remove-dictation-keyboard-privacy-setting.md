# Change log: Dictation removed, and a "Keyboard privacy" switch in Settings

**Plan:** `plans/20260924_220251_remove-dictation-keyboard-privacy-setting.md`
**Date:** 2026-09-24
**Replaces:** the always-on rule from `change_log/20260924_215911_keyboard_incognito.md`.
**Makes obsolete:** `change_log/20260924_212800_dictation_accuracy.md` (that code is deleted).

## Why

The in-app speech to text was much less accurate than the keyboard's own voice typing, which
already works in every text box. The user asked to remove it. The user also asked for keyboard
privacy to be a Settings switch, on by default, that tells people what it is for.

## Part A — Dictation removed

- Deleted: `dictation_bar.dart`, `dictation_language_sheet.dart`, `dictation_providers.dart`,
  `dictation_service.dart`, `dictation_text_cleaner.dart`, `speech_engine.dart`,
  `OnDeviceDictation.kt`, and their tests (`dictation_bar_test.dart`,
  `entry_editor_dictation_test.dart`, `dictation_service_test.dart`,
  `dictation_text_cleaner_test.dart`, `speech_engine_test.dart`, `fake_speech_engine.dart`,
  `OnDeviceDictationTest.kt`).
- Editor: the dictate buttons (top toolbar and bottom bar), the bar, and the insert code are
  gone from `editor_toolbar.dart`, `entry_editor_widgets.dart`, `entry_editor_layout.dart`,
  `entry_editor_screen.dart`, `entry_editor_actions_3.dart`.
- `MainActivity.kt`: the `speech` and `speech_events` channels, `reportOnDeviceSpeechStatus`,
  and unused imports removed. `AndroidManifest.xml`: the `RecognitionService` query removed;
  `RECORD_AUDIO` stays, for voice notes only.
- Strings: 21 dictation keys removed from all three ARB files. The FAQ microphone line
  (`helpFaqA3`) now says voice notes only, in all three languages.
- Voice notes are unchanged.

## Part B — Keyboard privacy switch

- New `lib/core/security/keyboard_privacy_controller.dart` (layer: core/security): store
  (SharedPreferences key `keyboard_privacy`; missing or unreadable = on), provider, and
  `KeyboardPrivacyController`. The store is opened in `main.dart` before the first frame.
- New `lib/core/security/keyboard_privacy_scope.dart`: an `InheritedWidget` set in
  `MaterialApp.builder` (`lib/app/app.dart`), so pages and dialogs all see the choice.
  `KeyboardPrivacyScope.allowLearning(context)` returns false while privacy is on, and when
  there is no scope.
- All 47 `TextField` / `TextFormField` and the 3 `QuillEditorConfig`s now pass
  `enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(context)`.
- `third_party/flutter_quill`: the fixed `false` became a real option,
  `enableIMEPersonalizedLearning` (default `true`), in `editor_config.dart`,
  `raw_editor_config.dart`, `editor.dart` and the text input mixin, each change marked
  `// JOURNAL VAULT PATCH`.
- Settings → Security: new `KeyboardPrivacyTile` under "Block Screenshots", with a subtitle
  that says what it is for. Turning it off asks first; a snackbar confirms each change.
- 8 new strings in English, Malayalam and Sanskrit.
- `tool/check_keyboard_incognito.sh` now requires the scope call on every text box and
  editor config, and the option in the quill copy.
- Docs: `features.md`, `security.md`, `architecture.md`, `implementation_progress.md`,
  `release_process.md`, `dependencies.md`, `CLAUDE.md`, `AGENTS.md`.

## Tests

- New `test/core/security/keyboard_privacy_controller_test.dart`: on by default, an
  unreadable store counts as on, saving works, a failed save keeps the old value.
- `test/app/settings_screen_security_test.dart`: the switch is on by default and shows its
  subtitle; turning it off asks first and Cancel keeps it on; confirming turns it off for
  every text box; turning it back on needs no dialog. (The plan named a new file; these sit
  next to the screenshot switch tests instead.)
- `test/features/entries/presentation/entry_editor_keyboard_test.dart`: the editor asks the
  keyboard not to learn when privacy is on, allows it when off, and treats no scope as on.
- `test/app/lock_gate_screen_test.dart`: the PIN box follows the setting.

Results: `flutter analyze` no issues; `flutter test` all 1010 pass; Kotlin unit tests pass;
`flutter build apk --flavor dev --debug` builds; `check_keyboard_incognito.sh`,
`check_no_internet_permission.sh`, `check_sanskrit_markers.sh`,
`check_absolute_paths.sh --all` pass.

Two tests unrelated to this change failed once each under full-suite load and passed on
re-runs: `sync_engine_wifi_test.dart` (local socket) and `time_capsule_widget_test.dart`
("builds a long list lazily"). They look timing-sensitive.

## Needs native-reader review

New Malayalam and Sanskrit strings: `labelSettingsKeyboardPrivacy`,
`descSettingsKeyboardPrivacy`, `bodySettingsKeyboardPrivacyOff`,
`bodySettingsKeyboardPrivacyOffBody`, `actionSettingsKeyboardPrivacyOff`,
`bodySettingsKeyboardPrivacyUpdatedOn`, `bodySettingsKeyboardPrivacyUpdatedOff`,
`errorSettingsKeyboardPrivacySave`, and the changed `helpFaqA3` microphone line. The
Sanskrit term for keyboard, कुञ्जीफलकम्, is a modern coinage.

## Not yet checked

On a phone: the switch in Settings, and that with it on a made-up word typed in an entry is
not suggested in another app.
