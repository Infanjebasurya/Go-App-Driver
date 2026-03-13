package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.ImagePickerService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class ImagePickerIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): ImagePickerService {
        val service = ImagePickerService(activity)
        MethodChannel(messenger, "app/image_picker_service")
            .setMethodCallHandler(service)
        return service
    }
}

