package com.sybrox.goapp_captain

import android.content.SharedPreferences
import android.content.Intent
import com.sybrox.goapp_captain.platform.integrations.ContactsIntegration
import com.sybrox.goapp_captain.platform.integrations.FilePickerIntegration
import com.sybrox.goapp_captain.platform.integrations.ImagePickerIntegration
import com.sybrox.goapp_captain.platform.integrations.NativeMapViewIntegration
import com.sybrox.goapp_captain.platform.integrations.PathProviderIntegration
import com.sybrox.goapp_captain.platform.integrations.ProfilePhotoProcessingIntegration
import com.sybrox.goapp_captain.platform.integrations.SharedPreferencesIntegration
import com.sybrox.goapp_captain.platform.integrations.SmsAutofillIntegration
import com.sybrox.goapp_captain.platform.integrations.UrlLauncherIntegration
import com.sybrox.goapp_captain.platform.services.AudioService
import com.sybrox.goapp_captain.platform.services.BackgroundService
import com.sybrox.goapp_captain.platform.services.ContactsService
import com.sybrox.goapp_captain.platform.services.FilePickerService
import com.sybrox.goapp_captain.platform.services.ImagePickerService
import com.sybrox.goapp_captain.platform.services.LocationService
import com.sybrox.goapp_captain.platform.services.NativeSettingsService
import com.sybrox.goapp_captain.platform.services.NotificationService
import com.sybrox.goapp_captain.platform.services.PermissionService
import com.sybrox.goapp_captain.platform.services.PathProviderService
import com.sybrox.goapp_captain.platform.services.ProfilePhotoProcessingService
import com.sybrox.goapp_captain.platform.services.SharedPreferencesService
import com.sybrox.goapp_captain.platform.services.SmsAutofillService
import com.sybrox.goapp_captain.platform.services.SmsAutofillStreamHandler
import com.sybrox.goapp_captain.platform.services.TripForegroundService
import com.sybrox.goapp_captain.platform.services.UrlLauncherService
import com.sybrox.goapp_captain.platform.services.VibrationService
import com.sybrox.goapp_captain.platform.services.network.NetworkService
import com.sybrox.goapp_captain.platform.services.network.NetworkUpdatesStreamHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

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
    private lateinit var sharedPreferencesService: SharedPreferencesService
    private lateinit var pathProviderService: PathProviderService
    private lateinit var urlLauncherService: UrlLauncherService
    private lateinit var contactsService: ContactsService
    private lateinit var filePickerService: FilePickerService
    private lateinit var imagePickerService: ImagePickerService
    private lateinit var smsAutofillService: SmsAutofillService
    private lateinit var smsAutofillStreamHandler: SmsAutofillStreamHandler
    private lateinit var profilePhotoProcessingService: ProfilePhotoProcessingService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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

        // Custom platform services (replacing Flutter plugins).
        sharedPreferencesService = SharedPreferencesIntegration().register(messenger, this)
        pathProviderService = PathProviderIntegration().register(messenger, this)
        urlLauncherService = UrlLauncherIntegration().register(messenger, this)
        contactsService = ContactsIntegration().register(messenger, this)
        filePickerService = FilePickerIntegration().register(messenger, this)
        imagePickerService = ImagePickerIntegration().register(messenger, this)

        val smsReg = SmsAutofillIntegration().register(messenger, this)
        smsAutofillService = smsReg.service
        smsAutofillStreamHandler = smsReg.streamHandler

        profilePhotoProcessingService =
            ProfilePhotoProcessingIntegration().register(messenger, this)

        NativeMapViewIntegration().register(flutterEngine, messenger, this)
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val handled = imagePickerService.onActivityResult(requestCode, resultCode, data) ||
            filePickerService.onActivityResult(requestCode, resultCode, data)

        if (handled) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        audioService.dispose()
        locationService.dispose()
        networkUpdatesStreamHandler.dispose()
        super.onDestroy()
    }
}
