package se.lnu.thesis.wearable_health.enums

enum class MethodCallType(val value: String) {
    GET_PLATFORM_VERSION("platformVersion"),
    CHECK_PERMISSIONS("checkPermissions"),
    REQUEST_PERMISSIONS("requestPermissions"),
    DATA_STORE_AVAILABILITY("dataStoreAvailability"),
    GET_DATA("getData"),
    UNDEFINED("undefined");

    companion object {
        fun fromString(value: String): MethodCallType {
            return when (value) {
                "platformVersion" -> GET_PLATFORM_VERSION
                "checkPermissions" -> CHECK_PERMISSIONS
                "requestPermissions" -> REQUEST_PERMISSIONS
                "dataStoreAvailability" -> DATA_STORE_AVAILABILITY
                "getData" -> GET_DATA
                else -> UNDEFINED
            }
        }
    }
}
