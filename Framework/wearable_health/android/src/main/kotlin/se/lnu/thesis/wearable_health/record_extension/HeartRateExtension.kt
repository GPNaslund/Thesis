package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateRecord

fun HeartRateRecord.serialize(): Map<String, Any?> {
    return mapOf(
        "startTimeEpochMs" to this.startTime.toEpochMilli().toString(),
        "endTimeEpochMs" to this.endTime.toEpochMilli().toString(),
        "startZoneOffsetSeconds" to this.startZoneOffset?.totalSeconds,
        "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds,
        "samples" to this.extractSamples()
    )
}

fun HeartRateRecord.extractSamples(): List<Map<String, Any?>> {
    val result: MutableList<Map<String, Any?>> = mutableListOf()
    for (sample in this.samples) {
        result.add(mapOf(
            "time" to sample.time.toString(),
            "beatsPerMinute" to sample.beatsPerMinute,
        ))
    }
    return result
}