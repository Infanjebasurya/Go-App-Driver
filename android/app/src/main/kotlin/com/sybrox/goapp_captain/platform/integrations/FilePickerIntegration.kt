package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.FilePickerService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class FilePickerIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): FilePickerService {
        val service = FilePickerService(activity)
        MethodChannel(messenger, "app/file_picker_service")
            .setMethodCallHandler(service)
        return service
    }
}

