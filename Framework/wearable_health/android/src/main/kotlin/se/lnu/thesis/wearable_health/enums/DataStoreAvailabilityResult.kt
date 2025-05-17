package se.lnu.thesis.wearable_health.enums

/**
 * Represents the availability status of the data store.
 * Used to communicate the state of the data store to the Flutter side of the plugin.
 */
enum class DataStoreAvailabilityResult(val result: String) {
    /**
     * Indicates that the data store is available and ready to use.
     * The native code will return this when all systems are operational.
     */
    AVAILABLE("available"),

    /**
     * Indicates that the data store is completely unavailable.
     * This might happen if the required permissions are denied or if
     * there's a critical error with the underlying storage system.
     */
    UNAVAILABLE("unavailable"),

    /**
     * Indicates that the data store exists but needs to be updated
     * before it can be used. This might occur during version migrations
     * or when schema changes are required.
     */
    NEEDS_UPDATE("needsUpdate")
}
