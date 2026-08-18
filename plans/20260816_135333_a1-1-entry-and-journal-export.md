# A1.1 — Export an entry or a whole journal (Markdown, HTML, text, PDF)

**Status:** completed

**Change log:** [`change_log/20260816_144133_a1-1-entry-and-journal-export.md`](../change_log/20260816_144133_a1-1-entry-and-journal-export.md)

**Approved:** 2026-08-16, with one change — every user-visible string this feature adds goes in a
single constants file (`lib/features/export/export_strings.dart`), so the later l10n extraction
(A6.4 / W8) is a one-file job for this feature instead of a hunt through the screens. See
section 4a.

**Implements:** `docs/enhancement_ideas.md` A1.1, and work item W6 in
[`plans/20260816_125915_cross-app-informed-roadmap.md`](20260816_125915_cross-app-informed-roadmap.md).

---

## 1. The issue

The app can read data in but never writes it out.

- `lib/features/import/` has three adapters (plain text, Markdown, DOCX).
- Nothing anywhere in `lib/` turns an entry back into a file.
- The only other way out is a backup archive, and `backup_service.dart` cannot restore it.

For an app whose main promise is "your data is yours and stays local", this is the promise least
kept. `docs/enhancement_ideas.md` section B2 calls it "a nicer prison". This plan fixes the export
half. Restore (A4.1) is a separate plan.

## 2. What will be built

Export from three places, in four formats, over three scopes.

**Formats**

| Format | File | How it is made |
|---|---|---|
| Markdown | `.md` | Quill delta → Markdown text |
| HTML | `.html` | Quill delta → one self-contained HTML page |
| Plain text | `.txt` | Quill delta → text, embeds flattened |
| PDF | `.pdf` | the same HTML, rendered by a native Android WebView |

**Scopes**

- One entry.
- A whole journal.
- A date range inside a journal.

**Options**

- Include attachments — decrypted copies written into an `attachments/` folder in the bundle.
- Include entry metadata (date, tags, mood) as a small header block. On by default.

**How the file is delivered**

- One entry, no attachments → a single file.
- Anything else → a `.zip` bundle, built with the `archive` package the app already has.
- Both are written through `FilePicker.saveFile`, the same scoped-storage save dialog the app
  already uses. No storage permission is asked for, and a Malayalam file name survives.

## 3. Why PDF is done this way

`docs/enhancement_ideas.md` points at `SreerajP_lyricchord` §2.9 as the strongest PDF route in the
app family, and this plan ports it rather than designing a new one.

The lyricchord method: build one self-contained HTML page with the fonts embedded as base64
`@font-face` data URIs, then hand it to a real Android `WebView` that is **attached to the window**
and print it to PDF through `PrintDocumentAdapter`.

Why it is the right one here:

- **Malayalam shapes correctly.** The platform WebView does the text shaping — chillu, conjuncts,
  reordered vowel signs. Journal entries may contain Malayalam.
- **The PDF text stays real and selectable**, not an image.
- **It stays offline.** The WebView has `blockNetworkLoads = true` and `allowFileAccess = false`,
  and the HTML has no URL in it at all — the fonts are inside the page as data URIs. This keeps the
  app's no-network promise (A5.3) intact.
- **No new pub dependency.** `printing` and `pdf` are not added. That matters because this app's
  `pubspec.yaml` already carries a documented dependency knot (`win32` / `file_picker`), and
  because `SreerajP_PDFApp`'s hard rules push against pulling in heavy PDF SDKs.

The lyricchord version also measures the widest lyric line and picks a page width from it. That is
a song-sheet trick and is **not** ported. Journal pages are plain A4, so the native side here is
simpler: load, wait for the fonts, print.

## 4. Files to be changed

### New — Dart

