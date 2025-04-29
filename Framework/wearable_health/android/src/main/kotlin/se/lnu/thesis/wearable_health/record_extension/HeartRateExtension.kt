package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateRecord

fun HeartRateRecord.serialize(): Map<String, String> {
    return mapOf(
        "startTimeEpochMs" to this.startTime.toEpochMilli().toString(),
        "endTimeEpochMs" to this.endTime.toEpochMilli().toString(),
        "startZoneOffsetSeconds" to this.startZoneOffset?.totalSeconds.toString(),
        "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds.toString(),
        "samples" to this.serializeSamples()
    )
}

fun HeartRateRecord.serializeSamples(): String {
    val result: MutableList<String> = mutableListOf()
    for (sample in this.samples) {
        result.add("[time:${sample.time.toString()}, beatsPerMinute:${sample.beatsPerMinute}")
    }
    return result.toString()
}