# Entry body not editable on a Malayalam device — fixed

Implements `plans/20260901_101500_quill-locale-fallback.md`.

## What was wrong

On a phone set to Malayalam, the entry editor showed the title field but drew the
formatting toolbar and the whole body as a plain grey block. Nothing could be typed.

The app supports `en` and `ml`. `flutter_quill` 11.5.1 has no Malayalam translation, so
Flutter treated `FlutterQuillLocalizations.delegate` as unsupported and left it out.
Every Quill widget reads `context.loc`, which throws
`MissingFlutterQuillLocalizationException` when that delegate is missing. A widget that
throws while building is painted as a grey box in a release build. The title field is a
plain Flutter `TextField`, which is why it kept working.

## What changed

| File | Change |
|---|---|
| `lib/core/l10n/quill_localizations_fallback.dart` | New. `QuillLocalizationsFallbackDelegate` reports support for every locale and forwards to Quill's own delegate, using `Locale('en')` when Quill has no translation for the current locale. Exported as the const `quillLocalizationsFallbackDelegate`. |
| `lib/app/app.dart` | Uses the new delegate in `localizationsDelegates` instead of `FlutterQuillLocalizations.delegate`. The direct `flutter_quill` import is gone. |
| `test/core/l10n/quill_localizations_fallback_test.dart` | New. Four tests: `ml` is unsupported by the package but supported by the wrapper; loading `ml` yields English Quill strings; a locale Quill does translate (`fr`) is passed through; `shouldReload` is false. |

## Effect

- The editor and toolbar work in Malayalam again.
- App text stays Malayalam — only Quill's own built-in labels fall back to English.
- Any future locale that Quill does not translate is covered by the same wrapper.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 781 tests, all pass.
- `dart format` — clean.