| File | What it does |
|---|---|
| `lib/core/utils/safe_file_name.dart` | Turns a title into a safe file name. Keeps Unicode letters, so a Malayalam title survives. Ported from lyricchord. |
| `lib/features/export/services/export_format.dart` | The four formats: name, extension, MIME type. |
| `lib/features/export/services/export_scope.dart` | The scope value object: single entry / whole journal / date range, plus the options. |
| `lib/features/export/services/export_document.dart` | One prepared entry ready to write out: title, date, tags, mood, delta ops, attachment list. |
| `lib/features/export/services/export_collector.dart` | Reads the database and turns a scope into a list of `ExportDocument`s. Uses the existing DAOs only. |
| `lib/features/export/services/delta_to_markdown.dart` | Quill delta → Markdown. The mirror of `markdown_import_adapter.dart`. |
| `lib/features/export/services/delta_to_html.dart` | Quill delta → an HTML fragment. |
| `lib/features/export/services/delta_to_plain_text.dart` | Quill delta → plain text. |
| `lib/features/export/services/export_html_builder.dart` | Wraps the fragments into one self-contained HTML page: embedded fonts, print CSS, one page break per entry. |
| `lib/features/export/services/html_pdf_service.dart` | Method-channel client for the native renderer. Ported from lyricchord's `HtmlPdfService`. |
| `lib/features/export/services/attachment_export_service.dart` | Decrypts an entry's attachments into the bundle, using the existing `AttachmentCryptoStorage.decryptToTempFile`. |
| `lib/features/export/services/export_service.dart` | The orchestrator: scope → documents → format → bytes. Returns either one file or a zip. |
| `lib/features/export/providers/export_providers.dart` | Riverpod wiring, same shape as `import_providers.dart`. |
| `lib/features/export/presentation/export_screen.dart` | The screen: scope, format, options, an outcome report. |

### 4a. New — strings

| File | What it does |
|---|---|
| `lib/features/export/export_strings.dart` | Every user-visible string this feature adds, as named constants on one class. |

This is the approved change to the plan. The rest of the app writes its text straight into the
widgets, which is why the l10n extraction (A6.4 / W8) is an **L**. This feature does not add to
that pile: when the extraction happens, this file maps one-to-one onto `.arb` keys and only this
file changes for the export feature.

Rules for it:

- Every string the user can see lives here — labels, buttons, snackbars, error messages.
- The constant name is the future `.arb` key, so nothing has to be renamed later.
- Strings with a value in them are functions, not constants
  (`exportedCount(int n)`), because that is what `intl` needs anyway.
- No string is built by joining fragments, since word order changes between languages.

Log messages and `SecurityEvents` descriptions are **not** in here. They are never shown to the
user and must not be translated.

### New — Android

| File | What it does |
|---|---|
| `android/app/src/main/kotlin/android/print/JvHtmlToPdf.kt` | Renders local HTML to PDF bytes in an attached, off-screen WebView. Ported and simplified from lyricchord's `LcHtmlToPdf`. It must sit in the `android.print` package because the `PrintDocumentAdapter` result-callback constructors are package-private. |

### New — assets

| File | What it does |
|---|---|
| `assets/fonts/NotoSansMalayalam-Regular.ttf` | Malayalam font embedded into the export HTML. ~77 KB. |
| `assets/fonts/NotoSansMalayalam-Bold.ttf` | Bold weight. ~76 KB. |
| `assets/fonts/OFL-Noto.txt` | The SIL Open Font Licence text. Required by the licence. |

Copied from `SreerajP_lyricchord/assets/fonts/`. SIL OFL 1.1, so redistribution inside the app is
allowed.

### Changed

| File | Change |
|---|---|
| `pubspec.yaml` | Add `assets/fonts/` to the asset list. **No new package dependency.** |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | Add one more method channel, `in.sreerajp.sreerajp_journal_vault/html_pdf`, with a single `convertHtml` method. The file already registers four channels; this follows the same shape. |
| `lib/features/entries/presentation/entry_editor_screen.dart` | Add an export action to the app bar (a share/download icon) that exports the entry being edited. |
| `lib/app/app.dart` | Two additions: an **Export Data** tile in Settings next to **Import Data**, and an export action on the journal detail screen. The Settings journal chooser only lists journals that are open (not locked, or unlocked this session). |
| `docs/features.md` | Document the export feature. |
| `docs/architecture.md` | Add the export feature to the layout section, and remove "no export path" from the section 21 gap list. |
| `docs/security.md` | Record the export decision: what leaves the vault, that the file written out is **not** encrypted, and that the render is offline. |

### New — tests

| File | What it covers |
|---|---|
| `test/features/export/delta_to_markdown_test.dart` | Headings, bold/italic, lists, quotes, code, table embed, callout embed, voice-note embed, empty document, broken delta JSON. |
| `test/features/export/delta_to_html_test.dart` | The same cases, plus HTML escaping of `& < > "` so entry text can never break the markup. |
| `test/features/export/delta_to_plain_text_test.dart` | Embeds flatten to something readable; nothing is silently dropped. |
| `test/features/export/export_collector_test.dart` | Each scope picks the right entries; date range boundaries are inclusive; tags and mood come through. |
| `test/features/export/export_service_test.dart` | Single file vs zip; file naming; attachments land in `attachments/`; a locked attachment is skipped and reported. |
| `test/features/export/safe_file_name_test.dart` | Malayalam kept, illegal characters removed, empty title falls back. |

