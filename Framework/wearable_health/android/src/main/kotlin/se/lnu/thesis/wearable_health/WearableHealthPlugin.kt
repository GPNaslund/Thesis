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
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.time.Instant
import kotlin.reflect.KClass
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import se.lnu.thesis.wearable_health.dto.CheckPermissionsRequest
import se.lnu.thesis.wearable_health.dto.CheckPermissionsResponse
import se.lnu.thesis.wearable_health.dto.DataStoreAvailabilityResponse
import se.lnu.thesis.wearable_health.dto.GetDataRequest
import se.lnu.thesis.wearable_health.dto.GetDataResponse
import se.lnu.thesis.wearable_health.dto.RequestPermissionsRequest
import se.lnu.thesis.wearable_health.dto.RequestPermissionsResponse
import se.lnu.thesis.wearable_health.enums.DataStoreAvailabilityResult
import se.lnu.thesis.wearable_health.enums.MethodCallType
import se.lnu.thesis.wearable_health.enums.ResultError
import se.lnu.thesis.wearable_health.record_extension.serialize

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
            MethodCallType.CHECK_PERMISSIONS -> handleCheckPermissions(call, result)
            MethodCallType.REQUEST_PERMISSIONS -> handleRequestPermissions(call, result)
            MethodCallType.DATA_STORE_AVAILABILITY -> checkDataStoreAvailability(result)
            MethodCallType.GET_DATA -> getData(call, result)
            MethodCallType.UNDEFINED -> result.notImplemented()
        }
    }

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
        val response = DataStoreAvailabilityResponse(status)
        result.success(response.toString())
    }

    private fun handleCheckPermissions(call: MethodCall, result: Result) {
        Log.d("WearableHealthPlugin", "handleCheckPermissions called")

        pluginScope.launch {
            Log.d("WearableHealthPlugin", "Coroutine started in pluginScope for handleCheckPermissions")
            val request = CheckPermissionsRequest.fromArguments(call.arguments)
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

                val response = CheckPermissionsResponse(granted)
                result.success(response.toMap())
            } catch (e: CancellationException) {
                Log.d("WearableHealthPlugin", "Coroutine cancelled")
            } catch (e: Exception) {
                Log.e("WearableHealthPlugin", "Error checking permissions", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun handleRequestPermissions(call: MethodCall, result: Result) {
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

        val request = RequestPermissionsRequest.fromArguments(call.arguments)
        Log.d("WearableHealthPlugin", "Launching Health Connect permission request")
        requestPermissionLauncher?.launch(request.toSetOfDefinitions())
    }

    private fun getData(call: MethodCall, result: Result) {
        pluginScope.launch {
            try {
                Log.d("WearableHealthPlugin", "Coroutine launched for getData")
                val serializedListResult: List<Map<String, Any?>> = withContext(Dispatchers.IO) {
                    Log.d("WearableHealthPlugin", "Executing read operations on IO dispatcher")
                    val req = GetDataRequest.fromArguments(call.arguments)
                    val dataList: MutableList<Map<String, Any?>> = mutableListOf()

                    for (dataType in req.healthDataTypes) {
                        Log.d("WearableHealthPlugin", "Reading data for ${dataType.value}")
                        val response = healthConnectClient.readRecords(
                            ReadRecordsRequest(
                                recordType = dataType.toRecord(),
                                timeRangeFilter = TimeRangeFilter.between(req.start, req.end)
                            )
                        )
                        Log.d("WearableHealthPlugin", "Read ${response.records.size} records for ${dataType.value}")

                        for (record in response.records) {
                            val serializedRecord: Map<String, Any?>? = when (record) {
                                is HeartRateRecord -> record.serialize()
                                is SkinTemperatureRecord -> record.serialize()
                                else -> {
                                    Log.w("WearableHealthPlugin", "Unsupported record type encountered: ${record::class.simpleName}")
                                    null
                                }
                            }
                            serializedRecord?.let { dataList.add(it) }
                        }
                    }
                    dataList
                }

                Log.d("WearableHealthPlugin", "Data fetch complete, sending ${serializedListResult.size} records to Flutter.")
                val response = GetDataResponse(serializedListResult)
                result.success(response.toMap())

            } catch (e: CancellationException) {
                Log.i("WearableHealthPlugin", "Data fetch job was cancelled", e)
                result.error("CANCELLED", "Data fetch cancelled", null)
            } catch (e: Exception) {
                Log.e("WearableHealthPlugin", "Error during data fetch coroutine", e)
                result.error("GET_DATA_FAIL", "Failed to get data: ${e.message}", e.toString())
            }
        }
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
                            val response = RequestPermissionsResponse(grantedPermissions)
                            resultToSend.success(response.toMap())
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
    }
}
