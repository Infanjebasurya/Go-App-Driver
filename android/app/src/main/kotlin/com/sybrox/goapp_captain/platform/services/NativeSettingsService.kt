package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NativeSettingsService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openWifiSettings" -> {
                activity.startActivity(
                    Intent(Settings.ACTION_WIFI_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                )
                result.success(true)
            }

            "openMobileDataSettings" -> {
                val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    Intent(Settings.ACTION_WIRELESS_SETTINGS)
                } else {
                    Intent(Settings.ACTION_DATA_ROAMING_SETTINGS)
                }
                activity.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }
}
