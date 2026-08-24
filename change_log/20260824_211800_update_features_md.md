# Change Log: Update features.md to List Only Implemented Features

**Date:** 2026-08-24  
**Plan:** `plans/20260824_211600_update_features_md.md`  

## Changes Made

Updated `docs/features.md` to accurately and comprehensively document all implemented features across the application and ensure only implemented features are listed:

1. **Daily Journaling Ritual & Thought Prompt Cards (Section 7)**:
   - Documented the multi-step mindful ritual experience (`ritual_screen.dart`), atmosphere selection, contemplation timer, card flip animations, and 1-tap entry creation from prompt.
   - Documented the curated Sanathana Dharma thought cards deck with bilingual English and Malayalam translations.
   - Documented custom prompt card creation, deck management, and custom categories.

2. **Encrypted Local Peer-to-Peer Wi-Fi Sync (Section 8)**:
   - Documented direct device-to-device Wi-Fi/LAN sync without cloud servers.
   - Documented the cryptographic protocol: ephemeral X25519 key exchange + AES-256-GCM message encryption.
   - Documented interactive conflict resolution (Keep Local, Keep Remote, Keep Both) and sync health dashboard.

3. **Optical Air-Gapped AirQR Sync (Section 8)**:
   - Documented zero-radio optical data transmission via animated QR code streams.
   - Documented air-gapped sync for app settings, templates, ritual decks, and journal entries.
   - Documented optical payload size checks and safety alerts.

4. **Time Capsules & Sealed Entries (Section 9)**:
   - Documented time-locked entries sealed until a future date and time.
   - Documented the countdown gate screen, time capsules list hub, and unlock reminder notifications.

5. **Authoring & Editor Enhancements (Section 2)**:
   - Documented image editing, cropping, and rotation before entry insertion.
   - Documented domain-specific templates and the collapsible category template chooser dialog.

6. **Architecture & Settings Modularization (Section 10)**:
   - Documented the modularized Settings architecture with dedicated screens under `lib/features/settings/`.
   - Updated the specialized DAO count from 20 to 23 DAOs (`UserTemplatesDao`, `UserRitualCardsDao`, `TimeCapsulesDao`).

## Verification

- Ran `flutter analyze` — passed with 0 issues.
- Verified that all paths in `docs/features.md` use relative repository references.
