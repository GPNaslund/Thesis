package se.lnu.thesis.wearable_health.health_connect

import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.SkinTemperatureRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import se.lnu.thesis.wearable_health.record_extension.serialize
import java.time.Instant
import kotlin.reflect.KClass

class HealthConnectDataManager {
    private val tag = "HCDataManager"
    fun getData(call: MethodCall, result: Result, pluginScope: CoroutineScope, healthConnectClient: HealthConnectClient) {
        pluginScope.launch {
            try {
                Log.d("WearableHealthPlugin", "Coroutine launched for getData")
                val serializedMapResult: Map<String, List<Map<String, Any?>>> = withContext(Dispatchers.IO) {
                    Log.d("WearableHealthPlugin", "Executing read operations on IO dispatcher")

                    val startInstant = extractInstant(call.arguments, result, "start") ?: throw Exception()
                    val endInstant = extractInstant(call.arguments, result, "end") ?: throw Exception()
                    val healthDataStrings = extractDataTypes(call.arguments, result) ?: throw Exception()
                    val healthDataTypes: MutableList<KClass<out Record>> = mutableListOf()
                    for (element in healthDataStrings) {
                        val healthDataType = permissionToClass(element)
                        if (healthDataType != null) {
                            healthDataTypes.add(healthDataType)
                        } else {
                            Log.d(tag, "Got unknown health data type: $element", null)
                        }
                    }

                    val dataMap: MutableMap<String, MutableList<Map<String, Any?>>> = mutableMapOf()
                    for (element in healthDataTypes.toSet()) {
                        dataMap[HealthPermission.getReadPermission(element)] = mutableListOf()
                    }

                    for (dataType in healthDataTypes) {
                        val response = healthConnectClient.readRecords(
                            ReadRecordsRequest(
                                recordType = dataType,
                                timeRangeFilter = TimeRangeFilter.between(startInstant, endInstant)
                            )
                        )
                        Log.d(tag,"Read ${response.records.size} records for $dataType")

                        for (record in response.records) {
                            when (record) {
                                is HeartRateRecord -> {
                                    val serialized = record.serialize()
                                    dataMap[HealthPermission.getReadPermission(record::class)]!!.add(serialized)
                                }
                                is SkinTemperatureRecord -> {
                                    val serialized = record.serialize()
                                    dataMap[HealthPermission.getReadPermission(record::class)]!!.add(serialized)
                                }
                                else -> {
                                    Log.w(
                                        tag,
                                        "Unsupported record type encountered: ${record::class.simpleName}"
                                    )
                                }
                            }
                        }
                    }
                    dataMap
                }

                Log.d(
                    "WearableHealthPlugin",
                    "Data fetch complete."
                )
                result.success(serializedMapResult)

            } catch (e: CancellationException) {
                Log.i("WearableHealthPlugin", "Data fetch job was cancelled", e)
                result.error("CANCELLED", "Data fetch cancelled", null)
            } catch (e: Exception) {
                Log.e("WearableHealthPlugin", "Error during data fetch coroutine", e)
                result.error("GET_DATA_FAIL", "Failed to get data: ${e.message}", e.toString())
            }
        }
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

    private fun extractInstant(arguments: Any, result: Result, key: String): Instant? {
        if (arguments !is Map<*, *>) {
            result.error("INVALID_ARGUMENT", "Expected Map, got: ${arguments::class}", null)
            return null
        }

        if (!arguments.containsKey(key)) {
            result.error("INVALID_ARGUMENT", "Expected map to contain key $key", null)
            return null;
        }

        val stringVal = arguments[key]
        if (stringVal !is String) {
            result.error("INVALID_ARGUMENT", "Expected $key to be a String", null)
            return null;
        }

        try {
            return Instant.parse(stringVal)
        } catch (e: Error) {
            result.error("INVALID_ARGUMENT", "Failed to parse string to Instant: $e.message", null)
            return null
        }
    }

    private fun permissionToClass(value: String): KClass<out Record>? {
        return when (value) {
            HealthPermission.getReadPermission(HeartRateRecord::class) -> HeartRateRecord::class
            HealthPermission.getReadPermission(SkinTemperatureRecord::class) -> SkinTemperatureRecord::class
            else -> null
        }
    }
}