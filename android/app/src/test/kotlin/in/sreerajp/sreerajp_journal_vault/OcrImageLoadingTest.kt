package `in`.sreerajp.sreerajp_journal_vault

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Covers [decodeSampleSize], [fitWithin] and [exifTransform]. Pure arithmetic,
 * so no device, emulator or bitmap is involved.
 */
class OcrImageLoadingTest {

    @Test
    fun `a small image is decoded at full size`() {
        assertEquals(1, decodeSampleSize(3000, 4000))
        assertEquals(1, decodeSampleSize(4500, 3000))
    }

    @Test
    fun `a 50 MP photo is sampled by two, not below the cap`() {
        // 8160 x 6120: halving gives 4080 on the long edge, still near the cap,
        // so the smooth resize keeps the detail.
        assertEquals(2, decodeSampleSize(8160, 6120))
    }

    @Test
    fun `a 200 MP photo is sampled until it fits in memory`() {
        val sample = decodeSampleSize(16320, 12240)
        val pixels = (16320L / sample) * (12240L / sample)
        assertEquals(4, sample)
        assertTrue(pixels <= OCR_MAX_DECODE_PIXELS)
    }

    @Test
    fun `a very long strip is sampled for its pixel count`() {
        val sample = decodeSampleSize(4400, 9000, maxLongEdge = 10_000, maxPixels = 10_000_000L)
        assertEquals(2, sample)
    }

    @Test
    fun `an unreadable size is decoded as is`() {
        assertEquals(1, decodeSampleSize(0, 0))
        assertEquals(1, decodeSampleSize(-1, 100))
    }

    @Test
    fun `fitWithin shrinks only images past the cap and keeps their shape`() {
        assertEquals(3000 to 4000, fitWithin(3000, 4000))
        assertEquals(4500 to 3375, fitWithin(8000, 6000))
        assertEquals(2250 to 4500, fitWithin(4000, 8000))
    }

    @Test
    fun `EXIF orientations map to the right turn`() {
        assertTrue(exifTransform(1).isIdentity)
        assertTrue(exifTransform(0).isIdentity)
        assertTrue(exifTransform(99).isIdentity)
        assertEquals(ExifTransform(0, mirror = true), exifTransform(2))
        assertEquals(ExifTransform(180, mirror = false), exifTransform(3))
        assertEquals(ExifTransform(180, mirror = true), exifTransform(4))
        assertEquals(ExifTransform(90, mirror = true), exifTransform(5))
        assertEquals(ExifTransform(90, mirror = false), exifTransform(6))
        assertEquals(ExifTransform(270, mirror = true), exifTransform(7))
        assertEquals(ExifTransform(270, mirror = false), exifTransform(8))
        assertFalse(exifTransform(6).isIdentity)
    }
}
