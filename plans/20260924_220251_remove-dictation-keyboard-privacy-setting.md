# Plan: Remove dictation, and make keyboard privacy a Settings switch

**Status:** completed
**Change log:** `change_log/20260924_222239_remove-dictation-keyboard-privacy-setting.md`

## The issue

1. **Dictation.** The in-app speech-to-text is much less accurate than the keyboard's own voice
   typing, which already works in every text box. The user wants dictation removed from the
   journal entirely. Voice notes (audio recordings) are a separate feature and stay.
2. **Keyboard privacy.** Since `plans/20260924_212832_keyboard_incognito.md`, every text box
   and the editor always ask the keyboard not to learn. The user wants this as a Settings
   switch, **on by default**, with a clear note telling the user what it is for.

## Part A — Remove dictation

### Delete

- `lib/features/entries/presentation/editor/dictation_bar.dart`
- `lib/features/entries/presentation/editor/dictation_language_sheet.dart`
- `lib/features/entries/providers/dictation_providers.dart`
- `lib/features/entries/services/dictation_service.dart`
- `lib/features/entries/services/dictation_text_cleaner.dart`
- `lib/features/entries/services/speech_engine.dart`
- `android/.../OnDeviceDictation.kt` and `android/app/src/test/.../OnDeviceDictationTest.kt`
- Tests: `dictation_bar_test.dart`, `entry_editor_dictation_test.dart`,
  `dictation_service_test.dart`, `dictation_text_cleaner_test.dart`, `speech_engine_test.dart`,
  `test/helpers/fake_speech_engine.dart`

### Change

- `editor_toolbar.dart`, `entry_editor_widgets.dart`, `entry_editor_layout.dart`,
  `entry_editor_screen.dart`, `entry_editor_actions_3.dart` — remove the two dictate buttons,
  the bar, `_dictate`, `_insertDictatedPhrase`, `_onDictationClosed`, `_isDictating`,
  `_dictationBarKey`, and `_withSpacesForOffset` if nothing else uses it.
- `MainActivity.kt` — remove the `speech` and `speech_events` channels,
  `reportOnDeviceSpeechStatus`, the `dictation` field and the `android.speech` imports.
- `AndroidManifest.xml` — remove the `<queries>` entry for `android.speech.RecognitionService`,
  and fix the comment on `RECORD_AUDIO` (still needed, for voice notes only).
- `voice_note_service.dart` — fix the doc comment that points to `DictationService`.
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` — remove the 25 dictation keys
  (`tooltipEditorDictate`, `titleDictation`, `labelDictation…`, `tooltipDictation…`,
  `helpDictation…`, `descDictation…`, `errorDictation…`, `actionDictation…`), then
  `flutter gen-l10n`. Any help or FAQ text that mentions dictation is reworded to say "use
  your keyboard's microphone button".
- Docs: `features.md`, `security.md`, `architecture.md`, `implementation_progress.md`,
  `release_process.md`, `dependencies.md` — remove or mark as removed. Old plans and change
  logs are history and stay as they are.

## Part B — Keyboard privacy switch (on by default)

### How it works

- **Store:** `SharedPreferences`, key `keyboard_privacy`, a plain `bool`. It is a preference,
  not a secret. Missing or unreadable means **on**.
- **Controller** (layer: core/security): `lib/core/security/keyboard_privacy_controller.dart`
  — a store interface (SharedPreferences and in-memory versions), a provider, and an
  `AsyncNotifier<bool>` with `setEnabled`, the same shape as `screen_security_controller.dart`.
- **Reaching every text box:** `lib/core/security/keyboard_privacy_scope.dart` — a small
  `InheritedWidget` put around the whole app in `MaterialApp.builder` (`lib/app/app.dart`), so
  pages and dialogs all see it. Text boxes use
  `enableIMEPersonalizedLearning: KeyboardPrivacyScope.allowLearning(context)`. While the value
  is still loading, learning is off.
- **The 47 text boxes** change from `false` to that call.
- **The editor:** the patched `flutter_quill` copy gets a proper option instead of a fixed
  `false`: `enableIMEPersonalizedLearning` on `QuillEditorConfig`, passed through to
  `QuillRawEditorConfig` and the keyboard settings (default `true`, as upstream would have
  it). This is 4 small edits in `third_party/flutter_quill`, each marked
  `// JOURNAL VAULT PATCH`. The entry editor passes the scope value.
