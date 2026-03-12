package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.UrlLauncherService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class UrlLauncherIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): UrlLauncherService {
        val service = UrlLauncherService(activity)
        MethodChannel(messenger, "app/url_launcher_service")
            .setMethodCallHandler(service)
        return service
    }
}

