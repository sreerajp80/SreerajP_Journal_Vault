# Implementation Plan: Check and Mark Part B (Critical Review) Status in enhancement_ideas.md

**Status:** completed  
**Date:** 2026-08-23  

## Issue

`docs/enhancement_ideas.md` contains Part B — Critical Review (sections B1 through B7), which originally detailed the app's architectural, functional, security, and habit-formation weaknesses. Several of these critique points have been directly addressed and implemented across recent milestones (e.g., A1.1 Export, A1.3 Drawing, A1.5 Editor QoL, A1.7 Templates, A4.1 Restore, A5.1 SQLCipher DB encryption, A5.3 Manifest guard, A5.6 Tamper alerts live screen, A6.2 Share receiver, A6.4 Localisation).

Part B needs to be comprehensively checked and each section marked clearly to document which critique points are fully resolved, which are partly addressed, and which specific items remain open.

## Detailed Review of Part B Sections

1. **B1. The feature list is far ahead of the finished product**
   - *Critiques addressed:* Backup now restores (✅ A4.1), Tamper alerts is a live screen (✅ A5.6), Security events are analyzed for integrity (✅ A5.6), dead "Coming soon" buttons in Settings are eliminated (Rule 6).
   - *Remaining open:* Sync transport (C6 optical air-gap sync).
   - *Status update:* Mark as mostly resolved with explicit completed/open breakdown.

2. **B2. The data can go in but cannot come out**
   - *Critiques addressed:* Export built across 4 formats (✅ A1.1), restore built with dry-run/merge/replace (✅ A4.1).
   - *Status update:* Mark as fully resolved / implemented.

3. **B3. The security story has one soft centre**
   - *Critiques addressed:* Plain SQLite diary text replaced with SQLCipher database encryption at rest (✅ A5.1), `INTERNET` permission removed & guarded by CI (✅ A5.3), security status surfaced on dedicated screen (✅ A5.6).
   - *Remaining open:* Release keystore configuration (operational release prerequisite).
   - *Status update:* Mark as mostly resolved with breakdown.

4. **B4. It is a strong store and a weak habit**
   - *Critiques addressed:* Inbound share capture (✅ A6.2), Editor quality-of-life shortcuts & stats (✅ A1.5), inline drawing & handwriting canvas (✅ A1.3), custom user templates (✅ A1.7).
   - *Remaining open:* Daily reminders & notifications (A6.1), Home screen widget (A6.3).
   - *Status update:* Mark as partly resolved with clear accounting of completed features.

5. **B5. The app assumes one kind of user**
   - *Critiques addressed:* Full English & Malayalam localisation with ARB catalogs and AppLocalizations across all screens (✅ A6.4).
   - *Remaining open:* Accessibility / TalkBack semantics (A6.5), Tablet & landscape two-pane layout (A6.6), Themes & font controls (A6.7).
   - *Status update:* Mark as partly resolved with clear accounting of completed features.

6. **B6. A shipped dependency contradicts the family's own hard rule**
   - *Critique:* `syncfusion_flutter_pdfviewer` dependency.
   - *Status update:* Open (not implemented yet).

7. **B7. What the app does exceptionally well**
   - *Status:* Core strengths summary (retained).

## Proposed Fix

Update `docs/enhancement_ideas.md` Part B (sections B1–B6) to:
1. Add explicit status badges / completion summaries (`✅ Resolved`, `✅ Mostly resolved`, `Partly resolved`, `Open`) under each section heading.
2. Cross-reference all implemented features (A1.1, A1.3, A1.5, A1.7, A4.1, A4.2, A5.1, A5.3, A5.6, A6.2, A6.4) with their completion dates and links.
3. Ensure relative paths only and simple English.

## Files to Change

- `docs/enhancement_ideas.md`

## Verification

- Inspect `docs/enhancement_ideas.md` to verify all Part B points align with active repository code and documentation.
- Run `sh tool/check_absolute_paths.sh --all` to confirm no absolute path rule violations.
