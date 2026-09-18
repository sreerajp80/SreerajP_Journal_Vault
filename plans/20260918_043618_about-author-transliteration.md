# Plan — Transliterate the About screen author name into Malayalam and Sanskrit

**Status:** Awaiting approval

## Issue

On the About screen, four values show in English only in all three languages:
`appName`, `details.author`, `details.aiUsed`, `details.ideUsed`.

This is mostly by design. `assets/config/app_config.json` follows the rule written in
`lib/core/config/app_config.dart`: a plain string means "the same text in every language",
which is right for a name or an email, while a sentence uses the `{"en", "ml", "sa"}` map.
That is why `description` and `details.license` are translated and the rest are not.

The row **labels** are already translated in all three languages. Only the **values** are
not. So in Sanskrit the author row already reads `लेखकः : Sreeraj P` — the label is
Sanskrit, the name is Latin script.

The one value worth changing is `details.author`. A person's name is not translated, but it
can be **transliterated**, so a reader using the Malayalam or Sanskrit interface sees the
name in the script they are reading. `aiUsed` and `ideUsed` are product names (Claude,
Anthropic, Google Gemini, VS Code, Antigravity) and stay in their original form.

## Scope

In scope:

- Turn `details.author` into a per-language map.

Out of scope (no change):

- `appName` — a brand name. It is typed as a plain `String` in `AppConfig`, so it cannot
  hold a language map without a code change. See "Open question" below.
- `details.aiUsed`, `details.ideUsed` — product names.
- `details.email` — an address, not text.

## Files to change

| File | Change |
|---|---|
| `assets/config/app_config.json` | `details.author` becomes an `en` / `ml` / `sa` map |

No Dart change is needed. No ARB change is needed.

## The fix

`assets/config/app_config.json`, inside `details`:

```json
"author": {
  "en": "Sreeraj P",
  "ml": "ശ്രീരാജ് പി",
  "sa": "श्रीराजः पी"
}
```

Everything else in the file stays as it is.

## Why no code change is needed

- `AppConfig.fromJson` builds every `details` entry through `LocalizedText.fromJson`, which
  already accepts either a plain string or a locale map
  (`lib/core/config/app_config.dart`).
- `AboutMetadata` passes `details` straight through and holds no named fields
  (`lib/features/about/application/about_metadata.dart`).
- `AboutScreen` loops the `details` map and calls `resolve(lang)` on each value
  (`lib/features/about/presentation/about_screen.dart`). It already resolves per language —
  it just had nothing but a plain string to resolve until now.
- Falling back is safe: `resolve` returns the `en` value for any language key that is
  missing.

## Layer note

This is a config-only edit. No new class, so no layer decision to make.

## Translation review

Both new values are transliterations of a personal name, not translated words:

- Malayalam `ശ്രീരാജ് പി`
- Sanskrit `श्रीराजः पी` — Devanagari, nominative ending, no nukta letters and no Hindi
  markers, so `tool/check_sanskrit_markers.sh` stays clean.

Per the localization rules, both must be listed as **needs native-reader review** in the
change log until a fluent reader approves them. If you would rather the Sanskrit row read
`श्रीराज पी` without the nominative ending, say so and I will use that instead.

## Testing

1. `sh tool/check_sanskrit_markers.sh`
2. `flutter analyze` — must stay at zero issues
3. `flutter test` — with attention to:
   - `test/core/config/app_config_test.dart`
   - `test/core/config/config_service_test.dart`
   - `test/features/about/about_metadata_test.dart`
   - `test/features/about/about_screen_test.dart`
   - `test/l10n/translation_parity_test.dart`
   - `test/l10n/label_length_test.dart`
4. Add a test to `test/core/config/app_config_test.dart` only if no existing case covers a
   `details` entry parsed from a locale map. Check first; do not duplicate a case.
5. Manual check: open About, switch the language in Settings between English, മലയാളം and
   संस्कृतम्, and confirm the author row changes script while every other row is unchanged.

## Re-test of earlier work

The About screen is the only screen that reads this file. Confirm the config also still
loads on a cold start (the screen shows real values, not the fallback `0.0.0`).

## Acceptance criteria

- The author row shows the name in the script of the active language, in all three
  languages.
- No other About row changes.
- `flutter analyze` clean, `flutter test` green, Sanskrit marker check clean.
- A change log is written to `change_log/` referencing this plan, listing both new strings
  as needing native-reader review.

## Open question — answer before I implement

Do you want `appName` transliterated too? It is the app's brand name, shown as the heading
of the About screen. Doing it is a bigger change than this plan:

- `AppConfig.appName` would change from `String` to `LocalizedText`
- `AboutMetadata.appName` would change with it
- `AboutScreen` would call `resolve(lang)` on it
- `AppConfig.fallback` and the tests that assert on `appName` would need updating

My recommendation is **no** — a brand name normally stays fixed in every language, and the
type was chosen deliberately to say so. But it is your app's identity, so it is your call.
If you want it, I will extend this plan rather than start a second one.
