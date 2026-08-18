# Plan: Cross-app-informed enhancement roadmap for SreerajP Journal Vault

**Status:** completed

**Written:** 2026-08-16
**Approved:** 2026-08-16 by the user.
**Completed:** 2026-08-16 — see [`change_log/20260816_140000_w0-enhancement-ideas-revision.md`](../change_log/20260816_140000_w0-enhancement-ideas-revision.md).

> **Scope note, added on completion.** The user clarified that the intent of this plan was
> **W0 only** — to use the cross-app findings to improve
> [`docs/enhancement_ideas.md`](../docs/enhancement_ideas.md). The plan as first written read as a
> nine-item build roadmap (W1–W9), which was not the intent.
>
> **What was done:** W0. `docs/enhancement_ideas.md` was revised in full — every correction in
> section 3 applied, effort sizes re-costed as port work, an "Already in the family" line added to
> the idea format, and the running order in its section 4 rewritten to match section 7 here.
>
> **What was not done, and was never meant to be done under this plan:** W1–W9. No code, no
> `pubspec.yaml`, no `lib/`, no `android/` file was touched. Those work items remain a **backlog
> described in this document**, not scheduled work. Each still needs its own plan under `plans/`
> before any code is written, as `enhancement_ideas.md` itself states.
>
> The status is `completed` rather than `partial_completion` because the plan's actual goal —
> the revised ideas document — was delivered whole.
**Supersedes the framing of:** [`docs/enhancement_ideas.md`](../docs/enhancement_ideas.md)
(written earlier the same day). That document is still useful for its idea list, but several of
its claims were based on reading only the opening paragraph of 5 of the 18 apps in `myapps.md`.
This plan is based on all 17 sibling apps and corrects them. See section 3.

---

## 1. What this plan is

The user asked for a plan they will implement in a **separate session**. So this document is
written to be picked up cold: each work item says what to build, which sibling app already
solved it, and what to copy from there.

The single biggest finding of the full cross-app check:

> **Almost nothing Journal Vault needs is new work for this author. It is porting work.**
> Encrypted backup with restore, P2P device sync, notifications, home screen widgets,
> localisation, accessibility, PDF export, share-intent handling — every one of these is already
> built, shipped, and documented in at least one sibling app, usually two or three.

That changes the effort estimates in `enhancement_ideas.md` substantially downward, and it
changes the order of work.

---

## 2. What was checked

All 17 sibling `docs/features.md` files listed in `myapps.md` (the 18th is this app).

- Read in full: `SreerajP_PDFApp`.
- Section headings mapped for all 17.
- Read in detail, the sections relevant to this app's gaps: `SreerajP_Authenticator` §5–6,
  `SreerajP_TextApp` §2.8, `SreerajPContactSphere` §6–7, `sms-sentry` §8–9, `sreerajp_todo` §11,
  `sreerajp_youtube_shortcut` §5.11, `SreerajP_LalithaSahasranamam` §4.6/§4.9,
  `chronotune-smart-clock` §12, `SreerajP_lyricchord` §2.9, `sreeraj_qr_reader` (StegoQR, AirQR),
  `vault-files` (secure notes), `SreerajP_CodeApp` §4.
- Keyword sweep across all 17 for: restore, export, notification, reminder, widget, OCR,
  localisation, Malayalam, share sheet, drawing, speech, sync, accessibility, tablet.

---

## 3. Corrections to `docs/enhancement_ideas.md`

These must be applied when that document is revised (work item W0 below).

