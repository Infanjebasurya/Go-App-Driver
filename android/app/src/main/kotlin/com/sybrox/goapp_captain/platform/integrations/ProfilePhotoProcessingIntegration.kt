package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.ProfilePhotoProcessingService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class ProfilePhotoProcessingIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): ProfilePhotoProcessingService {
        val service = ProfilePhotoProcessingService(activity)
        MethodChannel(messenger, "app/profile_photo_processing_service")
            .setMethodCallHandler(service)
        return service
    }
}

