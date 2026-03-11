package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `url_launcher` is implemented by its Flutter plugin on Android.
 */
internal class UrlLauncherIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}

