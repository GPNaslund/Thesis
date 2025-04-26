package se.lnu.thesis.wearable_health

import android.content.Context
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.SkinTemperatureRecord
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.reflect.KClass
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import se.lnu.thesis.wearable_health.enums.DataStoreAvailabilityResult
import se.lnu.thesis.wearable_health.enums.MethodCallType
import se.lnu.thesis.wearable_health.enums.ResultError

/** WearableHealthPlugin */
class WearableHealthPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var healthConnectClient: HealthConnectClient
    private lateinit var context: Context

    private var activityPluginBinding: ActivityPluginBinding? = null
    private var requestPermissionLauncher: ActivityResultLauncher<Set<String>>? = null
    private var pendingPermissionsResult: Result? = null

    private var dataTypes: MutableList<KClass<out Record>> = mutableListOf()
    private var permissions: MutableSet<String> = mutableSetOf()

    private val pluginJob = SupervisorJob()
    private val pluginScope = CoroutineScope(Dispatchers.Main.immediate + pluginJob)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wearable_health")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        healthConnectClient = HealthConnectClient.getOrCreate(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val callType = MethodCallType.fromString(call.method)
        when (callType) {
            MethodCallType.GET_PLATFORM_VERSION ->
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
            MethodCallType.HAS_PERMISSIONS -> handleHasPermissions(call, result)
            MethodCallType.REQUEST_PERMISSIONS -> handleRequestPermissions(call, result)
            MethodCallType.DATA_STORE_AVAILABILITY -> checkDataStoreAvailability(result)
            MethodCallType.GET_DATA -> getData(call, result)
            MethodCallType.UNDEFINED -> result.notImplemented()
        }
    }

    private fun checkDataStoreAvailability(result: Result) {
        val availabilityStatus = HealthConnectClient.getSdkStatus(context)
        when (availabilityStatus) {
            HealthConnectClient.SDK_AVAILABLE ->
                    result.success(DataStoreAvailabilityResult.AVAILABLE.result)
            HealthConnectClient.SDK_UNAVAILABLE ->
                    result.success(DataStoreAvailabilityResult.UNAVAILABLE.result)
            HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED ->
                    result.success(DataStoreAvailabilityResult.NEEDS_UPDATE.result)
        }
    }

    private fun handleHasPermissions(call: MethodCall, result: Result) {
        Log.d("WearableHealthPlugin", "handleHasPermissions called")

        pluginScope.launch {
            Log.d("WearableHealthPlugin", "Coroutine started in pluginScope for hasPermissions")
            try {
                val granted =
                        withContext(Dispatchers.IO) {
                            Log.d("WearableHealthPlugin", "Checking permissions on IO dispatcher")

                            if (!::healthConnectClient.isInitialized) {
                                val err = ResultError.HEALTH_CONNECT_CLIENT_NOT_INITIALIZED
                                result.error(err.errorCode, err.errorMessage, null)
                            }
                            healthConnectClient.permissionController.getGrantedPermissions()
                        }

                assignRequestedPermissions(call)

                val hasPermissions = granted.containsAll(permissions)
                Log.d("WearableHealthPlugin", "Has permissions: $hasPermissions")
                result.success(hasPermissions)
            } catch (e: CancellationException) {
                Log.d("WearableHealthPlugin", "Coroutine cancelled")
            } catch (e: Exception) {
                Log.e("WearableHealthPlugin", "Error checking permissions", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun handleRequestPermissions(call: MethodCall, result: Result) {
        assignRequestedPermissions(call)

        Log.d("WearableHealthPlugin", "permissions $dataTypes")
        Log.d("WearableHealthPlugin", "handleRequestPermissions called")
        if (pendingPermissionsResult != null) {
            result.error("ALREADY_REQUESTING", "A permission request is already in progress.", null)
            return
        }

        if (requestPermissionLauncher == null) {
            result.error("NOT_ATTACHED", "Plugin is not attached to an Activity.", null)
            Log.e(
                    "WearableHealthPlugin",
                    "Request permissions called while not attached to activity!"
            )
            return
        }

        pendingPermissionsResult = result

        Log.d("WearableHealthPlugin", "Launching Health Connect permission request")
        requestPermissionLauncher?.launch(permissions)
    }

    private fun getData(call: MethodCall, result: Result) {
        val arguments = call.arguments<Map<String, String>>()
        val start = arguments?.get("start") ?: ""
        val end = arguments?.get("end") ?: ""

        try {
            for (dataType in dataTypes) {}
        } catch (e: Exception) {}
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("WearableHealthPlugin", "onDetachedFromEngine")
        channel.setMethodCallHandler(null)
        try {
            pluginJob.cancel()
            Log.d("WearableHealthPlugin", "Plugin job cancelled")
        } catch (e: Exception) {
            Log.e("WearableHealthPlugin", "Error cancelling plugin job", e)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("WearableHealthPlugin", "onAttachedToActivity")
        this.activityPluginBinding = binding
        val activity = binding.activity
        if (activity is ComponentActivity) {
            requestPermissionLauncher =
                    activity.registerForActivityResult(
                            PermissionController.createRequestPermissionResultContract()
                    ) { grantedPermissions ->
                        Log.d(
                                "WearableHealthPlugin",
                                "Permission result received: $grantedPermissions"
                        )
                        val resultToSend = pendingPermissionsResult
                        pendingPermissionsResult = null

                        if (resultToSend != null) {
                            val allGranted = grantedPermissions.containsAll(permissions)
                            Log.d(
                                    "WearableHealthPlugin",
                                    "All requested permissions granted: $allGranted"
                            )
                            resultToSend.success(allGranted)
                        } else {
                            Log.w(
                                    "WearableHealthPlugin",
                                    "Permission result received but no pending Flutter result found."
                            )
                        }
                    }
            Log.d("WearableHealthPlugin", "Permission launcher registered.")
        } else {
            Log.e(
                    "WearableHealthPlugin",
                    "Activity is not a ComponentActivity, cannot register for result."
            )
        }
    }

    private fun assignRequestedPermissions(call: MethodCall) {
        val arguments = call.arguments<Map<String, List<String>>>()
        val dataTypeList = arguments?.get("dataTypes") ?: emptyList()

        for (dataType in dataTypeList) {
            when (dataType) {
                "heartRate" -> {
                    dataTypes.add(HeartRateRecord::class)
                    permissions.add(HealthPermission.getReadPermission(HeartRateRecord::class))
                }
                "skinTemperature" -> {
                    dataTypes.add(SkinTemperatureRecord::class)
                    permissions.add(
                            HealthPermission.getReadPermission(SkinTemperatureRecord::class)
                    )
                }
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d("WearableHealthPlugin", "onDetachedFromActivity")
        activityPluginBinding = null
        requestPermissionLauncher = null
        pendingPermissionsResult = null
        dataTypes = mutableListOf()
    }
}
