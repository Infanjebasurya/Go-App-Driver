package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `flutter_background_service` is implemented by its Flutter plugin on Android.
 * Note: this app also has custom foreground service control under `com.sybrox.goapp_captain.platform.services.BackgroundService`.
 */
internal class FlutterBackgroundServiceIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}
