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

/** WearableHealthPlugin */
class WearableHealthPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var activityPluginBinding: ActivityPluginBinding? = null


    // Providers
    private lateinit var hcManager: HealthConnectManager
    private lateinit var healthConnectClient: HealthConnectClient

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wearable_health")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        healthConnectClient = HealthConnectClient.getOrCreate(context)
        hcManager = HealthConnectManager(context, healthConnectClient) 
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val provider = Provider.fromString(call.method.split("/")[0])
        when (provider) {
            Provider.HEALTH_CONNECT -> hcManager.onMethodCall(call, result)
            Provider.UNKNOWN -> result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("WearableHealthPlugin", "onDetachedFromEngine")
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding // ✅ this is currently missing
        hcManager.onAttachedToActivity(binding)
    }


    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
        hcManager.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
        hcManager.onReattachedToActivityForConfigChanges(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d("WearableHealthPlugin", "onDetachedFromActivity")

        activityPluginBinding = null
        hcManager.onDetachedFromActivity()
    }
}
