package com.sybrox.goapp_captain.platform.views

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.view.View
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.MapsInitializer
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.gms.maps.model.PolylineOptions
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import kotlin.math.roundToInt

class NativeMapView(
    private val activity: Activity,
    messenger: BinaryMessenger,
    viewId: Int,
    private val creationParams: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler {
    private val mapView: MapView = MapView(activity)
    private val channel: MethodChannel = MethodChannel(messenger, "app/native_map_view_$viewId")

    private var googleMap: com.google.android.gms.maps.GoogleMap? = null
    private val markerIconCache: MutableMap<String, BitmapDescriptor> = mutableMapOf()

    init {
        MapsInitializer.initialize(activity, MapsInitializer.Renderer.LATEST) {}
        channel.setMethodCallHandler(this)

        mapView.onCreate(null)
        mapView.onResume()

        mapView.getMapAsync { map ->
            googleMap = map
            applyCreationParams()
            attachListeners()
        }
    }

    override fun getView(): View = mapView

    override fun dispose() {
        channel.setMethodCallHandler(null)
        googleMap = null
        mapView.onPause()
        mapView.onDestroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val map = googleMap
        if (map == null) {
            result.success(null)
            return
        }

        when (call.method) {
            "updateOptions" -> {
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as? Map<String, Any?>
                applyOptions(map, args ?: emptyMap())
                result.success(null)
            }

            "setMarkers" -> {
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as? Map<String, Any?>
                val markers = (args?.get("markers") as? List<*>) ?: emptyList<Any?>()
                setMarkers(map, markers)
                result.success(null)
            }

            "setPolylines" -> {
                @Suppress("UNCHECKED_CAST")
                val args = call.arguments as? Map<String, Any?>
                val polylines = (args?.get("polylines") as? List<*>) ?: emptyList<Any?>()
                setPolylines(map, polylines)
                result.success(null)
            }

            "animateTo" -> {
                val lat = (call.argument<Number>("latitude") ?: 0).toDouble()
                val lng = (call.argument<Number>("longitude") ?: 0).toDouble()
                val zoom = (call.argument<Number>("zoom") ?: 14).toFloat()
                map.animateCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom))
                result.success(null)
            }

            "animateToBounds" -> {
                @Suppress("UNCHECKED_CAST")
                val sw = call.argument<Map<String, Any?>>("southwest")
                @Suppress("UNCHECKED_CAST")
                val ne = call.argument<Map<String, Any?>>("northeast")
                val padding = (call.argument<Number>("padding") ?: 0).toInt()
                if (sw == null || ne == null) {
                    result.error("invalid_args", "bounds required", null)
                    return
                }
                val bounds = LatLngBounds(
                    LatLng((sw["latitude"] as Number).toDouble(), (sw["longitude"] as Number).toDouble()),
                    LatLng((ne["latitude"] as Number).toDouble(), (ne["longitude"] as Number).toDouble())
                )
                map.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding))
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun applyCreationParams() {
        val map = googleMap ?: return

        @Suppress("UNCHECKED_CAST")
        val initial = creationParams["initialCameraPosition"] as? Map<String, Any?>
        @Suppress("UNCHECKED_CAST")
        val target = initial?.get("target") as? Map<String, Any?>
        val lat = (target?.get("latitude") as? Number)?.toDouble() ?: 0.0
        val lng = (target?.get("longitude") as? Number)?.toDouble() ?: 0.0
        val zoom = (initial?.get("zoom") as? Number)?.toFloat() ?: 14f
        map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom))

        applyOptions(map, creationParams)

        val markers = creationParams["markers"] as? List<*> ?: emptyList<Any?>()
        val polylines = creationParams["polylines"] as? List<*> ?: emptyList<Any?>()
        setMarkers(map, markers)
        setPolylines(map, polylines)
    }

    private fun applyOptions(map: com.google.android.gms.maps.GoogleMap, args: Map<String, Any?>) {
        val myLocationEnabled = args["myLocationEnabled"] as? Boolean ?: false
        val zoomControlsEnabled = args["zoomControlsEnabled"] as? Boolean ?: false
        val compassEnabled = args["compassEnabled"] as? Boolean ?: false
        val mapToolbarEnabled = args["mapToolbarEnabled"] as? Boolean ?: false

        try {
            map.isMyLocationEnabled = myLocationEnabled
        } catch (_: SecurityException) {
        }

        map.uiSettings.isZoomControlsEnabled = zoomControlsEnabled
        map.uiSettings.isCompassEnabled = compassEnabled
        map.uiSettings.isMapToolbarEnabled = mapToolbarEnabled

        val styleJson = args["style"] as? String
        if (!styleJson.isNullOrBlank()) {
            try {
                map.setMapStyle(com.google.android.gms.maps.model.MapStyleOptions(styleJson))
            } catch (_: Exception) {
            }
        }
    }

    private fun setMarkers(map: com.google.android.gms.maps.GoogleMap, markers: List<*>) {
        map.clear()
        for (m in markers) {
            @Suppress("UNCHECKED_CAST")
            val marker = m as? Map<String, Any?> ?: continue
            @Suppress("UNCHECKED_CAST")
            val pos = marker["position"] as? Map<String, Any?> ?: continue
            val lat = (pos["latitude"] as? Number)?.toDouble() ?: continue
            val lng = (pos["longitude"] as? Number)?.toDouble() ?: continue
            val title = marker["title"] as? String
            val snippet = marker["snippet"] as? String
            val hue = (marker["hue"] as? Number)?.toFloat()
            val assetName = marker["assetName"] as? String

            val options = MarkerOptions()
                .position(LatLng(lat, lng))
                .title(title)
                .snippet(snippet)

            val assetIcon = assetName?.let { loadMarkerIcon(it) }
            if (assetIcon != null) {
                options.icon(assetIcon)
            } else if (hue != null) {
                options.icon(BitmapDescriptorFactory.defaultMarker(hue))
            }

            map.addMarker(options)
        }
    }

    private fun loadMarkerIcon(assetName: String): BitmapDescriptor? {
        if (assetName.isBlank()) return null
        markerIconCache[assetName]?.let { return it }
        return try {
            val lookupKey = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetName)
            activity.assets.open(lookupKey).use { input ->
                val bitmap = BitmapFactory.decodeStream(input) ?: return null
                val sizePx = (44f * activity.resources.displayMetrics.density).roundToInt()
                val scaled: Bitmap = Bitmap.createScaledBitmap(bitmap, sizePx, sizePx, true)
                val descriptor = BitmapDescriptorFactory.fromBitmap(scaled)
                markerIconCache[assetName] = descriptor
                descriptor
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun setPolylines(map: com.google.android.gms.maps.GoogleMap, polylines: List<*>) {
        for (p in polylines) {
            @Suppress("UNCHECKED_CAST")
            val poly = p as? Map<String, Any?> ?: continue
            val colorVal = (poly["color"] as? Number)?.toInt() ?: Color.GREEN
            val width = (poly["width"] as? Number)?.toFloat() ?: 4f
            val pointsRaw = poly["points"] as? List<*> ?: emptyList<Any?>()

            val opts = PolylineOptions()
                .color(colorVal)
                .width(width)

            for (ptAny in pointsRaw) {
                @Suppress("UNCHECKED_CAST")
                val pt = ptAny as? Map<String, Any?> ?: continue
                val lat = (pt["latitude"] as? Number)?.toDouble() ?: continue
                val lng = (pt["longitude"] as? Number)?.toDouble() ?: continue
                opts.add(LatLng(lat, lng))
            }
            map.addPolyline(opts)
        }
    }

    private fun attachListeners() {
        val map = googleMap ?: return
        map.setOnMapClickListener { latLng ->
            channel.invokeMethod(
                "onTap",
                mapOf("latitude" to latLng.latitude, "longitude" to latLng.longitude)
            )
        }
        map.setOnCameraMoveListener {
            val position = map.cameraPosition
            channel.invokeMethod(
                "onCameraMove",
                mapOf(
                    "target" to mapOf(
                        "latitude" to position.target.latitude,
                        "longitude" to position.target.longitude
                    ),
                    "zoom" to position.zoom
                )
            )
        }
        map.setOnCameraIdleListener {
            channel.invokeMethod("onCameraIdle", null)
        }
    }
}

