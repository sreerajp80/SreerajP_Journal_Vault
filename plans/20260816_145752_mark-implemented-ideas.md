# Mark implemented ideas in `enhancement_ideas.md`

**Status:** completed

**Change log:** [`change_log/20260816_150046_mark-implemented-ideas.md`](../change_log/20260816_150046_mark-implemented-ideas.md)

---

## 1. The issue

`docs/enhancement_ideas.md` still reads as if nothing in it has been built. Its own header says
"ideas only. Nothing here is approved or scheduled."

That is now out of date. **A1.1 — Export an entry or a whole journal — was implemented today**
(plan `20260816_135333`, change log `20260816_144133`). A reader opening the document has no way
to tell, and the ordering advice in section 4 still lists export as upcoming work.

There is also no way to mark a completed item, so the same confusion will recur with every future
item.

## 2. What was checked

Every idea heading in the document was checked against what is actually in the code, against
`docs/architecture.md` section 21, and against the eight files in `change_log/`.

**Only A1.1 is implemented.** Nothing else in Part A or Part C has been built:

- A4.1 restore, A4.3 delete-all-data, A4.4 retention caps, A5.1 database encryption,
  A5.2 crypto version byte, A5.3 `INTERNET` guard, A6.4 localisation, A6.8 splitting `app.dart`
  are all still listed as open in `architecture.md` section 21.
- B6 (replace `syncfusion_flutter_pdfviewer` with `pdfrx`) is **not** done — `pubspec.yaml` still
  depends on Syncfusion.
- C6 sync still has no transport.

So exactly one tick goes in. Nothing else gets marked, because nothing else has earned it.

## 3. The plan

### 3.1 Add a status key

A short "How completed items are marked" block in section 1, next to the existing explanation of
the four lines each idea has:

- ✅ — built and shipped. The item keeps a line saying when, and links to its plan and change log.
- No mark — still an idea.

Using a tick and nothing else, rather than a set of symbols for in-progress, dropped, and so on.
The document has one completed item; inventing five states for it would be noise. More states can
be added when something actually needs them.

### 3.2 Mark A1.1

- Heading becomes `### ✅ A1.1 Export an entry or a whole journal — implemented`.
- A short **Implemented** line under it: the date, what shipped, and links to the plan and change
  log.
- The existing **What / Why / Already in the family / Effort** lines stay as they are. They are the
  record of why the work was chosen and which sibling app it was ported from, and that is worth
  keeping rather than overwriting.
- One correction inside the item: it offered "four routes, pick one". Say which route was actually
  taken — the `SreerajP_lyricchord` §2.9 webview-and-embedded-fonts route — so a future reader is
  not left guessing.

### 3.3 Update the document header

The "Status of this document" line currently says nothing here is approved or scheduled. Change it
to say that one item has since been built, and point at the key.

### 3.4 Update section 4, the suggested order

Item 6 in the running order begins "A1.1 Export, then the habit layer". Mark the export half done
and leave the rest of the order untouched.

### 3.5 Note the half-answer in B2

B2 is titled "The data can go in but cannot come out" and says there are "zero export paths".
Half of that is no longer true. It gets a short note: export now exists, **restore still does
not**, so the section's conclusion — that A4.1 is the more serious gap — stands and in fact
sharpens.

This is a note, **not** a tick. B2 is a criticism, not a work item, and it is only half addressed.

## 4. Files to be changed

| File | Change |
|---|---|
| `docs/enhancement_ideas.md` | The five edits above. |

Nothing else. No code, no other document.

`docs/architecture.md`, `docs/features.md` and `docs/security.md` were already updated when the
export feature landed, so they need nothing here.

## 5. Risks

Low. It is one document, and no code depends on it.

The one thing to get right is **not over-ticking**. Marking an item complete that is only partly
built is exactly the habit Part B1 of this same document criticises the project for. Only A1.1 is
marked, and B2 gets a note that explicitly says the restore half is still missing.

---

## 6. Do you approve this plan?

Nothing outside this plan file will be changed until you say yes.
