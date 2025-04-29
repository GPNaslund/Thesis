package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.SkinTemperatureRecord

fun SkinTemperatureRecord.serialize(): Map<String, String> {
    return mapOf(
        "startTimeEpochMs" to this.startTime.toEpochMilli().toString(),
        "endTimeEpochMs" to this.endTime.toEpochMilli().toString(),
        "startZoneOffsetSeconds" to this.startZoneOffset?.totalSeconds.toString(),
        "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds.toString(),
        "baselineCelsius" to this.baseline?.inCelsius.toString(),
        "measurementLocation" to mapMeasurementLocationToString(this.measurementLocation),
        "deltas" to this.serializeDeltas()
    )
}

fun SkinTemperatureRecord.serializeDeltas(): String {
    val resultList: MutableList<String> = mutableListOf()
    for (delta in this.deltas) {
        val deltaString = "[timeMs:${delta.time.toEpochMilli()}, deltaCelsius:${delta.delta.inCelsius}]"
        resultList.add(deltaString)
    }
    return resultList.toString()
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
