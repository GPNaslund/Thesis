package se.lnu.thesis.wearable_health.enums

enum class DataStoreAvailabilityResult(val result: String) {
    AVAILABLE("available"),
    UNAVAILABLE("unavailable"),
    NEEDS_UPDATE("needsUpdate")
}