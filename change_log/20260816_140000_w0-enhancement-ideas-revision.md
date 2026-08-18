# Change log — W0: revise `docs/enhancement_ideas.md` from the cross-app check

**Date:** 2026-08-16
**Implements:** [`plans/20260816_125915_cross-app-informed-roadmap.md`](../plans/20260816_125915_cross-app-informed-roadmap.md), work item **W0**.
**Plan status moved to:** `completed`.

---

## Why this change was made

`docs/enhancement_ideas.md` was written earlier the same day. Several of its claims were based on
reading only the opening paragraph of 5 of the 18 apps in `myapps.md`. The roadmap plan re-checked
all 17 sibling apps and found those claims wrong or too pessimistic. W0 is the item that carries
those findings back into the ideas document.

A scope point worth recording: the roadmap plan reads like a nine-item build roadmap (W1–W9). The
user confirmed that was not the intent — the plan was only ever meant to improve the ideas
document. So W0 was implemented and W1–W9 were deliberately left alone.

## Files changed

| File | Change |
|---|---|
| `docs/enhancement_ideas.md` | Revised throughout. This is the real work. |
| `plans/20260816_125915_cross-app-informed-roadmap.md` | Status `in_progress` → `completed`; added a scope note explaining that W0 was the whole intent; reworded sections 8 and 9 so they record what actually happened. |
| `change_log/20260816_140000_w0-enhancement-ideas-revision.md` | This file. |

**No code was touched.** No `pubspec.yaml`, no `lib/`, no `android/`, no test file.

## What changed inside `docs/enhancement_ideas.md`

### Structure

- Added a **Revised** date and a banner pointing at the roadmap plan as the authority on framing,
  effort sizes, and running order.
- Changed the per-idea format from three lines to four. The new line is **"Already in the
  family"** — which sibling app already built the thing, and what to take from it. Where that line
  is present the item is porting work, not design work.
- Section 2 now records that all 17 sibling apps were checked, how they were checked, and states
  plainly that the first version read only 5 of them.
- Added the headline finding: **almost nothing this app needs is new work for this author; it is
  porting work.**

### Corrections applied

| Item | What changed |
|---|---|
| A1.1 Export | Added four routes from the family. `SreerajP_lyricchord` §2.9 named as the one to copy, because its embedded SIL OFL fonts make Malayalam shape correctly. PDF branch re-costed L → M. |
| A1.3 Drawing | Marked as genuinely new — the sweep found no drawing canvas in any of the 17 apps. |
| A2.3 OCR | Recorded that `SreerajP_PDFApp` hard rule 7 already rules OCR out of scope. Either follow the ruling or make the exception deliberate. |
| A4.1 Restore | Was "design open, effort L". Replaced with a four-row port table (`chronotune` §12, `sreerajp_todo` §11.2, `SreerajPContactSphere` §7, `SreerajP_Authenticator` §5). Re-costed **L → M**. |
| A4.2 Encrypted archives | Listed the five existing envelopes in the family and recommended converging on the `sreerajp_youtube_shortcut` `v1:` envelope. Re-costed **M → S**. |
| A4.3 Delete all data | Added `sms-sentry` `clearAllSms` and ContactSphere's wipe path. Re-costed **M → S–M**. |
| A5.2 Crypto version byte | Tied to the same `v1:` convention as A4.2, so the app has one versioning idea. |
| A5.3 `INTERNET` guard | Added the matching `SreerajP_PDFApp` hard rule 2, and a note that the guard interacts with C6. |
| A5.4 Decoy vault | Added the `sreeraj_qr_reader` StegoQR precedent. |
| A5.6 Security screens | Reframed under `SreerajP_PDFApp` rule 6, "Never a Dead Button". Both "Coming soon" rows are rule violations: build or remove. |
| A6.1 Notifications | Was framed as a new capability. Corrected: four mature stacks exist. Named `MantraJapaCounter` §5 / `sms-sentry` as the port source and `chronotune` for Android 13+ permission handling. |
| A6.2 Share-in | Added `SreerajP_PDFApp` §2.7 and lyricchord's `file_intent_listener.dart`, plus the `vault-files` VIEW-intent trick. |
| A6.3 Widget | Was L and framed as design. Corrected: `SreerajP_LalithaSahasranamam` §4.9 has a working `home_widget` + Kotlin provider. Re-costed **L → M**. |
| A6.4 Localisation | Corrected: at least 8 of 17 apps are EN/ML bilingual. Two patterns named. Stays **L**, because the extraction across ~90 Dart files is the real work and no sibling can do it. |
| A6.5 Accessibility | Was "untouched ground". Corrected: `daily_rule_cards` §8, `sreerajp_todo`, and `Sanathana_Dharma_Clock` all ship `Semantics` work. |

