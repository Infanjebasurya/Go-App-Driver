package com.sybrox.goapp_captain.platform.services

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PermissionService(
    private val activity: Activity,
    private val prefs: SharedPreferences
) : MethodChannel.MethodCallHandler {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingPermissionName: String? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> {
                val permissionName = call.argument<String>("permission")
                if (permissionName == null) {
                    result.error("invalid_args", "permission is required", null)
                    return
                }
                result.success(permissionStatus(permissionName))
            }

            "request" -> {
                val permissionName = call.argument<String>("permission")
                if (permissionName == null) {
                    result.error("invalid_args", "permission is required", null)
                    return
                }
                requestPermission(permissionName, result)
            }

            "openAppSettings" -> {
                val intent = Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.fromParts("package", activity.packageName, null)
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                activity.startActivity(intent)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false

        val result = pendingResult ?: return true
        val permissionName = pendingPermissionName ?: ""
        pendingResult = null
        pendingPermissionName = null

        val isGranted =
            grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (isGranted) {
            result.success("granted")
            return true
        }

        val permission = androidPermission(permissionName)
        val shouldShowRationale = permission != null &&
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        result.success(if (shouldShowRationale) "denied" else "permanentlyDenied")
        return true
    }

    private fun requestPermission(permissionName: String, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "A permission request is already running", null)
            return
        }

        if (permissionName == "notification" && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(permissionStatus(permissionName))
            return
        }

        val permission = androidPermission(permissionName)
        if (permission == null) {
            result.success("restricted")
            return
        }

        if (ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
            return
        }

        prefs.edit().putBoolean(permissionName, true).apply()
        pendingPermissionName = permissionName
        pendingResult = result
        ActivityCompat.requestPermissions(activity, arrayOf(permission), REQUEST_CODE)
    }

    private fun permissionStatus(permissionName: String): String {
        if (permissionName == "location") {
            return locationPermissionStatus()
        }
        if (permissionName == "notification") {
            return notificationPermissionStatus()
        }

        val permission = androidPermission(permissionName) ?: return "restricted"
        if (ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED) {
            return "granted"
        }

        val hasRequestedBefore = prefs.getBoolean(permissionName, false)
        val shouldShowRationale =
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        return if (hasRequestedBefore && !shouldShowRationale) {
            "permanentlyDenied"
        } else {
            "denied"
        }
    }

    private fun locationPermissionStatus(): String {
        val permission = Manifest.permission.ACCESS_FINE_LOCATION
        if (ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED) {
            return "whileInUse"
        }
        val hasRequestedBefore = prefs.getBoolean("location", false)
        val shouldShowRationale =
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        return if (hasRequestedBefore && !shouldShowRationale) {
            "deniedForever"
        } else {
            "denied"
        }
    }

    private fun notificationPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return if (NotificationManagerCompat.from(activity).areNotificationsEnabled()) {
                "granted"
            } else {
                "denied"
            }
        }

        val permission = Manifest.permission.POST_NOTIFICATIONS
        if (ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED) {
            return "granted"
        }

        val hasRequestedBefore = prefs.getBoolean("notification", false)
        val shouldShowRationale =
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        return if (hasRequestedBefore && !shouldShowRationale) {
            "permanentlyDenied"
        } else {
            "denied"
        }
    }

    private fun androidPermission(permissionName: String): String? {
        return when (permissionName) {
            "camera" -> Manifest.permission.CAMERA
            "contacts" -> Manifest.permission.READ_CONTACTS
            "location" -> Manifest.permission.ACCESS_FINE_LOCATION
            "photos" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Manifest.permission.READ_MEDIA_IMAGES
                } else {
                    Manifest.permission.READ_EXTERNAL_STORAGE
                }
            }

            "notification" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Manifest.permission.POST_NOTIFICATIONS
                } else {
                    null
                }
            }

            else -> null
        }
    }

    companion object {
        private const val REQUEST_CODE = 1107
    }
}
