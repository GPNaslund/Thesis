package se.lnu.thesis.wearable_health.dto

import se.lnu.thesis.wearable_health.enums.HealthDataType
import java.time.Instant

class GetDataRequest private constructor (
    val start: Instant,
    val end: Instant,
    val healthDataTypes: List<HealthDataType>
) {

    companion object {
        fun fromArguments(arguments: Any): GetDataRequest {
            validateArguments(arguments)
            arguments as Map<*, *>

            val startString = arguments["start"] as String
            val endString = arguments["end"] as String
            @Suppress("UNCHECKED_CAST")
            val dataTypesStrings = arguments["dataTypes"] as List<String>

            val startInstant = Instant.parse(startString)
            val endInstant = Instant.parse(endString)
            val healthDataTypeList: MutableList<HealthDataType> = mutableListOf()
            for (dataString in dataTypesStrings) {
                val healthDataType = HealthDataType.getDataTypeByValue(dataString)
                if (healthDataType == HealthDataType.UNKNOWN) {
                    print("[GetDataRequest] received unknown dataType string")
                    continue
                }
                healthDataTypeList.add(healthDataType)
            }
            return GetDataRequest(startInstant, endInstant, healthDataTypeList)
        }

        private fun validateArguments(arguments: Any) {
            if (arguments !is Map<*, *>) {
                throw IllegalArgumentException("[GetDataRequest] arguments must be a Map")
            }

            if (!arguments.containsKey("start")) {
                throw IllegalArgumentException("[GetDataRequest] request map lacks 'start' key")
            }

            if (arguments["start"] !is String) {
                throw IllegalArgumentException("[GetDataRequest] 'start' value is not a String")
            }

            if (!arguments.containsKey("end")) {
                throw IllegalArgumentException("[GetDataRequest] request map lacks 'end' key")
            }

            if (arguments["end"] !is String) {
                throw IllegalArgumentException("[GetDataRequest] 'end' value is not a String")
            }

            if (!arguments.containsKey("dataTypes")) {
                throw IllegalArgumentException("[GetDataRequest] request map lacks 'dataTypes' key")
            }

            val dataTypesList: Any? = arguments["dataTypes"]
            if (dataTypesList !is List<*>) {
                throw IllegalArgumentException("[GetDataRequest] 'dataTypes' value is not a List")
            }

            for (element in dataTypesList) {
                if (element !is String) {
                    throw IllegalArgumentException("[GetDataRequest] 'dataTypes' contained non String value")
                }
            }

        }
    }
}