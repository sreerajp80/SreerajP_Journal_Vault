package `in`.sreerajp.sreerajp_journal_vault

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import java.io.File

/**
 * Longest edge, in pixels, of an image handed to Tesseract.
 *
 * Matches the Dart side's enlarged-image cap. The enhance screen never sends a
 * larger image; this only protects the fallback path, where a full-size camera
 * photo (50 MP or more) could otherwise be decoded whole and run out of memory.
 */
const val OCR_MAX_LONG_EDGE = 4500

/**
 * Largest number of pixels decoded in one go before the final resize. A decode
 * above this is sampled down further first. At 4 bytes a pixel this is about
 * 100 MB, the most one bitmap may take on a mid-range phone.
 */
const val OCR_MAX_DECODE_PIXELS = 25_000_000L

/**
 * The `inSampleSize` to decode a [width] x [height] image with.
 *
 * The largest power of two that still leaves the long edge at or above
 * [maxLongEdge], so detail is only thrown away by the smooth resize that
 * follows, not by the coarse sampling. Raised further if the sampled image
 * would still hold more than [maxPixels] pixels.
 */
fun decodeSampleSize(
    width: Int,
    height: Int,
    maxLongEdge: Int = OCR_MAX_LONG_EDGE,
    maxPixels: Long = OCR_MAX_DECODE_PIXELS,
): Int {
    if (width <= 0 || height <= 0) return 1
    val longEdge = maxOf(width, height)
    var sample = 1
    while (longEdge / (sample * 2) >= maxLongEdge) sample *= 2
    while ((width.toLong() / sample) * (height.toLong() / sample) > maxPixels) sample *= 2
    return sample
}

/**
 * The size [width] x [height] is scaled to so its long edge is at most
 * [maxLongEdge], keeping its shape. Returned unchanged when it already fits.
 */
fun fitWithin(width: Int, height: Int, maxLongEdge: Int = OCR_MAX_LONG_EDGE): Pair<Int, Int> {
    val longEdge = maxOf(width, height)
    if (longEdge <= maxLongEdge || longEdge <= 0) return width to height
    val scale = maxLongEdge.toDouble() / longEdge
    return maxOf(1, Math.round(width * scale).toInt()) to
        maxOf(1, Math.round(height * scale).toInt())
}

/** How to turn a decoded image so it matches its EXIF orientation tag. */
data class ExifTransform(
    /** Clockwise rotation in degrees: 0, 90, 180 or 270. */
    val rotateDegrees: Int,
    /** Mirror left-to-right after the rotation. */
    val mirror: Boolean,
) {
    val isIdentity: Boolean get() = rotateDegrees == 0 && !mirror
}

/**
 * The turn needed for EXIF orientation [orientation] (1 to 8). Anything else,
 * including "undefined", needs none.
 */
fun exifTransform(orientation: Int): ExifTransform = when (orientation) {
    2 -> ExifTransform(0, mirror = true)
    3 -> ExifTransform(180, mirror = false)
    4 -> ExifTransform(180, mirror = true)
    5 -> ExifTransform(90, mirror = true)
    6 -> ExifTransform(90, mirror = false)
    7 -> ExifTransform(270, mirror = true)
    8 -> ExifTransform(270, mirror = false)
    else -> ExifTransform(0, mirror = false)
}

/**
 * Decodes [file] for text recognition: never larger than [OCR_MAX_LONG_EDGE] on
 * the long edge, and turned upright according to its EXIF tag.
 *
 * The images the enhance screen sends are already small, upright PNGs, so for
 * them this is a plain decode. Throws [IllegalArgumentException] when the file
 * is not an image.
 */
fun loadBitmapForOcr(file: File): Bitmap {
    val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
    BitmapFactory.decodeFile(file.absolutePath, bounds)
    if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
        throw IllegalArgumentException("Could not read image size")
    }

    val options = BitmapFactory.Options().apply {
        inSampleSize = decodeSampleSize(bounds.outWidth, bounds.outHeight)
        inPreferredConfig = Bitmap.Config.ARGB_8888
    }
    var bitmap = BitmapFactory.decodeFile(file.absolutePath, options)
        ?: throw IllegalArgumentException("Could not decode image")

    val (targetWidth, targetHeight) = fitWithin(bitmap.width, bitmap.height)
    if (targetWidth != bitmap.width || targetHeight != bitmap.height) {
        val scaled = Bitmap.createScaledBitmap(bitmap, targetWidth, targetHeight, true)
        if (scaled !== bitmap) bitmap.recycle()
        bitmap = scaled
    }

    val transform = exifTransform(readExifOrientation(file))
    if (transform.isIdentity) return bitmap

    val matrix = Matrix().apply {
        postRotate(transform.rotateDegrees.toFloat())
        if (transform.mirror) postScale(-1f, 1f)
    }
    val turned = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    if (turned !== bitmap) bitmap.recycle()
    return turned
}

/** The EXIF orientation tag of [file], or 1 (upright) when it has none. */
private fun readExifOrientation(file: File): Int = try {
    ExifInterface(file.absolutePath).getAttributeInt(
        ExifInterface.TAG_ORIENTATION,
        ExifInterface.ORIENTATION_NORMAL,
    )
} catch (_: Exception) {
    ExifInterface.ORIENTATION_NORMAL
}
