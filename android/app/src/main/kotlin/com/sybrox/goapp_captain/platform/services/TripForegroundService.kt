package com.sybrox.goapp_captain.platform.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import androidx.core.app.NotificationCompat

class TripForegroundService : Service() {
    private var timer: CountDownTimer? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_IDLE -> {
                isRunning = true
                startForeground(NOTIFICATION_ID, buildNotification("GoApp Driver", "Trip tracking idle"))
            }
            ACTION_START_TRIP -> {
                isRunning = true
                val title = intent.getStringExtra("title") ?: "Trip in progress"
                val subtitle = intent.getStringExtra("subtitle") ?: "Driver is moving"
                val durationMs = (intent.getLongExtra("duration_ms", 10000L)).coerceAtLeast(1000L)
                startForeground(NOTIFICATION_ID, buildNotification(title, "$subtitle (0%)"))
                startTripTimer(title, subtitle, durationMs)
            }
            ACTION_STOP_TRIP, ACTION_STOP_SERVICE -> {
                timer?.cancel()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
                isRunning = false
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        timer?.cancel()
        isRunning = false
        super.onDestroy()
    }

    private fun startTripTimer(title: String, subtitle: String, durationMs: Long) {
        timer?.cancel()
        timer = object : CountDownTimer(durationMs, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                val elapsed = durationMs - millisUntilFinished
                val progress = ((elapsed.toDouble() / durationMs.toDouble()) * 100.0)
                    .toInt()
                    .coerceIn(0, 100)
                updateNotification(title, "$subtitle ($progress%)")
            }

            override fun onFinish() {
                updateNotification(title, "$subtitle (100%)")
            }
        }.start()
    }

    private fun updateNotification(title: String, content: String) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, buildNotification(title, content))
    }

    private fun buildNotification(title: String, content: String): Notification {
        createChannel()
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(content)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "GoApp Driver",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Trip tracking service"
        }
        manager.createNotificationChannel(channel)
    }

    companion object {
        const val ACTION_START_IDLE = "goapp.background.START_IDLE"
        const val ACTION_START_TRIP = "goapp.background.START_TRIP"
        const val ACTION_STOP_TRIP = "goapp.background.STOP_TRIP"
        const val ACTION_STOP_SERVICE = "goapp.background.STOP_SERVICE"
        private const val CHANNEL_ID = "goapp_trip_service"
        private const val NOTIFICATION_ID = 4101

        @Volatile
        var isRunning: Boolean = false
    }
}
