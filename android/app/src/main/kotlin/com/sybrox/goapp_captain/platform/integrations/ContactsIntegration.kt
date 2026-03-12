package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.services.ContactsService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class ContactsIntegration {
    fun register(messenger: BinaryMessenger, activity: Activity): ContactsService {
        val service = ContactsService(activity)
        MethodChannel(messenger, "app/contacts_service")
            .setMethodCallHandler(service)
        return service
    }
}

