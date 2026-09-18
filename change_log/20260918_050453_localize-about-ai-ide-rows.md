# Localized the About screen `aiUsed` and `ideUsed` values

**Plan:** `plans/20260918_050147_localize-about-ai-ide-rows.md`
**Status:** Implemented

## What was wrong

On the About screen the row labels "AI used" and "IDE used" were translated
into all three languages, but their values were not. Both keys were written as
plain strings in `assets/config/app_config.json`. A plain string means "the
same text in every language" (`LocalizedText.plain` in
`lib/core/config/app_config.dart`), so a Malayalam or Sanskrit reader saw a
translated label followed by Latin-script text.

## What changed

One file, data only.

### `assets/config/app_config.json`

`details.aiUsed` and `details.ideUsed` changed from a plain string to the
`{"en": …, "ml": …, "sa": …}` map form already used by `appName`,
`description`, `details.author` and `details.license`.

| Key | en | ml | sa |
|---|---|---|---|
| `aiUsed` | Claude (Anthropic) / Google Gemini | ക്ലോഡ് (ആന്ത്രോപിക്) / ഗൂഗിൾ ജെമിനി | क्लोड् (आन्थ्रोपिक्) / गूगल् जेमिनी |
| `ideUsed` | VS Code / Antigravity | വിഎസ് കോഡ് / ആന്റിഗ്രാവിറ്റി | वि.एस्. कोड् / आन्टिग्राविटी |

`details.email` was left as a plain string on purpose — an address is not
translatable.

## What did not change

- **No Dart change.** `AboutMetadata` keeps the rows as `LocalizedText` and the
  About screen resolves them by active language, so the map form already
  worked end to end.
- **No ARB change.** The labels `aboutDetailAiUsed` and `aboutDetailIdeUsed`
  already existed in `app_en.arb`, `app_ml.arb` and `app_sa.arb`.
- **No test change.** `test/widget_test.dart` builds its own config fixture and
  does not read the shipped asset.

## Verification

| Check | Result |
|---|---|
| `sh tool/check_sanskrit_markers.sh` | Passed |
| `flutter test test/l10n/ test/core/config/ test/features/about/ test/widget_test.dart` | 52 tests, all passed |
| `flutter analyze` | No issues found |
| `dart format` | Not needed — no Dart file changed |

## Needs native-reader review

Both new transliterations are new terms and have not been checked by a fluent
reader:

- Malayalam: `ക്ലോഡ് (ആന്ത്രോപിക്) / ഗൂഗിൾ ജെമിനി`, `വിഎസ് കോഡ് / ആന്റിഗ്രാവിറ്റി`
- Sanskrit: `क्लोड् (आन्थ्रोपिक्) / गूगल् जेमिनी`, `वि.एस्. कोड् / आन्टिग्राविटी`

These are product names written in the reader's script. If a native reader
prefers the Latin original for recognisability, only the `ml` and `sa` values
in the config file need to change back — no code change.
