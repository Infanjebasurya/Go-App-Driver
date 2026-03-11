package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `audioplayers` is implemented by its Flutter plugin on Android.
 * Note: this app also has custom audio channels under `com.sybrox.goapp_captain.platform.services.AudioService`.
 */
internal class AudioPlayersIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}
