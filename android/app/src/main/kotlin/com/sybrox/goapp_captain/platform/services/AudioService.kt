package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class AudioService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
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

    fun dispose() {
        stopAudio(release = true)
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
        return if (assetPath.startsWith("assets/")) assetPath else "assets/$assetPath"
    }

    private fun resolveAudioAssetFile(assetPath: String): File {
        val lookupKey = FlutterInjector.instance().flutterLoader()
            .getLookupKeyForAsset(assetPath)
        val targetFile = File(activity.cacheDir, assetPath.replace('/', '_'))
        activity.assets.open(lookupKey).use { input ->
            targetFile.outputStream().use { output ->
                input.copyTo(output)
            }
        }
        return targetFile
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
        val manager = audioManager ?: (activity.getSystemService(Context.AUDIO_SERVICE) as AudioManager)
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
}
