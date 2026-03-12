package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `google_mlkit_face_detection` is implemented by its Flutter plugin on Android.
 */
internal class GoogleMlkitFaceDetectionIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}

