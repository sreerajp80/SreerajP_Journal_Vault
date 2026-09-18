# Localize the About screen `aiUsed` and `ideUsed` values

**Status:** Awaiting approval

## Issue

On the About screen every row label is translated into English, Malayalam and
Sanskrit, but two row *values* stay in Latin script in all three languages:

- `aiUsed` — `Claude (Anthropic) / Google Gemini`
- `ideUsed` — `VS Code / Antigravity`

In `assets/config/app_config.json` these two keys are written as plain strings.
A plain string means "the same text in every language" (`LocalizedText.plain`,
`lib/core/config/app_config.dart`), so a Malayalam or Sanskrit reader sees a
translated label followed by Latin-script text.

Every other translatable value in that file (`appName`, `description`,
`details.author`, `details.license`) already uses the `{"en": …, "ml": …,
"sa": …}` map form. `details.email` stays a plain string on purpose — an
address is not translatable.

## Fix

Change only the two values in the config file from a plain string to the
three-language map form, giving each product name its native-script
transliteration. Brand names stay recognisable; only the script changes.

| Key | en | ml | sa |
|---|---|---|---|
| `aiUsed` | Claude (Anthropic) / Google Gemini | ക്ലോഡ് (ആന്ത്രോപിക്) / ഗൂഗിൾ ജെമിനി | क्लोड् (आन्थ्रोपिक्) / गूगल् जेमिनी |
| `ideUsed` | VS Code / Antigravity | വിഎസ് കോഡ് / ആന്റിഗ്രാവിറ്റി | वि.एस्. कोड् / आन्टिग्राविटी |

No nukta letters are used in the Sanskrit values, so
`tool/check_sanskrit_markers.sh` stays green.

## Files to change

| File | Change |
|---|---|
| `assets/config/app_config.json` | `details.aiUsed` and `details.ideUsed` become `{en, ml, sa}` maps |

## Files that do NOT change

- No Dart change. `AboutMetadata` keeps the rows as `LocalizedText` and the
  screen resolves them by language, so the map form already works end to end.
- No ARB change. The labels `aboutDetailAiUsed` and `aboutDetailIdeUsed`
  already exist in all three ARB files.
- No test fixture change. `test/widget_test.dart` builds its own config
  fixture and does not read the real asset.

## Verification

1. `sh tool/check_sanskrit_markers.sh`
2. `flutter test test/l10n/ test/core/config/ test/features/about/ test/widget_test.dart`
3. `flutter analyze`
4. `dart format lib test integration_test`

## Risk

Low. One asset file, data only, no code path changes. If a value were
malformed, `LocalizedText.fromJson` falls back to the plain/fallback string,
so the row still renders.

## Open question for a native reader

The Malayalam and Sanskrit transliterations of the product names are new terms
and need native-reader review. They will be listed as "needs native-reader
review" in the change log.
