package `in`.sreerajp.sreerajp_journal_vault

/**
 * One recognised text line and where it sits on the page.
 *
 * Deliberately plain integers rather than `android.graphics.Rect`, so the
 * ordering below is pure arithmetic that a plain JUnit test can exercise without
 * a device or an Android shadow library.
 */
data class TextLineBox(
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
    val text: String,
) {
    val width: Int get() = right - left
}

/**
 * A line at least this share of the page's width is treated as spanning the whole
 * page — a headline, a footer, a rule — rather than belonging to one column.
 */
const val FULL_WIDTH_RATIO = 0.65f

/**
 * How much two lines must overlap horizontally, as a share of the narrower one,
 * before they are taken to belong to the same column.
 */
const val MIN_COLUMN_OVERLAP = 0.5f

/**
 * Lines a column needs before a band is believed to be laid out in columns.
 * Below this the grouping is more likely noise than a real column.
 */
const val MIN_LINES_PER_COLUMN = 3

/**
 * Puts recognised lines back into the order a person would read them.
 *
 * Text recognition returns lines in the order its own layout analysis decided,
 * and on a page with two columns plus something spanning both — a footer, a rule
 * — that order can cross from one column to the other and back.
 *
 * This works from where each line actually sits. The page is cut into bands at
 * every full-width line; each band is grouped into columns by horizontal
 * overlap; then bands are read top to bottom, columns left to right, and lines
 * within a column top to bottom.
 *
 * **The result is only reordered when a band genuinely looks like columns** —
 * two or more, each with at least [MIN_LINES_PER_COLUMN] lines. Anything else,
 * including every single-column page, comes back exactly as it was given. This
 * can make a real multi-column page better; it cannot make an ordinary page
 * worse.
 */
fun orderLinesForReading(lines: List<TextLineBox>): List<TextLineBox> {
    if (lines.size < 2) return lines

    val pageLeft = lines.minOf { it.left }
    val pageRight = lines.maxOf { it.right }
    val pageWidth = pageRight - pageLeft
    if (pageWidth <= 0) return lines

    // Cut the page into bands at every full-width line. A full-width line is a
    // band of its own, so it never gets sorted into a column beside the text it
    // actually sits above or below.
    val bands = mutableListOf<List<TextLineBox>>()
    var narrowRun = mutableListOf<TextLineBox>()
    for (line in lines.sortedBy { it.top }) {
        if (line.width >= FULL_WIDTH_RATIO * pageWidth) {
            if (narrowRun.isNotEmpty()) {
                bands.add(narrowRun)
                narrowRun = mutableListOf()
            }
            bands.add(listOf(line))
        } else {
            narrowRun.add(line)
        }
    }
    if (narrowRun.isNotEmpty()) bands.add(narrowRun)

    var foundColumns = false
    val ordered = mutableListOf<TextLineBox>()
    for (band in bands) {
        val columns = groupIntoColumns(band)
        val looksLikeColumns =
            columns.size >= 2 && columns.all { it.size >= MIN_LINES_PER_COLUMN }
        if (looksLikeColumns) {
            foundColumns = true
            for (column in columns.sortedBy { col -> col.minOf { it.left } }) {
                ordered.addAll(column.sortedBy { it.top })
            }
        } else {
            ordered.addAll(band.sortedBy { it.top })
        }
    }

    // Nothing here looked like a column layout, so trust the recognizer's own
    // order rather than imposing ours.
    return if (foundColumns) ordered else lines
}

/** Groups a band's lines into columns by how much they overlap horizontally. */
private fun groupIntoColumns(band: List<TextLineBox>): List<List<TextLineBox>> {
    val columns = mutableListOf<MutableList<TextLineBox>>()
    val spans = mutableListOf<IntArray>()

    for (line in band.sortedBy { it.left }) {
        val existing = spans.indexOfFirst { span ->
            overlapsHorizontally(span[0], span[1], line.left, line.right)
        }
        if (existing >= 0) {
            columns[existing].add(line)
            spans[existing][0] = minOf(spans[existing][0], line.left)
            spans[existing][1] = maxOf(spans[existing][1], line.right)
        } else {
            columns.add(mutableListOf(line))
            spans.add(intArrayOf(line.left, line.right))
        }
    }
    return columns
}

/** True when two horizontal spans overlap by more than [MIN_COLUMN_OVERLAP]. */
private fun overlapsHorizontally(
    aLeft: Int,
    aRight: Int,
    bLeft: Int,
    bRight: Int,
): Boolean {
    val overlap = minOf(aRight, bRight) - maxOf(aLeft, bLeft)
    if (overlap <= 0) return false
    val narrower = minOf(aRight - aLeft, bRight - bLeft)
    if (narrower <= 0) return false
    return overlap > MIN_COLUMN_OVERLAP * narrower
}
