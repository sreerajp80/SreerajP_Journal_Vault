package android.print

import android.app.Activity
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.view.ViewGroup
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import java.io.File
import kotlin.math.ceil
import kotlin.math.roundToInt

/**
 * Renders self-contained, local HTML to a PDF using a real [WebView] that is
 * ATTACHED to the activity window.
 *
 * **Why this exists.** Two reasons, and both matter.
 *
 * 1. Malayalam, and every other complex script, needs real text shaping —
 *    chillu, conjuncts, vowel signs that reorder around their consonant. The
 *    platform WebView does that shaping properly, and the resulting PDF keeps
 *    real, selectable text rather than a picture of it.
 * 2. The `printing` plugin's `convertHtml` builds a WebView that is never
 *    attached to a window. On newer Android the print document callbacks then
 *    never fire and the export hangs forever. Attaching the WebView, even
 *    off-screen, makes it lay out, so the callbacks run and a PDF comes back.
 *
 * This class lives in package `android.print` on purpose: the
 * [PrintDocumentAdapter.LayoutResultCallback] and
 * [PrintDocumentAdapter.WriteResultCallback] constructors are package-private,
 * so a subclass has to sit in this package.
 *
 * **Fully offline.** Network loading is blocked at the WebView, file access is
 * off, and the only thing ever loaded is the local HTML string passed in — the
 * fonts inside it are base64 data URIs, so no URL is fetched. This is what
 * keeps the app's no-network guarantee intact while still producing a PDF.
 *
 * Ported from `SreerajP_lyricchord`'s `LcHtmlToPdf`, minus its page-width
 * fitting: that measured the widest line of a song sheet to pick a page width,
 * which is a song-sheet trick. A journal page is a page of prose and wants
 * ordinary A4.
 */
class JvHtmlToPdf(private val activity: Activity) {

    /** Result callback: exactly one of [bytes] / [error] is non-null. */
    fun interface Callback {
        fun onResult(bytes: ByteArray?, error: String?, isTimeout: Boolean)
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * Renders [html] to a PDF at [widthPts] x [heightPts] with [marginPts]
     * margins, all in PostScript points (1/72 inch).
     *
     * [timeoutMs] is a hard limit: a render that has not finished by then is
     * abandoned and reported as a timeout, so a stuck WebView can never hang
     * the app.
     */
    fun convert(
        html: String,
        widthPts: Double,
        heightPts: Double,
        marginPts: Double,
        timeoutMs: Long,
        callback: Callback,
    ) {
        mainHandler.post {
            start(html, widthPts, heightPts, marginPts, timeoutMs, callback)
        }
    }

    private fun start(
        html: String,
        widthPts: Double,
        heightPts: Double,
        marginPts: Double,
        timeoutMs: Long,
        callback: Callback,
    ) {
        val root = activity.findViewById<ViewGroup>(android.R.id.content)
        if (root == null) {
            callback.onResult(null, "No window to render in", false)
            return
        }

        val webView = WebView(activity)
        webView.settings.javaScriptEnabled = true
        webView.settings.blockNetworkLoads = true // enforce offline
        webView.settings.allowFileAccess = false
        webView.settings.allowContentAccess = false

        var finished = false
        var timeoutRunnable: Runnable? = null

        fun cleanup() {
            timeoutRunnable?.let { mainHandler.removeCallbacks(it) }
            try {
                root.removeView(webView)
            } catch (_: Exception) {
            }
            try {
                webView.destroy()
            } catch (_: Exception) {
            }
        }

        fun finish(bytes: ByteArray?, error: String?, isTimeout: Boolean = false) {
            if (finished) return
            finished = true
            cleanup()
            callback.onResult(bytes, error, isTimeout)
        }

        // Attached so the WebView lays out, but pushed far off-screen so it is
        // never visible. The size here does not decide the layout — the print
        // attributes below do.
        val widthPx = ceil(widthPts * 96.0 / 72.0).toInt().coerceAtLeast(1)
        val heightPx = ceil(heightPts * 96.0 / 72.0).toInt().coerceAtLeast(1)
        val params = FrameLayout.LayoutParams(widthPx, heightPx)
        webView.translationX = 100000f
        root.addView(webView, params)

        var rendered = false

        // JavaScript calls this once the embedded fonts have finished loading.
        // Printing before that gives a page laid out with fallback metrics, and
        // Malayalam in particular comes out wrong.
        webView.addJavascriptInterface(
            object {
                @JavascriptInterface
                fun onFontsReady() {
                    mainHandler.post {
                        if (rendered || finished) return@post
                        rendered = true
                        render(webView, widthPts, heightPts, marginPts, ::finish)
                    }
                }
            },
            "AndroidPdf",
        )

        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                super.onPageFinished(view, url)
                // The catch matters: if document.fonts is missing or rejects,
                // printing with fallback fonts is far better than hanging until
                // the timeout and giving the user nothing.
                view.evaluateJavascript(
                    "(function(){try{" +
                        "document.fonts.ready.then(function(){" +
                        "window.AndroidPdf.onFontsReady();})" +
                        ".catch(function(){window.AndroidPdf.onFontsReady();});" +
                        "}catch(e){window.AndroidPdf.onFontsReady();}})();",
                    null,
                )
            }
        }

