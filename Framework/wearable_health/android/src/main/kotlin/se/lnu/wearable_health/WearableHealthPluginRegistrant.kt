package se.lnu.wearable_health

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

// This file provides plugin registration for older Flutter versions
// and ensures the plugin is properly registered
class HealthConnectPluginRegistrant {
    companion object {
        @JvmStatic
        fun registerWith(registrar: FlutterPlugin.FlutterPluginBinding) {
            val plugin = WearableHealthPlugin()
            plugin.onAttachedToEngine(registrar)
        }
    }
}