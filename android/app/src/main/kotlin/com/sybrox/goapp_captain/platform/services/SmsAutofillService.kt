package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import com.google.android.gms.auth.api.phone.SmsRetriever
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmsAutofillService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                try {
                    SmsRetriever.getClient(activity).startSmsRetriever()
                    result.success(null)
                } catch (e: Exception) {
                    result.error("sms_start_failed", e.message, null)
                }
            }

            "stop" -> {
                // No explicit stop API for SMS Retriever; stream handler unregisters receiver.
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }
}

