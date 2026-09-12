package `in`.sreerajp.sreerajp_journal_vault

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Covers [orderLinesForReading]. Pure arithmetic, so no device, emulator or
 * Android shadow library is involved.
 *
 * Coordinates below describe a page 1000 units wide: a left column at 0..480, a
 * right column at 520..1000, and anything spanning both.
 */
class OcrReadingOrderTest {

    private fun line(
        left: Int,
        top: Int,
        right: Int,
        text: String,
    ) = TextLineBox(left = left, top = top, right = right, bottom = top + 20, text = text)

    private fun texts(lines: List<TextLineBox>) = lines.map { it.text }

    @Test
    fun `orders two columns and keeps a full-width footer in place`() {
        // The failing case from a real scan: the recognizer crossed between the
        // columns near the bottom and put the page footer in the middle of it.
        val recognizerOrder = listOf(
            line(0, 0, 480, "left 1"),
            line(0, 30, 480, "left 2"),
            line(520, 0, 1000, "right 1"),
            line(520, 30, 1000, "right 2"),
            line(520, 60, 1000, "right 3"),
            line(0, 60, 480, "left 3"),
            line(0, 100, 1000, "footer"),
        )

        val ordered = orderLinesForReading(recognizerOrder)

        assertEquals(
            listOf("left 1", "left 2", "left 3", "right 1", "right 2", "right 3", "footer"),
            texts(ordered),
        )
    }

    @Test
    fun `keeps a full-width headline above its columns`() {
        val lines = listOf(
            line(0, 0, 1000, "headline"),
            line(520, 40, 1000, "right 1"),
            line(0, 40, 480, "left 1"),
            line(0, 70, 480, "left 2"),
            line(520, 70, 1000, "right 2"),
            line(0, 100, 480, "left 3"),
            line(520, 100, 1000, "right 3"),
        )

        val ordered = orderLinesForReading(lines)

        assertEquals(
            listOf("headline", "left 1", "left 2", "left 3", "right 1", "right 2", "right 3"),
            texts(ordered),
        )
    }

    @Test
    fun `leaves a single column exactly as it was given`() {
        val lines = listOf(
            line(0, 0, 1000, "one"),
            line(0, 30, 1000, "two"),
            line(0, 60, 1000, "three"),
            line(0, 90, 1000, "four"),
        )

        assertEquals(lines, orderLinesForReading(lines))
    }

    @Test
    fun `leaves a narrow single column exactly as it was given`() {
        // Narrow lines that all sit in the same place horizontally are one column,
        // not two, so nothing should be reordered.
        val lines = listOf(
            line(0, 0, 480, "one"),
            line(0, 30, 480, "two"),
            line(0, 60, 480, "three"),
        )

        assertEquals(lines, orderLinesForReading(lines))
    }

    @Test
    fun `does not reorder when a column is too short to be believed`() {
        // The right-hand group has two lines, below MIN_LINES_PER_COLUMN, so this
        // is more likely stray text than a real column. Order must be untouched.
        val lines = listOf(
            line(0, 0, 480, "left 1"),
            line(520, 0, 1000, "right 1"),
            line(0, 30, 480, "left 2"),
            line(520, 30, 1000, "right 2"),
            line(0, 60, 480, "left 3"),
        )

        assertEquals(lines, orderLinesForReading(lines))
    }

    @Test
    fun `returns an empty list unchanged`() {
        assertEquals(emptyList<TextLineBox>(), orderLinesForReading(emptyList()))
    }

    @Test
    fun `returns a single line unchanged`() {
        val lines = listOf(line(0, 0, 480, "only"))
        assertEquals(lines, orderLinesForReading(lines))
    }

    @Test
    fun `orders three columns left to right`() {
        val lines = listOf(
            line(700, 0, 1000, "c 1"),
            line(0, 0, 300, "a 1"),
            line(350, 0, 650, "b 1"),
            line(700, 30, 1000, "c 2"),
            line(0, 30, 300, "a 2"),
            line(350, 30, 650, "b 2"),
            line(700, 60, 1000, "c 3"),
            line(0, 60, 300, "a 3"),
            line(350, 60, 650, "b 3"),
        )

        val ordered = orderLinesForReading(lines)

        assertEquals(
            listOf("a 1", "a 2", "a 3", "b 1", "b 2", "b 3", "c 1", "c 2", "c 3"),
            texts(ordered),
        )
    }
}
