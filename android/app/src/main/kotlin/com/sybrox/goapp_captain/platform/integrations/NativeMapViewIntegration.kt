package com.sybrox.goapp_captain.platform.integrations

import android.app.Activity
import com.sybrox.goapp_captain.platform.views.NativeMapViewFactory
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger

internal class NativeMapViewIntegration {
    fun register(engine: FlutterEngine, messenger: BinaryMessenger, activity: Activity) {
        engine
            .platformViewsController
            .registry
            .registerViewFactory("app/native_map_view", NativeMapViewFactory(activity, messenger))
    }
}

