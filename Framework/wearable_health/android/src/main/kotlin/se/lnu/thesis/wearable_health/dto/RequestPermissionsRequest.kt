package se.lnu.thesis.wearable_health.dto

import se.lnu.thesis.wearable_health.enums.HealthDataType

class RequestPermissionsRequest private constructor(
    private val dataTypes: List<HealthDataType>
){

    companion object {
        fun fromArguments(arguments: Any): RequestPermissionsRequest {
            val dataStringsList = validateArguments(arguments)
            val healthDataList: MutableList<HealthDataType> = mutableListOf()
            for (dataString in dataStringsList) {
                val dataType = HealthDataType.getDataTypeByValue(dataString)
                if (dataType == HealthDataType.UNKNOWN) {
                    print("[RequestPermissionsRequest] received unknown data string")
                    continue
                }
                healthDataList.add(dataType)
            }
            return RequestPermissionsRequest(healthDataList)
        }

        private fun validateArguments(arguments: Any): List<String> {
            if (arguments !is Map<*, *>) {
                throw IllegalArgumentException("[RequestPermissionsRequest] arguments must be a Map")
            }

            if (!arguments.containsKey("dataTypes")) {
                throw IllegalArgumentException("[RequestPermissionsRequest] request map lacks 'dataTypes' key")
            }

            val dataTypesList: Any? = arguments["dataTypes"]

            if (dataTypesList !is List<*>) {
                throw IllegalArgumentException("[RequestPermissionsRequest] 'dataTypes' is not a List")
            }

            for (dataString in dataTypesList) {
                if (dataString !is String) {
                    throw IllegalArgumentException("[RequestPermissionsRequest] received non string i dataTypes list")
                }
            }

            @Suppress("UNCHECKED_CAST")
            val result = dataTypesList as List<String>
            return result
        }
    }

    fun toSetOfDefinitions(): Set<String> {
        val result: MutableSet<String> = mutableSetOf()
        for (dataType in this.dataTypes) {
            result.add(dataType.readDefinition)
        }
        return result
    }
}