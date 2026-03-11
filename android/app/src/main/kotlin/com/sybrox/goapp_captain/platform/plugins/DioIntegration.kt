package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `dio` is pure Dart; no Android native integration required.
 */
internal class DioIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op.
    }
}

