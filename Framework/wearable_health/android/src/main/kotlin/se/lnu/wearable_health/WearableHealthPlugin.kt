package se.lnu.wearable_health

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** WearableHealthPlugin */
class WearableHealthPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var pendingResult: Result? = null
  private var applicationContext: Context? = null

  private val healthConnectManager by lazy {
    HealthConnectManager(applicationContext ?: activity?.applicationContext)
  }

  companion object {
    const val REQUEST_HEALTH_CONNECT_PERMISSIONS = 42123
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, WearableHealthDataConstants.CHANNEL_NAME.value)
    channel.setMethodCallHandler(this)
    applicationContext = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      WearableHealthDataConstants.METHOD_GET_PLATFORM_VERSION.value -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      WearableHealthDataConstants.METHOD_REQUEST_PERMISSIONS.value -> requestPermissions(call, result)
      WearableHealthDataConstants.METHOD_START_COLLECTING.value -> result.notImplemented()
      else -> result.notImplemented()
    }
  }

  private fun requestPermissions(call: MethodCall, result: Result) {
    if (activity == null) {
      result.error("NO_ACTIVITY", "No activity available to launch permission request", null)
      return
    }

    try {
      pendingResult = result
      Log.d("WearableHealthPlugin", "Launching HealthConnectPermissionActivity to request or check permissions")
      Log.d("WearableHealthPlugin", "Received arguments: ${call.arguments<List<String>>()}")
      val intent = Intent(activity, HealthConnectPermissionActivity::class.java)
      activity?.startActivityForResult(intent, REQUEST_HEALTH_CONNECT_PERMISSIONS)
    } catch (e: Exception) {
      Log.e("WearableHealthPlugin", "Error launching activity", e)
      pendingResult = null
      result.error("PERMISSION_ERROR", e.message, null)
    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    Log.d("WearableHealthPlugin", "onActivityResult called: requestCode=$requestCode, resultCode=$resultCode, data=$data")

    if (requestCode == REQUEST_HEALTH_CONNECT_PERMISSIONS) {
      if (data == null || !data.hasExtra(HealthConnectPermissionActivity.PERMISSION_RESULT_KEY)) {
        Log.d("WearableHealthPlugin", "Returning from privacy policy, continuing permission flow")
        return true
      }

      try {
        val granted = data.getBooleanExtra(HealthConnectPermissionActivity.PERMISSION_RESULT_KEY, false)
        Log.d("WearableHealthPlugin", "Returning permission result to Flutter: granted=$granted")
        pendingResult?.success(granted)
      } catch (e: Exception) {
        Log.e("WearableHealthPlugin", "Error processing activity result", e)
        pendingResult?.error("ACTIVITY_RESULT_ERROR", "Error processing activity result: ${e.message}", null)
      } finally {
        pendingResult = null
      }
      return true
    }
    return false
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}