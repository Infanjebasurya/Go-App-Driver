package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `flutter_local_notifications` is implemented by its Flutter plugin on Android.
 * Note: this app also has custom notifications under `com.sybrox.goapp_captain.platform.services.NotificationService`.
 */
internal class FlutterLocalNotificationsIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}
