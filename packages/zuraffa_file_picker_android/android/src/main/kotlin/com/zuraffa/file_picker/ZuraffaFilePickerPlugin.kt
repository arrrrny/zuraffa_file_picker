package com.zuraffa.file_picker

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.io.File
import java.util.UUID

/**
 * The Android file picker: the system document picker (Storage Access
 * Framework) behind the shared `zuraffa_file_picker` channel.
 *
 * Picked documents are copied into the app cache so every descriptor
 * carries a readable filesystem path; `saveFile` writes optional bytes
 * into the created document and returns a readable snapshot path.
 * A dismissed picker resolves `null` — cancellation is a value, never
 * an exception.
 */
class ZuraffaFilePickerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    ActivityAware, PluginRegistry.ActivityResultListener {

    companion object {
        private const val CHANNEL_NAME = "zuraffa_file_picker"
        private const val PICK_FILES_REQUEST = 40781
        private const val SAVE_FILE_REQUEST = 40782
        private const val PICK_DIRECTORY_REQUEST = 40783

        private const val KEY_TYPE = "type"
        private const val KEY_EXTENSIONS = "allowedExtensions"
        private const val KEY_MULTIPLE = "multiple"
        private const val KEY_INITIAL_DIRECTORY = "initialDirectory"
        private const val KEY_FILE_NAME = "fileName"
        private const val KEY_BYTES = "bytes"

        private const val KEY_PATH = "path"
        private const val KEY_NAME = "name"
        private const val KEY_SIZE = "size"
        private const val KEY_MIME = "mimeType"

        private const val TYPE_ANY = "any"
        private const val TYPE_MEDIA = "media"
        private const val TYPE_IMAGE = "image"
        private const val TYPE_VIDEO = "video"
        private const val TYPE_AUDIO = "audio"
        private const val TYPE_CUSTOM = "custom"
    }

    private var channel: MethodChannel? = null
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null
    private var saveBytes: ByteArray? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel!!.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(
        call: io.flutter.plugin.common.MethodCall,
        result: MethodChannel.Result,
    ) {
        if (pendingResult != null) {
            result.error("already_active", "Another picker operation is in progress.", null)
            return
        }
        when (call.method) {
            "pickFiles" -> pickFiles(call.arguments(), result)
            "saveFile" -> saveFile(call.arguments(), result)
            "pickDirectory" -> pickDirectory(call.arguments(), result)
            else -> result.notImplemented()
        }
    }

    private fun pickFiles(args: Map<*, *>?, result: MethodChannel.Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("no_activity", "File picker requires a foreground activity.", null)
            return
        }
        val type = args?.get(KEY_TYPE) as? String ?: TYPE_ANY
        val extensions = (args?.get(KEY_EXTENSIONS) as? List<*>)?.filterIsInstance<String>() ?: emptyList()
        val multiple = args?.get(KEY_MULTIPLE) as? Boolean ?: false

