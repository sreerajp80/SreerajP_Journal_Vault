# Complete features.md — fill remaining gaps found by fresh audit

Implements: `plans/20260803_120500_complete-features-doc-audit.md`

## What changed

Edited `docs/features.md` only:

1. **Opening App Description paragraph:**
   - Added "saveable search presets and multi-criteria filtering (date range, journal, tag, mood,
     lock status, attachment presence)" next to the existing FTS5 search mention.
   - Added "a chronological timeline feed with a calendar entry navigator showing
     writing-activity and mood heatmaps" before the analytics/insights clause, so the Timeline tab
     (one of the app's 5 bottom-navigation destinations) is no longer the only numbered section
     left unmentioned in the summary.

2. **Section 1, "Disclosed Gaps" bullets:** added four bullets, matching open items already
   tracked in `docs/architecture.md` section 21 but missing from this doc:
   - No release keystore yet (debug-signed release builds).
   - No retention caps on entry revisions, security events, or sync logs.
   - `ACCESS_NETWORK_STATE` / `WAKE_LOCK` permissions arrive transitively and are unused.
   - The Home tab has no error/retry state for failed loads.

## Why

A fresh audit (comparing the doc against the live codebase and against
`docs/architecture.md` section 21) found these were the only two remaining gaps after earlier
passes today already fixed the Permissions Center description, the sync-disabled caveat, the
missing attachment viewer host screen, and most of the disclosed-gaps list. Everything else
checked (DAO list, method channel names, navigation tab order, version number, file-path
references) already matched the code exactly.
