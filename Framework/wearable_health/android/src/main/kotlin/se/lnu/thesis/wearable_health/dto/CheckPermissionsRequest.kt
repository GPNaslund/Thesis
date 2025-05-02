package se.lnu.thesis.wearable_health.dto

import androidx.health.connect.client.records.Record
import se.lnu.thesis.wearable_health.enums.HealthDataType
import kotlin.reflect.KClass

class CheckPermissionsRequest private constructor (
    val requestedDataTypes: List<KClass<out Record>>
){

    companion object {
        fun fromRecords(dataTypes: List<KClass<out Record>>): CheckPermissionsRequest {
            if (dataTypes.isEmpty()) {
                throw IllegalArgumentException("[CheckPermissionsRequest] cannot be constructed with empty list")
            }
            return CheckPermissionsRequest(dataTypes)
        }

        fun fromArguments(arguments: Any): CheckPermissionsRequest {
            val dataTypeStrings = validateArguments(arguments)
            val dataTypeRecords: MutableList<KClass<out Record>> = mutableListOf()

            for (string in dataTypeStrings) {
                val healthDataType = HealthDataType.getDataTypeByValue(string)
                if (healthDataType != HealthDataType.UNKNOWN) {
                    val record = healthDataType.toRecord()
                    dataTypeRecords.add(record)
                }
            }

            if (dataTypeRecords.isEmpty() && dataTypeStrings.isNotEmpty()) {
                throw IllegalArgumentException("[CheckPermissionsRequest] request map only contained unknown dataType strings")
            }

            return CheckPermissionsRequest(dataTypeRecords)
        }

        private fun validateArguments(arguments: Any): List<String> {
            if (arguments !is Map<*, *>) {
                throw IllegalArgumentException("[CheckPermissionsRequest] arguments must be a Map")
            }

            if (!arguments.containsKey("dataTypes")) {
                throw IllegalArgumentException("[CheckPermissionsRequest] serialized request lacks 'dataTypes' key")
            }

            val dataTypeValue: Any? = arguments["dataTypes"]
            if (dataTypeValue !is List<*>) {
                throw IllegalArgumentException("[CheckPermissionsRequest] 'dataTypes' must be a List<String>")
            }

            for (element in dataTypeValue) {
                if (element !is String) {
                    throw IllegalArgumentException("[CheckPermissionsRequest] dataTypes contained non String value")
                }
            }

            @Suppress("UNCHECKED_CAST")
            val stringList = dataTypeValue as List<String>
            return stringList
        }
    }
}