        val (mime, extraMimes) = mimeFilterFor(type, extensions)
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            setType(mime)
            if (extraMimes != null) {
                putExtra(Intent.EXTRA_MIME_TYPES, extraMimes)
            }
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiple)
        }
        pendingResult = result
        currentActivity.startActivityForResult(intent, PICK_FILES_REQUEST)
    }

    private fun saveFile(args: Map<*, *>?, result: MethodChannel.Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("no_activity", "File picker requires a foreground activity.", null)
            return
        }
        val fileName = args?.get(KEY_FILE_NAME) as? String
        saveBytes = args?.get(KEY_BYTES) as? ByteArray
        val mime = fileName?.substringAfterLast('.', "")
            ?.takeIf { it.isNotEmpty() }
            ?.let { MimeTypeMap.getSingleton().getMimeTypeFromExtension(it.lowercase()) }
            ?: "application/octet-stream"

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            setType(mime)
            if (fileName != null) {
                putExtra(Intent.EXTRA_TITLE, fileName)
            }
        }
        pendingResult = result
        currentActivity.startActivityForResult(intent, SAVE_FILE_REQUEST)
    }

    private fun pickDirectory(args: Any?, result: MethodChannel.Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("no_activity", "File picker requires a foreground activity.", null)
            return
        }
        // ACTION_OPEN_DOCUMENT_TREE has no initial-directory extra; the
        // argument is accepted and ignored on Android.
        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        currentActivity.startActivityForResult(intent, PICK_DIRECTORY_REQUEST)
    }

    private fun mimeFilterFor(type: String, extensions: List<String>): Pair<String, Array<String>?> {
        val resolver = MimeTypeMap.getSingleton()
        return when (type) {
            TYPE_IMAGE -> "image/*" to null
            TYPE_VIDEO -> "video/*" to null
            TYPE_AUDIO -> "audio/*" to null
            TYPE_MEDIA -> "*/*" to arrayOf("image/*", "video/*", "audio/*")
            TYPE_CUSTOM -> {
                val mimes = extensions.map { ext ->
                    resolver.getMimeTypeFromExtension(ext.lowercase()) ?: "application/octet-stream"
                }.toTypedArray()
                if (mimes.isEmpty()) "*/*" to null else "*/*" to mimes
            }
            else -> "*/*" to null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val result = pendingResult ?: return false
        pendingResult = null
        when (requestCode) {
            PICK_FILES_REQUEST -> {
                if (resultCode != Activity.RESULT_OK || data == null) {
                    result.success(null)
                    return true
                }
                val uris = mutableListOf<Uri>()
                data.data?.let { uris.add(it) }
                val clip = data.clipData
                if (clip != null) {
                    for (i in 0 until clip.itemCount) {
                        clip.getItemAt(i).uri?.let { if (!uris.contains(it)) uris.add(it) }
                    }
                }
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("no_activity", "Activity detached while picking.", null)
                    return true
                }
                val descriptors = uris.mapNotNull { uri ->
                    describeAndCopy(currentActivity, uri)
                }
                result.success(descriptors)
            }
            SAVE_FILE_REQUEST -> {
                val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
                if (uri == null) {
                    saveBytes = null
                    result.success(null)
                    return true
                }
                val currentActivity = activity
                if (currentActivity == null) {
                    saveBytes = null
                    result.error("no_activity", "Activity detached while saving.", null)
                    return true
                }
                saveBytes?.let { bytes ->
                    try {
                        currentActivity.contentResolver.openOutputStream(uri)?.use { out ->
                            out.write(bytes)
                        }
                    } catch (_: Exception) {
                        // The document was created; a failed write still
                        // returns the (empty) snapshot path.
                    }
                }
                saveBytes = null
                result.success(snapshot(currentActivity, uri))
            }
            PICK_DIRECTORY_REQUEST -> {
                val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
                if (uri == null) {
                    result.success(null)
                    return true
                }
                val path = treeUriToPath(uri)
                if (path == null) {
                    result.error(
                        "unresolved_directory",
                        "The picked directory is not on primary storage and cannot be mapped to a filesystem path.",
                        null,
                    )
                } else {
                    result.success(path)
                }
            }
        }
        return true
    }

    /** Queries metadata and copies the document into app cache. */
    private fun describeAndCopy(context: Context, uri: Uri): Map<String, Any?>? = try {
        val name = queryName(context, uri) ?: "document"
        val mime = context.contentResolver.getType(uri)
        val file = copyToCache(context, uri, name)
        mapOf(
            KEY_PATH to file.absolutePath,
            KEY_NAME to name,
            KEY_SIZE to file.length(),
            KEY_MIME to mime,
        )
    } catch (_: Exception) {
        null
    }

    /** Copies the created document's content into cache as a readable snapshot. */
    private fun snapshot(context: Context, uri: Uri): String? = try {
        val name = queryName(context, uri) ?: "document"
        copyToCache(context, uri, name).absolutePath
    } catch (_: Exception) {
        null
    }

    private fun queryName(context: Context, uri: Uri): String? {
        context.contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) {
                return cursor.getString(index)
            }
        }
        return uri.lastPathSegment
    }

    private fun copyToCache(context: Context, uri: Uri, name: String): File {
        val dir = File(context.cacheDir, "zuraffa_file_picker").apply { mkdirs() }
        val safeName = name.substringAfterLast('/')
        val target = File(dir, "${UUID.randomUUID()}_$safeName")
        context.contentResolver.openInputStream(uri)?.use { input ->
            target.outputStream().use { output ->
                input.copyTo(output)
            }
        }
        return target
    }

    /**
     * Best-effort mapping of a document-tree URI to a filesystem path:
     * `primary:<relative>` trees (the common case) map onto external
     * storage; other providers have no stable path mapping and fail with
     * `unresolved_directory`.
     */
    private fun treeUriToPath(uri: Uri): String? = try {
        val docId = DocumentsContract.getTreeDocumentId(uri)
        if (docId != null && docId.startsWith("primary:")) {
            val relative = docId.removePrefix("primary:").replace(':', '/')
            val storage = Environment.getExternalStorageDirectory() ?: return null
            File(storage, relative).absolutePath
        } else {
            null
        }
    } catch (_: Exception) {
        null
    }
}
