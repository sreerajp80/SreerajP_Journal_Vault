package `in`.sreerajp.sreerajp_journal_vault

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Covers [canStopEarly] and [earlyStopScore]. Pure arithmetic, so no device,
 * emulator or Tesseract is involved.
 */
class OcrPassRulesTest {

    /** A confident reading: 40 words at mean confidence 92 scores 3680. */
    private val confidentText = List(40) { "word" }.joinToString(" ")

    @Test
    fun `does not stop after the first mode, however confident`() {
        // The failing case from a real scan: the full-page mode dropped a cheat
        // sheet's column of keys, yet read the rest at mean confidence 92.
        assertFalse(canStopEarly(modeIndex = 0, text = confidentText, meanConfidence = 92))
    }

    @Test
    fun `stops after the second mode when the reading is confident`() {
        assertTrue(canStopEarly(modeIndex = 1, text = confidentText, meanConfidence = 92))
    }

    @Test
    fun `does not stop when the mean confidence is too low`() {
        assertFalse(canStopEarly(modeIndex = 1, text = confidentText, meanConfidence = 84))
    }

    @Test
    fun `does not stop when there is too little text`() {
        // 5 words at 95 scores 475, far under CONFIDENT_SCORE.
        assertFalse(canStopEarly(modeIndex = 1, text = "only five short words here", meanConfidence = 95))
    }

    @Test
    fun `early stop score is mean confidence times word count`() {
        assertEquals(0, earlyStopScore("   ", 90))
        assertEquals(270, earlyStopScore("one  two\nthree", 90))
    }
}
