package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateRecord

fun HeartRateRecord.serialize(): Map<String, Any?> {
    return mapOf(
        "startTimeEpochMs" to this.startTime.toEpochMilli(),
        "endTimeEpochMs" to this.endTime.toEpochMilli(),
        "startZoneOffsetSeconds" to this.startZoneOffset?.totalSeconds,
        "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds,
        "samples" to this.extractSamples(),
        "metadata" to this.extractMetadata()
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

fun HeartRateRecord.extractMetadata(): Map<String, Any?> {
    val result: Map<String, Any?> = mapOf(
        "clientRecordId" to this.metadata.clientRecordId,
        "clientRecordVersion" to this.metadata.clientRecordVersion,
        "dataOrigin" to this.metadata.dataOrigin,
        "device" to this.metadata.device,
        "id" to this.metadata.id,
        "lastModifiedTime" to this.metadata.lastModifiedTime.toString(),
        "recordingMethod" to this.metadata.recordingMethod,
    )
    return result
}