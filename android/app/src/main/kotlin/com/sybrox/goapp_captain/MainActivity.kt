package com.sybrox.goapp_captain

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity : FlutterActivity(), EventChannel.StreamHandler {
    private lateinit var permissionChannel: MethodChannel
    private lateinit var vibrationChannel: MethodChannel
    private lateinit var locationChannel: MethodChannel
    private lateinit var notificationChannel: MethodChannel
    private lateinit var audioChannel: MethodChannel
    private lateinit var backgroundChannel: MethodChannel
    private lateinit var networkChannel: MethodChannel
    private lateinit var permissionsChannel: MethodChannel
    private lateinit var networkEventsChannel: EventChannel
    private lateinit var prefs: SharedPreferences

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingPermissionName: String? = null
    private var pendingLocationResult: MethodChannel.Result? = null
    private var locationListener: LocationListener? = null
    private val locationHandler = Handler(Looper.getMainLooper())
    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var networkEventSink: EventChannel.EventSink? = null
    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        prefs = getSharedPreferences("native_permission_service", MODE_PRIVATE)

        permissionChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/permission_service"
        )
        permissionChannel.setMethodCallHandler(::handlePermissionCall)

        vibrationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/vibration_service"
        )
        vibrationChannel.setMethodCallHandler(::handleVibrationCall)

        locationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/location_service"
        )
        locationChannel.setMethodCallHandler(::handleLocationCall)

        notificationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/notification_service"
        )
        notificationChannel.setMethodCallHandler(::handleNotificationCall)

        audioChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/audio_service"
        )
        audioChannel.setMethodCallHandler(::handleAudioCall)

        backgroundChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/background_service"
        )
        backgroundChannel.setMethodCallHandler(::handleBackgroundCall)

        networkChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "native_network"
        )
        networkChannel.setMethodCallHandler(::handleNetworkCall)

        permissionsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "native_permissions"
        )
        permissionsChannel.setMethodCallHandler(::handleNativePermissionsCall)

        networkEventsChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "native_network_updates"
        )
        networkEventsChannel.setStreamHandler(this)
    }

    private fun handlePermissionCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> {
                val permissionName = call.argument<String>("permission")
                if (permissionName == null) {
                    result.error("invalid_args", "permission is required", null)
                    return
                }
                result.success(permissionStatus(permissionName))
            }

            "request" -> {
                val permissionName = call.argument<String>("permission")
                if (permissionName == null) {
                    result.error("invalid_args", "permission is required", null)
                    return
                }
                requestPermission(permissionName, result)
            }

            "openAppSettings" -> {
                val intent = Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.fromParts("package", packageName, null)
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleVibrationCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "vibrateAlert" -> {
                vibrateAlert()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleLocationCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkPermission" -> result.success(locationPermissionStatus())
            "requestPermission" -> requestLocationPermission(result)
            "isLocationServiceEnabled" -> result.success(isLocationServiceEnabled())
            "openLocationSettings" -> {
                startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(true)
            }
            "openAppSettings" -> {
                val intent = Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.fromParts("package", packageName, null)
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(true)
            }
            "getLastKnownPosition" -> result.success(getBestLastKnownPosition()?.toMap())
            "getCurrentPosition" -> {
                val timeLimitMs = call.argument<Int>("timeLimitMs") ?: 8000
                requestCurrentLocation(timeLimitMs, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleNotificationCall(call: MethodCall, result: MethodChannel.Result) {
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

    private fun handleAudioCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "playAsset" -> {
                val assetPath = call.argument<String>("assetPath")
                val volume = (call.argument<Double>("volume") ?: 1.0).toFloat()
                if (assetPath == null) {
                    result.error("invalid_args", "assetPath is required", null)
                    return
                }
                playAsset(assetPath, volume, result)
            }
            "stop" -> {
                stopAudio()
                result.success(null)
            }
            "dispose" -> {
                stopAudio(release = true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleBackgroundCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> result.success(null)
            "isRunning" -> result.success(TripForegroundService.isRunning)
            "startService" -> {
                val intent = Intent(this, TripForegroundService::class.java).apply {
                    action = TripForegroundService.ACTION_START_IDLE
                }
                ContextCompat.startForegroundService(this, intent)
                result.success(null)
            }
            "invoke" -> {
                val event = call.argument<String>("event")
                @Suppress("UNCHECKED_CAST")
                val data = call.argument<Map<String, Any?>>("data")
                val intent = Intent(this, TripForegroundService::class.java)
                if (event == BackgroundEvents.START_TRIP) {
                    intent.action = TripForegroundService.ACTION_START_TRIP
                    intent.putExtra("title", data?.get("title") as? String ?: "Trip in progress")
                    intent.putExtra("subtitle", data?.get("subtitle") as? String ?: "Driver is moving")
                    val durationMs = (data?.get("duration_ms") as? Number)?.toLong() ?: 10000L
                    intent.putExtra("duration_ms", durationMs)
                    ContextCompat.startForegroundService(this, intent)
                } else if (event == BackgroundEvents.STOP_TRIP) {
                    intent.action = TripForegroundService.ACTION_STOP_TRIP
                    startService(intent)
                } else if (event == "stopService") {
                    intent.action = TripForegroundService.ACTION_STOP_SERVICE
                    startService(intent)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleNetworkCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isConnected" -> result.success(isConnected())
            else -> result.notImplemented()
        }
    }

    private fun handleNativePermissionsCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "openWifiSettings" -> {
                startActivity(Intent(Settings.ACTION_WIFI_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(true)
            }
            "openMobileDataSettings" -> {
                val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    Intent(Settings.ACTION_WIRELESS_SETTINGS)
                } else {
                    Intent(Settings.ACTION_DATA_ROAMING_SETTINGS)
                }
                startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun requestPermission(permissionName: String, result: MethodChannel.Result) {
        if (pendingPermissionResult != null) {
            result.error("busy", "A permission request is already running", null)
            return
        }

        if (permissionName == "notification" && Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(permissionStatus(permissionName))
            return
        }

        val permission = androidPermission(permissionName)
        if (permission == null) {
            result.success("restricted")
            return
        }

        if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            result.success("granted")
            return
        }

        prefs.edit().putBoolean(permissionName, true).apply()
        pendingPermissionName = permissionName
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(this, arrayOf(permission), REQUEST_PERMISSION_CODE)
    }

    private fun permissionStatus(permissionName: String): String {
        if (permissionName == "location") {
            return locationPermissionStatus()
        }
        if (permissionName == "notification") {
            return notificationPermissionStatus()
        }

        val permission = androidPermission(permissionName) ?: return "restricted"
        if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            return "granted"
        }

        val hasRequestedBefore = prefs.getBoolean(permissionName, false)
        val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(this, permission)
        return if (hasRequestedBefore && !shouldShowRationale) {
            "permanentlyDenied"
        } else {
            "denied"
        }
    }

    private fun locationPermissionStatus(): String {
        val permission = Manifest.permission.ACCESS_FINE_LOCATION
        if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            return "whileInUse"
        }
        val hasRequestedBefore = prefs.getBoolean("location", false)
        val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(this, permission)
        return if (hasRequestedBefore && !shouldShowRationale) {
            "deniedForever"
        } else {
            "denied"
        }
    }

    private fun requestLocationPermission(result: MethodChannel.Result) {
        if (pendingPermissionResult != null) {
            result.error("busy", "A permission request is already running", null)
            return
        }
        val permission = Manifest.permission.ACCESS_FINE_LOCATION
        if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            result.success("whileInUse")
            return
        }
        prefs.edit().putBoolean("location", true).apply()
        pendingPermissionName = "location"
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(this, arrayOf(permission), REQUEST_PERMISSION_CODE)
    }

    private fun notificationPermissionStatus(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return if (NotificationManagerCompat.from(this).areNotificationsEnabled()) {
                "granted"
            } else {
                "denied"
            }
        }

        val permission = Manifest.permission.POST_NOTIFICATIONS
        if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            return "granted"
        }

        val hasRequestedBefore = prefs.getBoolean("notification", false)
        val shouldShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(this, permission)
        return if (hasRequestedBefore && !shouldShowRationale) {
            "permanentlyDenied"
        } else {
            "denied"
        }
    }

    private fun androidPermission(permissionName: String): String? {
        return when (permissionName) {
            "camera" -> Manifest.permission.CAMERA
            "location" -> Manifest.permission.ACCESS_FINE_LOCATION
            "photos" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Manifest.permission.READ_MEDIA_IMAGES
                } else {
                    Manifest.permission.READ_EXTERNAL_STORAGE
                }
            }

            "notification" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Manifest.permission.POST_NOTIFICATIONS
                } else {
                    null
                }
            }

            else -> null
        }
    }

    private fun isLocationServiceEnabled(): Boolean {
        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return manager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
            manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    }

    private fun getBestLastKnownPosition(): Location? {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }

        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val providers = manager.getProviders(true)
        var bestLocation: Location? = null
        for (provider in providers) {
            val location = manager.getLastKnownLocation(provider) ?: continue
            if (bestLocation == null || location.accuracy < bestLocation.accuracy) {
                bestLocation = location
            }
        }
        return bestLocation
    }

    private fun requestCurrentLocation(timeLimitMs: Int, result: MethodChannel.Result) {
        if (pendingLocationResult != null) {
            result.error("busy", "A location request is already running", null)
            return
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            result.error("permission_denied", "Location permission is not granted", null)
            return
        }

        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        if (!isLocationServiceEnabled()) {
            result.error("service_disabled", "Location service is disabled", null)
            return
        }

        pendingLocationResult = result
        val listener = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                completeLocationRequest(location)
            }
        }
        locationListener = listener

        try {
            if (manager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                manager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    0L,
                    0f,
                    listener,
                    Looper.getMainLooper()
                )
            }
            if (manager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                manager.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER,
                    0L,
                    0f,
                    listener,
                    Looper.getMainLooper()
                )
            }
        } catch (exception: SecurityException) {
            pendingLocationResult = null
            locationListener = null
            result.error("permission_denied", exception.message, null)
            return
        }

        locationHandler.postDelayed({
            if (pendingLocationResult == null) return@postDelayed
            completeLocationRequest(getBestLastKnownPosition())
        }, timeLimitMs.toLong())
    }

    private fun completeLocationRequest(location: Location?) {
        val result = pendingLocationResult ?: return
        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        locationListener?.let { manager.removeUpdates(it) }
        locationListener = null
        locationHandler.removeCallbacksAndMessages(null)
        pendingLocationResult = null

        if (location == null) {
            result.error("location_unavailable", "Current location is unavailable", null)
            return
        }
        result.success(location.toMap())
    }

    private fun Location.toMap(): Map<String, Double> {
        return mapOf(
            "latitude" to latitude,
            "longitude" to longitude
        )
    }

    private fun createNotificationChannel(
        channelId: String,
        channelName: String,
        channelDescription: String
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
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
        val builder = NotificationCompat.Builder(this, channelId)
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

        NotificationManagerCompat.from(this).notify(id, builder.build())
    }

    private fun playAsset(assetPath: String, volume: Float, result: MethodChannel.Result) {
        try {
            stopAudio(release = true)
            val normalizedAssetPath = normalizeFlutterAssetPath(assetPath)
            val assetFile = resolveAudioAssetFile(normalizedAssetPath)
            requestAudioFocus()
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                setDataSource(assetFile.absolutePath)
                setVolume(volume, volume)
                isLooping = false
                setOnCompletionListener {
                    abandonAudioFocus()
                }
                prepare()
                start()
            }
            result.success(null)
        } catch (exception: Exception) {
            result.error("audio_error", exception.message, null)
        }
    }

    private fun normalizeFlutterAssetPath(assetPath: String): String {
        return if (assetPath.startsWith("assets/")) {
            assetPath
        } else {
            "assets/$assetPath"
        }
    }

    private fun resolveAudioAssetFile(assetPath: String): File {
        val lookupKey = FlutterInjector.instance().flutterLoader()
            .getLookupKeyForAsset(assetPath)
        val targetFile = File(cacheDir, assetPath.replace('/', '_'))
        assets.open(lookupKey).use { input ->
            targetFile.outputStream().use { output ->
                input.copyTo(output)
            }
        }
        return targetFile
    }

    private fun isConnected(): Boolean {
        val manager = connectivityManager
            ?: getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        connectivityManager = manager
        val network = manager.activeNetwork ?: return false
        val capabilities = manager.getNetworkCapabilities(network) ?: return false
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
            capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
    }

    private fun stopAudio(release: Boolean = false) {
        mediaPlayer?.run {
            if (isPlaying) {
                stop()
            }
            reset()
            if (release) {
                release()
            }
        }
        if (release) {
            mediaPlayer = null
        }
        abandonAudioFocus()
    }

    private fun requestAudioFocus() {
        val manager = audioManager
            ?: getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager = manager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAcceptsDelayedFocusGain(false)
                .setOnAudioFocusChangeListener { }
                .build()
            audioFocusRequest = request
            manager.requestAudioFocus(request)
        } else {
            @Suppress("DEPRECATION")
            manager.requestAudioFocus(
                null,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
            )
        }
    }

    private fun abandonAudioFocus() {
        val manager = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { manager.abandonAudioFocusRequest(it) }
            audioFocusRequest = null
        } else {
            @Suppress("DEPRECATION")
            manager.abandonAudioFocus(null)
        }
    }

    private fun vibrateAlert() {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }

        if (!vibrator.hasVibrator()) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(450L, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(450L)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != REQUEST_PERMISSION_CODE) {
            return
        }

        val result = pendingPermissionResult ?: return
        val permissionName = pendingPermissionName ?: ""
        pendingPermissionResult = null
        pendingPermissionName = null

        val isGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (isGranted) {
            result.success("granted")
            return
        }

        val permission = androidPermission(permissionName)
        val shouldShowRationale = permission != null &&
            ActivityCompat.shouldShowRequestPermissionRationale(this, permission)
        result.success(if (shouldShowRationale) "denied" else "permanentlyDenied")
    }

    companion object {
        private const val REQUEST_PERMISSION_CODE = 1107
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        networkEventSink = events
        val manager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        connectivityManager = manager
        networkCallback?.let { manager.unregisterNetworkCallback(it) }
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                locationHandler.post {
                    networkEventSink?.success(isConnected())
                }
            }

            override fun onLost(network: Network) {
                locationHandler.post {
                    networkEventSink?.success(isConnected())
                }
            }

            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities
            ) {
                locationHandler.post {
                    networkEventSink?.success(isConnected())
                }
            }
        }
        networkCallback = callback
        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        manager.registerNetworkCallback(request, callback)
        locationHandler.post {
            events?.success(isConnected())
        }
    }

    override fun onCancel(arguments: Any?) {
        val manager = connectivityManager
        val callback = networkCallback
        if (manager != null && callback != null) {
            manager.unregisterNetworkCallback(callback)
        }
        networkCallback = null
        networkEventSink = null
    }
}

private object BackgroundEvents {
    const val START_TRIP = "start_trip"
    const val STOP_TRIP = "stop_trip"
}
