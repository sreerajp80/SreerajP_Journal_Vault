# Change log: The keyboard is asked not to learn from anything typed in the app

**Plan:** `plans/20260924_212832_keyboard_incognito.md`
**Date:** 2026-09-24

## Why

The app never asked the keyboard not to learn. So Gboard, Samsung Keyboard or SwiftKey could
save words from journal entries (names, places, private words) in their personal dictionary,
and offer them as suggestions in other apps. The journal editor (`flutter_quill`) had no option
to stop this, and Flutter's default allows learning. The user chose "always on", with no
Settings switch.

## What changed

- **Patched editor.** `third_party/flutter_quill/` is a copy of `flutter_quill` 11.5.1 (MIT,
  `LICENSE` kept; only `lib/`, `LICENSE`, `pubspec.yaml`, `README.md`, `CHANGELOG.md`). One line
  is added in `lib/src/editor/raw_editor/raw_editor_state_text_input_client_mixin.dart`, marked
  `// JOURNAL VAULT PATCH`: `enableIMEPersonalizedLearning: false`.
- `pubspec.yaml` — `dependency_overrides:` points `flutter_quill` at the copy. `pubspec.lock`
  updated. (`flutter pub get` also dropped the stale `speech_to_text` entries left from its
  earlier removal from `pubspec.yaml`.)
- `analysis_options.yaml` — the analyzer skips `third_party/**`.
- **All 47 text boxes** (`TextField` / `TextFormField`) in 23 files in `lib/` now pass
  `enableIMEPersonalizedLearning: false`. This includes the app-lock PIN box, which becomes a
  normal number box while "show PIN" is on.
- `tool/check_keyboard_incognito.sh` — new. Fails when a text box in `lib/` is missing the
  flag, when the editor patch is missing, or when `pubspec.yaml` no longer uses the copy.
  Added to CI (`.github/workflows/ci.yml`, job `permission-guard-check`).
- Docs: `docs/dependencies.md` (the copy, the patch, how to upgrade), `docs/security.md`
  (keyboard learning in section 10, a note in section 3), `CLAUDE.md` and `AGENTS.md` (the
  check command and the rule for new text boxes).

## Tests

- `test/features/entries/presentation/entry_editor_keyboard_test.dart` — new. The editor
  sends `enableIMEPersonalizedLearning: false` to the keyboard, and word suggestions stay on.
  Checked that it fails when the patch line is removed.
- `test/app/lock_gate_screen_test.dart` — the PIN box keeps the flag while the PIN is shown.
  (The plan named a new test file; the check was added to the existing PIN test instead.)
- `tool/check_keyboard_incognito.sh` — checked that it fails when one flag is removed.

Results: `dart format` clean, `flutter analyze` no issues, `flutter test` all 1081 pass.
`check_keyboard_incognito.sh`, `check_no_internet_permission.sh`, `check_sanskrit_markers.sh`
and `check_absolute_paths.sh --all` pass.

## Not yet checked

- A full APK build with the local copy (tests compile it, but no APK was built).
- On a phone with Gboard: type a made-up word in an entry, then in another app, and check
  the word is not suggested.

## Limits

A keyboard sees every key pressed. A keyboard that ignores the request, or a malicious one,
can still record text; only choosing a trusted keyboard protects against that. Suggestions
inside the journal will not learn the user's own words.

No new strings, so no Malayalam or Sanskrit text needs review.
