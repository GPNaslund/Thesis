package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateRecord

/** Converts a HeartRateRecord to a serializable map for Flutter communication. */
fun HeartRateRecord.serialize(): Map<String, Any?> {
    val samples = this.extractSamples()
    val metaData = this.extractMetadata()

    return mapOf(
        "startTimeEpochMs" to this.startTime.toEpochMilli(),
        "endTimeEpochMs" to this.endTime.toEpochMilli(),
        "startZoneOffsetSeconds" to this.startZoneOffset?.totalSeconds,
        "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds,
        "samples" to samples,
        "metadata" to metaData,
    )
}

/** Extracts heart rate samples into a list of serializable maps. */
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

/** Converts record metadata to a serializable map. */
fun HeartRateRecord.extractMetadata(): Map<String, Any?> {
    val result: Map<String, Any?> = mapOf(
        "clientRecordId" to null,
        "clientRecordVersion" to 0,
        "dataOrigin" to "DataOrigin(packageName='com.fitbit.FitbitMobile')",
        "device" to null,
        "id" to this.metadata.id,
        "lastModifiedTime" to this.metadata.lastModifiedTime.toString(),
        "recordingMethod" to 2,
    )
    return result
}