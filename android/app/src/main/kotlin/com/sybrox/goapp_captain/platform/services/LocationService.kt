package com.sybrox.goapp_captain.platform.services

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class LocationService(
    private val activity: Activity,
    private val prefs: SharedPreferences
) : MethodChannel.MethodCallHandler {
    private val handler = Handler(Looper.getMainLooper())
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingLocationResult: MethodChannel.Result? = null
    private var locationListener: LocationListener? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermission" -> result.success(locationPermissionStatus())
            "requestPermission" -> requestLocationPermission(result)
            "isLocationServiceEnabled" -> result.success(isLocationServiceEnabled())
            "openLocationSettings" -> {
                activity.startActivity(
                    Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                )
                result.success(true)
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

            "getLastKnownPosition" -> result.success(getBestLastKnownPosition()?.toMap())
            "getCurrentPosition" -> {
                val timeLimitMs = call.argument<Int>("timeLimitMs") ?: 8000
                requestCurrentLocation(timeLimitMs, result)
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

        val result = pendingPermissionResult ?: return true
        pendingPermissionResult = null

        val isGranted =
            grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (isGranted) {
            result.success("whileInUse")
            return true
        }

        val permission = Manifest.permission.ACCESS_FINE_LOCATION
        val shouldShowRationale =
            ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
        result.success(if (shouldShowRationale) "denied" else "deniedForever")
        return true
    }

    fun dispose() {
        val manager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        locationListener?.let { manager.removeUpdates(it) }
        locationListener = null
        handler.removeCallbacksAndMessages(null)
        pendingLocationResult = null
        pendingPermissionResult = null
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

    private fun requestLocationPermission(result: MethodChannel.Result) {
        if (pendingPermissionResult != null) {
            result.error("busy", "A permission request is already running", null)
            return
        }
        val permission = Manifest.permission.ACCESS_FINE_LOCATION
        if (ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED) {
            result.success("whileInUse")
            return
        }
        prefs.edit().putBoolean("location", true).apply()
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(activity, arrayOf(permission), REQUEST_CODE)
    }

    private fun isLocationServiceEnabled(): Boolean {
        val manager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return manager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
            manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    }

    private fun getBestLastKnownPosition(): Location? {
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }

        val manager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val providers = manager.getProviders(true)
        var bestLocation: Location? = null
        for (provider in providers) {
            val location = manager.getLastKnownLocation(provider) ?: continue
            if (bestLocation == null || location.accuracy < bestLocation.accuracy) {
                bestLocation = location
            }
        }
        return bestLocation
    }

    private fun requestCurrentLocation(timeLimitMs: Int, result: MethodChannel.Result) {
        if (pendingLocationResult != null) {
            result.error("busy", "A location request is already running", null)
            return
        }

        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            result.error("permission_denied", "Location permission is denied", null)
            return
        }

        val manager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        if (!isLocationServiceEnabled()) {
            result.error("service_disabled", "Location service is disabled", null)
            return
        }

        pendingLocationResult = result
        val listener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                completeLocationRequest(location)
            }
        }
        locationListener = listener

        try {
            if (manager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                manager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    0L,
                    0f,
                    listener,
                    Looper.getMainLooper()
                )
            }
            if (manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                manager.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    0L,
                    0f,
                    listener,
                    Looper.getMainLooper()
                )
            }
        } catch (exception: SecurityException) {
            pendingLocationResult = null
            locationListener = null
            result.error("permission_denied", exception.message, null)
            return
        }

        handler.postDelayed({
            if (pendingLocationResult == null) return@postDelayed
            completeLocationRequest(getBestLastKnownPosition())
        }, timeLimitMs.toLong())
    }

    private fun completeLocationRequest(location: Location?) {
        val result = pendingLocationResult ?: return
        val manager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        locationListener?.let { manager.removeUpdates(it) }
        locationListener = null
        handler.removeCallbacksAndMessages(null)
        pendingLocationResult = null

        if (location == null) {
            result.error("location_unavailable", "Current location is unavailable", null)
            return
        }
        result.success(location.toMap())
    }

    private fun Location.toMap(): Map<String, Double> {
        return mapOf(
            "latitude" to latitude,
            "longitude" to longitude
        )
    }

    companion object {
        private const val REQUEST_CODE = 1108
    }
}
