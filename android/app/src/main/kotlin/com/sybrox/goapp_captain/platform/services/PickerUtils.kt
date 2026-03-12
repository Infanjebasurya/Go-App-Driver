package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import java.io.File
import java.io.FileOutputStream

internal data class PickedFileResult(
    val path: String,
    val name: String,
    val sizeBytes: Long,
    val extension: String
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "path" to path,
        "name" to name,
        "sizeBytes" to sizeBytes,
        "extension" to extension
    )
}

internal object PickerUtils {
    fun copyUriToCache(activity: Activity, uri: Uri, prefix: String): PickedFileResult {
        val resolver = activity.contentResolver

        val (displayName, sizeBytes) = queryNameAndSize(activity, uri)
        val safeName = displayName.ifBlank { "$prefix-${System.currentTimeMillis()}" }
        val ext = extensionFromName(safeName)

        val dir = File(activity.cacheDir, "picked_files")
        if (!dir.exists()) dir.mkdirs()
        val outFile = File(dir, safeName)

        resolver.openInputStream(uri)?.use { input ->
            FileOutputStream(outFile).use { output ->
                input.copyTo(output)
            }
        } ?: throw IllegalStateException("Unable to open selected file")

        val resolvedSize = if (sizeBytes > 0) sizeBytes else outFile.length()
        return PickedFileResult(
            path = outFile.absolutePath,
            name = safeName,
            sizeBytes = resolvedSize,
            extension = ext
        )
    }

    private fun queryNameAndSize(activity: Activity, uri: Uri): Pair<String, Long> {
        val resolver = activity.contentResolver
        var name = ""
        var size = 0L
        val cursor: Cursor? = resolver.query(uri, null, null, null, null)
        cursor?.use {
            val nameIdx = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            val sizeIdx = it.getColumnIndex(OpenableColumns.SIZE)
            if (it.moveToFirst()) {
                if (nameIdx >= 0) name = it.getString(nameIdx) ?: ""
                if (sizeIdx >= 0) size = it.getLong(sizeIdx)
            }
        }
        return Pair(name, size)
    }

    private fun extensionFromName(name: String): String {
        val dot = name.lastIndexOf('.')
        if (dot < 0 || dot == name.length - 1) return ""
        return name.substring(dot + 1).lowercase()
    }
}

