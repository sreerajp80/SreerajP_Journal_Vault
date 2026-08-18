# Add journal management to docs/features.md and fill remaining gaps

Implements: `plans/20260803_114500_add-journal-management-and-fill-gaps.md`

## What changed

Edited `docs/features.md` only, no other files touched.

1. **App Description (opening paragraph):** now mentions the journal library home screen
   (create/edit/delete, tagging, optional password at creation) and the combined search screen,
   which were absent before. Also reworded "tamper detection alerts" to say the check is a basic
   backend check whose Settings entry point is currently a disabled "Coming soon" placeholder, and
   noted the migration engine is user-cancellable.

2. **New "Journal Library & Management (Home Tab)" bullet group in Section 8:** documents the
   journal grid cards (cover color, entry count, last-updated label, lock badge), the create/edit
   journal dialog (title, description, tags, optional password on creation), delete with cascading
   cleanup, the empty state, and the journal detail screen (entry list, password unlock gate,
   add-entry template chooser).

3. **New "Combined Search Screen" bullet in Section 4:** documents that the Search tab returns
   journals and entries together, has an entries-only filter toggle, and excludes entries from
   still-locked journals unless session-unlocked.

4. **New "Unified Settings Screen" bullet in Section 8:** documents the five Settings sections
   (Security, Appearance, Storage, Permissions, About) and the two disabled "Coming soon"
   placeholders (Tamper Alerts; Sync Conflicts/Sync Health when sync UI is off).

5. **Section 3 migration bullet:** added a line noting the migration dialog is user-cancellable.

## Why

The doc was missing the app's main landing screen and organizing concept (journal
create/edit/delete) entirely, plus under-describing the Search and Settings screens as unified
surfaces. Found by reading `lib/app/app.dart` directly and comparing against the doc's claims.
