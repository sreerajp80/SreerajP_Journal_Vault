# Change log — Transliterate the About screen author name into Malayalam and Sanskrit

**Plan:** `plans/20260918_043618_about-author-transliteration.md`
**Status:** Implemented

## What changed

One value in `assets/config/app_config.json`. The `details.author` entry was a plain
string, so the About screen showed the author's name in Latin script even when the app
language was Malayalam or Sanskrit. It is now a per-language map, so the name appears in
the script the reader is already reading.

Before:

```json
"author": "Sreeraj P",
```

After:

```json
"author": {
  "en": "Sreeraj P",
  "ml": "ശ്രീരാജ് പി",
  "sa": "श्रीराजः पी"
},
```

## Files changed

| File | Change |
|---|---|
| `assets/config/app_config.json` | `details.author` became an `en` / `ml` / `sa` map |

No Dart file changed. No ARB file changed. No test file changed.

## Why no code change was needed

The About path already resolved every detail row per language — the author row simply had
a plain string to resolve until now:

- `AppConfig.fromJson` builds each `details` entry through `LocalizedText.fromJson`, which
  accepts a plain string or a locale map (`lib/core/config/app_config.dart`).
- `AboutMetadata` passes `details` straight through and holds no named fields
  (`lib/features/about/application/about_metadata.dart`).
- `AboutScreen` loops `details` and calls `resolve(lang)` on each value
  (`lib/features/about/presentation/about_screen.dart`).

The row **label** was already translated in all three languages through the ARB key
`aboutDetailAuthor`, so only the value was in English.

## What deliberately did not change

- `appName` — a brand name, typed as a plain `String` in `AppConfig` on purpose.
- `details.aiUsed` and `details.ideUsed` — product names (Claude, Anthropic, Google Gemini,
  VS Code, Antigravity), which are not translated.
- `details.email` — an address, not text.

## Translation review

Both new strings are transliterations of a personal name, not translated words. They are
**pending native-reader review**:

- Malayalam `ശ്രീരാജ് പി` — needs native-reader review
- Sanskrit `श्रीराजः पी` — needs native-reader review. Devanagari, nominative ending, no
  nukta letters, no Hindi markers.

## Testing

| Check | Result |
|---|---|
| `sh tool/check_sanskrit_markers.sh` | Passed — covered `assets/config/app_config.json` and `lib/l10n/app_sa.arb` |
| `flutter analyze` | No issues found |
| `flutter test` | All 919 tests passed |

No new test was added. The plan called for one only if no existing case covered a `details`
entry parsed from a locale map; `test/core/config/app_config_test.dart` already has that
case, using the `license` key, and `LocalizedText` locale-map resolution is covered
separately in the same file. Adding another would have duplicated it.

The three tests that mention `author`
(`test/features/about/about_metadata_test.dart`, `test/features/about/about_screen_test.dart`,
`test/widget_test.dart`) each build their own fixture config rather than reading the real
asset, so none of them was affected.

## Still to do by hand

- Open About on a device, switch the language in Settings between English, മലയാളം and
  संस्कृतम्, and confirm the author row changes script while every other row stays the same.
- Get a fluent reader to confirm both transliterations, then drop the review note above.
