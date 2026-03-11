package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `vibration` is implemented by its Flutter plugin on Android.
 * Note: this app also has custom vibration channels under `com.sybrox.goapp_captain.platform.services.VibrationService`.
 */
internal class VibrationIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}
