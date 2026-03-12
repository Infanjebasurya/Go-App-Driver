package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.PathProviderService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class PathProviderIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): PathProviderService {
        val service = PathProviderService(activity)
        MethodChannel(messenger, "app/path_provider_service")
            .setMethodCallHandler(service)
        return service
    }
}

