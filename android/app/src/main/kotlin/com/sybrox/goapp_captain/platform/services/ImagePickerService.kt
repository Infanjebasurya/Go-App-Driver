package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class ImagePickerService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRequestCode: Int? = null
    private var pendingCameraOutputFile: File? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickImage" -> {
                val source = call.argument<String>("source") ?: "gallery"
                when (source) {
                    "camera" -> startCamera(result)
                    else -> startGallery(result)
                }
            }

            else -> result.notImplemented()
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val expected = pendingRequestCode
        if (expected == null || expected != requestCode) return false

        val result = pendingResult ?: return true
        pendingResult = null
        pendingRequestCode = null

        if (resultCode != Activity.RESULT_OK) {
            pendingCameraOutputFile = null
            result.success(null)
            return true
        }

        try {
            if (requestCode == REQUEST_CAMERA) {
                val file = pendingCameraOutputFile
                pendingCameraOutputFile = null
                if (file == null || !file.exists()) {
                    result.success(null)
                    return true
                }
                result.success(
                    mapOf(
                        "path" to file.absolutePath,
                        "name" to file.name
                    )
                )
                return true
            }

            val uri: Uri? = data?.data
            if (uri == null) {
                result.success(null)
                return true
            }
            val picked = PickerUtils.copyUriToCache(activity, uri, "image")
            result.success(mapOf("path" to picked.path, "name" to picked.name))
        } catch (e: Exception) {
            result.error("pick_failed", e.message, null)
        }
        return true
    }

    private fun startGallery(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "A picker is already running", null)
            return
        }
        pendingResult = result
        pendingRequestCode = REQUEST_GALLERY
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "image/*"
        }
        activity.startActivityForResult(intent, REQUEST_GALLERY)
    }

    private fun startCamera(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "A picker is already running", null)
            return
        }

        val outDir = File(activity.cacheDir, "camera_captures")
        if (!outDir.exists()) outDir.mkdirs()
        val outFile = File(outDir, "IMG_${System.currentTimeMillis()}.jpg")
        pendingCameraOutputFile = outFile

        val uri: Uri = FileProvider.getUriForFile(
            activity,
            "${activity.packageName}.fileprovider",
            outFile
        )

        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
            putExtra(MediaStore.EXTRA_OUTPUT, uri)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        pendingResult = result
        pendingRequestCode = REQUEST_CAMERA
        activity.startActivityForResult(intent, REQUEST_CAMERA)
    }

    companion object {
        private const val REQUEST_GALLERY = 2201
        private const val REQUEST_CAMERA = 2202
    }
}

