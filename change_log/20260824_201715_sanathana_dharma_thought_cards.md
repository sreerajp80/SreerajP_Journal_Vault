# Sanathana Dharma Thought Cards and User Card Creation

## Context
Implements the plan in `plans/20260824_201715_sanathana_dharma_thought_cards.md`.

Replaced the generic reflection cards and Western themes with 50 curated Sanathana Dharma teaching cards sourced from the Bhagavad Gita, Upanishads, Vedas, Yoga Sutras of Patanjali, Epics (Ramayana & Mahabharata), Thirukkural, and revered Acharyas/Saints. Added support for user-created custom cards backed by the encrypted database with full CRUD capabilities and spaced repetition scheduling.

---

## What Changed

### 1. Domain Layer (`lib/features/ritual/domain/`)
- Replaced `RitualTheme` categories with 10 Dharmic themes: `dharma`, `karma`, `bhakti`, `jnana`, `yoga`, `ahimsa`, `sathya`, `vairagya`, `seva`, and `shanti`.
- Replaced the 18 generic cards in `RitualCard.curatedDeck` with 50 Sanathana Dharma cards (`sd_01` to `sd_50`).
- Added `isUserCreated` and `dbId` properties to `RitualCard` to distinguish curated from custom cards.

### 2. Database Layer (`lib/core/database/`)
- Added `UserRitualCards` Drift table storing `theme`, `title`, `prompt`, `quote`, `quoteAuthor`, `createdAt`, and `updatedAt`.
- Added `UserRitualCardsDao` with methods: `createCard`, `getAllCards`, `watchAllCards`, `getCardById`, `updateCard`, and `deleteCard`.
- Registered `UserRitualCards` and `UserRitualCardsDao` in `@DriftDatabase`.
- Bumped schema version from 10 to 11 and added schema migration step in `onUpgrade`.
- Regenerated `app_database.g.dart`.

### 3. Service Layer (`lib/features/ritual/services/`)
- Extended `RitualService` to load and merge curated cards with database-persisted user cards.
- Added user card CRUD methods: `addUserCard`, `updateUserCard`, `deleteUserCard`, and `getUserCards`.
- Added deterministic tie-breaking by card number in `getTodayCardFromPool` for consistent daily card selection.

### 4. Presentation & State Management (`lib/features/ritual/`)
- Added `CreateRitualCardScreen` (`lib/features/ritual/presentation/create_ritual_card_screen.dart`) for creating and editing user cards with theme chip selection, form validation, and live card preview.
- Updated `RitualDeckScreen` (`lib/features/ritual/presentation/ritual_deck_screen.dart`) with a FloatingActionButton for creating new cards, "MY CARD" badge on user cards, and popup menu for editing or deleting user cards.
- Updated `RitualNotifier` in `lib/features/ritual/providers/ritual_providers.dart` to manage merged deck state, card refresh, and CRUD actions.
- Localized the journal creation check in `RitualScreen`.

### 5. Localization (`lib/l10n/app_en.arb`)
- Added localization keys for card creation/editing, delete confirmation dialogs, snackbar notifications, and form validation messages.
- Updated strings referencing the old 18-card deck to the 50-card Sanathana Dharma deck.
- Regenerated localization bindings with `flutter gen-l10n`.

### 6. Tests (`test/`)
- Updated `test/features/ritual/services/ritual_service_test.dart` for the 50 Sanathana Dharma cards, 10 Dharmic themes, and user card CRUD operations.
- Updated `test/features/ritual/presentation/ritual_screen_test.dart` for Dharmic themes, 50 cards, and testing the `CreateRitualCardScreen` form.
- Updated `test/core/database/migration_test.dart` to verify schema version 11 and table creation for `user_ritual_cards`.

---

## Verification
- `flutter analyze`: clean (0 issues).
- `flutter test test/features/ritual test/core/database/migration_test.dart`: 27 tests passed.
- `dart format lib test integration_test`: formatted cleanly.
- `tool/check_absolute_paths.sh --all`: clean (0 absolute path violations).
