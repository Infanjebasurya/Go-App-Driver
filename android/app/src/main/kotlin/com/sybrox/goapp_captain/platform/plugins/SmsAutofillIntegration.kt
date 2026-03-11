package com.sybrox.goapp_captain.platform.plugins

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger

/**
 * `sms_autofill` is implemented by its Flutter plugin on Android.
 * This class is a dedicated place for any app-specific platform-channel extensions, if needed later.
 */
internal class SmsAutofillIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity) {
        // No-op (plugin handles native side).
    }
}

