# Implementation Plan: Update features.md to List Only Implemented Features

**Status:** Proposed  
**Date:** 2026-08-24  

## Issue

`docs/features.md` needs an update to accurately list all implemented features in the codebase and only implemented features.

Recently implemented features that need to be documented include:
1. **Ritual Mode & Thought Cards (C9 Ritual Mode)**:
   - Daily mindfulness and journaling ritual flow with card flip and contemplation timer.
   - Built-in Sanathana Dharma thought cards localized in English and Malayalam.
   - Custom ritual card creation, editing, and deletion with custom categories and colors.
   - Start an entry directly from a thought card with pre-filled prompt context.
2. **Encrypted Local Peer-to-Peer Wi-Fi Sync (Wi-Fi P2P)**:
   - Zero-cloud, local network direct device-to-device sync.
   - End-to-end encrypted protocol using ephemeral X25519 key exchange and AES-256-GCM session keys.
   - Interactive conflict resolution screen (Keep Local, Keep Remote, Keep Both).
   - Sync health dashboard and diagnostic logging.
3. **Air-Gapped Optical AirQR Sync**:
   - Zero-network optical data transfer via animated QR code streams.
   - Air-gapped transmission and reception of app settings, ritual cards, templates, and journal entries.
   - Optical transfer payload size limits and transmission safety warnings.
4. **Time Capsules & Sealed Entries**:
   - Time-locked journal entries sealed until a future unlock date/time.
   - Sealed entry lock screen with countdown timer.
   - Time capsules hub under Home and Settings.
   - Local notification reminder support when a capsule unlocks.
5. **Image Editing & Annotation**:
   - In-editor image cropping, rotation, and adjustment before insertion into entries.
6. **Domain-Specific Templates & Collapsible Chooser**:
   - Domain-specific templates (Dream Journal, Review, Post-Mortem, Habit Tracker) with collapsible category chooser dialog.
7. **Modular Settings Architecture & 23 DAOs**:
   - Modularized Settings architecture with separate screens under `lib/features/settings/`.
   - Update DAO count from 20 to 23 specialized DAOs (`UserTemplatesDao`, `UserRitualCardsDao`, `TimeCapsulesDao`).

## Proposed Fix

Update `docs/features.md`:
1. **Overview & Description**: Update the introductory summary to reflect all implemented capabilities (Ritual Mode, Sanathana Dharma thought cards, Local Wi-Fi P2P sync, Optical AirQR sync, Time Capsules, and modular settings).
2. **Security & Encryption**: Keep SQLCipher, Keystore, and attachment encryption accurate, and document end-to-end encryption for Wi-Fi P2P sync.
3. **Editor & Authoring**: Add Time Capsule sealing, domain-specific templates, collapsible template chooser, and image editing/crop/rotate.
4. **Ritual Mode & Thought Cards**: Add a dedicated section detailing Ritual Mode, Sanathana Dharma thought prompt decks (English & Malayalam), custom card creation, and contemplation timer.
5. **Sync & Data Transfer**: Add dedicated sections for Local Encrypted Wi-Fi P2P Sync and Optical Air-Gapped AirQR Sync.
6. **Settings & Architecture**: Update DAO list to 23 DAOs, and document the modular Settings architecture.
7. **Relative Paths & Privacy**: Ensure strictly relative repository paths and simple English throughout.

## Files to Change

- `docs/features.md`

## Verification

- Review `docs/features.md` against the codebase to ensure every listed feature is implemented and reachable.
- Run `flutter analyze` to ensure code integrity.
- Run `flutter test` to ensure all automated test suites pass.