## 5. How each piece works

### 5.1 Reading the entries (`export_collector.dart`)

Uses only DAOs that already exist: `entriesDao.getEntriesForJournal`, `entriesDao.getEntryById`,
`journalsDao.getJournalById`, `tagsDao.getTagsForEntry`, `entryMoodsDao.getMoodForEntry`,
`attachmentsDao.getAttachmentsForEntry`. No schema change, so no database migration.

A date range filters on `Entry.entryDate`, falling back to `createdAt` when `entryDate` is null.

### 5.2 Turning a delta into text (`delta_to_*.dart`)

Entry bodies are stored as Quill delta JSON in `Entries.contentJson`. Three small pure converters
walk the ops. They are pure Dart — no Flutter, no plugins — so they are cheap to test.

The app has custom embeds that a plain converter would drop. Each is handled:

- **Table** (`table_embed.dart`, a JSON 2D list of strings) → a Markdown pipe table / an HTML
  `<table>` / aligned text.
- **Callout** (`callout_embed.dart`, `{style, text}`) → a Markdown blockquote with the style as a
  bold prefix / an HTML `<div class="callout callout-info">` / a bracketed line in plain text.
- **Any unknown embed** → a short placeholder line, never a crash. This follows
  `SreerajP_PDFApp` rule 5, "never crash on bad input", which `docs/enhancement_ideas.md` B1
  recommends this app adopt.

A `contentJson` that is null or will not parse falls back to the `plainText` column, and then to an
empty document. An export never throws because one entry is odd.

**Correction made during implementation.** This plan first said voice notes were a third custom
embed inside the document. They are not. The editor registers exactly two embed builders —
`TableEmbedBuilder` and `CalloutEmbedBuilder` (`entry_editor_screen.dart` lines 73–76). A voice note
is a **row in the `VoiceNotes` table** keyed by `entryId`, like an attachment, holding its own
encrypted file, duration and optional transcript.

So voice notes are handled by the collector, not by the delta converters:

- The collector reads them with `voiceNotesDao.getVoiceNotesForEntry`.
- Each one is listed at the end of the exported entry with its duration, and its **transcript is
  written out when there is one** — that text is the part a reader can actually use.
- The audio file is decrypted into the bundle only when "include attachments" is on, alongside the
  attachments.

### 5.3 Building the HTML (`export_html_builder.dart`)

One page holds every entry in the export, each in a `<div class="entry">` with
`page-break-after: always`, so a multi-entry PDF starts each entry on a fresh page.

The `@font-face` rules embed the two Noto Sans Malayalam files as base64 data URIs, exactly as
`pdf_export_service.dart` does in lyricchord. The font stack is
`'JvMalayalam', sans-serif` — the bundled font first (it carries Latin glyphs too), then whatever
the WebView has.

All user text is HTML-escaped.

The same builder serves the `.html` export and the PDF export, so what a user sees in a browser is
what they get on paper.

### 5.4 Rendering the PDF (`JvHtmlToPdf.kt` + `html_pdf_service.dart`)

Ported from lyricchord, minus the width-fitting:

1. Create a `WebView`, `javaScriptEnabled = true`, `blockNetworkLoads = true`,
   `allowFileAccess = false`.
2. Attach it to the activity's content view, pushed off-screen with a large `translationX`, sized
   to A4. It must be attached, or the print callbacks never fire on newer Android — that is the
   whole reason this class exists rather than `Printing.convertHtml`.
3. `loadDataWithBaseURL(null, html, ...)`. No URL is ever fetched.
4. On page finish, wait for `document.fonts.ready`, then call back into Kotlin through a tiny
   `@JavascriptInterface`. Measuring or printing before the fonts load gives wrong output.
5. Print to a temporary file in `cacheDir` at A4 with a 20 pt margin, read the bytes, delete the
   file, return the bytes.
6. A hard timeout on the native side, and a second timeout on the Dart side as a backstop, so a
   stuck render always fails with a message and never hangs.

The Dart side throws `HtmlPdfException` on failure, including `MissingPluginException` (no native
side — iOS today), so the UI can say "PDF export is not available on this device" instead of
showing a dead button.

