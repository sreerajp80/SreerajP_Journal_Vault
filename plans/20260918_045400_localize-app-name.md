# Plan — Translate the app name into Malayalam and Sanskrit

**Status:** Awaiting approval

## Issue

The About screen heading shows the app name in English in all three languages. It comes
from `appName` in `assets/config/app_config.json`, which is a plain string. `AppConfig`
types it as a plain `String` on purpose, with the comment "A brand name, the same in every
language", so the config file cannot hold a translation for it without a code change.

While checking this, a second problem turned up. The app name already lives in a **second**
place: the ARB key `titleApp`, used for the window and task-switcher title in
`lib/app/app.dart` and `lib/app/vault_unavailable_app.dart`. There:

- English — `SreerajP Journal Vault`
- Malayalam — `ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്` (already translated)
- Sanskrit — `SreerajP Journal Vault` (**still English — a real gap**)

So today the name is translated in one place and not the other, and the two can drift
apart. This plan fixes both and makes them agree.

## Decisions taken

Both were chosen by the repository owner before this plan was written:

1. **The config stays the source of truth** for the About screen, as the project rules
   require. `AppConfig.appName` becomes a `LocalizedText`, and `titleApp` in `app_sa.arb`
   is filled in with the same Sanskrit string so the two never disagree.
2. **The Sanskrit name is `श्रीराज्पी दैनन्दिनीकोषः`** — the brand "SreerajP" in
   Devanagari, with "Journal Vault" as real Sanskrit: दैनन्दिनी (a daily journal) +
   कोषः (a treasury or vault). This reads as Sanskrit instead of English in Devanagari
   letters, and avoids the ऑ vowel sign, which is not a Sanskrit sign.

The Malayalam string is the one already in `app_ml.arb`, reused so nothing changes for
Malayalam readers: `ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്`.

## Files to change

| File | Change |
|---|---|
| `lib/core/config/app_config.dart` | `appName` becomes `LocalizedText`; fallback and `fromJson` follow |
| `lib/features/about/application/about_metadata.dart` | `appName` becomes `LocalizedText` |
| `lib/features/about/presentation/about_screen.dart` | Heading calls `.resolve(lang)` |
| `assets/config/app_config.json` | `appName` becomes an `en` / `ml` / `sa` map |
| `lib/l10n/app_sa.arb` | `titleApp` gets the Sanskrit name |
| `test/core/config/app_config_test.dart` | Assertions read through `.resolve(...)` |
| `test/core/config/config_service_test.dart` | Same |
| `test/features/about/about_metadata_test.dart` | Fixture and assertion use `LocalizedText` |
| `test/widget_test.dart` | Fixture uses `LocalizedText` |

## The fix

### 1. `lib/core/config/app_config.dart`

Change the field type, the fallback, and the parse. The doc comment on `appName` currently
says the name is the same in every language — it must be rewritten, because that is the
rule being changed here.

```dart
// field
/// The app's own name. Translated, because the About heading and the task
/// switcher both show it to a reader in their own language.
final LocalizedText appName;

// fallback
static const AppConfig fallback = AppConfig(
  appName: LocalizedText.plain('SreerajP Journal Vault'),
  ...
);

// fromJson
appName: LocalizedText.fromJson(
  json['appName'],
  fallback: fallback.appName.resolve('en'),
),
```

Note this keeps the old safety behaviour: a wrong type such as `42` still yields the
fallback name, because `LocalizedText.fromJson` falls back on any non-string, non-map value.

### 2. `lib/features/about/application/about_metadata.dart`

`final String appName;` becomes `final LocalizedText appName;`. `buildAboutMetadata` still
passes `config.appName` straight through — no other change. The class keeps holding no
resolved UI strings, which is what its doc comment requires of the application layer.

### 3. `lib/features/about/presentation/about_screen.dart`

The heading at line 48 resolves for the active language, exactly as `description` on the
line below it already does:

