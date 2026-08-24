package `in`.sreerajp.sreerajp_journal_vault

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
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

class MainActivity : FlutterFragmentActivity() {
    private var pendingStorageTreeResult: MethodChannel.Result? = null
    private var shareChannel: MethodChannel? = null
    private var pendingSharePayload: Map<String, Any?>? = null

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


