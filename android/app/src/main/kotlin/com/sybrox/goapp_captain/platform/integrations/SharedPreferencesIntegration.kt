package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.SharedPreferencesService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class SharedPreferencesIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): SharedPreferencesService {
        val service = SharedPreferencesService(activity)
        MethodChannel(messenger, "app/shared_preferences_service")
            .setMethodCallHandler(service)
        return service
    }
}

