# Implementation Plan: Update enhancement_ideas.md to Sync with Implemented Features

**Status:** Implemented  
**Date:** 2026-08-23  

## Issue

`docs/enhancement_ideas.md` has outdated status notes and incomplete cross-references following the recent feature implementations and the correction of `docs/features.md`:
1. The top header states 12 items implemented instead of 13, and omits A5.6 from the header link list.
2. Section 1 states "Completed so far: 12 of the 41 numbered ideas" instead of 13.
3. Part B (Critical review) sections have outdated text regarding missing UI/last-mile connections for features that have since been fully implemented and wired (e.g., TamperAlertsScreen, share receiver, localization, drawing canvas, custom templates).
4. Section 4 (Suggested order) still lists several items as pending that have been implemented (A5.3 INTERNET guard, A6.2 Share receiver, A1.5 Editor QoL, A5.1 SQLCipher DB encryption).
5. Section 5 table at the end of the document lists only 4 of the 13 implemented items.

## Proposed Fix

Update `docs/enhancement_ideas.md`:
1. Update top summary and Section 1 count to **13 of 41 numbered ideas** completed, including A5.6 in the top list.
2. Add annotations / progress updates to Part B (Critical review) to reflect that Tamper Alerts, Backup Restore, Database encryption, Share receiving, and Localization have been completed.
3. Update Section 4 (Suggested order) checklist to mark completed items with ✅ and their implementation dates.
4. Complete the table of plans and change logs in Section 5 with entries for all 13 implemented items.
5. Ensure relative repository paths only and no absolute system details.

## Files to Change

- `docs/enhancement_ideas.md`

## Verification

- Verify links and plan / change log references against existing files in `plans/` and `change_log/`.
- Ensure no absolute paths are present.
