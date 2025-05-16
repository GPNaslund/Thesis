package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateVariabilityRmssdRecord

/** Converts a HeartRateVariabilityRmssdRecord to a serializable map for Flutter. */
fun HeartRateVariabilityRmssdRecord.serialize(): Map<String, Any?> {
    val metadata = this.extractMetadata()
    return mapOf(
        "timeEpochMs" to this.time.toEpochMilli(),
        "zoneOffsetSeconds" to this.zoneOffset?.totalSeconds,
        "heartRateVariabilityMillis" to this.heartRateVariabilityMillis,
        "metadata" to metadata
    )
}

/** Converts record metadata to a serializable map. */
fun HeartRateVariabilityRmssdRecord.extractMetadata(): Map<String, Any?> {
    val result: Map<String, Any?> = mapOf(
        "clientRecordId" to this.metadata.clientRecordId,
        "clientRecordVersion" to this.metadata.clientRecordVersion,
        "dataOrigin" to this.metadata.dataOrigin.toString(),
        "device" to this.metadata.device,
        "id" to this.metadata.id,
        "lastModifiedTime" to this.metadata.lastModifiedTime.toString(),
        "recordingMethod" to this.metadata.recordingMethod,
    )
    return result
}