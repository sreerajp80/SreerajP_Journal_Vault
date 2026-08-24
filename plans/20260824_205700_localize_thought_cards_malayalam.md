# Localize 50 Curated Thought Cards and Themes into Malayalam

**Status:** completed

---

## Problem

The 50 curated Sanathana Dharma thought cards (titles, reflection prompts, quotes, source citations) and theme names in `RitualCard` are hardcoded in English. When the app's language is switched to Malayalam, the surrounding UI buttons and labels appear in Malayalam, but the thought card text itself remains in English.

---

## Scope

1. **Add Malayalam translation fields and localization methods to `RitualCard` domain model**:
   - Add optional fields: `titleMl`, `promptMl`, `quoteMl`, and `quoteAuthorMl`.
   - Add helper methods: `localizedTitle(String languageCode)`, `localizedPrompt(String languageCode)`, `localizedQuote(String languageCode)`, and `localizedQuoteAuthor(String languageCode)`.
   - Add `localizedName(String languageCode)` to `RitualThemeExt` so theme names (Dharma, Karma, Bhakti, etc.) render in Malayalam (`ധർമ്മം`, `കർമ്മം`, `ഭക്തി`, etc.) when the active locale is Malayalam.

2. **Translate all 50 curated Sanathana Dharma cards into Malayalam**:
   - Add accurate, meaningful Malayalam translations for all 50 cards across all 10 themes (Dharma, Karma, Bhakti, Jnana, Yoga, Ahimsa, Sathya, Vairagya, Seva, Shanti).

3. **Update Ritual UI presentation to display localized content**:
   - In `ritual_screen.dart`: display card title, prompt, quote, quote author, and theme name in the active app locale. When creating an entry from a ritual card, send the localized title and prompt/quote text to the entry editor.
   - In `ritual_deck_screen.dart`: display card titles, quotes, prompt text, and theme filter chips in the active app locale.
   - In `create_ritual_card_screen.dart`: display theme names in the active app locale.

4. **Update tests**:
   - Add unit tests in `test/features/ritual/` to verify localized title, prompt, quote, and theme display under both English (`en`) and Malayalam (`ml`) locales.

---

## Proposed Changes

### 1. Domain Layer
- **`lib/features/ritual/domain/ritual_card.dart`**:
  - Add `titleMl`, `promptMl`, `quoteMl`, `quoteAuthorMl` to `RitualCard`.
  - Add `localizedTitle(String lang)`, `localizedPrompt(String lang)`, `localizedQuote(String lang)`, `localizedQuoteAuthor(String lang)`.
  - Add `localizedName(String lang)` on `RitualThemeExt`.
  - Populate Malayalam translations for all 50 cards in `RitualCard.curatedDeck`.

### 2. Presentation Layer
- **`lib/features/ritual/presentation/ritual_screen.dart`**:
  - Use `Localizations.localeOf(context).languageCode` to render localized card content, quotes, and themes.
- **`lib/features/ritual/presentation/ritual_deck_screen.dart`**:
  - Use localized getters for preview cards, full detail sheet, and filter chips.
- **`lib/features/ritual/presentation/create_ritual_card_screen.dart`**:
  - Display localized theme names in choice chips and preview cards.

### 3. Testing
- **`test/features/ritual/domain/ritual_card_localization_test.dart`**:
  - Verify localized getters return Malayalam content when `ml` is requested and English content when `en` is requested or when custom cards lack translations.
- Run `flutter analyze` and `flutter test`.

---

## Verification Plan

### Automated Tests
```bash
flutter analyze
flutter test
```

### Manual Verification
- Switch app language to Malayalam in Settings.
- Open Ritual Mode / Thought Cards to confirm that card themes, titles, prompts, quotes, and sources display in Malayalam.
- Switch back to English to confirm cards display in English.
