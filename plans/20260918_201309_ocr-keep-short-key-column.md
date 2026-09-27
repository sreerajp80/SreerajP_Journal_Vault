# Plan — Keep short "key" words in two-column OCR tables

**Status:** completed
**Change log:** `change_log/20260918_205637_ocr-early-stop-after-two-modes.md`
**Note:** The revised version was implemented.
**Date:** 2026-09-18
**Follows:** `plans/20260918_074147_ocr-noise-regression-fix.md`

## Revision (after desktop testing) — the real cause

The first version of this plan (kept below for the record) was approved and
built, but a desktop test showed its diagnosis was wrong.

Test setup: Tesseract 5.5 from conda-forge in a temporary folder outside the
repository, the app's own `assets/tessdata` models, and a Python copy of the
Kotlin pipeline. Input: a clean screenshot of the same cheat sheet. It showed
the same bug as the phone photo, so the photo quality is not the cause.

What Tesseract returned, pass by pass:

| Pass | Keys returned? | Mean confidence | Score |
|---|---|---|---|
| Page mode "auto" (PSM 3), tried first | **None at all** | 92 | 2975 |
| Page mode "single block" (PSM 6) | All, on the line of their meaning (`q` at 92) | 88 | 3608 |
| Page mode "sparse text" (PSM 11) | A few | 90 | 3307 |

- The keys are never dropped by our junk-line filter. The auto page mode's
  layout step throws the column of small, lone letters away before
  recognition, so they never reach our code.
- The single-block pass reads them well and scores higher, but **it never
  runs**. The auto pass passes the early-stop test (mean ≥ 85 and
  mean × words ≥ 2400), so the reading ends after the first pass. The code
  comment on the early stop already warns that a long main block can reach the
  score "even when a heading or a column was missed". Here it happened.

### Revised fix

1. **The early stop may only fire once at least the first two page modes
   (auto and single block) have run.** They fail in different ways: auto finds
   columns but can drop lone short words; single block keeps every row. Sparse
   text is still skipped on a confident page. The best score still wins.
   The rule goes into a small pure function (`canStopEarly`) in a new file
   `OcrPassRules.kt`, with a JUnit test.
2. **Revert the first version's code** — the key-line filter
   (`OcrLineFilter.kt`), the table-row merge in `OcrReadingOrder.kt`, and their
   tests. The test showed they do not fix this bug, and the project rules ask
   for small, scoped changes. They can come back later if a real scan needs
   them.

Desktop result with only fix 1 (old line filter): every key comes back, each
on the line of its meaning (`q Quit`, `-N Line numbers`, `Ctrl+C Stop …`).
What is left are ordinary misreads: `j`→`3`, `?pat`→`2pat`, `-S`→`-s`,
`-i`→`=`, `+G`→`+6`.

**Cost:** a clean page that used to stop after one pass now takes two. That
is one more Tesseract pass per scan on clean pages; pages that were not
confident already ran every pass, so they do not change.

### Revised files

