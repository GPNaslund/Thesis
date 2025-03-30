package se.lnu.wearable_health

enum class WearableHealthDataConstants(val value: String) {
    // Channel names
    CHANNEL_NAME("se.lnu.thesis.wearable_health/methods"),
    EVENT_CHANNEL_NAME("se.lnu.thesis.wearable_health/events"),

    // Method names
    METHOD_GET_PLATFORM_VERSION("getPlatformVersion"),
    METHOD_REQUEST_PERMISSIONS("requestPermissions"),
    METHOD_START_COLLECTING("startCollecting"),
}