```dart
Text(
  metadata.appName.resolve(lang),
  style: Theme.of(context).textTheme.headlineSmall,
),
```

### 4. `assets/config/app_config.json`

```json
"appName": {
  "en": "SreerajP Journal Vault",
  "ml": "ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്",
  "sa": "श्रीराज्पी दैनन्दिनीकोषः"
},
```

### 5. `lib/l10n/app_sa.arb`

```json
"titleApp": "श्रीराज्पी दैनन्दिनीकोषः",
```

`app_en.arb` and `app_ml.arb` are unchanged — English and Malayalam already hold the right
values, and the `@titleApp` description already exists in the template file.

### 6. Tests

These are mechanical: the value is no longer a `String`, so the assertions read through
`resolve`.

- `test/core/config/app_config_test.dart` — `expect(config.appName.resolve('en'), 'Vault')`
  and the same for the two fallback assertions and the `'Only Name'` case.
- `test/core/config/config_service_test.dart` — the six `appName` assertions, likewise.
- `test/features/about/about_metadata_test.dart` — the fixture becomes
  `LocalizedText.plain('SreerajP Journal Vault')` and the assertion resolves it.
- `test/widget_test.dart` — the fixture at line 175 becomes a `LocalizedText.plain(...)`.

Two new cases to add to `test/core/config/app_config_test.dart`:

- a config whose `appName` is a locale map resolves per language;
- a config whose `appName` is a plain string still resolves the same text in all three
  languages (the old shape must keep working, so an older config file is never broken).

`test/features/about/about_screen_test.dart` needs no change — its fixtures are raw JSON
strings, and a plain `appName` still parses.

## Layer note

No new class and no layer boundary moves. `LocalizedText` already lives in `core/config`,
the application layer keeps carrying unresolved text, and the presentation layer keeps
being the only place that knows the active language.

## Risk — read before approving

Changing a public field's type is a wider blast radius than a config edit. The compiler
finds every user, and `flutter analyze` must be clean before the change is considered done.
The known users are the nine files listed above; `grep` found no others.

## Translation review

Both values are **pending native-reader review**:

- Malayalam `ശ്രീരാജ്‌പി ജേണൽ വോൾട്ട്` — already in the app, unchanged by this plan, but
  now shown in a second place.
- Sanskrit `श्रीराज्पी दैनन्दिनीकोषः` — new. No nukta letters and no Hindi markers, so
  `tool/check_sanskrit_markers.sh` should stay clean.

## Testing

1. `sh tool/check_sanskrit_markers.sh`
2. `flutter analyze` — must be zero issues; this is the main check for a type change
3. `flutter test`, with attention to:
   - `test/core/config/app_config_test.dart`
   - `test/core/config/config_service_test.dart`
   - `test/features/about/about_metadata_test.dart`
   - `test/features/about/about_screen_test.dart`
   - `test/widget_test.dart`
   - `test/l10n/translation_parity_test.dart`
   - `test/l10n/label_length_test.dart` — `titleApp` is already on that test's
     `allowedToRunLong` list, so the longer Sanskrit name will not trip the budget
4. `dart format lib test integration_test`

## Re-test of earlier work

- The About screen still loads real values on a cold start, not the `0.0.0` fallback.
- The author row from the previous change still switches script per language.
- The window title still appears — `app.dart` and `vault_unavailable_app.dart` read
  `titleApp`, which changes value in Sanskrit for the first time.

## Acceptance criteria

- The About heading shows the app name in the script of the active language, in all three.
- The task-switcher title shows the Sanskrit name when the app language is Sanskrit.
- The config value and the `titleApp` value agree in all three languages.
- A config file with a plain-string `appName` still works.
- `flutter analyze` clean, `flutter test` green, Sanskrit marker check clean.
- A change log is written to `change_log/` referencing this plan, listing the Sanskrit name
  as needing native-reader review.
