package se.lnu.thesis.wearable_health.enums

/**
 * Defines the set of method calls that can be invoked from Flutter to the native Android side.
 * Each enum value represents a specific operation that the plugin can perform.
 * The string value is used for serialization when communicating between Flutter and native code.
 */
enum class MethodCallType(val value: String) {
    /**
     * Used to retrieve the platform version information from the Android device.
     * This is often used as a simple test to verify that the communication channel is working.
     */
    GET_PLATFORM_VERSION("platformVersion"),

    /**
     * Checks the current status of required permissions for the plugin to function.
     * Returns the permission state without attempting to request any permissions.
     */
    CHECK_PERMISSIONS("checkPermissions"),

    /**
     * Initiates the permission request flow for any permissions required by the plugin.
     * This will trigger the Android permission dialog if permissions are not already granted.
     */
    REQUEST_PERMISSIONS("requestPermissions"),

    /**
     * Checks whether the data store is available, unavailable, or needs an update.
     * Returns a DataStoreAvailabilityResult indicating the current state.
     */
    DATA_STORE_AVAILABILITY("dataStoreAvailability"),

    /**
     * Retrieves data from the native data store.
     * Used when Flutter needs to access data that's only available on the native side.
     */
    GET_DATA("getData"),

    /**
     * Represents an undefined or unrecognized method call.
     * Used as a fallback when the method string doesn't match any known value.
     */
    UNDEFINED("undefined");

    /**
     * Companion object containing utility methods for working with MethodCallType values.
     */
    companion object {
        /**
         * Converts a string method name to its corresponding MethodCallType enum value.
         *
         * @param value The string representation of the method call
         * @return The matching MethodCallType, or UNDEFINED if no match is found
         */
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
