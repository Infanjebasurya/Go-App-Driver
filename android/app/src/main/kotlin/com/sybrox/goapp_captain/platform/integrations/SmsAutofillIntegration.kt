package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.SmsAutofillService
import com.sybrox.goapp_captain.platform.services.SmsAutofillStreamHandler
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

internal class SmsAutofillIntegration {
    data class Registration(
        val service: SmsAutofillService,
        val streamHandler: SmsAutofillStreamHandler
    )

    fun register(messenger: BinaryMessenger, activity: Activity): Registration {
        val service = SmsAutofillService(activity)
        MethodChannel(messenger, "app/sms_autofill_service")
            .setMethodCallHandler(service)

        val streamHandler = SmsAutofillStreamHandler(activity)
        EventChannel(messenger, "app/sms_autofill_events")
            .setStreamHandler(streamHandler)

        return Registration(service = service, streamHandler = streamHandler)
    }
}

