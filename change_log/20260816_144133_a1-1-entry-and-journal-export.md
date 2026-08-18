# Change log — A1.1 entry and journal export

**Date:** 2026-08-16
**Implements:** [`plans/20260816_135333_a1-1-entry-and-journal-export.md`](../plans/20260816_135333_a1-1-entry-and-journal-export.md)
**Plan status:** completed

---

## What changed, in one line

The app can now write entries back out — as Markdown, HTML, plain text, or PDF — for one entry, a
whole journal, or a date range, with optional attachments.

## Why

The app imported but never exported. Nothing in `lib/` turned an entry back into a file, so the
only way out was a backup archive that cannot yet be restored. `docs/enhancement_ideas.md` B2
called this the promise the app kept least: "local data you cannot extract is not sovereignty; it
is a nicer prison."

## Approved changes to the plan

Two, both recorded in the plan file itself.

1. **Strings live in one file.** The user approved the plan with the condition that every new
   user-visible string go in a single constants file, so the later localisation work (A6.4 / W8) is
   a one-file job for this feature instead of a hunt through the screens. That file is
   `lib/features/export/export_strings.dart`.

2. **A correction found during implementation.** The plan said voice notes were a third custom
   Quill embed. They are not — the editor registers exactly two embed builders (table, callout),
   and a voice note is a row in the `VoiceNotes` table keyed by `entryId`. Voice notes are
   therefore handled by the collector, not the delta converters. Their **transcripts are written
   out as text** whether or not the audio is included, because a transcript is content.

## Files added

### Dart — the feature

| File | What it does |
|---|---|
| `lib/core/utils/safe_file_name.dart` | Title → safe file name. Keeps Malayalam letters; caps at 120 UTF-8 bytes without splitting a character. |
| `lib/features/export/export_strings.dart` | Every user-visible string, ready for ARB extraction. |
| `lib/features/export/services/delta_document.dart` | Parses a Quill delta into blocks. The shared foundation all three text renderers walk. |
| `.../delta_to_markdown.dart` | Blocks → Markdown. The mirror of `markdown_import_adapter.dart`. |
| `.../delta_to_html.dart` | Blocks → an HTML fragment, everything escaped. |
| `.../delta_to_plain_text.dart` | Blocks → plain text, nothing dropped. |
| `.../export_format.dart` | The four formats and their properties. |
| `.../export_scope.dart` | What an export covers. |
| `.../export_document.dart` | The prepared entry, attachment, and voice-note shapes. |
| `.../export_collector.dart` | The only part that reads the database. |
| `.../export_html_builder.dart` | The self-contained HTML page: embedded fonts, print CSS, one page break per entry. |
| `.../html_pdf_service.dart` | Method-channel client for the native renderer. |
| `.../export_service.dart` | Orchestrator: renders, decrypts attachments, zips, reports omissions. |
| `lib/features/export/providers/export_providers.dart` | Riverpod wiring. |
| `lib/features/export/presentation/export_screen.dart` | The screen. |

### Android

| File | What it does |
|---|---|
| `android/app/src/main/kotlin/android/print/JvHtmlToPdf.kt` | Renders local HTML to PDF in an attached, off-screen, network-blocked WebView. |

### Assets

`assets/fonts/NotoSansMalayalam-Regular.ttf`, `-Bold.ttf`, and `OFL-Noto.txt` (~155 KB total),
copied from `SreerajP_lyricchord`. SIL Open Font Licence 1.1; the licence text ships beside them as
the licence requires.

### Tests — 152 new

| File | Tests |
|---|---|
| `test/core/utils/safe_file_name_test.dart` | 10 |
| `test/features/export/delta_document_test.dart` | 26 |
| `test/features/export/delta_to_markdown_test.dart` | 26 |
| `test/features/export/delta_to_html_test.dart` | 25 |
| `test/features/export/delta_to_plain_text_test.dart` | 14 |
| `test/features/export/export_collector_test.dart` | 18 |
| `test/features/export/export_service_test.dart` | 20 |
| `test/features/export/export_screen_test.dart` | 13 |

## Files changed

