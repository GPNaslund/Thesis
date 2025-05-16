package se.lnu.thesis.wearable_health.enums

/** Identifies the health data provider sources supported by this plugin. */
enum class Provider(val value: String) {
    /** Android's Health Connect API provider. */
    HEALTH_CONNECT("healthConnect"),

    /** Used when the provider string doesn't match any known provider. */
    UNKNOWN("unknown");

    companion object {
        /** Converts a string provider name to its corresponding enum value. */
        fun fromString(value: String): Provider {
            return when (value) {
                "healthConnect" -> HEALTH_CONNECT
                else -> UNKNOWN
            }
        }
    }
}
