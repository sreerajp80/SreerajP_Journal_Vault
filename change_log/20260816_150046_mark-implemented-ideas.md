# Change log — mark implemented ideas in `enhancement_ideas.md`

**Date:** 2026-08-16
**Implements:** [`plans/20260816_145752_mark-implemented-ideas.md`](../plans/20260816_145752_mark-implemented-ideas.md)
**Plan status:** completed

---

## What changed, in one line

`docs/enhancement_ideas.md` now shows which of its ideas have been built. Exactly one has: A1.1
Export, marked ✅.

## Why

The document still read as if nothing in it existed, while A1.1 had been implemented earlier the
same day. A reader had no way to tell, and there was no convention for marking anything complete,
so the confusion would have recurred with every future item.

## Files changed

| File | Change |
|---|---|
| `docs/enhancement_ideas.md` | The six edits below. |

Nothing else. No code. `architecture.md`, `features.md` and `security.md` were already updated when
the export feature landed.

## The edits

1. **Document header** — the "Status of this document" line no longer claims nothing here is
   approved or scheduled. It says one item has been built, links to it, and points at the key.

2. **A completion key in section 1** — a two-row table: ✅ means built and shipped, no mark means
   still an idea. Two marks only, on purpose: there is one completed item, and inventing states
   for in-progress, partial, and abandoned work before anything is in those states would be noise.

   The key also states what a tick *means*: **a user can reach the feature.** Part B1 of the same
   document is about this project's habit of building a service, passing its tests, and never
   wiring it to a screen — so an item that stops short of the user does not earn a tick.

   It carries a running count — **1 of the 41 numbered ideas** (32 in Part A, 9 in Part C) — with
   a note that the number is meant to stay honest rather than look good.

3. **A1.1 marked ✅** with an **Implemented** block giving the date, what shipped, and links to its
   plan, change log, and code. The original What / Why / Already in the family / Effort lines are
   left untouched — they record why the work was chosen and which sibling app it was ported from,
   which is worth keeping.

   The block also answers a question the item left open. It had offered "four routes, pick one";
   it now records that the `SreerajP_lyricchord` §2.9 route was taken, and names two departures
   from it — no `printing` package (so no new dependency and the `win32` knot stayed untouched)
   and no page-width fitting (a song-sheet trick a page of prose does not want). It notes the two
   things the plan got wrong and had corrected during the work, and lists what was deliberately
   left out.

4. **B2 got a note, not a tick.** B2 says the app has "zero export paths". Half of that is no
   longer true, but `BackupService` still cannot read its own archives back. The note says so
   plainly and sharpens the section's conclusion: **A4.1 restore is now the harder of the two
   gaps, not the softer one** — export protects a user who plans ahead, restore protects one who
   did not.

5. **Section 4, item 5 — an ordering decision recorded honestly.** That item said the l10n
   extraction should happen *before* A1.1 wrote more hard-coded strings. It did not. The note
   records that A1.1 went first as a deliberate choice (the extraction is an **L** across ~90
   files), that the cost was contained rather than avoided by putting every new string in
   `lib/features/export/export_strings.dart` with `.arb`-shaped names, and that **the advice still
   holds for A6.1 and A6.2**, which have not been built.

6. **Section 4, item 6 and a new table in section 5** — export marked done, and a small table
   mapping each ✅ item to its plan and change log.

## What was checked before ticking anything

Every idea heading was checked against the code, `docs/architecture.md` section 21, and all eight
files in `change_log/`.

**Only A1.1 qualified.** Specifically confirmed *not* done, and so left unmarked:

- A4.1 restore, A4.3 delete-all-data, A4.4 retention caps, A5.1 database encryption, A5.2 crypto
  version byte, A5.3 `INTERNET` guard, A6.4 localisation, A6.8 splitting `app.dart` — all still
  listed as open in `architecture.md` section 21.
- **B6** — `pubspec.yaml` still depends on `syncfusion_flutter_pdfviewer`, so the replacement with
  `pdfrx` has not happened. It remains the top blocker in section 4.
- **C6** — sync still has no transport.

The risk in this task was over-ticking, which is the exact habit Part B1 criticises. One tick went
in, and B2 — a criticism rather than a work item, and only half addressed — got a note instead.

## Verification

- `sh tool/check_absolute_paths.sh --all` — **exits 0.** No absolute paths in the new content; all
  links are relative repository paths, as `CLAUDE.md` requires.
- Anchor link in the header checked against the GitHub heading-slug rules for a heading containing
  an emoji and an em dash.
- No code was touched, so the test suite and analyzer are unaffected — they were last run green at
  442 passing after the export work.
