package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SharedPreferencesService(activity: Activity) : MethodChannel.MethodCallHandler {
    private val prefs: SharedPreferences =
        activity.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAll" -> result.success(getAll())
            "set" -> handleSet(call, result)
            "remove" -> {
                val key = call.argument<String>("key")
                if (key.isNullOrBlank()) {
                    result.error("invalid_args", "key is required", null)
                    return
                }
                result.success(prefs.edit().remove(key).commit())
            }

            "clear" -> result.success(prefs.edit().clear().commit())
            else -> result.notImplemented()
        }
    }

    private fun getAll(): Map<String, Any?> {
        val raw: Map<String, *> = prefs.all
        val out = HashMap<String, Any?>(raw.size)
        for ((k, v) in raw) {
            out[k] = when (v) {
                is Set<*> -> v.filterIsInstance<String>()
                is Float -> v.toDouble()
                else -> v
            }
        }
        return out
    }

    private fun handleSet(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        val type = call.argument<String>("type")
        if (key.isNullOrBlank() || type.isNullOrBlank()) {
            result.error("invalid_args", "key and type are required", null)
            return
        }

        val editor = prefs.edit()
        when (type) {
            "string" -> editor.putString(key, call.argument<String>("value"))
            "int" -> editor.putInt(key, (call.argument<Number>("value") ?: 0).toInt())
            "double" -> editor.putFloat(key, (call.argument<Number>("value") ?: 0.0).toFloat())
            "bool" -> editor.putBoolean(key, call.argument<Boolean>("value") ?: false)
            "stringList" -> {
                @Suppress("UNCHECKED_CAST")
                val list = (call.argument<List<String>>("value") ?: emptyList())
                editor.putStringSet(key, list.toSet())
            }

            else -> {
                result.error("invalid_type", "Unsupported type: $type", null)
                return
            }
        }

        result.success(editor.commit())
    }

    companion object {
        private const val PREFS_NAME = "app_shared_preferences"
    }
}

