package com.ramsa.attendiq.attend_iq

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.ramsa.attendiq/storage"
        // Distinct 16-bit request code separated from plugin request codes
        // (flutter_local_notifications: 1..3, share_plus: 0x5873, file_picker: hash+43/83).
        private const val CREATE_DOCUMENT_REQUEST_CODE = 0x4208
    }

    private var pendingSaveResult: MethodChannel.Result? = null
    private var pendingSaveBytes: ByteArray? = null
    private var pendingSaveFileName: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToPublicStorage" -> {
                    val rawFileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    val rawSubFolder = call.argument<String>("subFolder") ?: ""
                    val mimeType = call.argument<String>("mimeType")
                        ?.takeIf { it.isNotBlank() }
                        ?: "application/octet-stream"
                    val isBeta = call.argument<Boolean>("isBeta") ?: false
                    val allowDocumentPicker = call.argument<Boolean>("allowDocumentPicker") ?: true

                    val cleanFileName = sanitizeFileName(rawFileName)
                    if (cleanFileName == null || bytes == null) {
                        result.error("INVALID_ARGS", "Valid fileName and bytes are required.", null)
                        return@setMethodCallHandler
                    }

                    val cleanSubFolder = sanitizeSubFolder(rawSubFolder)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        saveViaMediaStore(
                            fileName = cleanFileName,
                            bytes = bytes,
                            subFolder = cleanSubFolder,
                            mimeType = mimeType,
                            isBeta = isBeta,
                            result = result
                        )
                    } else if (!allowDocumentPicker) {
                        result.success(
                            mapOf(
                                "cancelled" to false,
                                "unsupportedSaf" to false,
                                "skippedDocumentPicker" to true
                            )
                        )
                    } else {
                        launchDocumentCreatePicker(
                            fileName = cleanFileName,
                            bytes = bytes,
                            mimeType = mimeType,
                            result = result
                        )
                    }
                }
                "openExportUri" -> {
                    val contentUri = call.argument<String>("contentUri")
                    val mimeType = call.argument<String>("mimeType")
                        ?.takeIf { it.isNotBlank() }
                        ?: "*/*"
                    if (contentUri.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "contentUri is missing.", null)
                        return@setMethodCallHandler
                    }
                    openExportContentUri(contentUri, mimeType, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveViaMediaStore(
        fileName: String,
        bytes: ByteArray,
        subFolder: String,
        mimeType: String,
        isBeta: Boolean,
        result: MethodChannel.Result
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            result.error("UNSUPPORTED_API", "MediaStore relative path requires API 29+.", null)
            return
        }

        val folderName = if (isBeta) "AttendIQ Beta" else "AttendIQ"
        val relativeSubPath = if (subFolder.isNotEmpty()) {
            "${Environment.DIRECTORY_DOCUMENTS}/$folderName/$subFolder"
        } else {
            "${Environment.DIRECTORY_DOCUMENTS}/$folderName"
        }

        val resolver = applicationContext.contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, relativeSubPath)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }

        val uri = try {
            resolver.insert(MediaStore.Files.getContentUri("external"), contentValues)
        } catch (e: Exception) {
            result.error("SAVE_FAILED", e.message ?: "MediaStore insert failed.", null)
            return
        }

        if (uri == null) {
            result.error("SAVE_FAILED", "MediaStore insert returned null URI.", null)
            return
        }

        try {
            val outputStream = resolver.openOutputStream(uri)
                ?: throw IOException("MediaStore returned null OutputStream.")
            outputStream.use { os ->
                os.write(bytes)
                os.flush()
            }

            val clearPending = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            val updatedRows = resolver.update(uri, clearPending, null, null)
            if (updatedRows <= 0) {
                throw IOException("Failed to finalize MediaStore pending entry.")
            }

            var actualDisplayName = fileName
            var actualRelativePath = relativeSubPath
            resolver.query(
                uri,
                arrayOf(
                    MediaStore.MediaColumns.DISPLAY_NAME,
                    MediaStore.MediaColumns.RELATIVE_PATH
                ),
                null,
                null,
                null
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIdx = cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
                    if (nameIdx >= 0) {
                        cursor.getString(nameIdx)
                            ?.takeIf { it.isNotBlank() }
                            ?.let { actualDisplayName = it }
                    }
                    val relIdx = cursor.getColumnIndex(MediaStore.MediaColumns.RELATIVE_PATH)
                    if (relIdx >= 0) {
                        cursor.getString(relIdx)
                            ?.trimEnd('/')
                            ?.takeIf { it.isNotBlank() }
                            ?.let { actualRelativePath = it }
                    }
                }
            }

            result.success(
                mapOf(
                    "contentUri" to uri.toString(),
                    "displayName" to actualDisplayName,
                    "relativePath" to actualRelativePath,
                    "cancelled" to false,
                    "unsupportedSaf" to false
                )
            )
        } catch (e: Exception) {
            try {
                resolver.delete(uri, null, null)
            } catch (_: Exception) {
            }
            result.error("SAVE_FAILED", e.message ?: "MediaStore write failed.", null)
        }
    }

    private fun launchDocumentCreatePicker(
        fileName: String,
        bytes: ByteArray,
        mimeType: String,
        result: MethodChannel.Result
    ) {
        if (pendingSaveResult != null) {
            result.error("REQUEST_IN_PROGRESS", "A file save dialog is already open.", null)
            return
        }

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }

        if (intent.resolveActivity(packageManager) == null) {
            result.success(
                mapOf(
                    "cancelled" to false,
                    "unsupportedSaf" to true
                )
            )
            return
        }

        pendingSaveResult = result
        pendingSaveBytes = bytes
        pendingSaveFileName = fileName

        try {
            startActivityForResult(intent, CREATE_DOCUMENT_REQUEST_CODE)
        } catch (e: ActivityNotFoundException) {
            clearPendingSave()
            result.success(
                mapOf(
                    "cancelled" to false,
                    "unsupportedSaf" to true
                )
            )
        } catch (e: Exception) {
            clearPendingSave()
            result.error("SAVE_FAILED", e.message ?: "Unable to launch document picker.", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != CREATE_DOCUMENT_REQUEST_CODE) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        val callback = pendingSaveResult
        val bytes = pendingSaveBytes
        val fallbackName = pendingSaveFileName ?: "export"
        clearPendingSave()

        // Activity may have been recreated by the OS while SAF picker was open.
        if (callback == null || bytes == null) {
            if (resultCode == Activity.RESULT_OK) {
                data?.data?.let { orphanedUri ->
                    try {
                        DocumentsContract.deleteDocument(applicationContext.contentResolver, orphanedUri)
                    } catch (_: Exception) {
                    }
                }
            }
            return
        }

        if (resultCode == Activity.RESULT_CANCELED) {
            callback.success(
                mapOf(
                    "cancelled" to true,
                    "unsupportedSaf" to false
                )
            )
            return
        }

        if (resultCode != Activity.RESULT_OK) {
            callback.error("SAVE_FAILED", "Document creation failed (code $resultCode).", null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            callback.error("SAVE_FAILED", "Document picker returned no URI.", null)
            return
        }

        val resolver = applicationContext.contentResolver
        try {
            val truncatedStream = resolver.openOutputStream(uri, "wt")
            if (truncatedStream != null) {
                truncatedStream.use { writeBytesToStream(it, bytes) }
            } else {
                val fallbackStream = resolver.openOutputStream(uri)
                    ?: throw IOException("Document provider returned null OutputStream.")
                fallbackStream.use { writeBytesToStream(it, bytes) }
            }

            var displayName = fallbackName
            resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (idx >= 0) {
                        cursor.getString(idx)?.takeIf { it.isNotBlank() }?.let { displayName = it }
                    }
                }
            }

            callback.success(
                mapOf(
                    "contentUri" to uri.toString(),
                    "displayName" to displayName,
                    "relativePath" to null,
                    "cancelled" to false,
                    "unsupportedSaf" to false
                )
            )
        } catch (e: Exception) {
            try {
                DocumentsContract.deleteDocument(resolver, uri)
            } catch (_: Exception) {
            }
            callback.error("SAVE_FAILED", e.message ?: "Failed to write SAF document.", null)
        }
    }

    private fun openExportContentUri(
        contentUriString: String,
        mimeType: String,
        result: MethodChannel.Result
    ) {
        try {
            val uri = Uri.parse(contentUriString)
            val authority = uri.authority
            if (uri.scheme != "content" || authority.isNullOrBlank() || authority.startsWith(packageName)) {
                result.error("INVALID_URI", "Only external content:// export URIs can be opened.", null)
                return
            }

            val viewIntent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            val chooser = Intent.createChooser(viewIntent, "Open File").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            try {
                startActivity(chooser)
                result.success(true)
            } catch (_: ActivityNotFoundException) {
                result.success(false)
            }
        } catch (e: Exception) {
            result.error("OPEN_URI_FAILED", e.message ?: "Failed to open content URI.", null)
        }
    }

    private fun sanitizeFileName(raw: String?): String? {
        if (raw.isNullOrBlank()) return null
        val base = raw.substringAfterLast('/').substringAfterLast('\\').trim()
        if (base.isEmpty() || base == "." || base == ".." || base.contains("..") || base.indexOf('\u0000') >= 0) {
            return null
        }
        return base
    }

    private fun sanitizeSubFolder(raw: String): String {
        val parts = raw.split('/', '\\')
            .map { it.trim() }
            .filter { it.isNotEmpty() && it != "." && it != ".." }
        return parts.joinToString("/")
    }

    private fun writeBytesToStream(outputStream: OutputStream, bytes: ByteArray) {
        outputStream.write(bytes)
        outputStream.flush()
    }

    private fun clearPendingSave() {
        pendingSaveResult = null
        pendingSaveBytes = null
        pendingSaveFileName = null
    }

    override fun onDestroy() {
        pendingSaveResult?.error("ACTIVITY_DESTROYED", "Activity destroyed before document save completed.", null)
        clearPendingSave()
        super.onDestroy()
    }
}
