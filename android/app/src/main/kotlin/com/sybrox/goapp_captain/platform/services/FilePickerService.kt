package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FilePickerService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRequestCode: Int? = null
    private var pendingAllowedExtensions: List<String> = emptyList()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickImage" -> startPick(
                result = result,
                requestCode = REQUEST_PICK_IMAGE,
                intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "image/*"
                },
                allowedExtensions = emptyList()
            )

            "pickCustom" -> {
                @Suppress("UNCHECKED_CAST")
                val allowed = call.argument<List<String>>("allowedExtensions") ?: emptyList()
                startPick(
                    result = result,
                    requestCode = REQUEST_PICK_CUSTOM,
                    intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "*/*"
                    },
                    allowedExtensions = allowed.map { it.lowercase() }
                )
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
        val allowedExt = pendingAllowedExtensions
        pendingAllowedExtensions = emptyList()

        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return true
        }

        val uri: Uri? = data?.data
        if (uri == null) {
            result.success(null)
            return true
        }

        try {
            val picked = PickerUtils.copyUriToCache(activity, uri, "file")
            if (allowedExt.isNotEmpty()) {
                val ext = picked.extension.lowercase()
                if (ext.isNotEmpty() && !allowedExt.contains(ext)) {
                    result.error("invalid_extension", "File extension .$ext is not allowed", null)
                    return true
                }
            }
            result.success(picked.toMap())
        } catch (e: Exception) {
            result.error("pick_failed", e.message, null)
        }
        return true
    }

    private fun startPick(
        result: MethodChannel.Result,
        requestCode: Int,
        intent: Intent,
        allowedExtensions: List<String>
    ) {
        if (pendingResult != null) {
            result.error("busy", "A picker is already running", null)
            return
        }
        pendingResult = result
        pendingRequestCode = requestCode
        pendingAllowedExtensions = allowedExtensions
        activity.startActivityForResult(intent, requestCode)
    }

    companion object {
        private const val REQUEST_PICK_IMAGE = 2301
        private const val REQUEST_PICK_CUSTOM = 2302
    }
}

