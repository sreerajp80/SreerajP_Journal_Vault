# Add journal management to docs/features.md and fill remaining gaps

**Status:** completed

## Files to be changed

- `docs/features.md` (only file changed)

## What the issue is

I checked `docs/features.md` against the current code in `lib/app/app.dart` and related files.
Confirmed problems:

1. **Journal management is completely missing from the doc.** The Home tab (`_HomeTab` in
   `lib/app/app.dart`) is the app's main landing screen and the top-level container for every
   entry, tag, and attachment. It has: a grid of journal cards with cover colors, entry counts,
   and "last updated" relative-time labels; create/edit/delete journal dialog with comma-separated
   tags and an optional password set at creation time; a lock badge on locked journal cards; an
   empty state; and a journal detail screen (chronological entry list, unlock-with-password gate
   for locked journals, "Add entry" FAB that opens the template chooser for new entries). None of
   this is in the App Description paragraph or the Exhaustive Feature List.

2. **The Search tab itself is not described**, only "Search Presets" (section 4). Missing: the
   Search screen searches journals and entries together, has an entries-only filter toggle, and
   excludes entries belonging to still-locked journals from results unless the journal is
   session-unlocked.

3. **The Settings screen is not described as a unified surface.** Individual settings (theme,
   auto-lock, permissions, storage, about) are documented piecemeal elsewhere, but the Settings
   tab that ties them into five sections (Security / Appearance / Storage / Permissions / About),
   including two visibly disabled "Coming soon" tiles (Tamper Alerts, and Sync Conflicts/Health
   when sync UI is off), is not mentioned anywhere.

4. **Storage migration cancellation** is not mentioned — the in-progress migration dialog lets the
   user cancel (`_MigrationProgressController.cancel()`), and the doc's migration bullet in
   section 3 doesn't say so.

5. **"Tamper detection alerts" in the App Description overstates what's reachable from the UI.**
   A basic tamper check exists in `security_event_service.dart` and logs `tamper_detected` events,
   so the claim isn't fabricated, but the corresponding Settings tile is rendered as a disabled
   `_ComingSoonTile`. The doc should note this the same way it already notes sync is
   implemented-but-disabled.

## The plan for the fix

Edit `docs/features.md` only, in place, no new files:

1. **App Description (opening paragraph):** add journal creation/management and the Search
   screen to the feature summary so the top-level container concept isn't absent from the
   description.

2. **New subsection in Section 8 (App Architecture, Navigation & User Experience):** add a
   "Journal Library & Management (Home Tab)" bullet group covering: journal grid cards (cover
   color, entry count, last-updated), create/edit/delete journal dialog with tags and optional
   password-at-creation, lock badge, empty state, and the journal detail screen (entry list,
   unlock gate, add-entry template chooser).

3. **Section 4 (Search, Smart Tags & Multi-Criteria Filtering):** add a bullet describing the
   Search tab itself — combined journal + entry results, entries-only filter toggle, and that
   locked-journal entries are excluded from results unless session-unlocked.

4. **Section 8:** add a bullet describing the Settings tab as the unified surface for the five
   sections, noting the two "Coming soon" placeholders (Tamper Alerts; Sync Conflicts/Health when
   `enableSyncUi` is false).

5. **Section 3 (migration bullet):** add "user-cancellable" to the migration engine bullet.

6. **App Description tamper-alerts clause:** reword "tamper detection alerts" to note the check
   exists in the backend but the Settings UI entry point is currently a disabled placeholder,
   mirroring the existing sync caveat pattern.

No other sections need changes.

## Change log

Will be written to `change_log/` after this edit is applied.
