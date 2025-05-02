package se.lnu.thesis.wearable_health.dto

import se.lnu.thesis.wearable_health.enums.HealthDataType

class RequestPermissionsResponse(private val grantedPermissions: Set<String>) {
    fun toMap(): Map<String, List<String>> {
        val dataTypeStrings: MutableList<String> = mutableListOf()
        for (definition in grantedPermissions) {
            val healthDataType = HealthDataType.getDataTypeByReadDefinition(definition)
            if (healthDataType == HealthDataType.UNKNOWN) {
                print("[CheckPermissionsResponse] received unknown permission from Set<String>")
                continue
            }
            dataTypeStrings.add(healthDataType.value)
        }
        return mapOf(
            "permissions" to dataTypeStrings
        )
    }
}