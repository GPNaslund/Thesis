package se.lnu.thesis.wearable_health


import android.content.Context
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.runBlocking

/** WearableHealthPlugin */
class WearableHealthPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var healthConnectClient: HealthConnectClient
  private lateinit var context: Context

  private var activityPluginBinding: ActivityPluginBinding? = null
  private var requestPermissionLauncher: ActivityResultLauncher<Set<String>>? = null
  private var pendingPermissionsResult: Result? = null

  private val permissions = setOf(
    HealthPermission.getReadPermission(StepsRecord::class),
  )

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wearable_health")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    healthConnectClient = HealthConnectClient.getOrCreate(context)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "hasPermissions" -> handleHasPermissions(call, result)
      "requestPermissions" -> handleRequestPermissions(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleHasPermissions(call: MethodCall, result: Result) {
    runBlocking {
      val hasPermissions = healthConnectClient.permissionController.getGrantedPermissions().containsAll(permissions)
      result.success(hasPermissions)
    }
  }

  private fun handleRequestPermissions(call: MethodCall, result: Result) {
    val arguments = call.arguments<Map<String, List<String>>>()
    val permissions = arguments?.get("permissions") ?: emptyList()

    Log.d("WearableHealthPlugin", "permissions $permissions")
    Log.d("WearableHealthPlugin","handleRequestPermissions called")
    if (pendingPermissionsResult != null) {
      result.error("ALREADY_REQUESTING", "A permission request is already in progress.", null)
      return
    }

    if (requestPermissionLauncher == null) {
      result.error("NOT_ATTACHED", "Plugin is not attached to an Activity.", null)
      Log.e("WearableHealthPlugin","Request permissions called while not attached to activity!")
      return
    }

    pendingPermissionsResult = result

    Log.d("WearableHealthPlugin","Launching Health Connect permission request")
    val permissionSet = permissions.toSet()
    requestPermissionLauncher?.launch(permissionSet)
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d("WearableHealthPlugin","onAttachedToActivity")
    this.activityPluginBinding = binding
    val activity = binding.activity
    if (activity is ComponentActivity) {
      requestPermissionLauncher = activity.registerForActivityResult(
        PermissionController.createRequestPermissionResultContract()
      ) { grantedPermissions ->
        Log.d("WearableHealthPlugin","Permission result received: $grantedPermissions")
        val resultToSend = pendingPermissionsResult
        pendingPermissionsResult = null

        if (resultToSend != null) {
          val allGranted = grantedPermissions.containsAll(permissions)
          Log.d("WearableHealthPlugin","All requested permissions granted: $allGranted")
          resultToSend.success(allGranted)
        } else {
          Log.w("WearableHealthPlugin","Permission result received but no pending Flutter result found.")
        }
      }
      Log.d("WearableHealthPlugin","Permission launcher registered.")
    } else {
      Log.e("WearableHealthPlugin","Activity is not a ComponentActivity, cannot register for result.")
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
  }

}