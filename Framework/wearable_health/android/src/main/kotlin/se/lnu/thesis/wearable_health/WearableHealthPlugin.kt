package se.lnu.thesis.wearable_health

import android.content.Context
import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import se.lnu.thesis.wearable_health.enums.Provider
import se.lnu.thesis.wearable_health.health_connect.HealthConnectManager

/**
 * Flutter plugin that provides access to wearable health data through various providers.
 * Handles communication between Flutter and native Android health data APIs.
 */
class WearableHealthPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /** The MethodChannel for communication between Flutter and native Android */
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var activityPluginBinding: ActivityPluginBinding? = null


    // Providers
    private lateinit var hcManager: HealthConnectManager
    private lateinit var healthConnectClient: HealthConnectClient

    /** Sets up the plugin when attached to the Flutter engine. */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wearable_health")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        healthConnectClient = HealthConnectClient.getOrCreate(context)
        hcManager = HealthConnectManager(context, healthConnectClient) 
    }

    /** Routes method calls to the appropriate provider based on the method name. */
    override fun onMethodCall(call: MethodCall, result: Result) {
        val provider = Provider.fromString(call.method.split("/")[0])
        when (provider) {
            Provider.HEALTH_CONNECT -> hcManager.onMethodCall(call, result)
            Provider.UNKNOWN -> result.notImplemented()
        }
    }

    /** Cleans up resources when detached from the Flutter engine. */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("WearableHealthPlugin", "onDetachedFromEngine")
        channel.setMethodCallHandler(null)
    }

    /** Forwards activity attachment to the health connect manager. */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        hcManager.onAttachedToActivity(binding)
    }

    /** Handles activity detachment during configuration changes. */
    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
        hcManager.onDetachedFromActivity()
    }

    /** Forwards activity reattachment to the health connect manager. */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
        hcManager.onReattachedToActivityForConfigChanges(binding)
    }

    /** Cleans up activity-related resources and notifies the health connect manager. */
    override fun onDetachedFromActivity() {
        Log.d("WearableHealthPlugin", "onDetachedFromActivity")
        activityPluginBinding = null
        hcManager.onDetachedFromActivity()
    }
}
