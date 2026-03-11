package com.sybrox.goapp_captain.platform.services.network

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NetworkService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isConnected" -> result.success(NetworkConnectivity.isConnected(activity))
            else -> result.notImplemented()
        }
    }
}
