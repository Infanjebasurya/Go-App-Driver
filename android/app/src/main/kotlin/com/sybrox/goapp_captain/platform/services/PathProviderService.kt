package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PathProviderService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getApplicationDocumentsDirectory" -> {
                result.success(activity.filesDir.absolutePath)
            }

            else -> result.notImplemented()
        }
    }
}

