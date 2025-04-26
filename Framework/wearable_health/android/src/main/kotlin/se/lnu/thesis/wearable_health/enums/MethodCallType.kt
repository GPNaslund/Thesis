package se.lnu.thesis.wearable_health.enums

enum class MethodCallType(val value: String) {
    GET_PLATFORM_VERSION("getPlatformVersion"),
    HAS_PERMISSIONS("hasPermissions"),
    REQUEST_PERMISSIONS("requestPermissions"),
    DATA_STORE_AVAILABILITY("dataStoreAvailability"),
    GET_DATA("getData"),
    UNDEFINED("undefined");

    companion object {
        fun fromString(value: String): MethodCallType {
            return when (value) {
                "getPlatformVersion" -> GET_PLATFORM_VERSION
                "hasPermissions" -> HAS_PERMISSIONS
                "requestPermissions" -> REQUEST_PERMISSIONS
                "dataStoreAvailability" -> DATA_STORE_AVAILABILITY
                else -> UNDEFINED
            }
        }
    }
}
