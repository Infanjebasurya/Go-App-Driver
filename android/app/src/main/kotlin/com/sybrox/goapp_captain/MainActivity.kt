package com.sybrox.goapp_captain

import android.content.SharedPreferences
import com.sybrox.goapp_captain.platform.services.AudioService
import com.sybrox.goapp_captain.platform.services.BackgroundService
import com.sybrox.goapp_captain.platform.services.LocationService
import com.sybrox.goapp_captain.platform.services.NativeSettingsService
import com.sybrox.goapp_captain.platform.services.NotificationService
import com.sybrox.goapp_captain.platform.services.PermissionService
import com.sybrox.goapp_captain.platform.services.TripForegroundService
import com.sybrox.goapp_captain.platform.services.VibrationService
import com.sybrox.goapp_captain.platform.services.network.NetworkService
import com.sybrox.goapp_captain.platform.services.network.NetworkUpdatesStreamHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private lateinit var prefs: SharedPreferences

    private lateinit var permissionService: PermissionService
    private lateinit var vibrationService: VibrationService
    private lateinit var locationService: LocationService
    private lateinit var notificationService: NotificationService
    private lateinit var audioService: AudioService
    private lateinit var backgroundService: BackgroundService
    private lateinit var networkService: NetworkService
    private lateinit var nativeSettingsService: NativeSettingsService
    private lateinit var networkUpdatesStreamHandler: NetworkUpdatesStreamHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        prefs = getSharedPreferences("native_permission_service", MODE_PRIVATE)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        permissionService = PermissionService(this, prefs)
        MethodChannel(messenger, "app/permission_service")
            .setMethodCallHandler(permissionService)

        vibrationService = VibrationService(this)
        MethodChannel(messenger, "app/vibration_service")
            .setMethodCallHandler(vibrationService)

        locationService = LocationService(this, prefs)
        MethodChannel(messenger, "app/location_service")
            .setMethodCallHandler(locationService)

        notificationService = NotificationService(this)
        MethodChannel(messenger, "app/notification_service")
            .setMethodCallHandler(notificationService)

        audioService = AudioService(this)
        MethodChannel(messenger, "app/audio_service")
            .setMethodCallHandler(audioService)

        backgroundService = BackgroundService(this)
        MethodChannel(messenger, "app/background_service")
            .setMethodCallHandler(backgroundService)

        networkService = NetworkService(this)
        MethodChannel(messenger, "native_network")
            .setMethodCallHandler(networkService)

        nativeSettingsService = NativeSettingsService(this)
        MethodChannel(messenger, "native_permissions")
            .setMethodCallHandler(nativeSettingsService)

        networkUpdatesStreamHandler = NetworkUpdatesStreamHandler(this)
        EventChannel(messenger, "native_network_updates")
            .setStreamHandler(networkUpdatesStreamHandler)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        val handled = permissionService.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        ) || locationService.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        if (handled) {
            return
        }

        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onDestroy() {
        audioService.dispose()
        locationService.dispose()
        networkUpdatesStreamHandler.dispose()
        super.onDestroy()
    }
}
