package `in`.sreerajp.sreerajp_journal_vault

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.Manifest
import android.content.pm.PackageManager
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.core.content.ContextCompat
import android.print.JvHtmlToPdf
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationCompat
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import kotlin.random.Random
import com.googlecode.tesseract.android.TessBaseAPI
import java.util.concurrent.Executors

class MainActivity : FlutterFragmentActivity() {
    private var pendingStorageTreeResult: MethodChannel.Result? = null
    private var shareChannel: MethodChannel? = null
    private var pendingSharePayload: Map<String, Any?>? = null
    private val ocrExecutor = Executors.newSingleThreadExecutor()

    /** Ids of recognition requests whose caller has gone away. */
    private val cancelledOcrRequests = mutableSetOf<Int>()
    private var activeTessApi: TessBaseAPI? = null
    private var activeTessLang: String? = null

    override fun onDestroy() {
        activeTessApi?.recycle()
        activeTessApi = null
        ocrExecutor.shutdown()
        super.onDestroy()
    }

    private val storageTreePicker = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult(),
    ) { result ->
        val pendingResult = pendingStorageTreeResult ?: return@registerForActivityResult
        pendingStorageTreeResult = null

        if (result.resultCode != Activity.RESULT_OK) {
            pendingResult.success(null)
            return@registerForActivityResult
        }

        val treeUri = result.data?.data
        if (treeUri == null) {
            pendingResult.error("storage_unavailable", "No storage location was selected", null)
            return@registerForActivityResult
        }

        try {
            val persistableFlags =
                result.data?.flags?.and(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                ) ?: (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            contentResolver.takePersistableUriPermission(treeUri, persistableFlags)
            pendingResult.success(
                mapOf(
                    "treeUri" to treeUri.toString(),
                    "displayName" to resolveTreeDisplayName(applicationContext, treeUri),
                ),
            )
        } catch (error: Exception) {
            pendingResult.error("storage_unavailable", error.message, null)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Sensitive Data Extension, engineering standard 15.2: FLAG_SECURE blocks
        // screenshots, screen recording, and the task-switcher preview. Applied once
        // for the whole window rather than per screen, because every screen in this
        // app can show private journal content.
        //
        // The user may switch this off in Settings. The choice is kept in this app's
        // own SharedPreferences so it can be read here, before the first frame is
        // drawn. A missing or unreadable value means protected.
        applyScreenSecurity(isScreenSecurityEnabled(applicationContext))

        pendingSharePayload = extractSharePayload(applicationContext, intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val payload = extractSharePayload(applicationContext, intent)
        pendingSharePayload = payload
        if (payload != null) {
            runOnUiThread {
                shareChannel?.invokeMethod("onShareReceived", payload)
            }
        }
    }

    /**
     * Tells Dart whether speech can be recognised on this device without a
     * network, and which languages the on-device recogniser has.
     *
     * Dictation starts only when `available` is true. The speech plugin makes
     * the same `isOnDeviceRecognitionAvailable` check before it picks a
     * recogniser, and would otherwise fall back to the online one — so this
     * check is what keeps dictated audio on the device.
     */
    private fun reportOnDeviceSpeechStatus(result: MethodChannel.Result) {
        val available = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            SpeechRecognizer.isOnDeviceRecognitionAvailable(applicationContext)
        val emptyStatus = mapOf(
            "available" to available,
            "installedLanguages" to emptyList<String>(),
            "supportedLanguages" to emptyList<String>(),
        )
        val hasMicPermission = ContextCompat.checkSelfPermission(
            applicationContext,
            Manifest.permission.RECORD_AUDIO,
        ) == PackageManager.PERMISSION_GRANTED
        // The language list needs Android 13 and the microphone permission.
        if (!available || Build.VERSION.SDK_INT < 33 || !hasMicPermission) {
            result.success(emptyStatus)
            return
        }

        val recognizer = try {
            SpeechRecognizer.createOnDeviceSpeechRecognizer(applicationContext)
        } catch (e: Exception) {
            result.success(emptyStatus)
            return
        }
        var replied = false
        fun reply(value: Map<String, Any>) {
            runOnUiThread {
                if (replied) return@runOnUiThread
                replied = true
                recognizer.destroy()
                result.success(value)
            }
        }
        try {
            recognizer.checkRecognitionSupport(
                Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH),
                Executors.newSingleThreadExecutor(),
                object : RecognitionSupportCallback {
                    override fun onSupportResult(support: RecognitionSupport) {
                        reply(
                            mapOf(
                                "available" to true,
                                "installedLanguages" to support.installedOnDeviceLanguages,
                                "supportedLanguages" to support.supportedOnDeviceLanguages,
                            ),
                        )
                    }

                    override fun onError(error: Int) {
                        reply(emptyStatus)
                    }
                },
            )
        } catch (e: Exception) {
            reply(emptyStatus)
        }
    }

    /** Sets or clears FLAG_SECURE on this window. Must run on the UI thread. */
    private fun applyScreenSecurity(enabled: Boolean) {
        if (enabled) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE,
            )
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ATTACHMENT_KEY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAttachmentKey" -> {
                    val keyReference = call.argument<String>("keyReference")
                    val createIfMissing =
                        call.argument<Boolean>("createIfMissing") ?: false
                    if (keyReference.isNullOrBlank()) {
                        result.error("invalid_args", "keyReference is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val encodedKey = getAttachmentKey(
                            context = applicationContext,
                            keyReference = keyReference,
                            createIfMissing = createIfMissing,
                        )
                        if (encodedKey == null) {
                            result.error("missing_key", "No attachment key found", null)
                        } else {
                            result.success(encodedKey)
                        }
                    } catch (error: Exception) {
                        result.error("keystore_failure", error.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DATABASE_KEY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDatabaseKey" -> {
                    val createIfMissing =
                        call.argument<Boolean>("createIfMissing") ?: false
                    try {
                        val encodedKey = getDatabaseKey(
                            context = applicationContext,
                            createIfMissing = createIfMissing,
                        )
                        if (encodedKey == null) {
                            result.error("missing_key", "No database key found", null)
                        } else {
                            result.success(encodedKey)
                        }
                    } catch (error: Exception) {
                        result.error("keystore_failure", error.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ATTACHMENT_STORAGE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "pickStorageTree" -> openStorageTreePicker(result)
                    "checkStorageTreeAccess" -> {
                        val treeUri = call.argument<String>("treeUri")
                        if (treeUri.isNullOrBlank()) {
                            result.error("invalid_args", "treeUri is required", null)
                            return@setMethodCallHandler
                        }
                        val uri = Uri.parse(treeUri)
                        result.success(
                            mapOf(
                                "available" to canAccessTree(applicationContext, uri),
                                "displayName" to resolveTreeDisplayName(applicationContext, uri),
                            ),
                        )
                    }

                    "writeStorageDocument" -> {
                        val treeUri = call.argument<String>("treeUri")
                        val fileName = call.argument<String>("fileName")
                        val bytesBase64 = call.argument<String>("bytesBase64")
                        if (treeUri.isNullOrBlank() || fileName.isNullOrBlank() || bytesBase64.isNullOrBlank()) {
                            result.error(
                                "invalid_args",
                                "treeUri, fileName, and bytesBase64 are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }

                        val documentUri = writeDocumentBytes(
                            context = applicationContext,
                            treeUri = Uri.parse(treeUri),
                            fileName = fileName,
                            bytes = Base64.decode(bytesBase64, Base64.NO_WRAP),
                        )
                        result.success(documentUri.toString())
                    }

                    "readStorageDocument" -> {
                        val documentUri = call.argument<String>("documentUri")
                        if (documentUri.isNullOrBlank()) {
                            result.error("invalid_args", "documentUri is required", null)
                            return@setMethodCallHandler
                        }
                        val bytes = readDocumentBytes(
                            context = applicationContext,
                            documentUri = Uri.parse(documentUri),
                        )
                        result.success(Base64.encodeToString(bytes, Base64.NO_WRAP))
                    }

                    "deleteStorageDocument" -> {
                        val documentUri = call.argument<String>("documentUri")
                        if (documentUri.isNullOrBlank()) {
                            result.error("invalid_args", "documentUri is required", null)
                            return@setMethodCallHandler
                        }
                        deleteDocumentIfExists(applicationContext, Uri.parse(documentUri))
                        result.success(null)
                    }

                    "migrateLocalFileToTree" -> {
                        val sourcePath = call.argument<String>("sourcePath")
                        val treeUri = call.argument<String>("treeUri")
                        val fileName = call.argument<String>("fileName")
                        if (sourcePath.isNullOrBlank() || treeUri.isNullOrBlank() || fileName.isNullOrBlank()) {
                            result.error(
                                "invalid_args",
                                "sourcePath, treeUri, and fileName are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        val documentUri = migrateLocalFileToTree(
                            context = applicationContext,
                            sourcePath = sourcePath,
                            treeUri = Uri.parse(treeUri),
                            fileName = fileName,
                        )
                        result.success(documentUri.toString())
                    }

                    "migrateTreeDocumentToLocalFile" -> {
                        val documentUri = call.argument<String>("documentUri")
                        val targetPath = call.argument<String>("targetPath")
                        if (documentUri.isNullOrBlank() || targetPath.isNullOrBlank()) {
                            result.error(
                                "invalid_args",
                                "documentUri and targetPath are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        migrateTreeDocumentToLocalFile(
                            context = applicationContext,
                            documentUri = Uri.parse(documentUri),
                            targetPath = targetPath,
                        )
                        result.success(null)
                    }

                    "cleanupPendingTreeDocuments" -> {
                        val treeUri = call.argument<String>("treeUri")
                        if (treeUri.isNullOrBlank()) {
                            result.error("invalid_args", "treeUri is required", null)
                            return@setMethodCallHandler
                        }
                        cleanupPendingTreeDocuments(
                            context = applicationContext,
                            treeUri = Uri.parse(treeUri),
                        )
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (error: MissingStorageException) {
                result.error("storage_unavailable", error.message, null)
            } catch (error: Exception) {
                result.error("storage_failure", error.message, null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            JOURNAL_LOCK_CHANNEL,
        ).setMethodCallHandler { call, result ->
            val credentialReference = call.argument<String>("credentialReference")
            if (credentialReference.isNullOrBlank()) {
                result.error("invalid_args", "credentialReference is required", null)
                return@setMethodCallHandler
            }

            try {
                when (call.method) {
                    "storeJournalSecret" -> {
                        val secretBase64 = call.argument<String>("secretBase64")
                        if (secretBase64.isNullOrBlank()) {
                            result.error("invalid_args", "secretBase64 is required", null)
                            return@setMethodCallHandler
                        }
                        storeJournalSecret(
                            context = applicationContext,
                            credentialReference = credentialReference,
                            secretBase64 = secretBase64,
                        )
                        result.success(null)
                    }

                    "loadJournalSecret" -> {
                        val secretBase64 = loadJournalSecret(
                            context = applicationContext,
                            credentialReference = credentialReference,
                        )
                        if (secretBase64 == null) {
                            result.error("missing_secret", "No journal secret found", null)
                        } else {
                            result.success(secretBase64)
                        }
                    }

                    "deleteJournalSecret" -> {
                        deleteJournalSecret(
                            context = applicationContext,
                            credentialReference = credentialReference,
                        )
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("keystore_failure", error.message, null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_PIN_LOCK_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "setAppPinCredential" -> {
                        val saltBase64 = call.argument<String>("saltBase64")
                        val verifierBase64 = call.argument<String>("verifierBase64")
                        val iterations = call.argument<Int>("iterations")
                        if (saltBase64.isNullOrBlank() ||
                            verifierBase64.isNullOrBlank() ||
                            iterations == null ||
                            iterations <= 0
                        ) {
                            result.error(
                                "invalid_args",
                                "saltBase64, verifierBase64, and iterations are required",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        setAppPinCredential(
                            context = applicationContext,
                            saltBase64 = saltBase64,
                            verifierBase64 = verifierBase64,
                            iterations = iterations,
                        )
                        result.success(null)
                    }

                    "getAppPinCredential" -> {
                        val payload = getAppPinCredential(applicationContext)
                        if (payload == null) {
                            result.success(null)
                        } else {
                            result.success(
                                mapOf(
                                    "saltBase64" to payload.saltBase64,
                                    "verifierBase64" to payload.verifierBase64,
                                    "iterations" to payload.iterations,
                                ),
                            )
                        }
                    }

                    "clearAppPinCredential" -> {
                        clearAppPinCredential(applicationContext)
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("keystore_failure", error.message, null)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            RUNTIME_ENVIRONMENT_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidSdkInt" -> result.success(android.os.Build.VERSION.SDK_INT)
                else -> result.notImplemented()
            }
        }

        // Screenshot / screen-recording protection. The window flag itself is set in
        // onCreate; this channel reports the saved choice and applies a new one at
        // once, so the switch in Settings takes effect without a restart.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SCREEN_SECURITY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isScreenSecurityEnabled" ->
                    result.success(isScreenSecurityEnabled(applicationContext))

                "setScreenSecurityEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled")
                    if (enabled == null) {
                        result.error("invalid_args", "enabled is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        setScreenSecurityEnabled(applicationContext, enabled)
                        runOnUiThread { applyScreenSecurity(enabled) }
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("screen_security_failure", error.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }

        // PDF export. Renders a self-contained local HTML page to PDF bytes in
        // an off-screen WebView — see JvHtmlToPdf for why a WebView rather than
        // a PDF library, and why it must be attached to the window.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            HTML_PDF_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                // Lets the export screen disable the PDF option up front
                // instead of offering a button that cannot work.
                "isAvailable" -> result.success(true)

                "convertHtml" -> {
                    val html = call.argument<String>("html")
                    if (html == null) {
                        result.error("bad_args", "html is required", null)
                        return@setMethodCallHandler
                    }
                    val widthPts = call.argument<Double>("widthPts") ?: 595.28
                    val heightPts = call.argument<Double>("heightPts") ?: 841.89
                    val marginPts = call.argument<Double>("marginPts") ?: 56.7
                    val timeoutMs = (call.argument<Int>("timeoutMs") ?: 60000).toLong()

                    JvHtmlToPdf(this).convert(
                        html,
                        widthPts,
                        heightPts,
                        marginPts,
                        timeoutMs,
                    ) { bytes, error, isTimeout ->
                        if (bytes != null) {
                            result.success(bytes)
                        } else {
                            // The Dart side maps these codes onto its own
                            // wording; the message is for the log only, since
                            // it can name a cache file path.
                            result.error(
                                if (isTimeout) "timeout" else "convert_failed",
                                error ?: "unknown error",
                                null,
                            )
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }

        shareChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_INTENT_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialShare" -> {
                        val payload = pendingSharePayload
                        pendingSharePayload = null
                        result.success(payload)
                    }
                    "clearPendingShare" -> {
                        pendingSharePayload = null
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NOTIFICATIONS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "showNotification" -> {
                    val id = call.argument<Int>("id") ?: 1
                    val title = call.argument<String>("title") ?: "Time Capsule"
                    val message = call.argument<String>("message") ?: ""
                    val channelId = call.argument<String>("channelId") ?: "time_capsules"
                    val channelName = call.argument<String>("channelName") ?: "Time Capsules"

                    try {
                        val notificationManager =
                            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val channel = NotificationChannel(
                                channelId,
                                channelName,
                                NotificationManager.IMPORTANCE_DEFAULT,
                            )
                            notificationManager.createNotificationChannel(channel)
                        }

                        val builder = NotificationCompat.Builder(this, channelId)
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(title)
                            .setContentText(message)
                            .setAutoCancel(true)
                            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

                        notificationManager.notify(id, builder.build())
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("notification_error", e.message, null)
                    }
                }
                "cancelNotification" -> {
                    val id = call.argument<Int>("id") ?: 1
                    try {
                        val notificationManager =
                            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        notificationManager.cancel(id)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("notification_error", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SPEECH_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "onDeviceSpeechStatus" -> reportOnDeviceSpeechStatus(result)
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TESSERACT_OCR_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "extractText" -> {
                    val imagePath = call.argument<String>("imagePath")
                    val language = call.argument<String>("language") ?: "eng+mal"
                    val requestId = call.argument<Int>("requestId") ?: 0
                    if (imagePath.isNullOrBlank()) {
                        result.error("invalid_args", "imagePath is required", null)
                        return@setMethodCallHandler
                    }
                    val imageFile = File(imagePath)
                    if (!imageFile.exists()) {
                        result.error("file_not_found", "Image file does not exist", null)
                        return@setMethodCallHandler
                    }

                    ocrExecutor.execute {
                        // Recognition runs one job at a time, so a job can sit in the
                        // queue long after the screen that asked for it has gone. Drop
                        // it instead of spending the CPU on an answer nobody wants.
                        if (isOcrRequestCancelled(requestId)) {
                            runOnUiThread { result.success("") }
                            return@execute
                        }
                        try {
                            ensureTessData(applicationContext)
                            val text = performTesseractOcr(applicationContext, imageFile, language)
                            runOnUiThread {
                                result.success(text)
                            }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("ocr_failure", e.message, null)
                            }
                        } finally {
                            clearCancelledOcrRequest(requestId)
                        }
                    }
                }
                "cancelOcr" -> {
                    val requestIds = call.argument<List<Int>>("requestIds")
                    if (requestIds == null) {
                        result.error("invalid_args", "requestIds is required", null)
                        return@setMethodCallHandler
                    }
                    synchronized(cancelledOcrRequests) {
                        cancelledOcrRequests.addAll(requestIds)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openStorageTreePicker(result: MethodChannel.Result) {
        if (pendingStorageTreeResult != null) {
            result.error("storage_unavailable", "Storage picker already active", null)
            return
        }

        pendingStorageTreeResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
        }
        storageTreePicker.launch(intent)
    }

    /**
     * Adds a clean white quiet-zone border around [src] so that dark edges or characters
     * touching the crop boundary do not confuse Tesseract's Leptonica binarizer.
     */
    private fun addQuietZonePadding(src: Bitmap, paddingPx: Int = 32): Bitmap {
        val paddedWidth = src.width + paddingPx * 2
        val paddedHeight = src.height + paddingPx * 2
        val output = Bitmap.createBitmap(paddedWidth, paddedHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        canvas.drawColor(Color.WHITE)
        canvas.drawBitmap(src, paddingPx.toFloat(), paddingPx.toFloat(), null)
        return output
    }

    /**
     * Returns a colour-inverted copy of [src].
     *
     * Tesseract and its Leptonica binarizer assume dark ink on light paper. Light
     * lettering on a dark band — a newspaper masthead, a titled banner, a slide —
     * is treated as background and dropped entirely. Recognising the inverted copy
     * as well is the only way that text is ever seen.
     */
    private fun invertBitmap(src: Bitmap): Bitmap {
        val output = Bitmap.createBitmap(src.width, src.height, Bitmap.Config.ARGB_8888)
        val matrix = ColorMatrix(
            floatArrayOf(
                -1f, 0f, 0f, 0f, 255f,
                0f, -1f, 0f, 0f, 255f,
                0f, 0f, -1f, 0f, 255f,
                0f, 0f, 0f, 1f, 0f,
            ),
        )
        val paint = Paint().apply { colorFilter = ColorMatrixColorFilter(matrix) }
        Canvas(output).drawBitmap(src, 0f, 0f, paint)
        return output
    }

    /**
     * Mean luminance of [src] on a 0..255 scale, measured on a small sampled copy
     * so a full-resolution photo is not walked pixel by pixel.
     */
    private fun meanLuminance(src: Bitmap): Int {
        val sample = Bitmap.createScaledBitmap(src, SAMPLE_EDGE, SAMPLE_EDGE, true)
        return try {
            val pixels = IntArray(SAMPLE_EDGE * SAMPLE_EDGE)
            sample.getPixels(pixels, 0, SAMPLE_EDGE, 0, 0, SAMPLE_EDGE, SAMPLE_EDGE)
            var total = 0L
            for (pixel in pixels) {
                val r = (pixel shr 16) and 0xFF
                val g = (pixel shr 8) and 0xFF
                val b = pixel and 0xFF
                total += (r * 299 + g * 587 + b * 114) / 1000
            }
            (total / pixels.size).toInt()
        } finally {
            if (sample !== src) sample.recycle()
        }
    }

    /** One recognised word, with what we need to keep it and place it. */
    private data class RecognisedWord(
        val text: String,
        val confidence: Float,
        val hasMalayalam: Boolean,
        val endsLine: Boolean,
        val lineLeft: Int,
        val lineTop: Int,
        val lineRight: Int,
        val lineBottom: Int,
    )

    /** True when [text] contains at least one letter from the Malayalam block. */
    private fun hasMalayalamLetter(text: String): Boolean {
        return text.any { it in MALAYALAM_BLOCK_START..MALAYALAM_BLOCK_END }
    }

    /**
     * Rebuilds the recognised text, dropping only words the recognizer was unsure
     * about *and* that are the wrong script for the page, then putting the
     * surviving lines into reading order.
     *
     * Running two languages at once means that when Tesseract meets a shape that
     * is not a letter at all — a printed ornament, a rule, a logo mark — it still
     * tries to name it, and a Latin letter is the easiest fit. Those are the words
     * worth dropping.
     *
     * A single confidence floor cannot express that. Real Malayalam photographed
     * off newsprint scores low too, and deleting a correct word is worse than
     * keeping a slightly wrong one: a reader can mend a wrong letter, but cannot
     * recover a word that is not there. So Malayalam words face a low floor and
     * keep almost everything, while a non-Malayalam word on a Malayalam page —
     * the ornament case, and only that — faces a high one.
     *
     * An English-only scan keeps every word. The filter exists to remove
     * ornaments misread on Malayalam pages; on an English page it only threw
     * away real words that a phone photo leaves with low confidence.
     *
     * Returns `null` when there is nothing to walk, so the caller can fall back.
     */
    private fun collectConfidentText(tess: TessBaseAPI, language: String): String? {
        val keepEverything = !language.contains("mal")
        val iterator = tess.resultIterator ?: return null
        val words = mutableListOf<RecognisedWord>()
        try {
            iterator.begin()
            do {
                val word = iterator
                    .getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_WORD)
                    ?.trim()
                    .orEmpty()
                val endsLine = iterator.isAtFinalElement(
                    TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE,
                    TessBaseAPI.PageIteratorLevel.RIL_WORD,
                )
                if (word.isNotEmpty()) {
                    // Left, top, right, bottom of the line this word sits on.
                    val box = iterator.getBoundingBox(
                        TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE,
                    )
                    words.add(
                        RecognisedWord(
                            text = word,
                            confidence = iterator.confidence(
                                TessBaseAPI.PageIteratorLevel.RIL_WORD,
                            ),
                            hasMalayalam = hasMalayalamLetter(word),
                            endsLine = endsLine,
                            lineLeft = box[0],
                            lineTop = box[1],
                            lineRight = box[2],
                            lineBottom = box[3],
                        ),
                    )
                } else if (endsLine && words.isNotEmpty()) {
                    words[words.size - 1] = words.last().copy(endsLine = true)
                }
            } while (iterator.next(TessBaseAPI.PageIteratorLevel.RIL_WORD))
        } finally {
            iterator.delete()
        }

        if (words.isEmpty()) return ""

        // Decide what kind of page this is, counting only words that clear the low
        // floor so that junk cannot vote. The high floor applies only to a page
        // that is clearly Malayalam. A mixed page, where some English words were
        // misread as Malayalam shapes, must keep its English words.
        val readable = words.filter { it.confidence >= MALAYALAM_CONFIDENCE_FLOOR }
        val malayalamCount = readable.count { it.hasMalayalam }
        val pageIsMalayalam = readable.isNotEmpty() &&
            malayalamCount >= readable.size * MALAYALAM_PAGE_SHARE

        val lines = mutableListOf<TextLineBox>()
        val lineText = StringBuilder()
        var left = 0
        var top = 0
        var right = 0
        var bottom = 0
        var started = false

        fun flushLine() {
            if (lineText.isEmpty()) return
            lines.add(TextLineBox(left, top, right, bottom, lineText.toString()))
            lineText.clear()
            started = false
        }

        for (word in words) {
            val floor = if (keepEverything) {
                0f
            } else if (word.hasMalayalam || !pageIsMalayalam) {
                MALAYALAM_CONFIDENCE_FLOOR
            } else {
                FOREIGN_CONFIDENCE_FLOOR
            }
            if (word.confidence >= floor) {
                if (lineText.isNotEmpty()) lineText.append(' ')
                lineText.append(word.text)
                if (started) {
                    left = minOf(left, word.lineLeft)
                    top = minOf(top, word.lineTop)
                    right = maxOf(right, word.lineRight)
                    bottom = maxOf(bottom, word.lineBottom)
                } else {
                    left = word.lineLeft
                    top = word.lineTop
                    right = word.lineRight
                    bottom = word.lineBottom
                    started = true
                }
            }
            if (word.endsLine) flushLine()
        }
        flushLine()

        return orderLinesForReading(lines).joinToString("\n") { it.text }.trim()
    }

    /**
     * Scores one recognition result. A pass is better when it is both confident and
     * finds more words, so a stray high-confidence fragment cannot beat a full line
     * of slightly less certain text.
     */
    private fun scoreRecognition(text: String, confidence: Int): Int {
        if (text.isBlank()) return 0
        val words = text.split(Regex("\\s+")).count { it.isNotBlank() }
        return confidence * words
    }

    /** One recognition attempt: a page segmentation mode against a given bitmap. */
    private fun isOcrRequestCancelled(requestId: Int): Boolean =
        synchronized(cancelledOcrRequests) { cancelledOcrRequests.contains(requestId) }

    private fun clearCancelledOcrRequest(requestId: Int) {
        synchronized(cancelledOcrRequests) { cancelledOcrRequests.remove(requestId) }
    }

    private data class OcrPass(val bitmap: Bitmap, val pageSegMode: Int)

    @Synchronized
    private fun performTesseractOcr(
        context: Context,
        imageFile: File,
        language: String,
    ): String {
        val datapath = context.filesDir.absolutePath
        val tess = activeTessApi ?: TessBaseAPI().also {
            activeTessApi = it
        }

        if (activeTessLang != language) {
            val success = tess.init(datapath, language)
            if (!success) {
                val fallbackLang = if (language.contains("eng")) "eng" else "mal"
                val fallbackSuccess = tess.init(datapath, fallbackLang)
                if (!fallbackSuccess) {
                    throw IllegalStateException("Failed to initialize Tesseract with language: $language")
                }
                activeTessLang = fallbackLang
            } else {
                activeTessLang = language
            }
        }

        // Our images are resized PNGs with no DPI metadata, so Tesseract's own
        // resolution guess is wrong and the LSTM line model loses accuracy on
        // vowel signs and ligatures. Telling it the effective DPI fixes that.
        tess.setVariable("user_defined_dpi", "300")
        tess.setVariable("preserve_interword_spaces", "1")

        val rawBitmap = BitmapFactory.decodeFile(imageFile.absolutePath)
            ?: throw IllegalArgumentException("Could not decode image file: ${imageFile.name}")

        // Add a clean white quiet-zone padding around the image. Tight crops often have
        // dark borders or character strokes that touch the edge, causing Leptonica to treat
        // them as page frames/borders and discard all text lines.
        val bitmap = addQuietZonePadding(rawBitmap, paddingPx = 32)
        if (bitmap !== rawBitmap) {
            rawBitmap.recycle()
        }

        // A dark-dominant image is very likely light text on a dark ground. Recognise
        // the inverted copy too and let the scoring below decide which reading wins.
        // A normal light page skips this entirely and stays as fast as before.
        val inverted = if (meanLuminance(bitmap) < DARK_IMAGE_LUMINANCE) {
            invertBitmap(bitmap)
        } else {
            null
        }

        return try {
            val passes = mutableListOf<OcrPass>()
            for (mode in PAGE_SEG_MODES) {
                passes.add(OcrPass(bitmap, mode))
            }
            if (inverted != null) {
                for (mode in PAGE_SEG_MODES) {
                    passes.add(OcrPass(inverted, mode))
                }
            }

            var bestText = ""
            var bestScore = 0
            for (pass in passes) {
                tess.pageSegMode = pass.pageSegMode
                tess.setImage(pass.bitmap)
                val rawText = tess.utF8Text?.trim() ?: ""
                // Prefer the confidence-filtered reading. If the floor stripped
                // everything but the recognizer did find words, keep the unfiltered
                // text — a tuning value must never turn a working scan blank.
                val filtered = collectConfidentText(tess, activeTessLang ?: language)
                val text = if (filtered.isNullOrEmpty()) rawText else filtered
                if (text.isNotEmpty()) {
                    val meanConfidence = tess.meanConfidence()
                    val score = scoreRecognition(text, meanConfidence)
                    if (score > bestScore) {
                        bestScore = score
                        bestText = text
                    }
                    // A clean page is read well on its first pass. Stop there rather
                    // than spending more passes to confirm it. Both a high score and a
                    // high mean confidence are needed: a score alone is reached by a
                    // long main block even when a heading or a column was missed.
                    if (score >= CONFIDENT_SCORE && meanConfidence >= CONFIDENT_MEAN) break
                }
            }

            tess.clear()
            bestText
        } finally {
            inverted?.recycle()
            bitmap.recycle()
        }
    }
}

private fun getAttachmentKey(
    context: Context,
    keyReference: String,
    createIfMissing: Boolean,
): String? {
    val prefs = context.getSharedPreferences(ATTACHMENT_KEY_PREFS, Context.MODE_PRIVATE)
    val wrappedKey = prefs.getString(keyReference, null)
    val wrappingKey = getOrCreateWrappingKey(ATTACHMENT_WRAPPING_KEY_ALIAS)

    if (wrappedKey != null) {
        return unwrapPayload(wrappingKey, wrappedKey)
    }
    if (!createIfMissing) {
        return null
    }

    val rawKey = ByteArray(32)
    Random.Default.nextBytes(rawKey)
    val payload = wrapPayload(wrappingKey, rawKey)
    prefs.edit().putString(keyReference, payload).apply()
    return Base64.encodeToString(rawKey, Base64.NO_WRAP)
}

/**
 * Returns the raw SQLCipher key for the journal database, base64 encoded.
 *
 * The key is 32 bytes from [SecureRandom]. It is stored only in wrapped form:
 * AES-256-GCM ciphertext under a Keystore-resident wrapping key, written to a
 * private SharedPreferences file as "iv:ciphertext". The raw bytes exist in
 * Dart only for the moment it takes to hand them to SQLCipher.
 *
 * Returns null when no key exists and [createIfMissing] is false. Callers must
 * treat that as "the vault cannot be opened" — never as "make a new one",
 * which would leave the old database unreadable and look like data loss.
 */
private fun getDatabaseKey(
    context: Context,
    createIfMissing: Boolean,
): String? {
    val prefs = context.getSharedPreferences(DATABASE_KEY_PREFS, Context.MODE_PRIVATE)
    val wrappedKey = prefs.getString(DATABASE_KEY_NAME, null)
    val wrappingKey = getOrCreateWrappingKey(DATABASE_WRAPPING_KEY_ALIAS)

    if (wrappedKey != null) {
        return unwrapPayload(wrappingKey, wrappedKey)
    }
    if (!createIfMissing) {
        return null
    }

    val rawKey = ByteArray(32)
    SecureRandom().nextBytes(rawKey)
    val payload = wrapPayload(wrappingKey, rawKey)
    // commit(), not apply(): the key must be on disk before the database is
    // encrypted with it. An asynchronous write lost to a crash would strand
    // the vault behind a key that no longer exists anywhere.
    prefs.edit().putString(DATABASE_KEY_NAME, payload).commit()
    return Base64.encodeToString(rawKey, Base64.NO_WRAP)
}

private fun storeJournalSecret(
    context: Context,
    credentialReference: String,
    secretBase64: String,
) {
    val prefs = context.getSharedPreferences(JOURNAL_SECRET_PREFS, Context.MODE_PRIVATE)
    val wrappingKey = getOrCreateWrappingKey(JOURNAL_WRAPPING_KEY_ALIAS)
    val secretBytes = Base64.decode(secretBase64, Base64.NO_WRAP)
    val payload = wrapPayload(wrappingKey, secretBytes)
    prefs.edit().putString(credentialReference, payload).apply()
}

private fun loadJournalSecret(
    context: Context,
    credentialReference: String,
): String? {
    val prefs = context.getSharedPreferences(JOURNAL_SECRET_PREFS, Context.MODE_PRIVATE)
    val wrappedPayload = prefs.getString(credentialReference, null) ?: return null
    val wrappingKey = getOrCreateWrappingKey(JOURNAL_WRAPPING_KEY_ALIAS)
    return unwrapPayload(wrappingKey, wrappedPayload)
}

private fun deleteJournalSecret(
    context: Context,
    credentialReference: String,
) {
    val prefs = context.getSharedPreferences(JOURNAL_SECRET_PREFS, Context.MODE_PRIVATE)
    prefs.edit().remove(credentialReference).apply()
}

private data class AppPinCredentialPayload(
    val saltBase64: String,
    val verifierBase64: String,
    val iterations: Int,
)

private fun setAppPinCredential(
    context: Context,
    saltBase64: String,
    verifierBase64: String,
    iterations: Int,
) {
    val prefs = context.getSharedPreferences(APP_PIN_PREFS, Context.MODE_PRIVATE)
    val wrappingKey = getOrCreateWrappingKey(APP_PIN_WRAPPING_KEY_ALIAS)
    val saltBytes = Base64.decode(saltBase64, Base64.NO_WRAP)
    val verifierBytes = Base64.decode(verifierBase64, Base64.NO_WRAP)
    val saltPayload = wrapPayload(wrappingKey, saltBytes)
    val verifierPayload = wrapPayload(wrappingKey, verifierBytes)
    prefs.edit()
        .putString(APP_PIN_KEY_SALT, saltPayload)
        .putString(APP_PIN_KEY_VERIFIER, verifierPayload)
        .putInt(APP_PIN_KEY_ITERATIONS, iterations)
        .apply()
}

private fun getAppPinCredential(context: Context): AppPinCredentialPayload? {
    val prefs = context.getSharedPreferences(APP_PIN_PREFS, Context.MODE_PRIVATE)
    val saltPayload = prefs.getString(APP_PIN_KEY_SALT, null) ?: return null
    val verifierPayload = prefs.getString(APP_PIN_KEY_VERIFIER, null) ?: return null
    val iterations = prefs.getInt(APP_PIN_KEY_ITERATIONS, 0).takeIf { it > 0 } ?: return null
    val wrappingKey = getOrCreateWrappingKey(APP_PIN_WRAPPING_KEY_ALIAS)
    val saltBase64 = unwrapPayload(wrappingKey, saltPayload)
    val verifierBase64 = unwrapPayload(wrappingKey, verifierPayload)
    return AppPinCredentialPayload(
        saltBase64 = saltBase64,
        verifierBase64 = verifierBase64,
        iterations = iterations,
    )
}

private fun clearAppPinCredential(context: Context) {
    val prefs = context.getSharedPreferences(APP_PIN_PREFS, Context.MODE_PRIVATE)
    prefs.edit().clear().apply()
}

private fun writeDocumentBytes(
    context: Context,
    treeUri: Uri,
    fileName: String,
    bytes: ByteArray,
): Uri {
    val tree = requireWritableTree(context, treeUri)
    val document = createDocument(tree, fileName)
    try {
        context.contentResolver.openOutputStream(document.uri, "w")?.use { output ->
            output.write(bytes)
            output.flush()
        } ?: throw MissingStorageException("Could not open the selected SD card file")
        return document.uri
    } catch (error: Exception) {
        document.delete()
        throw error
    }
}

private fun readDocumentBytes(
    context: Context,
    documentUri: Uri,
): ByteArray {
    val document = DocumentFile.fromSingleUri(context, documentUri)
        ?: throw MissingStorageException("External attachment file is missing")
    if (!document.exists()) {
        throw MissingStorageException("External attachment file is missing")
    }
    return context.contentResolver.openInputStream(documentUri)?.use { input ->
        input.readBytes()
    } ?: throw MissingStorageException("Could not open external attachment file")
}

private fun deleteDocumentIfExists(
    context: Context,
    documentUri: Uri,
) {
    val document = DocumentFile.fromSingleUri(context, documentUri) ?: return
    if (document.exists()) {
        document.delete()
    }
}

private fun migrateLocalFileToTree(
    context: Context,
    sourcePath: String,
    treeUri: Uri,
    fileName: String,
): Uri {
    val sourceFile = File(sourcePath)
    if (!sourceFile.exists()) {
        throw MissingStorageException("Attachment file is missing from app-private storage")
    }

    val tree = requireWritableTree(context, treeUri)
    val tempDocument = createDocument(tree, "$fileName$ATTACHMENT_MIGRATION_TEMP_SUFFIX")
    try {
        FileInputStream(sourceFile).use { input ->
            context.contentResolver.openOutputStream(tempDocument.uri, "w")?.use { output ->
                copyStream(input, output)
            } ?: throw MissingStorageException("Could not open SD card destination file")
        }
        if (!tempDocument.renameTo(fileName)) {
            throw MissingStorageException("Could not finalize the SD card attachment file")
        }
        return tempDocument.uri
    } catch (error: Exception) {
        tempDocument.delete()
        throw error
    }
}

private fun migrateTreeDocumentToLocalFile(
    context: Context,
    documentUri: Uri,
    targetPath: String,
) {
    val document = DocumentFile.fromSingleUri(context, documentUri)
        ?: throw MissingStorageException("External attachment file is missing")
    if (!document.exists()) {
        throw MissingStorageException("External attachment file is missing")
    }

    val targetFile = File(targetPath)
    targetFile.parentFile?.mkdirs()
    try {
        context.contentResolver.openInputStream(documentUri)?.use { input ->
            FileOutputStream(targetFile).use { output ->
                copyStream(input, output)
            }
        } ?: throw MissingStorageException("Could not open external attachment file")
    } catch (error: Exception) {
        targetFile.delete()
        throw error
    }
}

private fun cleanupPendingTreeDocuments(
    context: Context,
    treeUri: Uri,
) {
    val tree = requireWritableTree(context, treeUri)
    tree.listFiles().forEach { child ->
        if (child.name?.endsWith(ATTACHMENT_MIGRATION_TEMP_SUFFIX) == true) {
            child.delete()
        }
    }
}

private fun canAccessTree(context: Context, treeUri: Uri): Boolean {
    return try {
        val tree = DocumentFile.fromTreeUri(context, treeUri) ?: return false
        tree.canRead() && tree.canWrite() && tree.exists()
    } catch (_: Exception) {
        false
    }
}

private fun resolveTreeDisplayName(
    context: Context,
    treeUri: Uri,
): String {
    return try {
        DocumentFile.fromTreeUri(context, treeUri)?.name ?: "SD Card"
    } catch (_: Exception) {
        "SD Card"
    }
}

private fun requireWritableTree(
    context: Context,
    treeUri: Uri,
): DocumentFile {
    val tree = DocumentFile.fromTreeUri(context, treeUri)
        ?: throw MissingStorageException("Selected SD card location is unavailable")
    if (!tree.exists() || !tree.canRead() || !tree.canWrite()) {
        throw MissingStorageException(
            "Selected SD card location is unavailable or permission was revoked",
        )
    }
    return tree
}

private fun createDocument(
    tree: DocumentFile,
    fileName: String,
): DocumentFile {
    tree.findFile(fileName)?.delete()
    return tree.createFile("application/octet-stream", sanitizeFileName(fileName))
        ?: throw MissingStorageException("Could not create a file in the selected SD card location")
}

private fun sanitizeFileName(name: String): String {
    return name.replace(Regex("[^a-zA-Z0-9._-]"), "_")
}

private fun copyStream(
    input: InputStream,
    output: OutputStream,
) {
    val buffer = ByteArray(DEFAULT_STREAM_BUFFER_SIZE)
    while (true) {
        val read = input.read(buffer)
        if (read <= 0) {
            break
        }
        output.write(buffer, 0, read)
    }
    output.flush()
}

private fun wrapPayload(wrappingKey: SecretKey, rawBytes: ByteArray): String {
    val cipher = Cipher.getInstance(AES_MODE)
    cipher.init(Cipher.ENCRYPT_MODE, wrappingKey)
    val encrypted = cipher.doFinal(rawBytes)
    return listOf(
        Base64.encodeToString(cipher.iv, Base64.NO_WRAP),
        Base64.encodeToString(encrypted, Base64.NO_WRAP),
    ).joinToString(":")
}

private fun unwrapPayload(wrappingKey: SecretKey, wrappedPayload: String): String {
    val parts = wrappedPayload.split(':')
    require(parts.size == 2) { "Wrapped payload is invalid" }

    val iv = Base64.decode(parts[0], Base64.NO_WRAP)
    val encrypted = Base64.decode(parts[1], Base64.NO_WRAP)
    val cipher = Cipher.getInstance(AES_MODE)
    cipher.init(
        Cipher.DECRYPT_MODE,
        wrappingKey,
        GCMParameterSpec(128, iv),
    )
    val decrypted = cipher.doFinal(encrypted)
    return Base64.encodeToString(decrypted, Base64.NO_WRAP)
}

private fun getOrCreateWrappingKey(alias: String): SecretKey {
    val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE).apply {
        load(null)
    }

    val existing = keyStore.getKey(alias, null) as? SecretKey
    if (existing != null) {
        return existing
    }

    val generator = KeyGenerator.getInstance(
        KeyProperties.KEY_ALGORITHM_AES,
        ANDROID_KEY_STORE,
    )
    generator.init(
        KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        ).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .setKeySize(256)
            .build(),
    )
    return generator.generateKey()
}

private class MissingStorageException(message: String) : IOException(message)

/**
 * Reads the user's screenshot-protection choice. Defaults to enabled, and stays
 * enabled if the preference store cannot be read, so a failure never leaves the
 * window unprotected.
 */
private fun isScreenSecurityEnabled(context: Context): Boolean = try {
    context
        .getSharedPreferences(SCREEN_SECURITY_PREFS, Context.MODE_PRIVATE)
        .getBoolean(SCREEN_SECURITY_KEY_ENABLED, true)
} catch (error: Exception) {
    true
}

private fun setScreenSecurityEnabled(context: Context, enabled: Boolean) {
    context
        .getSharedPreferences(SCREEN_SECURITY_PREFS, Context.MODE_PRIVATE)
        .edit()
        .putBoolean(SCREEN_SECURITY_KEY_ENABLED, enabled)
        .apply()
}

private const val ATTACHMENT_KEY_CHANNEL = "sreerajp.journal_vault/attachment_keys"
private const val DATABASE_KEY_CHANNEL = "sreerajp.journal_vault/database_key"
private const val ATTACHMENT_STORAGE_CHANNEL = "sreerajp.journal_vault/attachment_storage"
private const val JOURNAL_LOCK_CHANNEL = "sreerajp.journal_vault/journal_lock"
private const val APP_PIN_LOCK_CHANNEL = "sreerajp.journal_vault/app_pin_lock"
private const val ATTACHMENT_KEY_PREFS = "attachment_keys"
private const val DATABASE_KEY_PREFS = "database_key"
private const val DATABASE_KEY_NAME = "vault_db_key_v1"
private const val JOURNAL_SECRET_PREFS = "journal_lock_secrets"
private const val APP_PIN_PREFS = "app_pin_lock"
private const val APP_PIN_KEY_SALT = "salt"
private const val APP_PIN_KEY_VERIFIER = "verifier"
private const val APP_PIN_KEY_ITERATIONS = "iterations"
private const val ATTACHMENT_WRAPPING_KEY_ALIAS = "sreerajp_journal_vault_attachment_wrap_v1"
private const val JOURNAL_WRAPPING_KEY_ALIAS = "sreerajp_journal_vault_journal_lock_wrap_v1"
private const val APP_PIN_WRAPPING_KEY_ALIAS = "sreerajp_journal_vault_app_pin_wrap_v1"
private const val DATABASE_WRAPPING_KEY_ALIAS = "sreerajp_journal_vault_database_wrap_v1"
private const val RUNTIME_ENVIRONMENT_CHANNEL = "sreerajp.journal_vault/runtime_environment"
private const val HTML_PDF_CHANNEL = "sreerajp.journal_vault/html_pdf"
private const val SCREEN_SECURITY_CHANNEL = "sreerajp.journal_vault/screen_security"
private const val SHARE_INTENT_CHANNEL = "sreerajp.journal_vault/share_intent"
private const val NOTIFICATIONS_CHANNEL = "sreerajp.journal_vault/notifications"
private const val TESSERACT_OCR_CHANNEL = "sreerajp.journal_vault/ocr"
private const val SPEECH_CHANNEL = "sreerajp.journal_vault/speech"

/**
 * Identifies the set of language models currently shipped in assets.
 *
 * `ensureTessData` copies the models to internal storage once and then leaves
 * them alone, so an app update carrying a new model would never replace the old
 * copy. Bumping this string forces one re-copy. Change it whenever any file in
 * `assets/tessdata/` changes.
 */
private const val TESSDATA_VERSION = "2026-09-16-eng-best-mal-best"

/** Name of the marker file recording which model set is on disk. */
private const val TESSDATA_VERSION_FILE = ".model_version"

/** First character of the Unicode Malayalam block. */
private const val MALAYALAM_BLOCK_START = '\u0D00'

/** Last character of the Unicode Malayalam block. */
private const val MALAYALAM_BLOCK_END = '\u0D7F'

/**
 * Word confidence (0..100) below which a word in the page's own script is
 * discarded.
 *
 * Deliberately low. Malayalam photographed off newsprint often scores in the
 * forties, and losing a correct word costs the reader more than keeping a
 * slightly wrong one.
 */
private const val MALAYALAM_CONFIDENCE_FLOOR = 30f

/**
 * Word confidence (0..100) below which a word that is *not* in the page's script
 * is discarded — a Latin word on a Malayalam page.
 *
 * Ornaments, rules and logo marks are reported this way and score well under 40.
 * Raise this, never the floor above, if such junk starts appearing again.
 */
private const val FOREIGN_CONFIDENCE_FLOOR = 60f

/**
 * Share of readable words (0..1) that must be Malayalam before a page counts as
 * Malayalam and [FOREIGN_CONFIDENCE_FLOOR] applies to its other words. A simple
 * majority let mixed pages lose their English words.
 */
private const val MALAYALAM_PAGE_SHARE = 0.7

/** Edge length of the downscaled copy used to measure average brightness. */
private const val SAMPLE_EDGE = 32

/**
 * Mean luminance (0..255) below which an image counts as dark-dominant and is
 * also recognised inverted.
 */
private const val DARK_IMAGE_LUMINANCE = 110

/**
 * Score (mean confidence x word count) above which a pass is considered good
 * enough to stop trying the remaining page segmentation modes.
 */
private const val CONFIDENT_SCORE = 2400

/**
 * Mean confidence (0..100) a pass must also reach before the remaining page
 * segmentation modes are skipped.
 */
private const val CONFIDENT_MEAN = 85

/**
 * Page segmentation modes tried in order: a full page first, then a single
 * uniform block for crops and columns, then sparse text for banners, headers
 * and scattered words. Every mode is scored and the best reading wins — an
 * earlier mode returning *some* text no longer blocks the later ones.
 */
private val PAGE_SEG_MODES = listOf(
    TessBaseAPI.PageSegMode.PSM_AUTO,
    TessBaseAPI.PageSegMode.PSM_SINGLE_BLOCK,
    TessBaseAPI.PageSegMode.PSM_SPARSE_TEXT,
)
private const val SCREEN_SECURITY_PREFS = "screen_security"
private const val SCREEN_SECURITY_KEY_ENABLED = "enabled"
private const val ANDROID_KEY_STORE = "AndroidKeyStore"
private const val AES_MODE = "AES/GCM/NoPadding"
private const val ATTACHMENT_MIGRATION_TEMP_SUFFIX = ".migrating"
private const val DEFAULT_STREAM_BUFFER_SIZE = 64 * 1024

private fun extractSharePayload(context: Context, intent: Intent?): Map<String, Any?>? {
    if (intent == null) return null
    val action = intent.action ?: return null

    when (action) {
        Intent.ACTION_SEND -> {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT)
            val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            val streamUri = if (android.os.Build.VERSION.SDK_INT >= 33) {
                intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            }

            val mediaItems = mutableListOf<Map<String, Any?>>()
            if (streamUri != null) {
                val item = resolveMediaItem(context, streamUri)
                if (item != null) mediaItems.add(item)
            }

            if (text.isNullOrBlank() && subject.isNullOrBlank() && mediaItems.isEmpty()) {
                return null
            }

            val type = when {
                mediaItems.any {
                    val fn = (it["fileName"] as? String)?.lowercase() ?: ""
                    fn.endsWith(".jvenc") || fn.endsWith(".jvbk")
                } -> "sealedFile"
                mediaItems.isNotEmpty() -> "media"
                else -> "text"
            }

            return mapOf(
                "type" to type,
                "text" to text,
                "subject" to subject,
                "mediaItems" to mediaItems,
            )
        }
        Intent.ACTION_SEND_MULTIPLE -> {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT)
            val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            val streamUris = if (android.os.Build.VERSION.SDK_INT >= 33) {
                intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
            }

            val mediaItems = mutableListOf<Map<String, Any?>>()
            streamUris?.forEach { uri ->
                val item = resolveMediaItem(context, uri)
                if (item != null) mediaItems.add(item)
            }

            if (text.isNullOrBlank() && subject.isNullOrBlank() && mediaItems.isEmpty()) {
                return null
            }

            return mapOf(
                "type" to "media",
                "text" to text,
                "subject" to subject,
                "mediaItems" to mediaItems,
            )
        }
        Intent.ACTION_VIEW -> {
            val dataUri = intent.data ?: return null
            val item = resolveMediaItem(context, dataUri) ?: return null
            return mapOf(
                "type" to "sealedFile",
                "text" to null,
                "subject" to null,
                "mediaItems" to listOf(item),
            )
        }
        else -> return null
    }
}

private fun resolveMediaItem(context: Context, uri: Uri): Map<String, Any?>? {
    try {
        var fileName: String? = null
        val contextResolver = context.contentResolver

        if (uri.scheme == "content") {
            val cursor = contextResolver.query(
                uri,
                arrayOf(android.provider.OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )
            cursor?.use {
                if (it.moveToFirst()) {
                    val nameIndex = it.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                    if (nameIndex != -1) {
                        fileName = it.getString(nameIndex)
                    }
                }
            }
        }
        if (fileName.isNullOrBlank()) {
            fileName = uri.lastPathSegment ?: "shared_attachment"
        }

        val mimeType = contextResolver.getType(uri) ?: "application/octet-stream"
        val bytes = contextResolver.openInputStream(uri)?.use { it.readBytes() } ?: return null

        return mapOf(
            "fileName" to fileName,
            "mimeType" to mimeType,
            "bytesBase64" to Base64.encodeToString(bytes, Base64.NO_WRAP),
        )
    } catch (_: Exception) {
        return null
    }
}

private fun ensureTessData(context: Context) {
    val tessDataDir = File(context.filesDir, "tessdata")
    if (!tessDataDir.exists()) {
        tessDataDir.mkdirs()
    }

    // The models on disk are only replaced when the shipped set changes. Without
    // this check an app update carrying a new model would keep using the old copy
    // for everyone who already had the app installed.
    val versionFile = File(tessDataDir, TESSDATA_VERSION_FILE)
    val installedVersion = try {
        if (versionFile.exists()) versionFile.readText().trim() else null
    } catch (_: Exception) {
        null
    }
    val needsRefresh = installedVersion != TESSDATA_VERSION

    for (lang in listOf("eng", "mal")) {
        val targetFile = File(tessDataDir, "$lang.traineddata")
        val possibleAssetPaths = listOf(
            "flutter_assets/assets/tessdata/$lang.traineddata",
            "assets/tessdata/$lang.traineddata",
        )
        if (needsRefresh || !targetFile.exists() || targetFile.length() == 0L) {
            for (assetPath in possibleAssetPaths) {
                try {
                    context.assets.open(assetPath).use { input ->
                        FileOutputStream(targetFile).use { output ->
                            input.copyTo(output)
                        }
                    }
                    if (targetFile.exists() && targetFile.length() > 0L) {
                        break
                    }
                } catch (_: Exception) {
                    // Try next path
                }
            }
        }
    }

    // Record the version only once every model is actually on disk, so a copy that
    // failed part way is retried on the next run instead of being marked done.
    if (needsRefresh) {
        val allPresent = listOf("eng", "mal").all { lang ->
            File(tessDataDir, "$lang.traineddata").let { it.exists() && it.length() > 0L }
        }
        if (allPresent) {
            try {
                versionFile.writeText(TESSDATA_VERSION)
            } catch (_: Exception) {
                // Losing the marker only costs one extra copy on the next launch.
            }
        }
    }
}