- **A change takes effect** the next time a text box is tapped. The keyboard reads the setting
  when it connects.

### What the user sees

In **Settings → Security**, under "Block Screenshots", a new switch:

- **Title:** "Keyboard privacy"
- **Subtitle (what it is for):** "Asks your keyboard not to learn the words you type here, so
  private words don't show up as suggestions in other apps. Your keyboard's own settings
  still apply."
- **Turning it off** shows a confirm dialog first, as "Block Screenshots" does:
  - Title: "Let the keyboard learn?"
  - Body: "Your keyboard may remember words from your journal, such as names and places, and
    suggest them in other apps. Turn this off only if you want better suggestions while
    writing."
  - Buttons: "Cancel" and "Allow learning"
- A short confirmation snackbar after each change, and an error snackbar if saving fails.

All new strings go into English, Malayalam and Sanskrit, with `@key` descriptions. The
Malayalam and Sanskrit wording is marked "needs native-reader review" in the change log.
New keys: `labelSettingsKeyboardPrivacy`, `descSettingsKeyboardPrivacy`,
`bodySettingsKeyboardPrivacyOff`, `bodySettingsKeyboardPrivacyOffBody`,
`actionSettingsKeyboardPrivacyOff`, `bodySettingsKeyboardPrivacyUpdatedOn`,
`bodySettingsKeyboardPrivacyUpdatedOff`, `errorSettingsKeyboardPrivacySave`.

Not included: a security-event log entry for this switch (the screenshot switch has one). It
can be a later change.

### Check script

`tool/check_keyboard_incognito.sh` now requires `enableIMEPersonalizedLearning:
KeyboardPrivacyScope.allowLearning(context)` on every text box, and the option in the quill
copy. The editor passes the same value.

## Files to change (Part B)

- New: `lib/core/security/keyboard_privacy_controller.dart`,
  `lib/core/security/keyboard_privacy_scope.dart`
- `lib/app/app.dart` (scope), `lib/main.dart` (only if the store needs an override)
- `lib/features/settings/presentation/security_settings_screen.dart` (the switch)
- The 23 files with text boxes; the entry editor's `QuillEditorConfig`
- `third_party/flutter_quill/lib/src/editor/config/editor_config.dart`,
  `.../raw_editor/config/raw_editor_config.dart`, `.../editor/editor.dart`,
  `.../raw_editor/raw_editor_state_text_input_client_mixin.dart`
- `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb`
- `tool/check_keyboard_incognito.sh`, `docs/security.md`, `docs/dependencies.md`,
  `docs/features.md`, `CLAUDE.md`, `AGENTS.md`

## Tests

- New `test/core/security/keyboard_privacy_controller_test.dart`: on by default; a missing or
  broken store reads as on; `setEnabled` saves.
- New `test/features/settings/presentation/keyboard_privacy_tile_test.dart`: the switch shows
  the title and subtitle; turning it off asks first, and Cancel keeps it on; turning it back
  on needs no dialog.
- `entry_editor_keyboard_test.dart`: learning off when the setting is on; on when it is off.
- `lock_gate_screen_test.dart`: the PIN box follows the setting.
- Parity and label-length tests cover the new strings.

## Acceptance criteria

- No dictation button, bar, strings, Dart or Kotlin code is left. Voice notes still work.
- Settings shows "Keyboard privacy", on by default, with the subtitle above.
- On: no text box or the editor lets the keyboard learn. Off (after confirming): they do.
- `flutter analyze` clean, `flutter test` passes, `flutter gen-l10n` run, all `tool/`
  checks pass, and the Kotlin unit tests pass.
