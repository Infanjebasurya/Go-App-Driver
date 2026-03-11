package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `geolocator` is implemented by its Flutter plugin on Android.
 * Note: this app also has custom location channels under `com.sybrox.goapp_captain.platform.services.LocationService`.
 */
internal class GeolocatorIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}
