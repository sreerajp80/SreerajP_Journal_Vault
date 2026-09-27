# Plan: Ask the keyboard not to learn from anything typed in the app

**Status:** completed
**Change log:** `change_log/20260924_215911_keyboard_incognito.md`

## The issue

Android lets an app tell the keyboard "do not learn from this box" (the incognito
request, `IME_FLAG_NO_PERSONALIZED_LEARNING`). Trusted keyboards such as Gboard,
Samsung Keyboard and SwiftKey respect it: they do not add the words to their personal
dictionary or suggestion history.

The app never sends this request today:

1. **The journal editor.** `flutter_quill` 11.5.1 builds its keyboard settings in
   `lib/src/editor/raw_editor/raw_editor_state_text_input_client_mixin.dart` (inside the
   package) and has no option for it. Flutter's default is "learning allowed". So the
   keyboard may learn from every entry typed.
2. **Every other text box** (about 47 `TextField` / `TextFormField` in 23 files):
   titles, tags, search, templates, journal names, and so on. They use the default
   too.
3. **The app-lock PIN box** (`lib/app/app_lock_setup_screens.dart`). It is a
   password field, and keyboards do not learn from those, but its "show PIN" button
   turns it into a normal number field while the PIN is visible.

Password fields (`obscureText: true`) are already safe: Android marks them as
passwords and keyboards do not learn from them.

What this can **not** fix: a keyboard still sees every key pressed. A keyboard that
ignores the request, or that is malicious, can still record text. Only choosing a
trusted keyboard protects against that. The app will say nothing about this in the UI
in this change.

## The fix

1. **Patch `flutter_quill`** so the editor sends the request.
   - Copy `flutter_quill` 11.5.1 into `third_party/flutter_quill/` (its licence, MIT,
     allows this; keep its `LICENSE` file).
   - Change one line: add `enableIMEPersonalizedLearning: false` to its
     `TextInputConfiguration(...)`. Mark it with a `// JOURNAL VAULT PATCH` comment.
   - Point the app at the copy with `dependency_overrides:` in `pubspec.yaml`.
   - Record it in `docs/dependencies.md`: why the copy exists, the one patched line,
     and that a `flutter_quill` upgrade must repeat the patch or drop the copy.
   - Separately (outside this repository), offer the same option to the
     `flutter_quill` maintainers. If they accept it, the copy can be removed later.
2. **All other text boxes.** Add `enableIMEPersonalizedLearning: false` to every
   `TextField` and `TextFormField` in `lib/`, including the PIN box, so it stays safe
   while the PIN is shown.
3. **Keep it that way.** Add `tool/check_keyboard_incognito.sh`: it fails when a
   `TextField(` or `TextFormField(` in `lib/` has no `enableIMEPersonalizedLearning:
   false`, and when the patched line is missing from `third_party/flutter_quill`. Run it
   next to the other `tool/` checks.

Not changed: how typing, suggestions or autocorrect look. The keyboard still suggests
words from its general dictionary; it just does not remember words from this app.

## Files to change

- `third_party/flutter_quill/` — new, a patched copy of the package.
- `pubspec.yaml` — `dependency_overrides: flutter_quill: path: third_party/flutter_quill`.
- `pubspec.lock` — updated by `flutter pub get`.
- The 23 files in `lib/` that build a `TextField` or `TextFormField`.
- `tool/check_keyboard_incognito.sh` — new.
- `docs/dependencies.md`, `docs/security.md` (threat model: keyboard learning), and
  `README.md` or `docs/release_process.md` where the other `tool/` checks are listed.
- Tests:
  - `test/features/entries/presentation/entry_editor_keyboard_test.dart` — the editor
    attaches to the keyboard with `enableIMEPersonalizedLearning == false` (checked
    through the text input channel in a widget test).
  - `test/app/app_lock_pin_keyboard_test.dart` — the PIN box keeps it false when the
    PIN is shown.

## Trade-off

The keyboard will not learn names or words the user types often in the journal, so its
suggestions for those words will be a bit worse — also for Malayalam. This is the usual
price of incognito typing.

## Decision

Always on, with no Settings switch (user's choice, 2026-09-24). A switch can be a later
change if the weaker suggestions become a problem.

## Acceptance criteria

- The editor and every text box send `enableIMEPersonalizedLearning: false`.
- `sh tool/check_keyboard_incognito.sh` passes, and fails if the flag is removed from
  one box.
- `flutter analyze` is clean, `flutter test` passes.
- On a phone with Gboard: typing a new made-up word in an entry, then in another app,
  does not offer that word as a suggestion.