| Claim in the ideas doc | What the full check found |
|---|---|
| Reminders/notifications framed as new capability (A6.1) | Four apps ship mature notification stacks: `chronotune` (foreground services, full-screen intents, Android 13/14 permission handling), `MantraJapaCounter`, `sms-sentry`, `SreerajPContactSphere`. This is a port. |
| Home screen widget framed as L effort (A6.3) | `SreerajP_LalithaSahasranamam` §4.9 has a working `home_widget` + Kotlin `SadhanaWidgetProvider` with deep links, and documents its own cold-start limitation. `chronotune` has Canvas-rendered widgets. Port, not design. |
| Backup restore framed as L, design open (A4.1) | Restore is solved three different ways in the family. See W2 — the design is off-the-shelf. |
| Localisation framed as L (A6.4) | At least 8 apps are EN/ML bilingual. `Sanathana_Dharma_Clock` and `SreerajP_PDFApp` both do it with `flutter_localizations` + `intl`. `SreerajP_LalithaSahasranamam` does a 3-script switcher with a bundled lookup table and no `intl` at all. |
| Accessibility framed as untouched ground (A6.5) | `daily_rule_cards` §8, `sreerajp_todo`, and `Sanathana_Dharma_Clock` all ship `Semantics` work, WCAG touch targets, and font-scale handling. Copy their patterns. |
| C6 sync "conflicts with the zero-network promise" | **Wrong, or at least incomplete.** `SreerajP_Authenticator` §6b and `sreeraj_qr_reader` (AirQR) both ship **optical air-gap sync** — animated QR stream out, camera in, with error correction. Zero network permission. This resolves the conflict I raised and is the right transport for this app. |
| A2.3 OCR proposed without reservation | `SreerajP_PDFApp` hard rule 7 explicitly puts **OCR out of scope**, with graceful degradation instead. The author has already ruled on this. Either follow the ruling or make the exception deliberate. |
| C7 PDF annotation proposed as new | `SreerajP_PDFApp` §2.3 has a full non-destructive annotation overlay keyed by SHA-256 content fingerprint, with flatten-to-PDF export. Do not rebuild. |
| Nothing said about the PDF viewer dependency | **New finding, see W1.** This is the most urgent item the cross-app check surfaced. |

---

## 4. Work items

Ordered. W1 and W2 should land before anything else.

### W0 — Revise `docs/enhancement_ideas.md`

Apply the corrections in section 3. Re-cost the effort estimates as port work. Add a
"already solved in the family" column to the idea tables.

**Files:** `docs/enhancement_ideas.md`.

---

### W1 — Resolve the Syncfusion dependency conflict ⚠️

**The issue.** `SreerajP_PDFApp` declares a hard architectural rule:

> *"Commercial or proprietary SDKs (e.g., Syncfusion, PSPDFKit, Apryse) are strictly forbidden."*

Journal Vault's `pubspec.yaml` depends on **`syncfusion_flutter_pdfviewer: ^33.2.13`**, used by
`lib/features/attachments/presentation/pdf_attachment_view.dart`. This directly contradicts the
rule the author applies to the sibling app that specialises in PDFs. Syncfusion's community
licence also carries revenue and headcount conditions that a released app has to satisfy.

There is a second cost: the long comment in `pubspec.yaml` documents that Syncfusion is what
pins `package_info_plus` to 9.x and `device_info_plus` to 12.x, via a `win32` conflict with
`file_picker`. **Removing Syncfusion unblocks that whole dependency knot.**

**The fix.** Replace `syncfusion_flutter_pdfviewer` with **`pdfrx`** (pdfium, BSD), which is what
`SreerajP_PDFApp` uses in production. If PDF text extraction for the FTS index also needs
replacing, `SreerajP_PDFApp` uses **PdfBox-Android** (Apache 2.0) behind a Kotlin platform
channel.

**Files:** `pubspec.yaml`, `lib/features/attachments/presentation/pdf_attachment_view.dart`,
possibly the FTS extraction path in `lib/features/search/`, and the dependency-pin comment block
in `pubspec.yaml`.

**Effort:** M. **Do this before the release keystore is created**, since it changes shipped code.

---

### W2 — Backup restore

The top functional gap. `backup_service.dart` creates and verifies; nothing restores.

**Port from — pick the closest, do not invent:**