| File | Change |
|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OcrPassRules.kt` | New: `canStopEarly`, `MIN_PASSES_BEFORE_EARLY_STOP = 2`, and the early-stop constants moved here |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | `runPasses` uses `canStopEarly`; first-version edits reverted |
| `android/app/src/test/kotlin/in/sreerajp/sreerajp_journal_vault/OcrPassRulesTest.kt` | New tests |
| `OcrLineFilter.kt`, `OcrLineFilterTest.kt` | Deleted (first version, not needed) |
| `OcrReadingOrder.kt`, `OcrReadingOrderTest.kt` | First-version additions reverted |
| `docs/architecture.md` | Section 14: early stop needs two page modes |

### Revised acceptance criteria

- The cheat sheet returns every key on the line of its meaning (desktop
  check above; to be confirmed on the phone).
- A confident clean page still stops early, after the second mode.
- The moiré screen fix from this morning is unchanged (the line filter is
  back to exactly how it was).

---

## First version (superseded)

## The issue

A photo of a screen showing a cheat sheet was scanned. The page is a
two-column table: a short key on the left (`q`, `Space`, `b`, `j`, `/pat`,
`-N`, `+G` …) and its meaning on the right (`Quit`, `Page down` …).

The text returned kept every meaning but lost **every key**. The only key that
survived is `Ctrl+C` (read as `CtrlsC`), and it came out on the same line as
its meaning: `CtrlsC Stop follow/search operation`.

## Why it happens

All of this is in the native Tesseract code in `MainActivity.kt`
(`collectConfidentText` and `runPasses`). No Dart code filters OCR text.

1. **The key sits on a line of its own.** The gap between a short key and its
   meaning is wide, so Tesseract reads the key column as separate lines, each
   holding one short word such as `q`. `Ctrl+C` is wider, so its gap is small,
   and Tesseract joined it to its meaning. That is why it alone survived.
2. **The junk-line filter drops those lines.** Added today to remove screen
   moiré, it drops a line when its average confidence is under 35 **and** no
   word reaches 60. A one-letter word in bold monospace on a photo of a screen
   gets a low confidence, so a line holding only `q` or `-N` meets both tests
   and is dropped — on English pages too.
3. **The score also pushes the keys out.** Each kept word adds
   `confidence − 45` to the score. A low-confidence key therefore *lowers* the
   score, so a pass that found the keys (for example sparse-text mode) loses to
   a pass that did not.
4. **Even if kept, keys would be in the wrong place.** They would come out as a
   block of keys followed by a block of meanings, not `q Quit`. Nothing puts a
   key back on the same row as its meaning.

Point 2 is the most likely main cause. I cannot prove it without the photo on
a real device, but it matches the output exactly: every one-word line is gone,
the one joined line is kept.

## The fix

### 1. Do not treat a short "key-like" line as noise

New pure Kotlin function in a new file
`android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OcrLineFilter.kt`,
so it can be unit tested on the PC like `OcrReadingOrder.kt`.

A line is kept, even with low confidence, when **all** of these hold:

- it has at most 2 words;
- each word is at most 12 characters, uses only letters, digits and the
  signs common in keys and options (`+ - / ? . : _ = < > ~ ^ *`), and holds
  at least one letter or digit;
- its height is between 0.6× and 1.6× the median height of the page's
  confident lines (any word ≥ 60). This stops a speck of moiré texture that
  happens to look like a letter from being kept.

Every other line goes through the existing junk-line rule unchanged. So the
moiré fix from this morning still works: moiré junk comes as long lines of
many words, and those are still dropped.

### 2. Do not let those kept keys lower the score

In `scoreWords`, the words of a line kept only by rule 1 add
`max(0, confidence − 45)` instead of `confidence − 45`. A pass that finds the
keys is then never scored below a pass that missed them. Everything else is
scored as today.

### 3. Put each key back on the row of its meaning

New pure function `mergeTableRows` in `OcrReadingOrder.kt`, run just before
`orderLinesForReading`.

- A "key" line is a short line (at most 2 words, at most 25% of the page
  width).
- A key is joined to the nearest line on its **right** that shares its visual
  row (they overlap vertically by more than half of the shorter line), giving
  `q Quit`.
- This only happens when the page shows the pattern at least **3 times** with
  the keys' left edges lined up (within one line height). One stray short line
  at the end of a newspaper paragraph therefore never gets glued to the next
  column.
- If the pattern is not found, the lines are returned exactly as given.

### Files to change

| File | Change |
|---|---|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OcrLineFilter.kt` | New: `isNoiseLine`, `isKeyLikeLine` (pure functions) |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/MainActivity.kt` | `collectConfidentText` uses the new filter and scoring, and calls `mergeTableRows` |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_journal_vault/OcrReadingOrder.kt` | New `mergeTableRows` |
| `android/app/src/test/kotlin/in/sreerajp/sreerajp_journal_vault/OcrLineFilterTest.kt` | New tests |
| `android/app/src/test/kotlin/in/sreerajp/sreerajp_journal_vault/OcrReadingOrderTest.kt` | Tests for `mergeTableRows` |
| `docs/architecture.md` | Section 14: describe the key-line rule and the row merge |

No Dart, l10n, dependency, permission or schema change.

## Tests

Kotlin unit tests (run on the PC):

- a one-word, low-confidence line `q` of normal height is kept;
- `-N`, `/pat`, `+/text`, `Ctrl+C` are kept;
- a low-confidence line of 6 junk words is still dropped (moiré case);
- a one-character speck much smaller than the text lines is still dropped;
- a line of only `|` or `~` is still dropped (no letter or digit);
- a key table of 5 rows is merged into `q Quit`, `b Page up` …;
- two newspaper columns with one short paragraph-end line are **not** merged;
- a page with only 2 key-like rows is not merged;
- all existing `OcrReadingOrderTest` cases still pass.

Then: `flutter analyze`, `flutter test`, `:app:testDevDebugUnitTest`,
`:app:compileDevDebugKotlin`, `sh tool/check_absolute_paths.sh --all`.

If you can save the cheat-sheet photo into the scratch folder, I will also run
it through desktop Tesseract with the app's models, the same way as the last
change, and report the result before and after.

## Acceptance criteria

- The cheat-sheet photo returns the keys, each on the line of its meaning
  (small misreads such as `CtrlsC` may remain — that is the recognizer).
- The moiré screen photo from this morning is no worse.
- Plain paragraphs and real two-column pages read as before.

## Risks

- A small, low-confidence misread (for example `l` for `|`) may now be kept
  where it was dropped before. The height check and the "short line only" rule
  keep this rare, and a wrong letter is easier to fix than a missing one.
- The row merge could join two lines that are not a key and its meaning. The
  "3 lined-up rows" rule makes that unlikely.