### Part B — critical review

- **B1** gained a new subsection: the half-wired-feature pattern is a **family-wide habit, not a
  Journal Vault bug**. `SreerajP_CodeApp` §4.1 lists 14 such features. `SreerajP_PDFApp` rules 5
  and 6 are quoted verbatim as the fix worth adopting.
- **New B6** — *the most urgent finding, and completely absent from the first version.*
  `syncfusion_flutter_pdfviewer` contradicts `SreerajP_PDFApp`'s hard rule banning proprietary
  SDKs, carries licence conditions, and is what pins `package_info_plus` / `device_info_plus`
  through the `win32` conflict with `file_picker`. Fix is `pdfrx`. Must land before the release
  keystore.
- The old B6 ("what the app does exceptionally well") is renumbered **B7** and kept unchanged.

### Part C — unique ideas

Every idea gained a **Re-checked** line.

- **C6 was wrong and is now corrected.** It claimed sync "conflicts with the zero-network
  promise". `SreerajP_Authenticator` §6b and `sreeraj_qr_reader` AirQR both ship **optical
  air-gap sync** — animated QR out, camera in — which needs no network permission at all. The
  section is retitled "over light, not over the network". The LAN route is kept as the fallback,
  with `sms-sentry`'s hostile-peer hardening and TextApp's `FLAG_SECURE` named.
- **C7 reduced** — do not rebuild PDF annotation; `SreerajP_PDFApp` §2.3 already has it. The
  documents view and attachment search stay.
- **C3 strengthened** — confirmed as the only Part C idea with no precedent anywhere in the family.
- **C5 strengthened** — `SreerajP_CodeApp` §4.3 lists the same idea as planned-but-unbuilt.
- **C9 made much cheaper** — `SreerajP_LalithaSahasranamam` §4.6 ships an Anki-style spaced
  repetition engine, a better "On This Day" than a fixed year-ago lookup.
- **C1** — audio plumbing exists in three apps; the novel part is transcript-to-audio alignment.
- **C4** and **C8** gained precedents (StegoQR; PDFApp §2.7).
- **C2** unchanged — nothing in the family is close.

### Section 4 — running order

Rewritten to match the roadmap plan's section 7. Two items moved to the front: replacing
Syncfusion (new number 1, because it must precede the release keystore), and splitting `app.dart`
plus l10n extraction ahead of any work that writes more strings.

### Section 5 — related documents

Added the roadmap plan as the authority, and a note that `myapps.md` lives outside this
repository. That last point was checked: `myapps.md` is not in the repo, so it is referenced as
plain text rather than as a link that would not resolve.

## Verification

- No code changed, so no build or test run applies.
- All in-repo document links added by this change were checked to resolve.
- `myapps.md` was searched for in the repository and is absent; it is therefore not linked.

## What was deliberately not done

W1–W9 of the roadmap plan. No code, dependency, manifest, or test was touched. Those items remain
a described backlog in both the roadmap plan and `docs/enhancement_ideas.md`. Each needs its own
plan under `plans/` and its own approval before any code is written.