| App | What to take |
|---|---|
| `chronotune-smart-clock` §12 | Self-describing **versioned** backup format (`FORMAT_VERSION`), **MERGE vs REPLACE** import modes, and primary-key omission on export with reassignment on import to avoid ID collisions. |
| `sreerajp_todo` §11.2 | The safety sequence: passphrase validation → **schema version check** (auto-migrate older, reject newer via a `BackupVersionTooNewException`) → `PRAGMA integrity_check` → atomic database replace. Also WAL checkpointing before export (§11.1). |
| `SreerajPContactSphere` §7 | Whole-database-plus-binary-assets backup (contacts photos ≈ this app's encrypted attachments), and gating the restore screen behind a biometric/PIN check. |
| `SreerajP_Authenticator` §5 | Backward-compatible decryption of older backup formats, so old backups are never orphaned by an update. Also the `ImportResult` dialog reporting added vs skipped. |

**Files:** `lib/features/backup/services/backup_service.dart` (restore path),
new `backup_restore_service.dart`, `lib/features/backup/presentation/` (restore screen),
`lib/core/database/app_database.dart` (schema version gate).

**Effort:** M with the ports, not L.

---

### W3 — Password-encrypted backup archives

Five apps already do this. Converge on one of the existing envelopes rather than a sixth.

- `SreerajP_Authenticator`: `.aes` file, PBKDF2 **300,000** iterations then AES-256-GCM.
- `SreerajPContactSphere`: `.csbak`, PBKDF2 300k + AES-GCM-256.
- `sreerajp_youtube_shortcut` §5.11: self-describing envelope string
  `v1:<salt_b64>:<iv_b64>:<ciphertext_b64>`, with encrypted-file auto-detection on import.
- `sreerajp_todo` §11.1: passphrase-encrypted ZIP, minimum 8 characters.

**Recommendation:** the youtube_shortcut `v1:` envelope, because it is versioned and
self-describing — which is exactly the property the attachment crypto format is missing (W4).

**Effort:** S once W2 exists.

---

### W4 — Small security items already scoped

- **Attachment crypto version byte.** Known gap in `architecture.md` §21. Adopt the same `v1:`
  prefix convention as W3 so the whole app has one versioning idea.
- **Guard the absent `INTERNET` permission.** Add `tools:node="remove"` plus a build check.
  Verified: `INTERNET` really is absent from the merged `prodRelease` manifest today, but only
  because no current plugin asks for it. `SreerajP_PDFApp` hard rule 2 states the same guarantee
  and is worth matching. **Note this interacts with W7** — if LAN sync is ever chosen over
  optical sync, this guard has to be revisited.
- **Retention caps** on `EntryRevisions`, `SecurityEvents`, `SyncLogs`.
- **Delete all data.** `sms-sentry` has `clearAllSms`; `ContactSphere` documents a full-replace
  wipe path. Required by standard §15.4.

**Effort:** S each.

---

### W5 — Export

Currently zero export paths exist. Import is one-way.

**Port from:**

- `SreerajP_lyricchord` §2.9 — the strongest PDF export in the family: HTML rendered through a
  native webview (`HtmlPdfService`) with **embedded base64 SIL OFL fonts** for correct Malayalam
  shaping and selectable PDF text, safe file naming that preserves non-English letters, and share
  sheet integration via `printing`. This matters here because journal entries may contain
  Malayalam.
- `SreerajP_CodeApp` §3.6 and `SreerajP_TextApp` §2.10 — export/print/share hub patterns.
- `SreerajP_PDFApp` §2.6 — alternatively, **hand off** to PDFApp: it already accepts shared plain
  text and images via `ACTION_SEND` and converts them to PDF. Cheapest possible route for a first
  version.

**Files:** new `lib/features/export/`, plus an entry point in the editor and the journal detail
screen.

**Effort:** M for Markdown/HTML/text; M more for PDF via the lyricchord approach.

---

### W6 — Habit layer: notifications, share-in, widget

- **Notifications / reminders** — port from `MantraJapaCounter` §5 or `sms-sentry` §5/§7 (simpler
  than `chronotune`, which needs foreground services this app does not). Include Android 13+
  `POST_NOTIFICATIONS` handling as `chronotune` documents. **Rule: notification text must never
  contain entry content.**
- **Share-in** — `vault-files`, `SreerajP_PDFApp` §2.7, and `SreerajP_lyricchord`
  (`file_intent_listener.dart`) all handle inbound intents. Also worth copying: `vault-files`
  gives its `.securenote` files a dedicated VIEW intent filter.
- **Home screen widget** — port from `SreerajP_LalithaSahasranamam` §4.9 (`home_widget` + Kotlin
  provider + deep link). **Security question to answer first: the widget must show nothing but a
  button on a locked device.** Note Lalitha's documented cold-start deep-link limitation.

**Effort:** M each, as ports.

---

### W7 — Sync transport: optical air-gap, not LAN

`SyncEngine` (392 lines), vector clocks, `SyncEncryptionService`, and the conflict UI are built
and tested. Only the transport is missing.

**Recommended transport: optical air-gap.** Port from `SreerajP_Authenticator` §6b and
`sreeraj_qr_reader` AirQR — animated QR frame stream out, camera in, error correction for dropped
frames, live progress. **It needs no network permission at all**, so it preserves this app's
zero-network guarantee, which LAN sync would break.

If LAN sync is chosen instead, four mature implementations exist to copy — `SreerajP_Authenticator`
§6a, `SreerajP_TextApp` §2.8, `SreerajPContactSphere` §6, `sms-sentry` §8. All four share the same
shape: QR + pairing-code out-of-band key exchange, PBKDF2 (200k–300k) → AES-256-GCM session key,
selective vs full sync, add-only merge. From `sms-sentry` specifically, copy the **hostile-peer
hardening**: bounded line readers, payload and item caps, handshake timeouts, host idle auto-stop,
single-client lock. From `SreerajP_TextApp`, copy `FLAG_SECURE` on the pairing screen.

**Effort:** M–L given how much exists.

---

### W8 — Localisation and accessibility

- **l10n:** no `lib/l10n/` and no `AppLocalizations` use today, despite `flutter_localizations`
  being a dependency. Port the `flutter_localizations` + `intl` ARB setup from
  `Sanathana_Dharma_Clock` §8 or `SreerajP_PDFApp` hard rule 8. Do the string extraction **before**
  W5/W6 add more hard-coded strings.
- **Accessibility:** port `Semantics` patterns from `daily_rule_cards` §8 (screen-reader labels,
  WCAG touch targets, font-scale-proof layout) and `sreerajp_todo` (task-tile semantics, colour
  -blind-safe status iconography). The mood chart's green/orange/red is currently colour-only and
  must carry a non-colour cue.

**Effort:** L for extraction, M for accessibility.

---

### W9 — Refactor `lib/app/app.dart`

~2,830 lines holding the shell, navigation, home tab, search tab, and the whole settings UI.
Every item above that touches settings touches this file. Extract to `lib/features/settings/`.

**Effort:** M plus regression testing.

---

## 5. The systemic finding — worth acting on

`SreerajP_CodeApp` §4.1 is titled *"Known Gaps: Documented-Before, Not-Built-Yet, or Half-Wired"*
and lists 14 features that were documented as finished but are not: a `SymbolExtractor` with no
screen, a `ZipService` never called, `addBookmark()` no UI calls, settings toggles never read by
the code that should read them.

Journal Vault has exactly the same pattern — a sync engine constructed by nothing, backup with no
restore, "Coming soon" placeholders, `AttachmentOpenRouter.open` throwing `UnimplementedError`
behind a complete UI (since fixed). `SreerajP_LalithaSahasranamam` §6 and
`SreerajPContactSphere` likewise carry explicit "not implemented" sections.

**This is a family-wide habit, not a Journal Vault bug.** `SreerajP_PDFApp` is the app that
solved it, with two hard rules worth adopting verbatim here:

> **Rule 6 — "Never a Dead Button":** shared components report their operational state and provide
> clear setup or fallback paths when unavailable.
>
> **Rule 5 — "Never Crash on Bad Input":** corrupt, truncated, empty, or password-protected files
> trigger clear error UI, not crashes.

**Proposed action:** adopt both rules in `CLAUDE.md` / `docs/architecture.md`, and make them
concrete — *a feature is not done until an integration test drives it through the UI.* Under
Rule 6, the two "Coming soon" placeholders in Settings (Tamper Alerts, and Sync Conflicts when
sync UI is off) are rule violations and should either be built or removed.

---

## 6. Unique-feature ideas, re-checked against the family

Revised from `enhancement_ideas.md` Part C now that all apps are known.

| Idea | Status after the full check |
|---|---|
| **C3 Time capsules** (sealed entries) | **Still the best value-to-effort.** Nothing in the family does date-gated key release. Genuinely novel. |
| **C1 Voice-first journalling** | Still strong and still distinctive. But note `SreerajP_PDFApp` §2.2 and `SreerajP_CodeApp` §3.5 both ship TTS, and `chronotune` §10 ships offline voice commands — so the audio-plumbing experience exists. The novel part is transcript-to-audio **alignment**, which nothing in the family has. |
| **C2 Knowledge graph** | Unchanged — nothing in the family is close. Most ambitious, hardest to copy. |
| **C5 Rewrite-aware entries** | Now stronger: `SreerajP_CodeApp` §4.3 lists a "Local Offline Code Time Machine & AST Visual Diff" as a *planned, unbuilt* concept. The same idea, built here first, on data this app already collects in `EntryRevisions`. |
| **C4 Two-key journals** | Keep, but note a precedent: `sreeraj_qr_reader` **StegoQR** already does decoy-visible / hidden-encrypted content behind biometric unlock. That is the pattern for the A5.4 decoy vault too. |
| **C8 Tamper-evident vault** | Keep. `SreerajP_PDFApp` §2.7 (offline signature verification, X.509 chains, Bouncy Castle, SHA-256 fingerprinting) is a real precedent for the crypto and for the *honesty of the claim* — it carefully documents what it cannot check. Match that discipline. |
| **C9 Ritual mode** | Now much cheaper. `daily_rule_cards` is an 18-card reflection deck built for exactly this. Additionally `SreerajP_LalithaSahasranamam` §4.6 ships an **Anki-style spaced repetition** engine (Hard/Revision/Easy → 1/3/`7×level` days) — that is directly reusable for resurfacing past entries and prompts, which is a better "On This Day" than a fixed year-ago lookup. |
| **C6 Local sync** | Reframed — see W7. Optical air-gap, not LAN. |
| **C7 Attachment-native journalling** | Reduced. PDF annotation should not be rebuilt; hand off to `SreerajP_PDFApp` or port its overlay. The documents view and attachment-text search remain worthwhile and cheap. |

---

## 7. Suggested order for the implementation session

1. **W1** Syncfusion → pdfrx. Unblocks the dependency pins, resolves the policy conflict.
2. **W2** Backup restore. Then **W3** encrypted archives, **W4** small security items.
3. Create the release keystore (`release_process.md` §0) — still the hard release blocker.
4. **W9** Split `app.dart` before adding more settings.
5. **W8** l10n extraction before more strings are written.
6. **W5** Export, then **W6** habit layer.
7. **W7** Sync transport.
8. Then pick **one** flagship from section 6.

---

## 8. Files this plan would touch

**Actually changed by this plan:** `docs/enhancement_ideas.md` (W0) only, plus this plan file and
the change log. Nothing else.

The list below was the *hypothetical* scope if W1–W9 were ever built. They were not. Treat it as a
backlog map, not a record of work done:

- `pubspec.yaml` (W1, W6, W8)
- `lib/features/attachments/presentation/pdf_attachment_view.dart` (W1)
- `lib/features/backup/` (W2, W3)
- `lib/core/database/app_database.dart` (W2, W4)
- `android/app/src/main/AndroidManifest.xml` + a new prod manifest (W4, W6)
- new `lib/features/export/` (W5)
- new `lib/features/settings/` (W9)
- new `lib/l10n/` (W8)
- `lib/features/sync/` (W7)
- `lib/app/app.dart` (W9, and most others)
- `docs/enhancement_ideas.md` (W0), `docs/architecture.md` and `CLAUDE.md` (section 5 rules)

---

## 9. Approval and outcome

**Approved in full on 2026-08-16.**

**Closed on 2026-08-16.** W0 was implemented — `docs/enhancement_ideas.md` now carries every
correction, re-costing, and re-ordering described above. W1–W9 were never in scope; they stay in
this document and in the revised ideas document as a described backlog, each needing its own plan
before any code is written.

Change log: [`change_log/20260816_140000_w0-enhancement-ideas-revision.md`](../change_log/20260816_140000_w0-enhancement-ideas-revision.md).
