# Change Log: Localize 50 Curated Thought Cards and Themes into Malayalam

**Plan Reference:** `plans/20260824_205700_localize_thought_cards_malayalam.md`  
**Date:** 2026-08-24  
**Author:** AI Pair Programmer

---

## Summary of Changes

Translated all 50 curated Sanathana Dharma thought cards (titles, reflection prompts, quotes, source citations) and all 10 theme names into Malayalam. Added localized getters in the domain model and wired the Ritual presentation layer to dynamically display cards and themes based on the active app language.

---

## Files Changed

1. **`lib/features/ritual/domain/ritual_card.dart`**:
   - Added optional fields `titleMl`, `promptMl`, `quoteMl`, `quoteAuthorMl` to `RitualCard`.
   - Added localized getters `localizedTitle()`, `localizedPrompt()`, `localizedQuote()`, `localizedQuoteAuthor()` falling back to English when Malayalam is absent.
   - Added `localizedName(String languageCode)` to `RitualThemeExt` for all 10 Dharmic themes.
   - Populated complete Malayalam translations for all 50 curated cards in `RitualCard.curatedDeck`.

2. **`lib/features/ritual/presentation/ritual_screen.dart`**:
   - Displayed localized theme name, title, prompt, quote, and quote author in prompt step.
   - Displayed localized title in the journal prompt description.
   - Passed localized title, prompt, and quote text into `EntryEditorScreen` when opening the journal editor from a ritual card.

3. **`lib/features/ritual/presentation/ritual_deck_screen.dart`**:
   - Displayed localized theme names in filter chips.
   - Rendered localized title, prompt, quote, and quote author in card tiles.
   - Used localized title in card delete confirmation dialog.

4. **`lib/features/ritual/presentation/create_ritual_card_screen.dart`**:
   - Rendered localized theme names in theme choice chips and live preview card.

5. **`test/features/ritual/domain/ritual_card_localization_test.dart`**:
   - Added tests verifying that all 50 curated cards have complete Malayalam translations.
   - Verified that `localized*` getters return Malayalam when locale is `ml` and English when locale is `en`.
   - Verified that custom cards without translations fall back to default fields.
   - Verified all 10 theme names in English and Malayalam.

---

## Verification

- `flutter analyze` passed with 0 issues.
- `flutter test` passed all 776 tests.
- `dart format` formatted all modified source and test files.
