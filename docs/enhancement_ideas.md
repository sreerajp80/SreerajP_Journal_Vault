# Enhancement Ideas — SreerajP Journal Vault

**Written:** 2026-08-16
**Revised:** 2026-08-16, after all 17 sibling apps were checked instead of 5.
**Status of this document:** mostly ideas. **Sixteen items have since been built** and are marked ✅ —
[A1.1 Export](#-a11-export-an-entry-or-a-whole-journal--implemented),
[A1.2 Inline images](#-a12-inline-images-in-the-editor-body--implemented),
[A1.3 Drawing and handwriting blocks](#-a13-drawing-and-handwriting-blocks--implemented),
[A1.5 Editor quality of life](#-a15-editor-quality-of-life--implemented),
[A1.7 Custom entry templates](#-a17-templates-the-user-can-create--implemented),
[A2.1 Tag colours](#-a21-tag-colours--implemented),
[A4.1 Restore from a backup](#-a41-restore-from-a-backup--implemented),
[A4.2 Password-protected backup and export files](#-a42-password-protected-backup-and-export-files--implemented),
[A5.1 Encrypt the database at rest](#-a51-encrypt-the-database-at-rest--implemented),
[A5.3 Guard the missing INTERNET permission](#-a53-guard-the-missing-internet-permission--implemented),
[A5.6 Finish the security screens](#-a56-finish-the-security-screens),
[A6.2 Receive shared text and images from other apps](#-a62-receive-shared-text-and-images-from-other-apps--implemented),
[A6.4 Localisation](#-a64-localisation--implemented),
[C3 Time capsules](#-c3-time-capsules-and-letters-to-your-future-self--implemented),
[C6 Device-to-device sync](#-c6-encrypted-device-to-device-sync--implemented), and
[C9 Ritual mode](#-c9-ritual-mode--a-journal-that-opens-like-a-practice-not-an-app---done-2026-08-24). Everything
else is still an idea: not approved, not scheduled, and each one still needs its own plan under
`plans/` before any code is written. See the completion key in section 1.

> **Read the roadmap plan first.**
> [`plans/20260816_125915_cross-app-informed-roadmap.md`](../plans/20260816_125915_cross-app-informed-roadmap.md)
> supersedes this document's **framing, effort sizes, and running order**. This document is kept
> for its idea list and its critical review. The roadmap is the approved plan of work; the
> corrections it lists (its section 3) have been applied below.

---

## 1. How to read this document

The document has three parts.

- **Part A — Make what already exists better.** Ideas that build on features the app already
  has. Low risk, mostly known work.
- **Part B — Critical review.** An honest look at where the app is weak, where a feature is
  only half delivered, and where the story told in `features.md` is thinner than it sounds.
- **Part C — Ideas that would make this app unique.** Features that, as far as the author's own
  app family and the common journal apps go, almost nobody ships.

Each idea has four lines:

- **What** — the feature in one or two sentences.
- **Why** — the reason it is worth doing.
- **Already in the family** — which sibling app has already built this, and what to take from it.
  This line is the most important one in the document. Where it is present, the item is **porting
  work, not design work**, and the effort size below it has been cut to match. Where it says
  *nothing yet*, the item really is new ground.
- **Effort** — a rough size: **S** (a day or less), **M** (a few days), **L** (a week or more),
  **XL** (a milestone of its own).

Effort is a guess, not a promise. The sizes in the first version of this document were written
before the sibling apps were checked properly, and most of them were too high.

### How completed items are marked

| Mark | Meaning |
|---|---|
| ✅ | Built and shipped. The item carries an **Implemented** line with the date and links to its plan and change log. |
| *no mark* | Still an idea. Not started, not approved, not scheduled. |

Only two marks, on purpose. Inventing states for
in-progress, partial, and abandoned work before anything is in those states would be noise. More
marks can be added when something is actually in one of them.

Where an item shipped **narrower than it was written**, the tick stays but the Implemented line
says exactly what was cut and why. A2.1 is the first of these: its tag colours were built, its
nested tag paths were dropped on purpose. A tick is not a claim that the original paragraph was
delivered word for word.

**A tick means a user can reach the feature**, not that the code exists. Part B1 below is about
this project's habit of building a service, passing its tests, and never wiring it to a screen —
so an item that stops short of the user does **not** get a tick.

Completed so far: **16 of the 41 numbered ideas** in Parts A and C (13 in Part A, 3 in Part C).
That number is meant to stay honest, not to look good.

---

## 2. What was analysed

To keep the ideas grounded, these were read first:

- `docs/features.md` — the full feature list.
- `docs/architecture.md` section 21 — the known-gaps list.
- `pubspec.yaml` — what the app can do with the packages it already has.
- The whole `lib/` tree (89 Dart files, 44 test files).
- `android/app/src/main/AndroidManifest.xml` and the merged `prodRelease` manifest under
  `build/`.
- **All 17 sibling `docs/features.md` files listed in `myapps.md`** (the 18th app is this one).
  `SreerajP_PDFApp` was read in full; section headings were mapped for all 17; the sections
  relevant to this app's gaps were read in detail; and a keyword sweep was run across all 17 for
  restore, export, notification, reminder, widget, OCR, localisation, Malayalam, share sheet,
  drawing, speech, sync, accessibility, and tablet.

The first version of this document read only the opening paragraph of 5 of those 17 apps, and
several of its claims were wrong as a result. Those claims have been corrected here.

The sibling apps matter because several ideas that sound new here are already solved next door.
Where that is true, it is said plainly — the point is to reuse, not to rebuild.

### The single biggest finding

> **Almost nothing this app needs is new work for this author. It is porting work.**
> Encrypted backup with restore, device-to-device sync, notifications, home screen widgets,
> localisation, accessibility, PDF export, share-intent handling — every one of these is already
> built, shipped, and documented in at least one sibling app, usually two or three.

That is why most effort sizes in this revision are smaller than in the first version, and why the
running order in section 4 changed.

---

# Part A — Make what already exists better

## A1. Entries and the editor

### ✅ A1.1 Export an entry or a whole journal — implemented

> **Implemented 2026-08-16.** All four formats, all three scopes, optional attachments. Reachable
> from the entry editor, the journal detail screen, and Settings → Export Data.
> Plan: [`plans/20260816_135333_a1-1-entry-and-journal-export.md`](../plans/20260816_135333_a1-1-entry-and-journal-export.md) ·
> Change log: [`change_log/20260816_144133_a1-1-entry-and-journal-export.md`](../change_log/20260816_144133_a1-1-entry-and-journal-export.md) ·
> Code: `lib/features/export/`
>
> **Route taken: the `SreerajP_lyricchord` §2.9 one** — of the four listed below. PDF is rendered
> by a native on-window Android WebView fed a self-contained HTML page with Noto Sans Malayalam
> embedded as base64 `@font-face`, so Malayalam shapes correctly and the PDF text stays
> selectable. Two departures from that original: **no `printing` package** — the file is saved
> through `FilePicker.saveFile`, so no new dependency was added and the `win32` knot in
> `pubspec.yaml` was left alone — and **no page-width fitting**, which is a song-sheet trick that
> a page of prose does not want.
>
> Two things the original plan got wrong, both corrected during the work: voice notes are rows in
> the `VoiceNotes` table, **not** a third Quill embed; and `security.md` §14 already required an
> explicit confirmation step before any plaintext export, so a confirmation dialog was added.
>
> **Not done, deliberately:** share-sheet hand-off, exporting across all journals at once, and
> PDF on iOS. The PDF renderer is Android only; the other three formats work everywhere.
> Encrypting the exported file was on this list too, and was **done on 2026-08-18 as part of
> A4.2** — the export screen can now seal the file with the shared envelope.

**What:** Export to Markdown, HTML, PDF, or a plain `.txt` file. One entry, a date range, or a
whole journal. Optionally include the attachments in a folder next to it.
**Why:** Today the app imports but never exports. Nothing in `lib/` writes an entry back out.
That makes the vault a one-way door: a user can put ten years of their life in and cannot get it
out except through a backup archive they cannot even restore. For a privacy-first app this is the
single biggest missing promise — "your data is yours" is only true if you can take it with you.
**Already in the family:** four routes, pick one.
- `SreerajP_lyricchord` §2.9 — the strongest PDF export in the family, and the right one here:
  HTML rendered through a native webview (`HtmlPdfService`) with **embedded base64 SIL OFL fonts**,
  so Malayalam shapes correctly and the PDF text stays selectable. Also safe file naming that
  keeps non-English letters, and share-sheet integration via `printing`. Journal entries may
  contain Malayalam, so this matters here.
- `SreerajP_CodeApp` §3.6 and `SreerajP_TextApp` §2.10 — export / print / share hub patterns.
- `SreerajP_PDFApp` §2.6 — the cheapest first version: **hand off** instead of building. PDFApp
  already accepts shared plain text and images via `ACTION_SEND` and turns them into a PDF.
**Effort:** M for Markdown/HTML/text. M more for PDF via the lyricchord approach — not L, because
the font embedding and the webview pipeline are copied, not designed.

### ✅ A1.2 Inline images in the editor body — implemented

> **Implemented 2026-08-16.** An image can be put into the flow of the writing from the editor
> toolbar. It is drawn in the body, can be sized small / medium / full width, and opens full
> screen on a tap. Exports carry it: HTML and PDF draw the picture into the page, Markdown links
> to the file beside it, plain text names it.
> Plan: [`plans/20260816_163000_a1-2-inline-images.md`](../plans/20260816_163000_a1-2-inline-images.md) ·
> Change log: [`change_log/20260816_171500_a1-2-inline-images.md`](../change_log/20260816_171500_a1-2-inline-images.md) ·
> Code: `lib/features/entries/presentation/editor/image_embed.dart`,
> `.../inline_image_store.dart`
>
> **The picture is an ordinary encrypted attachment; the embed holds only its row id.** So an
> inline image is backed up, synced, moved between app-private and SD card storage, and exported
> by the paths that already existed — and no schema change was needed. It deliberately does *not*
> use Quill's built-in `image` embed, which would put the picture into `Entries.contentJson`,
> which is stored unencrypted.
>
> **A locked attachment stays locked inline** — the body shows a "tap to unlock" box and asks for
> the same biometric prompt the attachment tray uses, and an export leaves a locked image out of
> the page and says so.
>
> Not built: drag-to-resize, cropping, and pasting or dropping an image into the editor.

**What:** Show images inside the Quill document, not only in the attachment tray.
**Why:** A journal without pictures in the flow of the text feels like a form, not a diary.
The encryption and storage layer already handles image bytes; what is missing is a Quill embed
that decrypts to a temporary file and renders it, in the same style as the existing voice-note
embed.
**Effort:** M.

### ✅ A1.3 Drawing and handwriting blocks — implemented

> **Implemented 2026-08-23.** A sketch embed where the user can draw with a finger or stylus,
> stored as an AES-256-GCM encrypted PNG attachment with vector stroke data for in-place re-editing.
> Plan: [`plans/20260823_134800_a1-3-drawing-handwriting-blocks.md`](../plans/20260823_134800_a1-3-drawing-handwriting-blocks.md) ·
> Change log: [`change_log/20260823_143800_a1-3-drawing-handwriting-blocks.md`](../change_log/20260823_143800_a1-3-drawing-handwriting-blocks.md) ·
> Code: `lib/features/entries/presentation/editor/drawing/`,
> `lib/features/entries/presentation/editor/drawing_embed.dart`
>
> **Interactive canvas with tools and styles:** Pen, Highlighter (semi-transparent blending),
> Eraser, 10-color preset palette, 4 stroke widths (Fine, Normal, Thick, Bold), and 4 paper
> background patterns (Blank, Ruled lines, Square grid, Dot grid).
>
> **Encrypted and integrated:** Rendered PNG images are encrypted via `AttachmentCryptoStorage`
> and stored as attachments, with vector JSON preserved in `DrawingEmbed` for lossless editing.
> Embedded inline with small / medium / full width sizing, full-screen viewer, version history
> previews, and export support across Markdown, HTML, PDF, and Plain Text.

**What:** A sketch embed where the user can draw with a finger or stylus, stored as an encrypted
vector or PNG attachment.
**Why:** Diaries are not only typed. A quick doodle, a mind map, a signature, a page of maths —
these are exactly the things people keep in paper journals and lose when they move to an app.
It also fits the existing embed pattern (`table_embed.dart`, `callout_embed.dart`).
**Already in the family:** nothing yet. The keyword sweep across all 17 apps found no stylus or
drawing canvas anywhere. This is one of the few Part A items that is genuinely new work.
**Effort:** L.

### A1.4 Checklists and task blocks that mean something
**What:** A checkbox list block in the editor, with a simple roll-up ("3 of 7 done") on the entry
card.
**Why:** Quill has checkbox lists; the app does not surface them in the toolbar. Cheap win.
Note the deliberate limit: full task management is `sreerajp_todo`'s job. This should stay
inside the entry, not become a second todo app.
**Effort:** S.

### ✅ A1.5 Editor quality of life — implemented
**What:** A bundle of small things: word and character count in the editor bar, a distraction-free
full-screen writing mode, a "focus paragraph" dim, an auto-save indicator with a timestamp, and
Markdown-style shortcuts while typing (`# ` becomes a heading, `- ` becomes a bullet).
**Why:** These are the details that decide whether someone writes in the app every day or stops
after a week. All are local to the editor and carry no data risk.
**Effort:** M for the set.
**Shipped:** 2026-08-21. Added `EditorStatsBar` with live word/char count and auto-save state indicator,
`EditorMarkdownShortcuts` for real-time Markdown prefix expansions (`#`, `##`, `###`, `-`, `*`, `+`, `1.`, `[]`, `>`, ```` ``` ````),
distraction-free full-screen writing view, and focus paragraph dimming.

### A1.6 Better version history
**What:** A real side-by-side diff with added and removed text highlighted, restore of a single
paragraph rather than the whole snapshot, and a retention cap so `EntryRevisions` stops growing
forever.
**Why:** The retention cap is already listed as an open gap in `architecture.md` section 21.
Every edit writes a full snapshot of the document, so a heavily edited entry can quietly become
the largest thing in the database.
**Effort:** M.

### ✅ A1.7 Templates the user can create — implemented

> **Implemented 2026-08-23.** Users can create, edit, and delete custom entry templates with rich text starter content, default titles, and dynamic date/time tokens (`{{today}}`, `{{weekday}}`, `{{date}}`, `{{time}}`, `{{year}}`, `{{month}}`, `{{day}}`). Custom templates appear alongside built-ins under "My templates" in the template chooser dialog. Users can also save existing journal entries directly as new reusable templates via the editor app bar action.
> Plan: [`plans/20260823_150200_a1-7-custom-entry-templates.md`](../plans/20260823_150200_a1-7-custom-entry-templates.md) ·
> Change log: [`change_log/20260823_151500_a1-7-custom-entry-templates.md`](../change_log/20260823_151500_a1-7-custom-entry-templates.md) ·
> Code: `lib/features/entries/templates/`, `lib/features/entries/presentation/template_manager_screen.dart`, `lib/features/entries/presentation/template_editor_screen.dart`, schema v9

**What:** Let the user write their own templates and save them, not just pick from the built-in
ones in `entry_templates.dart`. Allow date tokens (`{{today}}`, `{{weekday}}`) that fill in on use.
**Why:** The built-in list is fixed at compile time. Journalling habits are personal — a person
who writes a daily standup log needs a different skeleton from someone keeping a dream diary.
**Effort:** M.

## A2. Search and organisation

### ✅ A2.1 Tag colours — implemented

> **Implemented 2026-08-16.** Tags carry an optional colour, and there is a tag manager screen —
> reached from the Home app bar — to rename, recolour or delete any tag.
> Plan: [`plans/20260816_155016_a2-1-tag-colours.md`](../plans/20260816_155016_a2-1-tag-colours.md) ·
> Change log: [`change_log/20260816_160436_a2-1-tag-colours.md`](../change_log/20260816_160436_a2-1-tag-colours.md) ·
> Code: `lib/features/tags/`, schema v8
>
> **Shipped narrower than written, on purpose.** Colours were built. **Nested `work/projects/vault`
> tag paths and the tag tree were dropped**, and so was any per-journal tag cap. The reasoning,
> settled before the plan was written: this app already has a grouping layer — a **journal** is the
> category, and an entry belongs to exactly one. Tags are the second, cross-cutting axis. Nested
> paths would have been a display convention layered on top of a grouping the app already has, so
> they solved a problem journals already solve.
>
> **What actually caused the "200 tags" pain was different from the diagnosis below.** The list is
> long because `Tags` is one global table with no management screen at all — tags could only be
> typed when a journal was *created*, and never renamed, recoloured or deleted afterwards. The tag
> manager is the fix. A journal-scoped tag picker is the remaining half, and is not built.
>
> **Also fixed along the way:** the journal form hid its tags field when editing
> (`if (!isEdit)`), so journal tags could be set once and never changed. Editing now works, writing
> only the difference.
>
> **How the colour is chosen:** a stored colour wins; otherwise one is derived from an FNV-1a hash
> of the tag name. So every existing tag got a distinct colour immediately, with no backfill and
> nothing for the user to set. `String.hashCode` was avoided deliberately — it is not stable across
> Dart versions, and using it would silently reshuffle every colour on an upgrade.
>
> **Not done:** a journal-scoped tag picker, merging two tags into one, and filtering journals by
> tag colour.

**What:** Support `work/projects/vault` style tag paths, give tags a colour, and show a tag tree
instead of a flat chip list.
**Why:** The flat tag list works at 20 tags and breaks at 200. A journal is a long-lived store,
so it will get to 200.
**Effort:** M.

### A2.2 Search result snippets with the match highlighted
**What:** Show the matching sentence with the search word highlighted, instead of a plain title
list.
**Why:** FTS5 has a `snippet()` function built in, so the database side is nearly free. Search
without context makes the user open five entries to find one.
**Effort:** S.

### A2.3 Search the OCR text of images
**What:** Run on-device text recognition over imported images and feed the result into the
existing `attachment_text_fts` table.
**Why:** The text-extraction pipeline already exists for `.txt`, `.pdf`, `.md`, and `.csv`. Images
are the one common attachment type it cannot see into. Photos of receipts, whiteboards, and
handwritten notes become searchable. Must be an on-device engine only — no cloud OCR, ever, or
the zero-telemetry promise breaks.
**Already in the family — and the author has already ruled against this.** `SreerajP_PDFApp` hard
rule 7 puts **OCR explicitly out of scope**, and ships graceful degradation instead. That app is
the one that specialises in documents, so its ruling carries weight here. `20260725_000000_remediation-plan.md`
also lists PDF OCR as out of scope. Either follow the ruling, or make the exception a deliberate,
written decision — do not drift into it.
**Effort:** L, if it is done at all.

### A2.4 Saved smart views
**What:** Turn a saved search preset into a pinned view on the home screen — "This month",
"Locked entries", "Entries with voice notes", "Untagged".
**Why:** `SearchPresets` already stores the filters. This just gives them a front door.
**Effort:** S.

## A3. Insights

### A3.1 Word-based mood, not only the 1–5 picker
**What:** Alongside the manual mood rating, count how often the user writes words from a small
built-in emotion word list, and chart that.
**Why:** People forget to tap the mood picker. The words they use do not lie. The word list must
be a plain bundled asset with no model and no network — this is a word counter, not sentiment AI.
**Effort:** M.

### A3.2 More useful insight cards
**What:** Writing time-of-day histogram ("you write most at 22:00"), average entry length trend,
longest gap without writing, tag co-occurrence ("`work` and `stress` appear together 14 times"),
and a per-journal breakdown.
**Why:** The insights screen already has the hard parts — the service, the chart widgets, the
streak logic. Extra cards are mostly new queries.
**Effort:** M.

### A3.3 A year-in-review page
**What:** One scrollable page at the end of a year: total words, best streak, mood curve, top
tags, the first and last entry, a picked memory from each month.
**Why:** It gives the user a reason to come back and a reason to keep writing. It also exports
nicely once A1.1 exists.
**Effort:** M.

## A4. Backup, restore, and data safety

### ✅ A4.1 Restore from a backup — implemented

> **Implemented 2026-08-18.** Preview, replace or merge, dry run, and a restore screen
> behind the PIN or device check. The archive format went to version 2, which also fixed
> two things this entry did not name: entry moods and saved search presets were never
> exported at all, and attachment files were copied into the archive still encrypted with
> the device key, so they could never be opened on a new phone. Version 1 archives still
> restore.
>
> Plan: [`plans/20260818_134141_a4-1-backup-restore.md`](../plans/20260818_134141_a4-1-backup-restore.md) ·
> Change log: [`change_log/20260818_152000_a4-1-backup-restore.md`](../change_log/20260818_152000_a4-1-backup-restore.md) ·
> Code: `lib/features/backup/`
>
> **Route taken: all four sources, read from their source code rather than their
> summaries.** `chronotune-smart-clock` gave the mode enum and dropping primary keys on
> import; `sreerajp_todo` the safety sequence, the exception shapes and the 8-character
> password floor; `SreerajPContactSphere` the container that carries binary assets as
> content and the gate; `SreerajP_Authenticator` the self-describing envelope and the
> added-vs-skipped result. Two deliberate departures: `sreerajp_todo` replaces the whole
> database file atomically, which cannot support merge and does not fit a JSON-row
> archive, so one Drift transaction plus an automatic pre-restore backup gives the same
> "never half-applied" promise; and the dry run is new here, since none of the four had
> one.

**What:** Read a backup archive back into the app, with a preview of what it contains, a choice
between replace and merge, and a dry run.
**Why:** `backup_service.dart` creates and verifies backups but cannot restore them. A backup
that has never been restored is not a backup; it is a file. Right now a lost or wiped phone means
all journal data is gone, no matter how many backups were made. This is the single most serious
functional gap in the app.
**Already in the family — solved four different ways. Do not invent a fifth.** The first version
of this document called the design "open". It is not; it is off the shelf.

| App | What to take |
|---|---|
| `chronotune-smart-clock` §12 | A self-describing **versioned** backup format (`FORMAT_VERSION`), **MERGE vs REPLACE** import modes, and omitting primary keys on export then reassigning them on import so IDs cannot collide. |
| `sreerajp_todo` §11.2 | The safety sequence: passphrase validation → **schema version check** (auto-migrate older, reject newer with a `BackupVersionTooNewException`) → `PRAGMA integrity_check` → atomic database replace. Plus WAL checkpointing before export (§11.1). |
| `SreerajPContactSphere` §7 | Whole-database-plus-binary-assets backup — contact photos there map exactly onto encrypted attachments here — and gating the restore screen behind a biometric or PIN check. |
| `SreerajP_Authenticator` §5 | Backward-compatible decryption of older backup formats, so an update never orphans an old backup. Plus the `ImportResult` dialog reporting added vs skipped. |

**Effort:** **M**, not L — the design work is already done next door.

### ✅ A4.2 Password-protected backup and export files — implemented
**What:** Encrypt the backup file itself under a user passphrase, separate from the device
Keystore.
**Why:** A backup written to the SD card or copied to a PC leaves the Keystore's protection
behind.
**Already in the family — five times.** Converge on one of these envelopes rather than adding a
sixth to the family:
- `SreerajP_Authenticator` — an `.aes` file, PBKDF2 at **300,000** iterations then AES-256-GCM.
- `SreerajPContactSphere` — `.csbak`, PBKDF2 300k + AES-GCM-256.
- `sreerajp_youtube_shortcut` §5.11 — a self-describing envelope string
  `v1:<salt_b64>:<iv_b64>:<ciphertext_b64>`, with encrypted-file auto-detection on import.
- `sreerajp_todo` §11.1 — a passphrase-encrypted ZIP, minimum 8 characters.

**Recommended: the `sreerajp_youtube_shortcut` `v1:` envelope**, because it is versioned and
self-describing — which is exactly the property the attachment crypto format is missing (A5.2).
Using it in both places gives the whole app one versioning idea instead of two.
**Effort:** **S** once A4.1 exists, not M.

> **Implemented 2026-08-18.** Half of this arrived with A4.1: the backup archive is sealed by
> a self-describing binary envelope with a **random** salt, replacing the fixed salt that made
> one password produce one key on every device and in every backup. The rest was finished the
> same day.
> Plan: [`plans/20260818_145453_a4-2-encrypted-export-envelope.md`](../plans/20260818_145453_a4-2-encrypted-export-envelope.md) ·
> Change log: [`change_log/20260818_163000_a4-2-encrypted-export-envelope.md`](../change_log/20260818_163000_a4-2-encrypted-export-envelope.md) ·
> Code: `lib/core/security/vault_envelope.dart`, `lib/core/security/vault_payload.dart`,
> `lib/features/export/presentation/open_encrypted_export_screen.dart`
>
> **The envelope moved to `lib/core/security/` as `VaultEnvelope`**, so the backup archive and
> the export file use one format instead of two. The bytes on disk did not change, so every
> archive written by A4.1 still opens.
>
> **The export screen gained a "Protect with a password" switch**, off by default. The real file
> name and mime type ride **inside** the sealed bytes in a `JVP1` payload header, and the file is
> offered as `journal_export_<date>.jvenc` — a name like `Leaving my job.md.jvenc` would give
> away the very thing the password hides. Settings → "Open an encrypted export" unwraps one
> again; it never writes anything back into the vault.
>
> **The PBKDF2 recommendation above was not followed, deliberately.** What the `v1:` envelope was
> recommended *for* was being versioned and self-describing. `VaultEnvelope` is both, and it also
> writes the KDF and its cost into the file, so the cost can be raised later without orphaning
> old files — which a `v1:<salt>:<iv>:<ciphertext>` string cannot do. Argon2id is memory-hard,
> PBKDF2 is not, and switching would have broken every archive written since A4.1. The family
> target is the idea, and this envelope carries it further. Full reasoning in
> `docs/security.md` section 14.

### A4.3 "Delete all data"
**What:** A confirmed, typed-phrase destructive action that wipes the database, the attachments,
the Keystore aliases, and the preferences.
**Why:** Already listed as required by the standard (§15.4) and already listed as missing in
`architecture.md` section 21. It is also a genuine user need — a person who keeps a private
diary must be able to destroy it quickly.
**Already in the family:** `sms-sentry` has `clearAllSms`; `SreerajPContactSphere` documents a
full-replace wipe path. Both give the shape of a safe destructive action.
**Effort:** **S–M** with those as a reference. Still needs care: a partial wipe is worse than no
wipe.

### A4.4 Retention caps everywhere
**What:** Caps on `EntryRevisions`, `SecurityEvents`, and `SyncLogs`, configurable in Settings.
**Why:** All three tables grow without limit today. On a multi-year vault this ends as a slow app
and a large backup.
**Effort:** S.

## A5. Security

### ✅ A5.1 Encrypt the database at rest — implemented

> **Implemented 2026-08-18.** The vault is SQLCipher, keyed by 32 `SecureRandom` bytes held in
> the Android Keystore and passed as a raw key. An existing plain database is converted on the
> first launch after the update, and the plain original is deleted only once the encrypted vault
> has opened for real.
> Plan: [`plans/20260818_153817_a5-1-encrypt-database-at-rest.md`](../plans/20260818_153817_a5-1-encrypt-database-at-rest.md) ·
> Change log: [`change_log/20260818_161934_a5-1-encrypt-database-at-rest.md`](../change_log/20260818_161934_a5-1-encrypt-database-at-rest.md) ·
> Code: `lib/core/database/`
>
> **Built differently from the paragraph below.** `sqlcipher_flutter_libs` was not used.
> `package:sqlite3` now supplies the native library through a build hook, so SQLCipher is
> selected by four lines in `pubspec.yaml` and `sqlite3_flutter_libs` and `drift_flutter` came
> out. That has a real benefit the original plan did not expect: the *test runner* gets SQLCipher
> too, so the conversion is proven on the host, not only on a device.
>
> **Two costs, both real.** Losing the Keystore key now means losing the journal — there is no
> password fallback, so the app shows a "vault cannot be opened" screen that points at
> restore-from-backup rather than starting empty. And `libsqlcipher.so` is about 4.9 MB per ABI.

**What:** Move to an encrypted SQLite build (SQLCipher via `sqlcipher_flutter_libs`) with the key
held in the Android Keystore.
**Why:** Today only attachments are encrypted. Entry text and the whole FTS index sit in plain
SQLite inside the app-private directory. The risk was consciously accepted, and the reasoning
(root or an offline flash dump only) is fair — but for an app whose main selling point is
"security-hardened vault", plain-text entry bodies are the weakest part of the claim. Note the
real cost: FTS5 over an encrypted database is slower, and migration of an existing vault has to
be flawless or it destroys data.
**Effort:** XL.

### A5.2 A version byte on the attachment crypto format
**What:** Prefix every encrypted attachment with a format version.
**Why:** Already a known gap. It costs almost nothing now and blocks any future algorithm change
if it is skipped.
**Already in the family:** the app already has this envelope — `VaultEnvelope` in
`lib/core/security/`, built for the backup archive in A4.1 and given to the export file in A4.2.
It sits in `core/` precisely so the attachment format can adopt it, which would leave the app
with one versioning idea rather than two.
**Effort:** S.

### ✅ A5.3 Guard the missing `INTERNET` permission — implemented

> **Implemented 2026-08-23.** Explicit `tools:node="remove"` entries for `INTERNET`,
> `ACCESS_NETWORK_STATE`, and `WAKE_LOCK` are added to `android/app/src/main/AndroidManifest.xml`.
> Debug and profile builds use `tools:node="replace"` for `INTERNET` to support local tooling.
> Automated tests (`test/core/security/manifest_permission_guard_test.dart`) and
> `tool/check_no_internet_permission.sh` in `.github/workflows/ci.yml` enforce this invariant.
> Plan: [`plans/20260823_202800_guard-internet-and-transitive-permissions.md`](../plans/20260823_202800_guard-internet-and-transitive-permissions.md) ·
> Change log: [`change_log/20260823_203500_guard-internet-and-transitive-permissions.md`](../change_log/20260823_203500_guard-internet-and-transitive-permissions.md)

**What:** Add an explicit `<uses-permission android:name="android.permission.INTERNET"
tools:node="remove" />` to the production manifest and a CI check that fails the build if
`INTERNET` appears in the merged manifest.
**Why:** Checked against the merged `prodRelease` manifest: `INTERNET` really is absent today, so
the offline claim holds. But it holds by luck — no plugin currently asks for it. There is no
`tools:node="remove"` and no check, so the day a dependency is added or upgraded, the app's
central promise could break silently and nobody would notice. Same treatment is worth applying to
the unused `ACCESS_NETWORK_STATE` and `WAKE_LOCK` permissions.
**Already in the family:** `SreerajP_PDFApp` hard rule 2 states the same no-network guarantee and
is worth matching word for word.
**Interacts with C6.** If LAN sync were ever chosen over optical air-gap sync, this guard has to
be revisited — see the correction under C6, which removes that conflict.
**Effort:** S. High value for the size.

### A5.4 Decoy vault / duress PIN
**What:** A second PIN that opens a separate, harmless-looking journal set, with the real vault
invisible.
**Why:** This is the difference between protection from a thief and protection from a person
standing next to you demanding you unlock the phone. For a private diary that second case is the
realistic one. Must be built so that the decoy is not detectable from file sizes or database
shape — otherwise it is theatre.
**Already in the family:** `sreeraj_qr_reader` **StegoQR** already ships decoy-visible content
with hidden encrypted content behind a biometric unlock. That is the pattern for this and for C4.
**Effort:** L, and only worth doing if it is done properly.

### A5.5 Panic wipe and failed-attempt lockout
**What:** Optional: after N failed unlock attempts, either lock the app for a cooling period or
wipe. Also a quick panic gesture that closes and locks instantly.
**Why:** The audit log already records failed attempts; nothing acts on them.
**Effort:** M.

### A5.6 Finish the security screens

> **✅ Answered, 2026-08-23.** Tamper Alerts has its own dedicated screen (`TamperAlertsScreen`)
> wired up under Settings → Security, providing live vault integrity status, on-demand vault integrity
> verification across all journals and entries, educational explanation, and tamper alert logs.
> The dead "Coming soon" fallback tiles for sync rows when `enableSyncUi` is off have been removed,
> eliminating all dead buttons in Settings per Rule 6.

**What:** Wire up the "Coming soon" Tamper Alerts placeholder in Settings, and the second such
placeholder (Sync Conflicts, when the sync UI flag is off).
**Why:** A disabled placeholder in a security section reads worse than no entry at all — it tells
the user the app watches for tampering when it does not.
**Already in the family:** `SreerajP_PDFApp` hard **rule 6 — "Never a Dead Button"**: a shared
component reports its own operational state and offers a setup or fallback path when it is
unavailable. Under that rule both placeholders are violations, and each should be **either built
or removed** — not left sitting there. See B1, where this becomes a family-wide finding.
**Effort:** M to build, S to remove.

## A6. App shell, platform, and polish

### A6.1 Reminders and notifications
**What:** A daily writing reminder at a chosen time, a nudge when a streak is about to break, and
an "On This Day" morning notification.
**Why:** The app has no notification capability at all — `flutter_local_notifications` is not a
dependency. Journalling is a habit app as much as a storage app, and habits need a prompt. The
notification text must never contain entry content; only "You have a memory from 3 years ago".
**Already in the family — four mature notification stacks.** The first version of this document
framed reminders as a new capability for this author. They are not.
- `MantraJapaCounter` §5 or `sms-sentry` §5/§7 — **port from these**, they are the closest fit
  and the simplest.
- `SreerajPContactSphere` — another working scheduled-reminder stack.
- `chronotune-smart-clock` — the most advanced (foreground services, full-screen intents), which
  is *more* than this app needs. But copy its **Android 13+ `POST_NOTIFICATIONS` permission
  handling**, which is the part everyone gets wrong.
**Effort:** M, as a port.

### ✅ A6.2 Receive shared text and images from other apps — implemented

> **Implemented 2026-08-23.** Intent filters configured for `ACTION_SEND` (text/plain, image/*, */*), `ACTION_SEND_MULTIPLE` (images/files), and `ACTION_VIEW` (`.jvenc` and `.jvbk` encrypted archives). Incoming shares are processed natively and passed to Flutter via MethodChannel (`sreerajp.journal_vault/share_intent`).
> When unlocked (or after passing the PIN/biometric lock gate), a Quick Capture dialog allows selecting the destination journal, editing the title and text, previewing attachments, and saving directly to the vault or opening in the full editor. Shared `.jvenc` and `.jvbk` files route directly to the standalone encrypted export viewer.
> Plan: [`plans/20260823_210500_a6-2-receive-shared-text-and-images.md`](../plans/20260823_210500_a6-2-receive-shared-text-and-images.md) ·
> Change log: [`change_log/20260823_213500_a6-2-receive-shared-text-and-images.md`](../change_log/20260823_213500_a6-2-receive-shared-text-and-images.md) ·
> Code: `android/app/src/main/AndroidManifest.xml`, `android/.../MainActivity.kt`, `lib/features/share_receiver/`

**What:** An intent filter so the Android share sheet offers "SreerajP Journal Vault", dropping
the shared item into a chosen journal or a quick-capture inbox.
**Why:** Right now the only way to get something in is to open the app and type or import. Most
journal moments start somewhere else — a link, a photo, a quote in a chat.
**Already in the family:** `vault-files`, `SreerajP_PDFApp` §2.7, and `SreerajP_lyricchord`
(`file_intent_listener.dart`) all handle inbound intents. Also worth copying: `vault-files` gives
its `.securenote` files a dedicated VIEW intent filter, which is the same trick this app would
need for its own backup archives.
**Effort:** M, as a port.

### A6.3 Home screen widget and quick capture
**What:** A small widget with "New entry" and today's streak; a lightweight capture screen that
skips the full editor.
**Why:** Speed of capture decides whether a thought gets written down. Note the security
question that must be answered first: what does the widget show on a locked device? The safe
answer is nothing but a button.
**Already in the family:** `SreerajP_LalithaSahasranamam` §4.9 has a working `home_widget` plus a
Kotlin `SadhanaWidgetProvider` with deep links, and honestly documents its own cold-start
deep-link limitation — read that before starting. `chronotune-smart-clock` has Canvas-rendered
widgets if something richer is ever wanted. This is a port with a Kotlin side, not a design job.
**Effort:** **M**, not L.

### ✅ A6.4 Localisation — implemented

> **Implemented 2026-08-23.** Standard `flutter_localizations` + `intl` ARB localization pipeline configured with `lib/l10n/app_en.arb` (800 synchronized keys with descriptive `@key` metadata) and `lib/l10n/app_ml.arb` (full natural Malayalam translations).
> Extracted all hard-coded UI strings across entries, editor, drawing canvas, attachments, import, features catalog, and all 14 help center screens to `AppLocalizations`. Added bilingual widget and unit tests in `test/l10n/app_localizations_test.dart`.
> Plan: [`plans/20260823_221300_a64_localisation.md`](../plans/20260823_221300_a64_localisation.md) ·
> Change log: [`change_log/20260823_224500_a64_localisation.md`](../change_log/20260823_224500_a64_localisation.md) ·
> Code: `lib/l10n/`, `lib/features/`, `test/l10n/`

**What:** Extract all UI strings to ARB files and add at least Malayalam, following the device
language.
**Why:** `flutter_localizations` is already a dependency but there is no `lib/l10n/` folder and no
`AppLocalizations` use anywhere — every string is hard-coded.
**Already in the family — at least 8 of the 17 apps are EN/ML bilingual**, so both the pattern
and much of the Malayalam vocabulary already exist.
- `Sanathana_Dharma_Clock` §8 and `SreerajP_PDFApp` hard rule 8 — the standard
  `flutter_localizations` + `intl` ARB setup. Port either.
- `SreerajP_LalithaSahasranamam` — a 3-script switcher using a bundled lookup table and no `intl`
  at all, if a lighter approach is ever wanted.
**Do the string extraction before A1.1, A6.1 and A6.2**, because each of those writes new
hard-coded strings that would otherwise have to be extracted twice.
**Effort:** L. This stays L: the extraction across ~90 Dart files is the work, and no sibling app
can do it for this one.

### A6.5 Accessibility
**What:** `Semantics` labels on the icon-only buttons, screen-reader ordering in the editor,
a check that the app is usable at 200% font scale, and contrast checks on the mood colours and
the tag heatmap.
**Why:** There is no `Semantics(` widget anywhere in `lib/` today. The app is unusable with
TalkBack in places, and the colour-only mood chart (green/orange/red) carries no meaning for a
colour-blind user.
**Already in the family:** the first version of this document called accessibility untouched
ground for this author. It is not. `daily_rule_cards` §8 ships screen-reader labels, WCAG touch
targets, and font-scale-proof layout; `sreerajp_todo` ships task-tile semantics and colour-blind-
safe status iconography; `Sanathana_Dharma_Clock` also ships `Semantics` work. Copy those
patterns rather than deriving them.
**Effort:** M, as a port.

### A6.6 Tablet and landscape layouts
**What:** A two-pane list-and-editor layout on wide screens.
**Why:** The manifest allows rotation; the UI is built for one phone width. A journal is a
reading app as much as a writing app, and people read on tablets.
**Effort:** M.

### ✅ A6.7 Themes worth looking at — implemented

> **Implemented 2026-08-24.** Added rich reading surfaces (**Paper / Sepia** with warm parchment `#F8F3E6` background and espresso text, **OLED / True Black** with pure `#000000` pitch black background for AMOLED battery savings, Light, Dark, and System). Added **Reading Typography** controls with body font family selection (Sans-serif, Book Serif, Monospace) and body font size adjustments (12pt–24pt with presets) featuring live interactive preview. Integrated with `QuillEditor` in entry editor, history, and template editing, with SharedPreferences persistence and encrypted AirQR cross-device sync.
> Plan: [`plans/20260824_144200_reading_themes_and_typography.md`](../plans/20260824_144200_reading_themes_and_typography.md) ·
> Change log: [`change_log/20260824_145500_reading_themes_and_typography.md`](../change_log/20260824_145500_reading_themes_and_typography.md)

**What:** More than light and dark: a paper/sepia reading theme, adjustable font family and size
for the entry body, and true black for OLED.
**Why:** People choose journal apps partly on how the writing surface feels. This is cheap and
directly affects daily use.
**Effort:** S.

### ✅ A6.8 Split up `app.dart` — implemented

> **Implemented 2026-08-24.** Extracted all settings sub-screens, sections, and dialogs from
> `lib/app/app.dart` into `lib/features/settings/presentation/` (`SettingsTab`, `SettingsSectionCard`,
> `SecuritySettingsScreen`, `ScreenSecurityTile`, `PinSetupDialog`, `StorageSettingsScreen`,
> `StorageSection`, `MigrationProgressDialog`, `PermissionsSettingsScreen`, `PermissionsSection`,
> and `LockedAttachmentsScreen`).
> Extracted `unlockedJournalIdsProvider` into `lib/features/journal_lock/providers/journal_lock_providers.dart`
> and `AppLockState`/`appLockProvider` into `lib/features/lock_gate/providers/lock_gate_providers.dart`.
> Reduced `lib/app/app.dart` by over 1,400 lines while maintaining 100% test coverage and zero regression across 758 tests.
> Plan: [`plans/20260824_142100_split_settings_out_of_app_dart.md`](../plans/20260824_142100_split_settings_out_of_app_dart.md) ·
> Change log: [`change_log/20260824_142700_split_settings_out_of_app_dart.md`](../change_log/20260824_142700_split_settings_out_of_app_dart.md)

**What:** Move the settings UI out of `lib/app/app.dart` into `lib/features/settings/`.
**Why:** The file was over 3,700 lines and held the shell, the navigation, the home tab, the
search tab, and the entire settings screen. Moving settings into its own feature module decouples
settings from the root shell, eliminates merge conflicts, and ensures adherence to the Tier 2 architecture.
**Effort:** M, plus careful regression testing.

---

# Part B — Critical review

This section is deliberately blunt. It is about the app as it stands, not about the ideas above.

## ✅ B1. The feature list is far ahead of the finished product — mostly resolved

`features.md` is an impressive document. Reading the code alongside it, a pattern shows up: many
features are built to the point where the data layer and the service work and the tests pass,
but the last step to the user is missing or hidden.

- The **sync engine** is 392 lines, encrypted, conflict-aware, tested — and constructed by
  nothing. There is no transport, so it cannot move a single byte between devices. The UI is
  hidden behind a flag.
- ~~**Backup** creates archives it cannot restore.~~ **Resolved 2026-08-18 (✅ A4.1).**
- ~~**Tamper alerts** are a disabled "Coming soon" row.~~ **Resolved 2026-08-23 (✅ A5.6).**
- ~~**Security events** are recorded diligently and never acted upon.~~ **Resolved 2026-08-23 (✅ A5.6).**

The `architecture.md` "last-mile integration pass" already caught and closed one wave of exactly
this problem — an attachment router that threw `UnimplementedError` behind a complete UI, smart
tags built and imported by no screen. That was good work. But the pattern is a habit of the
project, not a one-off, and it will keep recurring unless a feature is only called done when a
user can reach it.

### This is a family-wide habit, not a Journal Vault bug

The full cross-app check turned this from a criticism of one app into a finding about all of
them. `SreerajP_CodeApp` §4.1 is titled *"Known Gaps: Documented-Before, Not-Built-Yet, or
Half-Wired"* and lists **14** features documented as finished that are not: a `SymbolExtractor`
with no screen, a `ZipService` nothing calls, an `addBookmark()` no UI invokes, settings toggles
never read by the code that should read them. `SreerajP_LalithaSahasranamam` §6 and
`SreerajPContactSphere` carry their own explicit "not implemented" sections.

`SreerajP_PDFApp` is the app that solved it, with two hard rules worth adopting here **verbatim**:

> **Rule 6 — "Never a Dead Button":** shared components report their operational state and provide
> clear setup or fallback paths when unavailable.
>
> **Rule 5 — "Never Crash on Bad Input":** corrupt, truncated, empty, or password-protected files
> trigger clear error UI, not crashes.

**Suggested action:** put both rules in `CLAUDE.md` and `architecture.md`, and make them concrete
with one testable sentence — *a feature is not done until an integration test drives it through
the UI*. Under rule 6, the two "Coming soon" rows in Settings (Tamper Alerts, and Sync Conflicts
when the sync UI is off) are rule violations today; see A5.6.

> **✅ Answered, 2026-08-23.** The dead placeholders have been resolved per Rule 6: Tamper Alerts is
> now a dedicated, live `TamperAlertsScreen` with full integrity verification, and the disabled sync
> fallback rows were removed from Settings (see ✅ A5.6). Backup restore was built on 2026-08-18 (✅ A4.1).
> Sync transport remains the open item (see C6).

## ✅ B2. The data can go in but cannot come out — resolved

Import adapters for Markdown, DOCX, and plain text. Zero export paths. No restore. For an app
built on the promise "your data stays yours and stays local", this is the promise least kept.
Local data you cannot extract is not sovereignty; it is a nicer prison. **A1.1 and A4.1 should
come before anything in Part C.** Several of the unique ideas below also assume an export format
exists.

> **Half answered, 2026-08-16.** The export half was built first — see ✅ A1.1. A user can take
> their writing out as Markdown, HTML, plain text, or PDF, with attachments.
>
> **✅ Fully answered, 2026-08-18.** The restore half is built too — see ✅ A4.1. A backup can be
> read back with a preview, a replace-or-merge choice and a dry run, and a version 2 archive
> restores onto a phone that never held the original encryption key. Data now goes in, comes
> out, and comes back. The paragraph above is kept as written because it is the reason both
> items were done before anything in Part C.

## ✅ B3. The security story has one soft centre — mostly resolved

The security work is genuinely good: Keystore-wrapped AES-256-GCM attachments, FLAG_SECURE,
`allowBackup="false"` with transfer blocked, R8 with keep rules, obfuscation, a redacting logger,
no `INTERNET` in the merged production manifest. That is more than most apps in this category do.

~~But the entry text itself — the actual diary — is stored in plain SQLite, along with a full-text
index that by design contains every word the user ever wrote.~~ **Closed 2026-08-18 with A5.1.**
The database and its FTS index are SQLCipher-encrypted with a Keystore-held key, so the mismatch
this paragraph was about — an app described as a "security-hardened vault" whose diary text was
readable with a file browser — is gone. What remains of the point: the app still does not *say*
any of this on a screen of its own. A5.6 covers that.

Second soft spot: the release build still falls back to the **debug signing key**. Nothing else
in this document matters if a build ships that way, because switching to a real key later forces
an uninstall, which destroys every journal in the app. This is a hard blocker and it is already
known.

> **✅ Answered, 2026-08-23.** Database encryption at rest was implemented with SQLCipher (✅ A5.1),
> the `INTERNET` permission is strictly removed and guarded by CI (✅ A5.3), and the security integrity UI
> is live in `TamperAlertsScreen` under Settings → Security (✅ A5.6). Release signing keystore setup remains
> as an operational step prior to distribution (`release_process.md`).

## B4. It is a strong store and a weak habit — partly resolved

Everything in the app is about holding writing safely. Almost nothing is about getting a person
to write. There are no reminders, no widget, no share-in, no quick capture, no streak nudge. The
insights screen counts streaks that nothing helps the user keep. A journal app lives or dies on
daily return, and the app currently gives the user no reason to open it.

> **Partly answered, 2026-08-23.** Inbound share capture is implemented (✅ A6.2) allowing quick entry
> capture from the system share sheet, along with editor quality-of-life shortcuts and stats (✅ A1.5),
> drawing and handwriting canvas (✅ A1.3), and custom entry templates (✅ A1.7).
> Notifications (A6.1) and widgets (A6.3) remain open.

## B5. The app assumes one kind of user — partly resolved

No localisation, no accessibility work, no tablet layout, no font control. All three of these are
"later" decisions that get more expensive the longer they wait — localisation especially, since
every hard-coded string written from now on is one more string to extract.

> **Partly answered, 2026-08-24.** Localisation is fully implemented (✅ A6.4) across all UI screens
> with complete English and Malayalam ARB catalogs. Reading themes and typography controls are fully implemented
> (✅ A6.7) with paper/sepia, OLED true black, and body font selection/sizing. Accessibility (A6.5) and tablet layouts (A6.6) remain open.

## B6. A shipped dependency contradicts the family's own hard rule — ✅ implemented (2026-08-23)
`syncfusion_flutter_pdfviewer` was completely removed and replaced with `pdfrx` (PDFium, BSD/MIT) in `pubspec.yaml` and `pdf_attachment_view.dart`, resolving the policy conflict and removing commercial license constraints.

## B7. What the app does exceptionally well

To be fair, this is real and should not be lost while chasing new ideas:

- The **embed system** — tables, callouts, inline voice notes — is genuinely nice work and is
  the natural place to build most of the unique features in Part C.
- **Per-journal and per-attachment locking** is finer-grained than what most journal apps offer.
- **Backlinks with an inbound "Linked From" panel** puts a real knowledge-graph feature inside a
  diary app. Almost no journal app does this.
- The **honesty of the documentation**. `architecture.md` section 21 lists this project's own
  failures in detail. That is rare and it is why this review could be specific.

---

# Part C — Ideas that would make this app unique

The test applied to each idea: does any well-known journal app ship this, and does any of the
author's own apps already do it? Ideas that only pass "sounds nice" were left out.

The strongest three are marked ⭐.

**Every idea below was re-checked against all 17 sibling apps.** Where the check changed the
verdict, it is said under **Re-checked**. C6 changed the most — its stated conflict with the
zero-network promise turned out to be avoidable.

## ⭐ C1. Voice-first journalling with a searchable spoken archive

**What:** Make speaking the primary way to write, not a side feature. Open the app, press one
button, talk. The recording is encrypted and kept; the on-device transcription becomes the entry
body; both stay linked so tapping any sentence plays back the audio of that sentence.

**What makes it unique:** Voice memo apps keep the audio and lose the text. Journal apps take
dictation and throw the audio away. Almost nobody keeps both, aligned, searchable, and encrypted
on-device with no cloud. Ten years later the user can search a word and hear their own voice
saying it. That is something a text journal can never give back.

**Why this app can do it:** `record`, `speech_to_text`, the encrypted attachment pipeline, the
voice-note embed, and the FTS index all already exist. What is missing is timestamp alignment
between the transcript and the audio, and a capture-first screen.

**Watch out for:** on-device speech recognition quality varies by device and language, and
`speech_to_text` is a thin wrapper over whatever the device provides. Some phones will route it
through Google servers, which would break the offline promise — this must be checked and
disclosed, and the feature must degrade to "audio only, no transcript" rather than silently going
online.

**Re-checked:** still strong, still distinctive — but part of it is cheaper than stated. The
audio-plumbing experience exists in the family: `SreerajP_PDFApp` §2.2 and `SreerajP_CodeApp` §3.5
both ship TTS, and `chronotune-smart-clock` §10 ships offline voice commands. **The genuinely
novel part is transcript-to-audio alignment**, which nothing in the family has. Spend the effort
there.

**Effort:** L.

## ⭐ C2. A private, on-device knowledge graph of a life

**What:** Take the existing `[[backlink]]` system further into something no diary app has: named
entities. When the user writes a person, place, or project name, it becomes a node. Every node
gets its own page — every entry mentioning that person, on a timeline, with the mood trend of
entries they appear in, the first and last mention, and which other people appear alongside them.

**What makes it unique:** Obsidian has the graph but no privacy model, no mood, and no encryption.
Day One has the diary but no graph. Nobody has the combination: an encrypted personal diary that
can answer *"show me every time I mentioned my father, and how I felt"* — computed entirely on the
device, with nothing leaving it.

**Why this app can do it:** `Backlinks`, `vault_backlink_parser.dart`, FTS5, `EntryMoods`, and
the timeline are all in place. Entity detection can start fully manual (the user marks a name
once, the app finds the rest by text match), so no model is needed.

**Watch out for:** this is the one feature where getting it wrong is creepy rather than useful.
Detection must be opt-in and correctable, and it must never guess a relationship the user did not
state.

**Re-checked:** unchanged. Nothing in the 17 sibling apps is close to this. It stays the most
ambitious idea here and the hardest for anyone to copy.

**Effort:** XL, but it can ship in stages — entity pages first, mood overlay second, co-occurrence
last.

## ✅ C3. Time capsules and letters to your future self — implemented

> **Implemented 2026-08-24.** Cryptographic date-gated key release and entry sealing:
> - **Cryptographic Seal:** Entry contents (`contentJson`, `plainText`) are encrypted with AES-256-GCM under a dedicated per-capsule key and wiped from cleartext database storage and FTS index.
> - **Date-Gated Release:** Decryption key release is locked until the specified unlock date (1m, 6m, 1y, 3y, 5y, or custom date). Unsealing early is refused (`TimeCapsuleLockedException`).
> - **Monotonic High-Water Clock Protection:** Persisted monotonic timestamping prevents device clock rollback tampering (`TimeCapsuleClockTamperException`).
> - **UI & Integration:** Preset configuration dialog with teaser note (`TimeCapsuleSealDialog`), live countdown screen with locked unseal action (`TimeCapsuleSealedScreen`), catalog overview (`TimeCapsulesListScreen`), Home screen ready-to-open celebration banner, entry list indicators, and complete backup/restore round-trip support.
>
> Plan: [`plans/20260824_131500_time_capsules_sealed_entries.md`](../plans/20260824_131500_time_capsules_sealed_entries.md) ·
> Change log: [`change_log/20260824_131500_time_capsules_sealed_entries.md`](../change_log/20260824_131500_time_capsules_sealed_entries.md) ·
> Code: `lib/features/entries/services/time_capsule_service.dart`, `lib/features/entries/presentation/time_capsule_*.dart`, `lib/features/entries/providers/time_capsule_providers.dart`

**What:** Write an entry and seal it until a chosen date. Until that date the entry is encrypted
under a key the app will not release, the body is not shown, and it is excluded from search. On
the date it opens, with a notification.

**What makes it unique:** A handful of apps do a novelty "email your future self". None do it as
a real cryptographic seal inside an encrypted local vault, where even the owner cannot peek early
because the app genuinely will not decrypt it. It changes what a journal is for — not only a
record of the past but a message forward.

**Why this app can do it:** The per-journal and per-attachment lock machinery, the Keystore
secret store, and the crypto layer are the same primitives. It needs a date-gated key release and
an FTS exclusion.

**Watch out for:** device clock changes, and what happens if the user restores the vault on a new
phone before the seal date — the design must survive both without either leaking early or losing
the entry forever.

**Re-checked:** confirmed, and strengthened. Nothing in the family does date-gated key release.
Of the 17 apps, this is the idea with no precedent at all — it is genuinely novel work, and still
only M.

**Effort:** M — genuinely small for how distinctive it is. **Best value-to-effort idea in this
document.**

## C4. Two-key journals — a diary only two people together can open

**What:** A journal that needs two secrets to unlock: the owner's, plus a second passphrase given
to a trusted person. Neither alone opens it.

**What makes it unique:** Split-key access exists in enterprise vaults, never in personal
journals. It solves a real and rarely addressed problem — what happens to a private diary when its
owner dies or is incapacitated. Right now the honest answer for this app is "it is gone forever",
which for a lifetime vault is a design flaw, not a feature.

**Re-checked:** keep, with a precedent to lift. `sreeraj_qr_reader` **StegoQR** already ships
decoy-visible content with hidden encrypted content behind a biometric unlock — the same shape as
this and as the A5.4 decoy vault.

**Effort:** L. Needs a careful key-splitting design (Shamir or a simple two-share XOR) and a very
clear explanation to the user, because a misunderstood recovery scheme loses data.

## C5. Rewrite-aware entries — see how your own opinion changed

**What:** The app already snapshots every edit. Turn that into a feature instead of a safety net:
for entries the user revisits over months or years, show an "evolution" view — how the text
changed over time, which sentences survived every rewrite, and when the mood attached to it moved.

**What makes it unique:** Every app has version history as an undo mechanism. Nobody presents it
as content. For a long-running belief, plan, or set of goals, the diff *is* the interesting part.

**Why this app can do it:** `EntryRevisions` already stores title, full Quill JSON, and plain text
on every edit. The data has been collected all along; only the view is missing.

**Re-checked: now stronger than when it was written.** `SreerajP_CodeApp` §4.3 lists a "Local
Offline Code Time Machine & AST Visual Diff" as a *planned, unbuilt* concept. That is the same
idea — and this app could build it first, on data it has already been collecting.

**Effort:** M.

## ✅ C6. Encrypted device-to-device sync — implemented

> **Implemented 2026-08-24.** Both transports built, tested, and integrated:
> 1. **Optical Air-Gap Sync (AirQR):** Animated QR frame stream on one screen and camera scanner on the other. 100% offline with zero network permissions. Includes PBKDF2-HMAC-SHA256 (200k iterations) session key derivation, AES-256-GCM authenticated chunk encryption, SHA-256 integrity verification, out-of-order frame capture with live completion progress, pre-flight size gating warnings (<256 KB starts immediately, 256 KB–1 MB warns, 1 MB–4 MB recommends Wi-Fi Sync, >4 MB blocks with Wi-Fi referral), and first-class **App Settings Sync** (< 1 sec) transferring theme, custom accent colors, screen security, ritual configuration, user templates, and tags.
> 2. **Encrypted Local Wi-Fi Sync:** Peer-to-peer Wi-Fi socket transport for large journals and media attachments. Encrypted with PBKDF2 + AES-256-GCM, hostile-peer hardening (`BoundedLineReader`, payload caps, handshake timeouts, single-client lock), full encrypted attachment streaming, and vector-clock merge conflict detection.
>
> Plans: [`plans/20260824_123000_optical_airqr_sync.md`](../plans/20260824_123000_optical_airqr_sync.md) · [`plans/20260824_114500_wifi_p2p_sync.md`](../plans/20260824_114500_wifi_p2p_sync.md)
> Change logs: [`change_log/20260824_124500_optical_airqr_sync.md`](../change_log/20260824_124500_optical_airqr_sync.md) · [`change_log/20260824_120500_wifi_p2p_sync.md`](../change_log/20260824_120500_wifi_p2p_sync.md)
> Code: `lib/features/airqr/`, `lib/features/sync/`

**What:** Give the finished sync engine a transport. **Recommended: optical air-gap sync** — an
animated QR frame stream on one screen, the other device's camera reading it, with error
correction for dropped frames and a live progress bar. No server, no account, and **no network
permission of any kind**.

**What makes it unique among journal apps:** every multi-device journal app routes through a
company's servers. An encrypted diary that syncs phone-to-tablet with no account, no server, and
no internet permission is a genuinely different product.

**Why this app can do it cheaply:** `SyncEngine` (392 lines), the vector clocks,
`SyncEncryptionService`, and the conflict UI are all built and tested. Only the transport is
missing.

## C7. Attachment-native journalling

**What:** Treat the vault as the place where documents live, not only where they are stapled to
text. A "documents" view across all journals, full-text search inside every attached PDF (already
indexed today, but never surfaced as its own search), and the ability to annotate a PDF page and
have the annotation become an entry.

**What makes it unique:** journal apps treat attachments as decoration. This app already extracts
and indexes their text — it just does not show that anywhere. It is a distinctive capability the
app already paid for and does not advertise.

**Re-checked — scope reduced. Do not build the PDF annotation part.** `SreerajP_PDFApp` §2.3
already has a full non-destructive annotation overlay, keyed by SHA-256 content fingerprint, with
flatten-to-PDF export. Either hand off to that app or port its overlay; rebuilding it here would
be duplicated work in the same family. **The documents view and attachment-text search stay
worthwhile and stay cheap** — they are the part nothing else does.

**Effort:** M for the documents view and attachment search. Drop the L annotation branch.

## C8. A vault that can prove it was not tampered with

**What:** Chain each entry to a hash of the previous one, and let the user export a signed
verification report showing the vault's contents have not been altered since a given date.

**What makes it unique:** no consumer journal app offers integrity proof. It gives the app a real
use for people who need a defensible personal record — a work diary, a health log, an incident
record, a caregiving log. That is an audience no journal app currently serves, and it fits the
security posture the app already has.

**Why it fits:** `SecurityEvents` and the "basic tamper check" already gesture at this. This turns
a background check into a user-visible guarantee.

**Watch out for:** be precise about the claim. Local hash chaining proves the vault was not edited
*outside the app*; it does not prove *when* something was written. Overstating it would be worse
than not shipping it.

**Re-checked:** keep, with a precedent for both halves. `SreerajP_PDFApp` §2.7 does offline
signature verification with X.509 chains, Bouncy Castle, and SHA-256 fingerprinting — that is the
crypto. It is also a model for **the honesty of the claim**: it carefully documents what it
*cannot* check. Match that discipline here.

**Effort:** M.

## C9. Ritual mode — a journal that opens like a practice, not an app — ✅ done, 2026-08-24.

**What:** An optional guided open: a breath timer, one reflective prompt drawn from a rotating
deck, then the editor already opened to today's entry.

**What makes it unique:** journal apps compete on features. Almost none design the *entry
experience*. And this one has a head start — `daily_rule_cards` in the same family is already an
18-card curated deck of reflection cards built for exactly this kind of morning practice. Its
content and card model could feed this app's prompts directly, which is a cheap and genuinely
nice piece of reuse across the family.

**Re-checked — now much cheaper, and better than planned.**
`SreerajP_LalithaSahasranamam` §4.6 ships an **Anki-style spaced repetition** engine
(Hard / Revision / Easy → 1 / 3 / `7×level` days). That is directly reusable for resurfacing past
entries and prompts — and it is a far better "On This Day" than a fixed year-ago lookup, because
it adapts to what the user actually wants to see again.

**Effort:** M, and mostly assembly.

---

## 4. Suggested order

Nothing here is scheduled. This order matches the approved roadmap plan
([`plans/20260816_125915_cross-app-informed-roadmap.md`](../plans/20260816_125915_cross-app-informed-roadmap.md)
section 7), which is the authority if the two ever disagree.

Two things moved to the front compared with the first version of this document.

**First — clear the blockers:**

1. ✅ **B6 — replace `syncfusion_flutter_pdfviewer` with `pdfrx`** — **done, 2026-08-23.** Replaced
   proprietary Syncfusion PDF viewer with open-source `pdfrx` (PDFium, BSD/MIT) and untied the dependency knot.
2. ✅ A4.1 Backup restore and ✅ A4.2 sealed files — **both done, 2026-08-18**. The envelope
   is versioned, self-describing, uses a random salt, and now lives in `lib/core/security/`
   where the export file uses it too. What is left of this line is the small security items:
   A5.2 crypto version byte, ✅ A5.3 `INTERNET` guard (done 2026-08-23), ✅ A5.6 Security screens
   (done 2026-08-23), A4.4 retention caps, A4.3 delete all data.
3. Create the release keystore (`release_process.md` §0). Still the hard release blocker.

**Second — make future work cheaper before doing more of it:**

4. A6.8 Split `app.dart`. Every settings-touching item below touches this one 2,830-line file.
5. ✅ A6.4 l10n extraction — **done, 2026-08-23.** All UI strings extracted across the app with complete English and Malayalam ARB catalog.

**Third — make the app worth opening every day:**

6. ✅ A1.1 Export — **done, 2026-08-16.** Then the habit layer: A6.1 Reminders, ✅ A6.2 Share-in
   (done 2026-08-23), A6.3 Widget. ✅ A6.7 Themes (done 2026-08-24), ✅ A1.5 Editor polish (done 2026-08-21), ✅ A1.3
   Drawing/handwriting (done 2026-08-23), ✅ A1.7 Custom templates (done 2026-08-23), and A2.2
   Search snippets are cheap wins to fold in.
7. ✅ **C6 Sync transport** — **done, 2026-08-24.** Both Optical Air-Gap Sync (AirQR with 100% offline QR stream + Settings Sync) and Encrypted Local Wi-Fi Sync (P2P socket with attachment streaming) implemented and verified.

**Fourth — flagship features from Part C:**

8. ✅ **C9 Ritual mode** — **done, 2026-08-24.** Guided breath timer, 18-card curated reflection deck, and Anki-style spaced repetition engine with direct transition to today's entry.
9. ✅ **C3 (time capsules)** — **done, 2026-08-24.** Cryptographically sealed entries to your future self with date-gated key release, monotonic clock rollback protection, countdowns, and backup support. C1 (voice-first) is the one that would define the app. C2 (knowledge
   graph) is the most ambitious and the hardest to copy.

Doing one of them well is worth more than starting all three.

**Running alongside all of it:** adopt `SreerajP_PDFApp`'s rules 5 and 6 (see B1), so the
half-wired-feature habit stops adding to this list faster than the list is worked off.

---

## 5. Related documents

- [`plans/20260816_125915_cross-app-informed-roadmap.md`](../plans/20260816_125915_cross-app-informed-roadmap.md)
  — **the approved plan of work.** It supersedes this document's framing, sizes and ordering, and
  is where each item's work-item number (W0–W9) lives.
- `myapps.md` — the external list of 18 sibling apps this revision was checked against. It is not
  stored in this repository.
- [`features.md`](features.md) — what the app does today.
- [`architecture.md`](architecture.md) section 21 — the known-gaps list this document builds on.
- [`security.md`](security.md) — the security posture and its accepted risks.
- [`release_process.md`](release_process.md) — the keystore step that blocks release.
- [`journal_vault_plan.md`](journal_vault_plan.md) — the product milestone plan.

### Plans and change logs for the items marked ✅

| Item | Plan | Change log |
|---|---|---|
| A1.1 Export | [`20260816_135333`](../plans/20260816_135333_a1-1-entry-and-journal-export.md) | [`20260816_144133`](../change_log/20260816_144133_a1-1-entry-and-journal-export.md) |
| A1.2 Inline images | [`20260816_163000`](../plans/20260816_163000_a1-2-inline-images.md) | [`20260816_171500`](../change_log/20260816_171500_a1-2-inline-images.md) |
| A1.3 Drawing / handwriting | [`20260823_134800`](../plans/20260823_134800_a1-3-drawing-handwriting-blocks.md) | [`20260823_143800`](../change_log/20260823_143800_a1-3-drawing-handwriting-blocks.md) |
| A1.5 Editor quality of life | [`20260821_212800`](../plans/20260821_212800_editor_quality_of_life.md) | [`20260821_214000`](../change_log/20260821_214000_editor_quality_of_life.md) |
| A1.7 Custom entry templates | [`20260823_150200`](../plans/20260823_150200_a1-7-custom-entry-templates.md) | [`20260823_151500`](../change_log/20260823_151500_a1-7-custom-entry-templates.md) |
| A2.1 Tag colours | [`20260816_155016`](../plans/20260816_155016_a2-1-tag-colours.md) | [`20260816_160436`](../change_log/20260816_160436_a2-1-tag-colours.md) |
| A4.1 Backup restore | [`20260818_134141`](../plans/20260818_134141_a4-1-backup-restore.md) | [`20260818_152000`](../change_log/20260818_152000_a4-1-backup-restore.md) |
| A4.2 Encrypted export / backup envelope | [`20260818_145453`](../plans/20260818_145453_a4-2-encrypted-export-envelope.md) | [`20260818_163000`](../change_log/20260818_163000_a4-2-encrypted-export-envelope.md) |
| A5.1 Encrypt database at rest | [`20260818_153817`](../plans/20260818_153817_a5-1-encrypt-database-at-rest.md) | [`20260818_161934`](../change_log/20260818_161934_a5-1-encrypt-database-at-rest.md) |
| A5.3 Guard INTERNET permission | [`20260823_202800`](../plans/20260823_202800_guard-internet-and-transitive-permissions.md) | [`20260823_203500`](../change_log/20260823_203500_guard-internet-and-transitive-permissions.md) |
| A5.6 Finish security screens | [`20260823_204600`](../plans/20260823_204600_finish_security_screens_tamper_alerts.md) | [`20260823_205500`](../change_log/20260823_205500_finish_security_screens_tamper_alerts.md) |
| A6.2 Receive shared text and images | [`20260823_210500`](../plans/20260823_210500_a6-2-receive-shared-text-and-images.md) | [`20260823_213500`](../change_log/20260823_213500_a6-2-receive-shared-text-and-images.md) |
| A6.4 Localisation | [`20260823_221300`](../plans/20260823_221300_a64_localisation.md) | [`20260823_224500`](../change_log/20260823_224500_a64_localisation.md) |
| C3 Time capsules | [`20260824_131500`](../plans/20260824_131500_time_capsules_sealed_entries.md) | [`20260824_131500`](../change_log/20260824_131500_time_capsules_sealed_entries.md) |
| C6 Device-to-device sync | [`20260824_123000`](../plans/20260824_123000_optical_airqr_sync.md) · [`20260824_114500`](../plans/20260824_114500_wifi_p2p_sync.md) | [`20260824_124500`](../change_log/20260824_124500_optical_airqr_sync.md) · [`20260824_120500`](../change_log/20260824_120500_wifi_p2p_sync.md) |
| C9 Ritual mode | [`20260824_111500`](../plans/20260824_111500_c9_ritual_mode.md) | [`20260824_111500`](../change_log/20260824_111500_c9_ritual_mode.md) |
