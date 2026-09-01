# Fix: entry body is not editable on a Malayalam device

**Status:** completed

## The issue

On a phone set to Malayalam, opening the entry editor shows the title field, but the
formatting toolbar and the whole body area are replaced by a plain grey block. Nothing
can be typed into the body. The title still works.

Cause:

- The app supports two locales, `en` and `ml` (`lib/l10n/app_localizations.dart`).
- `flutter_quill` 11.5.1 ships translations for many locales, but **not** `ml`.
- Because of that, `FlutterQuillLocalizations.delegate.isSupported(Locale('ml'))` is
  `false`, so Flutter never installs that delegate for a Malayalam locale.
- Every Quill widget reads `context.loc`, which is
  `FlutterQuillLocalizations.of(context) ?? throw MissingFlutterQuillLocalizationException()`.
  With the delegate missing, this throws while building.
- In a release build a widget that throws while building is drawn as a grey box. That
  is exactly the grey area in the screenshot. In English the same screen works, which
  is why the bug looks locale-specific.

## The fix

Keep the app in Malayalam, but always give Quill a language it knows. Wrap
`FlutterQuillLocalizations.delegate` in a small delegate that claims to support every
locale and falls back to English when Quill has no translation for the current one.

This is a two-file change plus a test. It does not touch the editor, the database, or
any crypto.

## Files to change

| File | Change |
|---|---|
| `lib/core/l10n/quill_localizations_fallback.dart` | **New.** `quillLocalizationsFallbackDelegate` — a `LocalizationsDelegate<FlutterQuillLocalizations>` whose `isSupported` is always `true`, and whose `load` passes the locale through to Quill's own delegate when Quill supports it, otherwise loads `Locale('en')`. |
| `lib/app/app.dart` | Use the new delegate in `localizationsDelegates` in place of `FlutterQuillLocalizations.delegate`. |
| `test/core/l10n/quill_localizations_fallback_test.dart` | **New.** Tests that the delegate reports support for `ml`, that loading `ml` returns English Quill strings, and that loading `en` still returns English. |

## Notes

- The editor's own labels (title, save, tooltips) keep coming from `AppLocalizations`,
  so Malayalam is unaffected there. Only the Quill built-in strings fall back to
  English, which is far better than a dead editor.
- Same fix protects any future locale that Quill does not translate.
- After the change: `flutter analyze` must be clean and `flutter test` must pass.
