package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `permission_handler` is implemented by its Flutter plugin on Android.
 * Note: this app also has custom permission channels under `com.sybrox.goapp_captain.platform.services.PermissionService`.
 */
internal class PermissionHandlerIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}
