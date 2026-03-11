package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.Intent
import androidx.core.content.ContextCompat
import com.sybrox.goapp_captain.platform.services.TripForegroundService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BackgroundService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> result.success(null)
            "isRunning" -> result.success(TripForegroundService.isRunning)
            "startService" -> {
                val intent = Intent(activity, TripForegroundService::class.java).apply {
                    action = TripForegroundService.ACTION_START_IDLE
                }
                ContextCompat.startForegroundService(activity, intent)
                result.success(null)
            }

            "invoke" -> {
                val event = call.argument<String>("event")
                @Suppress("UNCHECKED_CAST")
                val data = call.argument<Map<String, Any?>>("data")
                val intent = Intent(activity, TripForegroundService::class.java)
                if (event == BackgroundEvents.START_TRIP) {
                    intent.action = TripForegroundService.ACTION_START_TRIP
                    intent.putExtra("title", data?.get("title") as? String ?: "Trip in progress")
                    intent.putExtra("subtitle", data?.get("subtitle") as? String ?: "Driver is moving")
                    val durationMs = (data?.get("duration_ms") as? Number)?.toLong() ?: 10000L
                    intent.putExtra("duration_ms", durationMs)
                    ContextCompat.startForegroundService(activity, intent)
                } else if (event == BackgroundEvents.STOP_TRIP) {
                    intent.action = TripForegroundService.ACTION_STOP_TRIP
                    activity.startService(intent)
                } else if (event == "stopService") {
                    intent.action = TripForegroundService.ACTION_STOP_SERVICE
                    activity.startService(intent)
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }
}

private object BackgroundEvents {
    const val START_TRIP = "start_trip"
    const val STOP_TRIP = "stop_trip"
}
