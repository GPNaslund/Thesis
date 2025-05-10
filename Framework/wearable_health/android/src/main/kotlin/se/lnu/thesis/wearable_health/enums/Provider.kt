package se.lnu.thesis.wearable_health.enums

enum class Provider(val value: String) {
    HEALTH_CONNECT("healthConnect"),
    UNKNOWN("unknown");


    companion object {
        fun fromString(value: String): Provider {
            return when (value) {
                "healthConnect" -> HEALTH_CONNECT
                else -> UNKNOWN
            }
        }
    }
}