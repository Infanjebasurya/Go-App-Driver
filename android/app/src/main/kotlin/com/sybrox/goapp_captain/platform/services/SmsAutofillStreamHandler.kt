package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Status
import io.flutter.plugin.common.EventChannel

class SmsAutofillStreamHandler(private val activity: Activity) : EventChannel.StreamHandler {
    private var events: EventChannel.EventSink? = null
    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        events = eventSink
        registerReceiver()
    }

    override fun onCancel(arguments: Any?) {
        events = null
        unregisterReceiver()
    }

    private fun registerReceiver() {
        if (receiver != null) return
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action != SmsRetriever.SMS_RETRIEVED_ACTION) return
                val extras = intent.extras ?: return
                val status = extras.get(SmsRetriever.EXTRA_STATUS) as? Status ?: return
                when (status.statusCode) {
                    CommonStatusCodes.SUCCESS -> {
                        val message = extras.getString(SmsRetriever.EXTRA_SMS_MESSAGE) ?: return
                        val code = extractDigitsCode(message)
                        if (code.isNotBlank()) {
                            events?.success(code)
                        }
                    }

                    CommonStatusCodes.TIMEOUT -> {
                        // Ignore.
                    }
                }
            }
        }

        val filter = IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(receiver, filter)
        }
    }

    private fun unregisterReceiver() {
        val r = receiver ?: return
        receiver = null
        try {
            activity.unregisterReceiver(r)
        } catch (_: Exception) {
        }
    }

    private fun extractDigitsCode(message: String): String {
        val digits = message.replace(Regex("[^0-9]"), "")
        // App expects 4-digit OTP.
        return if (digits.length >= 4) digits.substring(0, 4) else digits
    }
}

