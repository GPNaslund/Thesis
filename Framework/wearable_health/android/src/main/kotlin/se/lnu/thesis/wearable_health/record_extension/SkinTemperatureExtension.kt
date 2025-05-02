package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.SkinTemperatureRecord

fun SkinTemperatureRecord.serialize(): Map<String, Any?> {
    return mapOf(
        "startTimeEpochMs" to this.startTime.toEpochMilli(),
        "endTimeEpochMs" to this.endTime.toEpochMilli(),
        "startZoneOffsetSeconds" to this.startZoneOffset,
        "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds,
        "baselineCelsius" to this.baseline?.inCelsius,
        "measurementLocation" to mapMeasurementLocationToString(this.measurementLocation),
        "deltas" to this.extractDeltas(),
    )
}

fun SkinTemperatureRecord.extractDeltas(): List<Map<String, Any?>> {
    val resultList: MutableList<Map<String, Any?>> = mutableListOf()
    for (delta in this.deltas) {
        resultList.add(mapOf(
            "timeMs" to delta.time.toEpochMilli(),
            "deltaCelsius" to delta.delta.inCelsius
        ))
    }
    return resultList
}

fun mapMeasurementLocationToString(location: Int): String {
    return when (location) {
        SkinTemperatureRecord.MEASUREMENT_LOCATION_UNKNOWN -> "unknown"
        SkinTemperatureRecord.MEASUREMENT_LOCATION_FINGER -> "finger"
        SkinTemperatureRecord.MEASUREMENT_LOCATION_TOE -> "toe"
        SkinTemperatureRecord.MEASUREMENT_LOCATION_WRIST -> "wrist"
        else -> "invalid_or_unknown_location_code(${location})"
    }
}
