package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.sybrox.goapp_captain.R
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NotificationService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                createNotificationChannel(
                    channelId = call.argument<String>("channelId") ?: "ride_updates",
                    channelName = call.argument<String>("channelName") ?: "Ride Updates",
                    channelDescription = call.argument<String>("channelDescription")
                        ?: "Notifications for ride flow milestones and rider updates."
                )
                result.success(null)
            }

            "show" -> {
                showNotification(
                    id = call.argument<Int>("id") ?: 1000,
                    title = call.argument<String>("title") ?: "",
                    body = call.argument<String>("body") ?: "",
                    channelId = call.argument<String>("channelId") ?: "ride_updates",
                    channelName = call.argument<String>("channelName") ?: "Ride Updates",
                    channelDescription = call.argument<String>("channelDescription")
                        ?: "Notifications for ride flow milestones and rider updates.",
                    progress = null,
                    maxProgress = null,
                    ongoing = false
                )
                result.success(null)
            }

            "showProgress" -> {
                showNotification(
                    id = call.argument<Int>("id") ?: 1000,
                    title = call.argument<String>("title") ?: "",
                    body = call.argument<String>("body") ?: "",
                    channelId = call.argument<String>("channelId") ?: "ride_updates",
                    channelName = call.argument<String>("channelName") ?: "Ride Updates",
                    channelDescription = call.argument<String>("channelDescription")
                        ?: "Notifications for ride flow milestones and rider updates.",
                    progress = call.argument<Int>("progress"),
                    maxProgress = call.argument<Int>("maxProgress"),
                    ongoing = call.argument<Boolean>("ongoing") ?: true
                )
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun createNotificationChannel(
        channelId: String,
        channelName: String,
        channelDescription: String
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = activity.getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            channelId,
            channelName,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = channelDescription
            enableVibration(true)
        }
        manager.createNotificationChannel(channel)
    }

    private fun showNotification(
        id: Int,
        title: String,
        body: String,
        channelId: String,
        channelName: String,
        channelDescription: String,
        progress: Int?,
        maxProgress: Int?,
        ongoing: Boolean
    ) {
        createNotificationChannel(channelId, channelName, channelDescription)
        val builder = NotificationCompat.Builder(activity, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(!ongoing)
            .setOngoing(ongoing)
            .setOnlyAlertOnce(progress != null)

        if (progress != null && maxProgress != null) {
            builder.setProgress(maxProgress, progress, false)
        }

        NotificationManagerCompat.from(activity).notify(id, builder.build())
    }
}
