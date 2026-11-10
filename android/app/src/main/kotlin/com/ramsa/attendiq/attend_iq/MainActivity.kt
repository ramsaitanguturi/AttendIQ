package com.ramsa.attendiq.attend_iq

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ramsa.attendiq/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToPublicStorage" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    val subFolder = call.argument<String>("subFolder") ?: ""
                    val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                    val isBeta = call.argument<Boolean>("isBeta") ?: false

                    if (fileName == null || bytes == null) {
                        result.error("INVALID_ARGS", "FileName or bytes missing", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val folderName = if (isBeta) "AttendIQ Beta" else "AttendIQ"
                        val relativeSubPath = if (subFolder.isNotEmpty()) "Documents/$folderName/$subFolder" else "Documents/$folderName"

                        var savedPath: String? = null

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            val contentValues = ContentValues().apply {
                                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                                put(MediaStore.MediaColumns.RELATIVE_PATH, relativeSubPath)
                            }
                            val resolver = context.contentResolver
                            val uri = resolver.insert(MediaStore.Files.getContentUri("external"), contentValues)
                            if (uri != null) {
                                resolver.openOutputStream(uri)?.use { os ->
                                    os.write(bytes)
                                }
                                savedPath = "/storage/emulated/0/$relativeSubPath/$fileName"
                            }
                        }

                        if (savedPath == null) {
                            val docsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
                            val targetDir = File(docsDir, if (subFolder.isNotEmpty()) "$folderName/$subFolder" else folderName)
                            if (!targetDir.exists()) {
                                targetDir.mkdirs()
                            }
                            val targetFile = File(targetDir, fileName)
                            FileOutputStream(targetFile).use { fos ->
                                fos.write(bytes)
                            }
                            savedPath = targetFile.absolutePath
                        }

                        result.success(savedPath)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, e)
                    }
                }
                "openFolder" -> {
                    val folderPath = call.argument<String>("folderPath") ?: ""
                    try {
                        val file = File(folderPath)
                        val intent = Intent(Intent.ACTION_VIEW)
                        val uri = Uri.parse("content://com.android.externalstorage.documents/document/primary%3A" +
                                Uri.encode(file.path.replace("/storage/emulated/0/", "")))
                        intent.setDataAndType(uri, "*/*")
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(Intent.createChooser(intent, "Open Folder"))
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Intent.ACTION_GET_CONTENT)
                            intent.addCategory(Intent.CATEGORY_OPENABLE)
                            intent.type = "*/*"
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(Intent.createChooser(intent, "Open Folder"))
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("OPEN_FOLDER_FAILED", e2.message, e2)
                        }
                    }
                }
                "openFile" -> {
                    val filePath = call.argument<String>("filePath")
                    val mimeType = call.argument<String>("mimeType") ?: "*/*"
                    if (filePath == null) {
                        result.error("INVALID_ARGS", "FilePath missing", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val file = File(filePath)
                        val uri = FileProvider.getUriForFile(
                            context,
                            "${context.packageName}.fileprovider",
                            file
                        )
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, mimeType)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(Intent.createChooser(intent, "Open File"))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("OPEN_FILE_FAILED", e.message, e)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