### 5.5 Packing and saving (`export_service.dart`)

- One entry, no attachments → the raw bytes, saved as `<safe title>.<ext>`.
- Otherwise → a zip built with `archive`, laid out as:

```
<journal name>_export/
  entries/2026-08-16_my-entry.md
  entries/2026-08-15_another.md
  attachments/12_photo.jpg
  README.txt          (what this export is, when it was made, what is inside)
```

Saved with `FilePicker.saveFile(bytes: ...)`, which uses the system save dialog. Scoped storage,
no permission, and the Unicode file name is preserved — the share sheet's content URI would
percent-encode it and garble a Malayalam name, which lyricchord already hit and fixed this way.

### 5.6 The screen (`export_screen.dart`)

Takes a journal (and optionally one entry) and shows:

- what is being exported, in words;
- a format picker (Markdown, HTML, Text, PDF);
- a scope picker (this entry / whole journal / date range, with a date range picker);
- two switches: include attachments, include metadata;
- an Export button with a progress state;
- an outcome list, in the same style as `import_screen.dart`'s results list — including anything
  that was skipped and why.

PDF is shown but disabled with an explanation on a platform with no native renderer, rather than
failing after the user taps it (rule 6, "never a dead button").

## 6. Security decisions

These need to be right, because this is the feature that takes data *out* of a vault.

1. **A locked journal is never exported without being unlocked.** The Settings chooser only lists
   journals that are unlocked for this session, using the existing `_unlockedJournalIdsProvider`.
   The journal detail screen's export action already sits behind that screen's unlock gate.
2. **A locked attachment is skipped.** `AttachmentLocks` rows are checked; a locked attachment is
   left out of the bundle and named in the outcome report, so the user is never quietly given an
   incomplete export.
3. **The exported file is plain, not encrypted.** That is the point of an export, but the screen
   must say so in one plain sentence, and `docs/security.md` must record it.
4. **Every export is logged.** A row goes into `SecurityEvents` with type `export_attempt` — a type
   the table's own documentation already lists but that nothing writes today. The log records the
   scope, format and entry count. **It never records entry content.**
5. **Nothing goes near the network.** No new dependency, no `INTERNET` permission, network loading
   blocked in the WebView, and no URL in the HTML.
6. **Temporary files are cleaned up.** Decrypted attachment copies go through the existing
   `AttachmentTempFileManager` and are deleted when the export finishes or fails.

## 7. What is deliberately not in this plan

- **Restore** — that is A4.1 and needs its own plan.
- **Encrypting the exported file** — belongs with A4.2's envelope work, so both use one format.
- **Share-sheet hand-off** — save first. Sharing can be added later without changing anything here.
- **Exporting across every journal at once** — one journal at a time keeps the lock rules simple.
- **iOS PDF** — the native renderer is Android only. The other three formats work everywhere.

## 8. Order of work

1. `safe_file_name.dart` + its test.
2. The three delta converters + their tests. Pure Dart, no plugins — this is the bulk of the
   logic and all of it is testable without a device.
3. `export_collector.dart`, `export_document.dart`, `export_scope.dart` + tests.
4. `export_html_builder.dart` with the fonts, plus the pubspec asset entry.
5. `export_service.dart` with zipping and attachments + tests.
6. The Kotlin renderer and `html_pdf_service.dart`.
7. `export_screen.dart` and the three entry points.
8. Docs: `features.md`, `architecture.md`, `security.md`.
9. The change log under `change_log/`.

Steps 1–5 and 8–9 are device-free. Only steps 6–7 need a device to check.

## 9. Risks

| Risk | Handling |
|---|---|
| The WebView print callbacks hang. | This is the exact bug lyricchord hit and fixed by attaching the WebView. Two timeouts on top. |
| Malayalam still comes out as boxes. | The font is embedded in the page, and the render waits for `document.fonts.ready`. Must be checked on a device with a real Malayalam entry before this is called done. |
| A very large journal makes a huge PDF. | The render is timed out and fails with a message. If it turns out to be a real limit, a later change can page the export; not designed for now. |
| Adding ~155 KB of fonts to the APK. | Accepted. It is the price of correct Malayalam in a PDF, and it is the same trade lyricchord already made. |
| The export becomes another half-wired feature (B1). | Every entry point is wired in this plan, and an integration test drives the screen end to end. |

---

## 10. Do you approve this plan?

Nothing outside this file will be changed until you say yes.
