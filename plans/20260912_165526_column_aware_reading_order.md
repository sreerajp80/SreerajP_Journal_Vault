# Plan — Put two-column text back in reading order

**Status:** Awaiting approval

## The problem

A scanned two-column newspaper article came back with its tail interleaved:

```
... വീട്ടുകാർക്കു അവളെക്കുറിച്ചുള്ള     (column 2)
പ്പെട്ടു വീട്ടിൽ പോകാതെയായി.            (column 1, last line)
12 മാതൃവാണി ഈ ആഗസ്റ്റ് 2026            (page footer, spans both columns)
എല്ലാ പ്രതീക്ഷകളും നശിച്ചു.              (column 2, last line)
```

Every word is present. Only the sequence is wrong.

## Correcting an earlier suggestion

I first suggested biasing the pass scoring toward `PSM_AUTO`, which does column
detection, on the theory that a flatter mode was winning on word count.

That was wrong. `CONFIDENT_SCORE` is 1600, and this scan produced 73 words at
roughly 75 confidence — about 5475. `PSM_AUTO` runs first, cleared the threshold
and broke the loop. It already won. Changing the scoring would do nothing here.

The wrong order comes from Tesseract's own layout analysis, most likely confused
by the full-width footer line and the rule above it cutting across both columns.

## The fix

Order the lines ourselves, using the position of each line on the page.
Tesseract gives us that through `PageIterator.getBoundingRect(RIL_TEXTLINE)`,
confirmed present in Tesseract4Android 4.9.0.

### New file: `android/app/src/main/kotlin/.../OcrReadingOrder.kt`

Pure geometry, no Android or Tesseract types, so it can be unit tested without a
device or Robolectric.

```kotlin
data class TextLineBox(
    val left: Int, val top: Int, val right: Int, val bottom: Int, val text: String,
)

fun orderLinesForReading(lines: List<TextLineBox>): List<TextLineBox>
```

Algorithm:

1. Fewer than two lines — return unchanged.
2. Page width is the span from the leftmost left edge to the rightmost right edge.
3. Mark a line **full width** when its own width is at least
   `FULL_WIDTH_RATIO` (0.65) of the page width. A headline, a footer or a rule
   spanning the page is one of these.
4. Split the lines, sorted top to bottom, into **bands**: each full-width line is
   a band on its own, and each run of narrower lines between them is a band.
5. Inside a band, group lines into **columns**: sorted by left edge, a line joins
   the current column when its horizontal span overlaps the column's span by more
   than `MIN_COLUMN_OVERLAP` (0.5) of the narrower of the two. Otherwise it starts
   a new column.
6. Emit bands top to bottom; within a band, columns left to right; within a
   column, lines top to bottom.

### The guard, which matters more than the algorithm

Reordering is **only** applied when a band genuinely looks like columns: at least
two columns, each holding at least `MIN_LINES_PER_COLUMN` (3) lines. Otherwise
the original order is returned untouched.

A single-column page, a receipt, a note, a cropped snippet — all keep exactly
the behaviour they have today. This change can only affect a page that really is
laid out in columns.

### `MainActivity.kt`

`collectConfidentText` currently builds one string as it walks words. It changes
to:

1. Walk words as now, also recording each word's line rectangle from
   `getBoundingRect(RIL_TEXTLINE)`.
2. Apply the existing two-tier confidence filter, unchanged.
3. Group surviving words into `TextLineBox` values, one per line.
4. Pass them through `orderLinesForReading`.
5. Join the result with newlines.

The two-tier floor, the page-script vote and the empty-result fallback all stay
as they are.

### Tests — new test source set

The project has no Kotlin unit tests today: `android/app/src/` holds only
`debug`, `main` and `profile`, and `build.gradle.kts` declares no test
dependency. A layout algorithm I cannot run on a device should not ship
unverified, so this adds one.

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | `testImplementation("junit:junit:4.13.2")` |
| `android/app/src/test/kotlin/.../OcrReadingOrderTest.kt` | New |

Cases to cover:

- two columns with a full-width footer — the failing case above, in the right order
- a single column — returned completely unchanged
- two columns where one holds fewer than three lines — unchanged, guard holds
- an empty list and a single line — unchanged
- a full-width headline above two columns — headline first, then the columns

## Files to change

| File | Change |
|---|---|
| `android/app/src/main/kotlin/.../OcrReadingOrder.kt` | New — the ordering algorithm |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Collect line rectangles; order lines before joining |
| `android/app/build.gradle.kts` | Add the JUnit test dependency |
| `android/app/src/test/kotlin/.../OcrReadingOrderTest.kt` | New — the tests above |

No Dart change. No new permission, asset or runtime package — JUnit is test-only.
Model files untouched, so `TESSDATA_VERSION` stays as it is.

## Honest limits

- This fixes **order**, not recognition. A word Tesseract never found stays lost.
- The thresholds (0.65, 0.5, 3) are judgement calls tuned against one photograph.
  They are named constants for that reason. If a page orders badly after this,
  the fix is to adjust a constant, not to rewrite the algorithm.
- A page whose columns genuinely overlap horizontally — a wrapped pull quote, an
  image with text flowing around it — may still order oddly. The guard keeps it
  from being made worse than today, not perfect.

## Checks after implementing

- `./gradlew :app:testProdDebugUnitTest` — the new tests pass
- `./gradlew :app:compileProdDebugKotlin`
- `flutter analyze` clean
- `flutter test`
- On a device: rescan the same article and confirm the tail reads in order —
  column one complete, then column two, then the footer
- On a device: scan a plain single-column page and confirm nothing changed