| File | Change |
|---|---|
| `pubspec.yaml` | Added `assets/fonts/` to the asset list. **No new package dependency.** |
| `android/.../MainActivity.kt` | Added the `sreerajp.journal_vault/html_pdf` channel with `convertHtml` and `isAvailable`. |
| `lib/features/entries/presentation/entry_editor_screen.dart` | Export action in the app bar. Saves first if the entry is dirty, so what is exported is what is on screen. |
| `lib/app/app.dart` | Export action on the journal detail app bar, and an "Export Data" tile in Settings next to "Import Data". |
| `docs/features.md` | Documented the feature, the new method channel, and updated the summary paragraph. |
| `docs/architecture.md` | New "Closed on 2026-08-16 — export" subsection in section 21, with the design decisions and what stays deferred. |
| `docs/security.md` | Rewrote section 14's plaintext-export policy, added the controls table and accepted residual risks, added open risk 8, and updated the review date. |
| `test/features/about/about_screen_test.dart` | **Unrelated pre-existing failure, fixed on request.** An uncommitted change had renamed the fallback app name from `SreerajP_Journal_Vault` to `SreerajP Journal Vault`; the test still expected the old value. |

## How the pieces work

### PDF

Ported from `SreerajP_lyricchord` §2.9 rather than designed fresh. A self-contained HTML page is
handed to a real Android `WebView` that is **attached to the window** and printed through
`PrintDocumentAdapter`.

Two reasons it is done this way:

- **Malayalam needs real text shaping** — chillu, conjuncts, vowel signs that reorder around their
  consonant. The platform WebView does that, and the PDF keeps selectable text rather than a
  picture of it.
- **The WebView must be attached** or the print callbacks never fire on newer Android. That is why
  `JvHtmlToPdf` exists instead of `Printing.convertHtml`, which hangs forever.

The lyricchord version also measured the widest line to pick a page width. That is a song-sheet
trick and was **not** ported: a journal page is prose and wants ordinary A4.

### Offline

Enforced twice. The page embeds its fonts as base64 data URIs so it holds no URL at all, and the
WebView sets `blockNetworkLoads` with file and content access off. The first matters most — the
`.html` export is opened in the user's own browser, where this app's WebView settings do not apply.

### Output shape

One entry with nothing attached is a single file. Anything else is a zip:

```
entries/2026-08-15_my-entry.md
attachments/12_photo.jpg
README.txt
```

Saved through the system save dialog, so no storage permission is asked for and a Malayalam file
name survives. HTML and PDF put every entry in one document with a page break between them;
Markdown and plain text write one file per entry.

## Security decisions

- **Explicit confirmation before any plaintext export.** `docs/security.md` section 14 already
  said no plaintext export should be added "without an explicit user confirmation step." The
  passive warning card on the screen was not enough to meet that, so a confirmation dialog naming
  the entry count and format was added, and is covered by tests.
- **Locked journals** are not offered in the Settings picker; they must be unlocked on their own
  screen, which is the only place that asks for the password.
- **Locked attachments are never decrypted.** The lock is checked before the file is touched, and
  the omission is named in the outcome list rather than hidden.
- **Plaintext lifetime is bounded.** Each attachment is decrypted, copied in, and its temporary
  file released immediately — never more than one plaintext file in the cache at a time. The
  native side deletes its temporary PDF as soon as the bytes are read.
- **Every export is audited.** A `SecurityEvents` row of type `export_attempt` records scope,
  format, journal id, entry count, and skipped count — never entry content, titles, or file names.
  That event type was documented in the table but written by nothing until now.

## Robustness

`SreerajP_PDFApp` rule 5 — never crash on bad input — was applied to the parser. Corrupt delta
JSON falls back to the `plainText` column; an unknown embed becomes a named placeholder rather
than vanishing; attributes of a surprising type are ignored. A ten-year journal must not become
unexportable because one entry holds an op this build has never seen.

Rule 6 — never a dead button — was applied to PDF. Where the native renderer is missing the option
is shown disabled with a reason, and the other three formats still work.

## Verification

- `flutter analyze` — **no issues**, whole project.
- `dart format --set-exit-if-changed lib test integration_test` — **exits 0**.
- `flutter test` — **442 passing, 0 failing.** The suite was 290 before this change, of which one
  was failing: the pre-existing About test, fixed here on request. 152 tests were added.
- `flutter build apk --debug --flavor dev` — **succeeds**, so the new Kotlin compiles and links.

## Not verified — needs a device

The PDF path has no automated coverage below the method channel, because it needs a real WebView.
Before this feature is called done, on a device:

1. Export an entry containing **Malayalam** as PDF and confirm the text shapes correctly and can
   be selected in a PDF reader.
2. Export a whole journal as PDF and confirm each entry starts on a fresh page.
3. Export with attachments and confirm the zip opens and the files are intact.
4. Confirm a locked attachment is left out and named in the outcome list.
