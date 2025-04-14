package se.lnu.thesis.wearable_health

import HealthConnectPermissionManager
import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/** WearableHealthPlugin */
class WearableHealthPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var permissionManager: HealthConnectPermissionManager
  private lateinit var permissionsLauncher: PermissionLauncherWrapper
  private lateinit var context: Context
  private var activity: Activity? = null
  private var lastPermissionResult: Result? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wearable_health")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "hasPermissions" -> handleHasPermissions(call, result)
      "getPermissions" -> handleRequestPermissions(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleHasPermissions(call: MethodCall, result: Result) {
    val permissions = call.argument<List<String>>("permissions")?.toSet() ?: emptySet()
    CoroutineScope(Dispatchers.Main).launch {
      val has = permissionManager.hasPermissions(permissions)
      result.success(has)
    }
  }

  private fun handleRequestPermissions(call: MethodCall, result: Result) {
    val permissions = call.argument<List<String>>("permissions")?.toSet() ?: emptySet()
    lastPermissionResult = result
    permissionsLauncher.launch(permissions)
  }

  private fun onHealthConnectPermissionCallback(granted: Set<String>) {
    val result = lastPermissionResult ?: return
    lastPermissionResult = null
    result.success(granted.isNotEmpty())
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)

    val contract = PermissionController.createRequestPermissionResultContract()

    permissionManager = HealthConnectPermissionManager(context, HealthConnectClient.getOrCreate(context))
    permissionsLauncher = PermissionLauncherWrapper()

    permissionsLauncher.register(activity as ComponentActivity, contract) { granted ->
      onHealthConnectPermissionCallback(granted)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    return false
  }

}
