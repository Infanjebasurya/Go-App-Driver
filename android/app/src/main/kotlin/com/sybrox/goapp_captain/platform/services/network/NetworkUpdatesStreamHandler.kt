package com.sybrox.goapp_captain.platform.services.network

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class NetworkUpdatesStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var connectivityManager: ConnectivityManager? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        val manager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        connectivityManager = manager
        networkCallback?.let { manager.unregisterNetworkCallback(it) }

        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) = push()
            override fun onLost(network: Network) = push()
            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities
            ) = push()

            private fun push() {
                mainHandler.post {
                    eventSink?.success(NetworkConnectivity.isConnected(context))
                }
            }
        }
        networkCallback = callback

        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        manager.registerNetworkCallback(request, callback)

        mainHandler.post {
            events?.success(NetworkConnectivity.isConnected(context))
        }
    }

    override fun onCancel(arguments: Any?) {
        dispose()
    }

    fun dispose() {
        val manager = connectivityManager
        val callback = networkCallback
        if (manager != null && callback != null) {
            manager.unregisterNetworkCallback(callback)
        }
        networkCallback = null
        connectivityManager = null
        eventSink = null
    }
}
