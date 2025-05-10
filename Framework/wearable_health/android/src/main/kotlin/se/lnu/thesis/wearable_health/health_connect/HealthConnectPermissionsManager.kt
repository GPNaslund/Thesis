package se.lnu.thesis.wearable_health.health_connect

import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.coroutines.cancellation.CancellationException

class HealthConnectPermissionsManager() {
    private val TAG = "HCPermissionManager"

    fun checkPermissions(result: Result, pluginScope: CoroutineScope, healthConnectClient: HealthConnectClient) {
        Log.d(TAG, "checkPermissions called")
        pluginScope.launch {
            Log.d(TAG, "Coroutine started in pluginScope for checkPermissions")
            try {
                val granted =
                    withContext(Dispatchers.IO) {
                        Log.d(TAG, "Checking permissions on IO dispatcher")
                        healthConnectClient.permissionController.getGrantedPermissions()
                    }
                result.success(granted.toList())
            } catch (e: CancellationException) {
                Log.d(TAG, "Coroutine cancelled")
            } catch (e: Exception) {
                Log.e(TAG, "Error checking permissions", e)
                result.error("ERROR", e.message, null)
            }
        }
    }

    fun requestPermissions(call: MethodCall, result: Result, requestPermissionLauncher: ActivityResultLauncher<Set<String>>?) {
        Log.d(TAG, "handleRequestPermissions called")

        if (requestPermissionLauncher == null) {
            result.error("NOT_ATTACHED", "Plugin is not attached to an Activity.", null)
            Log.e(TAG, "Request permissions called while not attached to activity!")
            return
        }

        val dataTypes = extractDataTypes(call.arguments, result) ?: return
        Log.d(TAG, "Launching Health Connect permission request")
        requestPermissionLauncher.launch(dataTypes)
    }

    private fun extractDataTypes(arguments: Any, result: Result): Set<String>? {
        if (arguments !is Map<*, *>) {
            result.error("INVALID_ARGUMENT", "Expected Map, got: ${arguments::class}", null)
            return null;
        }

        if (!arguments.containsKey("types")) {
            result.error("INVALID_ARGUMENT", "Expected map to contain key 'types'", null)
            return null;
        }

        val dataTypeValue: Any? = arguments["types"]
        if (dataTypeValue !is List<*>) {
            result.error("INVALID_ARGUMENT", "Expected 'types' to be a list", null)
            return null
        }

        for (element in dataTypeValue) {
            if (element !is String) {
                result.error("INVALID_ARGUMENT", "Got non string value in 'types' list", null);
            }
        }

        @Suppress("UNCHECKED_CAST")
        val stringList = dataTypeValue as List<String>
        return stringList.toSet()
    }
}