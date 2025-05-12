package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.SkinTemperatureRecord

fun SkinTemperatureRecord.serialize(): Map<String, Any?> {
    val deltas = this.extractDeltas()
    val metadata = this.extractMetadata()

    return mapOf(
            "startTimeEpochMs" to this.startTime.toEpochMilli(),
            "endTimeEpochMs" to this.endTime.toEpochMilli(),
            "startZoneOffsetSeconds" to this.startZoneOffset?.totalSeconds,
            "endZoneOffsetSeconds" to this.endZoneOffset?.totalSeconds,
            "baselineCelsius" to this.baseline?.inCelsius,
            "measurementLocation" to this.measurementLocation,
            "deltas" to deltas,
            "metadata" to metadata,
    )
}

fun SkinTemperatureRecord.extractDeltas(): List<Map<String, Any?>> {
    val resultList: MutableList<Map<String, Any?>> = mutableListOf()
    for (delta in this.deltas) {
        resultList.add(
                mapOf(
                        "time" to delta.time.toString(),
                        "delta" to
                                mapOf(
                                        "inCelsius" to delta.delta.inCelsius,
                                        "inFahrenheit" to delta.delta.inFahrenheit
                                )
                )
        )
    }
    return resultList
}

fun SkinTemperatureRecord.extractMetadata(): Map<String, Any?> {
    val result: Map<String, Any?> =
            mapOf(
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
