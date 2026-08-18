# Complete features.md — fill remaining gaps found by fresh audit

**Status:** completed

## Files to be changed

- `docs/features.md` (only file changed)

## What the issue is

I re-audited `docs/features.md` against the current codebase (screens, services, DAOs, method
channels, pubspec packages, and `docs/architecture.md` section 21). Earlier plans today already
fixed the Permissions Center description, the sync "disabled" caveat, the missing viewer host
screen, the "Delete all data" / DB-encryption / crypto-version-byte gaps, and the backup-restore
gap. Those are done and still correct.

Two things are still missing after those fixes:

1. **The opening "App Description" paragraph (lines 1-11) skips two things that get their own
   numbered section further down:**
   - The **Timeline tab** and its **Calendar Entry Navigator** (section 5, `timeline_screen.dart`,
     `_Calendar` with `table_calendar`) — Timeline is one of the app's 5 bottom-navigation
     destinations (`app.dart`, alongside Home, Search, Insights, Settings) and gets a full
     numbered section, but the intro paragraph never mentions it.
   - **Search Presets / saved filters** and **multi-criteria filtering** (section 4, lines
     114-120: filter by text, date range, journal, tag, mood, lock status, attachment presence) —
     the intro only mentions the FTS5 search screen, not saved presets or the filter dimensions.

2. **The "Disclosed Gaps" bullet list (section 1, currently 4 bullets) is narrower than
   `docs/architecture.md` section 21.** That document lists several more still-open items that are
   relevant to a security/production-standard app and worth surfacing here too:
   - No release keystore yet — release builds still fall back to the debug signing key
     (release-blocking, distinct from the Sensitive-Data-only gaps already listed).
   - No retention caps on entry revisions, security events, or sync logs (they grow unbounded).
   - `ACCESS_NETWORK_STATE` and `WAKE_LOCK` permissions arrive transitively and are unused, even
     though the app's "zero-telemetry, no network permission" claim (intro paragraph, section 1)
     is about the `INTERNET` permission specifically — worth a one-line caveat so the claim isn't
     read as "no extra permissions at all".
   - The Home tab has no error/retry state for failed loads.

## The plan for the fix

Edit `docs/features.md` only, in place:

1. **Opening paragraph:** insert a short clause (after the search/tags sentence, before the
   "background backup scheduler" clause) naming the Timeline feed with its calendar heatmap, and
   naming search presets / multi-criteria filtering alongside the existing FTS5 search mention.
   Keep it terse — this paragraph is already one long sentence; add clauses, not new sentences,
   consistent with its existing style.

2. **Section 1, "Disclosed Gaps" bullets:** add four bullets for the items listed above (release
   keystore, retention caps, unused transitive permissions, Home tab error/retry state), each one
   line, in the same terse style as the existing four bullets. Point to
   `docs/architecture.md` section 21 rather than duplicating detail.

No other sections need changes — DAOs, method channel names, navigation tab list, and version
number were all re-verified against the code and are already correct.

## Change log

Will be written to `change_log/` after this edit is approved and applied.