        timeoutRunnable = Runnable { finish(null, "Rendering timed out", true) }
        mainHandler.postDelayed(timeoutRunnable, timeoutMs)

        // No base URL, so nothing in the page can resolve a relative address.
        webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
    }

    private fun render(
        webView: WebView,
        widthPts: Double,
        heightPts: Double,
        marginPts: Double,
        finish: (ByteArray?, String?, Boolean) -> Unit,
    ) {
        var outFile: File? = null
        try {
            val mediaSize = PrintAttributes.MediaSize(
                "jv-page",
                "Page",
                (widthPts * 1000.0 / 72.0).roundToInt(),
                (heightPts * 1000.0 / 72.0).roundToInt(),
            )
            val marginMils = (marginPts * 1000.0 / 72.0).roundToInt()
            val attributes = PrintAttributes.Builder()
                .setMediaSize(mediaSize)
                .setResolution(PrintAttributes.Resolution("pdf", "pdf", 600, 600))
                .setMinMargins(
                    PrintAttributes.Margins(marginMils, marginMils, marginMils, marginMils),
                )
                .build()

            val adapter = webView.createPrintDocumentAdapter("journal_vault_export")
            val file = File.createTempFile("jv_export", ".pdf", activity.cacheDir)
            outFile = file

            adapter.onLayout(
                null,
                attributes,
                null,
                object : PrintDocumentAdapter.LayoutResultCallback() {
                    override fun onLayoutFinished(info: PrintDocumentInfo?, changed: Boolean) {
                        try {
                            val pfd = ParcelFileDescriptor.open(
                                file,
                                ParcelFileDescriptor.MODE_READ_WRITE,
                            )
                            adapter.onWrite(
                                arrayOf(PageRange.ALL_PAGES),
                                pfd,
                                CancellationSignal(),
                                object : PrintDocumentAdapter.WriteResultCallback() {
                                    override fun onWriteFinished(pages: Array<out PageRange>?) {
                                        super.onWriteFinished(pages)
                                        if (pages == null || pages.isEmpty()) {
                                            file.delete()
                                            finish(null, "No pages produced", false)
                                            return
                                        }
                                        try {
                                            val bytes = file.readBytes()
                                            // The PDF holds decrypted journal
                                            // content, so the temporary copy is
                                            // deleted the moment it is read.
                                            file.delete()
                                            finish(bytes, null, false)
                                        } catch (e: Exception) {
                                            file.delete()
                                            finish(null, e.message ?: "Could not read PDF", false)
                                        }
                                    }

                                    override fun onWriteFailed(error: CharSequence?) {
                                        super.onWriteFailed(error)
                                        file.delete()
                                        finish(null, error?.toString() ?: "PDF write failed", false)
                                    }
                                },
                            )
                        } catch (e: Exception) {
                            file.delete()
                            finish(null, e.message ?: "PDF write failed", false)
                        }
                    }

                    override fun onLayoutFailed(error: CharSequence?) {
                        super.onLayoutFailed(error)
                        file.delete()
                        finish(null, error?.toString() ?: "PDF layout failed", false)
                    }
                },
                null,
            )
        } catch (e: Exception) {
            outFile?.delete()
            finish(null, e.message ?: "PDF render failed", false)
        }
    }
}
