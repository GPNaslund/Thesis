package se.lnu.thesis.wearable_health.health_connect

import android.content.Context
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import se.lnu.thesis.wearable_health.enums.DataStoreAvailabilityResult
import se.lnu.thesis.wearable_health.enums.MethodCallType

/** Manages Health Connect integration, handling permissions and data operations. */
class HealthConnectManager (
    private val context: Context,
    private val healthConnectClient: HealthConnectClient
): ActivityAware {

    private var activityPluginBinding: ActivityPluginBinding? = null
    private var requestPermissionLauncher: ActivityResultLauncher<Set<String>>? = null
    private var pendingPermissionsResult: Result? = null

    private val pluginJob = SupervisorJob()
    private val pluginScope = CoroutineScope(Dispatchers.Main.immediate + pluginJob)

    private val healthConnectPermissionsManager = HealthConnectPermissionsManager()
    private val healthConnectDataManager = HealthConnectDataManager()

    private val tag = "HealthConnectManager"

    /** Handles method calls from Flutter and routes them to appropriate functions. */
    fun onMethodCall(call: MethodCall, result: Result) {
        val methodCallString = call.method.split("/")[1]
        val callType = MethodCallType.fromString(methodCallString)
        when (callType) {
            MethodCallType.GET_PLATFORM_VERSION -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            MethodCallType.CHECK_PERMISSIONS -> checkPermissions(result)
            MethodCallType.REQUEST_PERMISSIONS -> handleRequestPermissions(call, result)
            MethodCallType.DATA_STORE_AVAILABILITY -> checkDataStoreAvailability(result)
            MethodCallType.GET_DATA -> getData(call, result)
            MethodCallType.UNDEFINED -> {
                Log.d("HealthConnectManager", "Received undefined method call: $methodCallString")
                result.notImplemented()
            }
        }
    }

    /** Checks availability status of Health Connect and returns the result. */
    private fun checkDataStoreAvailability(result: Result) {
        val availabilityStatus = HealthConnectClient.getSdkStatus(context)
        var status: DataStoreAvailabilityResult = DataStoreAvailabilityResult.AVAILABLE
        when (availabilityStatus) {
            HealthConnectClient.SDK_AVAILABLE ->
                status = DataStoreAvailabilityResult.AVAILABLE
            HealthConnectClient.SDK_UNAVAILABLE ->
                status = DataStoreAvailabilityResult.UNAVAILABLE
            HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED ->
                status = DataStoreAvailabilityResult.NEEDS_UPDATE
        }
        result.success(status.toString())
    }

    /** Verifies current permissions status for requested health data types. */
    private fun checkPermissions(result: Result) {
        Log.d(tag, "checkPermissions called")
        healthConnectPermissionsManager.checkPermissions(result, pluginScope, healthConnectClient)
    }

    /** Initiates the permission request flow if no request is already pending. */
    private fun handleRequestPermissions(call: MethodCall, result: Result) {
        if (pendingPermissionsResult != null) {
            Log.d(tag, "Permission request attempted while another is pending.")
            result.error("ALREADY_PENDING", "Another permission request is already pending.", null)
            return 
        }

        if (requestPermissionLauncher == null) {
             Log.e(tag, "Cannot request permissions, launcher is null (not attached to activity?).")
             result.error("NOT_ATTACHED", "Cannot request permissions when not attached to an activity.", null)
             return
        }

        pendingPermissionsResult = result
        healthConnectPermissionsManager.requestPermissions(call, result, requestPermissionLauncher)
    }

    /** Retrieves health data using the HealthConnectDataManager. */
    private fun getData(call: MethodCall, result: Result) {
        healthConnectDataManager.getData(call, result, pluginScope, healthConnectClient)
    }

    /** Sets up the activity binding and permission launcher when attached to an activity. */
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
                        resultToSend.success(grantedPermissions.toList())
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

    /** Handles activity detachment during configuration changes. */
    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    /** Reattaches to activity after configuration changes. */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    /** Cleans up resources when detached from activity. */
    override fun onDetachedFromActivity() {
        Log.d("WearableHealthPlugin", "onDetachedFromActivity")
        activityPluginBinding = null
        requestPermissionLauncher = null
        pendingPermissionsResult = null
    }
}
