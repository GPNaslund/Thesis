package se.lnu.thesis.wearable_health.dto

import se.lnu.thesis.wearable_health.enums.DataStoreAvailabilityResult

class DataStoreAvailabilityResponse(private val availability: DataStoreAvailabilityResult) {
    override fun toString(): String {
        return availability.toString()
    }
}