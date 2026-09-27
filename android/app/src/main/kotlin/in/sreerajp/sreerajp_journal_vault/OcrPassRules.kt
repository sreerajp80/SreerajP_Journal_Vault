package `in`.sreerajp.sreerajp_journal_vault

/**
 * Score (mean confidence x word count) above which a pass is considered good
 * enough to stop trying the remaining page segmentation modes.
 */
const val CONFIDENT_SCORE = 2400

/**
 * Mean confidence (0..100) a pass must also reach before the remaining page
 * segmentation modes are skipped.
 */
const val CONFIDENT_MEAN = 85

/**
 * Page segmentation modes that must have run on an image before the remaining
 * ones may be skipped: the full-page mode and the single-block mode.
 *
 * They fail in different ways. The full-page mode finds columns, but its layout
 * step can throw away a column of short, lone words — the keys of a cheat sheet
 * such as `q` or `-N` — before recognition, and still read the rest with high
 * confidence. The single-block mode keeps every row, key and meaning together.
 * Stopping after the first mode alone lost those keys.
 */
const val MIN_PASSES_BEFORE_EARLY_STOP = 2

/**
 * True when the remaining page segmentation modes can be skipped after the pass
 * at [modeIndex] (0 for the first mode), which read [text] with a mean
 * confidence of [meanConfidence].
 *
 * A clean page is read well early, so there is no need to spend more passes
 * confirming it. Both a high score and a high mean confidence are needed: a score
 * alone is reached by a long main block even when a heading or a column was
 * missed. And at least [MIN_PASSES_BEFORE_EARLY_STOP] modes must have run, since
 * even a confident first pass can miss a whole column.
 */
fun canStopEarly(modeIndex: Int, text: String, meanConfidence: Int): Boolean =
    modeIndex + 1 >= MIN_PASSES_BEFORE_EARLY_STOP &&
        earlyStopScore(text, meanConfidence) >= CONFIDENT_SCORE &&
        meanConfidence >= CONFIDENT_MEAN

/**
 * The old score, mean confidence times word count. Used only to decide that a
 * pass is so clearly good that the remaining passes can be skipped.
 */
fun earlyStopScore(text: String, confidence: Int): Int {
    if (text.isBlank()) return 0
    val words = text.split(Regex("\\s+")).count { it.isNotBlank() }
    return confidence * words
}
