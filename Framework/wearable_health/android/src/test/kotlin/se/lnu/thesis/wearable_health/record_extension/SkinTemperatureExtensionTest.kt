package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.SkinTemperatureRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.records.metadata.Device
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.units.Temperature
import androidx.health.connect.client.units.TemperatureDelta
import io.mockk.every
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.Instant
import java.time.ZoneOffset

class SkinTemperatureExtensionTest {

    @Test
    fun `test SkinTemperatureRecord serialize creates correct map structure`() {
        val startTime = Instant.parse("2023-01-01T10:00:00Z")
        val endTime = Instant.parse("2023-01-01T10:05:00Z")
        val startZoneOffset = ZoneOffset.ofHours(1)
        val endZoneOffset = ZoneOffset.ofHours(1)
        val baselineTemp = Temperature.celsius(36.5)
        val measurementLocation = 1

        val delta1 = mockk<SkinTemperatureRecord.Delta>()
        val deltaTemp1 = mockk<TemperatureDelta>()
        every { deltaTemp1.inCelsius } returns 0.5
        every { deltaTemp1.inFahrenheit } returns 32.9
        every { delta1.time } returns Instant.parse("2023-01-01T10:01:00Z")
        every { delta1.delta } returns deltaTemp1

        val delta2 = mockk<SkinTemperatureRecord.Delta>()
        val deltaTemp2 = mockk<TemperatureDelta>()
        every { deltaTemp2.inCelsius } returns 0.7
        every { deltaTemp2.inFahrenheit } returns 33.26
        every { delta2.time } returns Instant.parse("2023-01-01T10:02:30Z")
        every { delta2.delta } returns deltaTemp2

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns Instant.parse("2023-01-01T10:06:00Z")
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val skinTempRecord = mockk<SkinTemperatureRecord>()
        every { skinTempRecord.startTime } returns startTime
        every { skinTempRecord.endTime } returns endTime
        every { skinTempRecord.startZoneOffset } returns startZoneOffset
        every { skinTempRecord.endZoneOffset } returns endZoneOffset
        every { skinTempRecord.baseline } returns baselineTemp
        every { skinTempRecord.measurementLocation } returns measurementLocation
        every { skinTempRecord.deltas } returns listOf(delta1, delta2)
        every { skinTempRecord.metadata } returns metadata

        val serialized = skinTempRecord.serialize()

        assertEquals(startTime.toEpochMilli(), serialized["startTimeEpochMs"])
        assertEquals(endTime.toEpochMilli(), serialized["endTimeEpochMs"])
        assertEquals(startZoneOffset.totalSeconds, serialized["startZoneOffsetSeconds"])
        assertEquals(endZoneOffset.totalSeconds, serialized["endZoneOffsetSeconds"])
        assertEquals(baselineTemp.inCelsius, serialized["baselineCelsius"])
        assertEquals(measurementLocation, serialized["measurementLocation"])

        @Suppress("UNCHECKED_CAST")
        val deltas = serialized["deltas"] as List<Map<String, Any?>>
        assertEquals(2, deltas.size)

        assertEquals(delta1.time.toString(), deltas[0]["time"])
        @Suppress("UNCHECKED_CAST")
        val delta1Map = deltas[0]["delta"] as Map<String, Any?>
        assertEquals(delta1.delta.inCelsius, delta1Map["inCelsius"])
        assertEquals(delta1.delta.inFahrenheit, delta1Map["inFahrenheit"])

        assertEquals(delta2.time.toString(), deltas[1]["time"])
        @Suppress("UNCHECKED_CAST")
        val delta2Map = deltas[1]["delta"] as Map<String, Any?>
        assertEquals(delta2.delta.inCelsius, delta2Map["inCelsius"])
        assertEquals(delta2.delta.inFahrenheit, delta2Map["inFahrenheit"])

        @Suppress("UNCHECKED_CAST")
        val serializedMetadata = serialized["metadata"] as Map<String, Any?>
        assertEquals(metadata.id, serializedMetadata["id"])
        assertEquals(metadata.clientRecordId, serializedMetadata["clientRecordId"])
        assertEquals(metadata.clientRecordVersion, serializedMetadata["clientRecordVersion"])
        assertEquals(metadata.dataOrigin.toString(), serializedMetadata["dataOrigin"])
        assertEquals(metadata.lastModifiedTime.toString(), serializedMetadata["lastModifiedTime"])
        assertEquals(metadata.device, serializedMetadata["device"])
        assertEquals(metadata.recordingMethod, serializedMetadata["recordingMethod"])
    }

    @Test
    fun `test extractDeltas converts all deltas correctly`() {
        val delta1 = mockk<SkinTemperatureRecord.Delta>()
        val deltaTemp1 = mockk<TemperatureDelta>()
        every { deltaTemp1.inCelsius } returns 0.5
        every { deltaTemp1.inFahrenheit } returns 32.9
        every { delta1.time } returns Instant.parse("2023-01-01T10:01:00Z")
        every { delta1.delta } returns deltaTemp1

        val delta2 = mockk<SkinTemperatureRecord.Delta>()
        val deltaTemp2 = mockk<TemperatureDelta>()
        every { deltaTemp2.inCelsius } returns 0.7
        every { deltaTemp2.inFahrenheit } returns 33.26
        every { delta2.time } returns Instant.parse("2023-01-01T10:02:30Z")
        every { delta2.delta } returns deltaTemp2

        val delta3 = mockk<SkinTemperatureRecord.Delta>()
        val deltaTemp3 = mockk<TemperatureDelta>()
        every { deltaTemp3.inCelsius } returns 0.3
        every { deltaTemp3.inFahrenheit } returns 32.54
        every { delta3.time } returns Instant.parse("2023-01-01T10:03:45Z")
        every { delta3.delta } returns deltaTemp3

        val deltas = listOf(delta1, delta2, delta3)

        val skinTempRecord = mockk<SkinTemperatureRecord>()
        every { skinTempRecord.deltas } returns deltas

        val extractedDeltas = skinTempRecord.extractDeltas()

        assertEquals(3, extractedDeltas.size)

        for (i in deltas.indices) {
            assertEquals(deltas[i].time.toString(), extractedDeltas[i]["time"])

            @Suppress("UNCHECKED_CAST")
            val deltaMap = extractedDeltas[i]["delta"] as Map<String, Any?>
            assertEquals(deltas[i].delta.inCelsius, deltaMap["inCelsius"])
            assertEquals(deltas[i].delta.inFahrenheit, deltaMap["inFahrenheit"])
        }
    }

    @Test
    fun `test extractMetadata converts all metadata fields correctly`() {
        val time = Instant.now()

        val device = mockk<Device>()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns time
        every { metadata.device } returns device
        every { metadata.recordingMethod } returns 1

        val skinTempRecord = mockk<SkinTemperatureRecord>()
        every { skinTempRecord.metadata } returns metadata

        val extractedMetadata = skinTempRecord.extractMetadata()

        assertEquals(metadata.id, extractedMetadata["id"])
        assertEquals(metadata.clientRecordId, extractedMetadata["clientRecordId"])
        assertEquals(metadata.clientRecordVersion, extractedMetadata["clientRecordVersion"])
        assertEquals(metadata.dataOrigin.toString(), extractedMetadata["dataOrigin"])
        assertEquals(metadata.lastModifiedTime.toString(), extractedMetadata["lastModifiedTime"])
        assertEquals(metadata.device, extractedMetadata["device"])
        assertEquals(metadata.recordingMethod, extractedMetadata["recordingMethod"])
    }

    @Test
    fun `test serialize handles null fields gracefully`() {
        val now = Instant.now()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns now
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val skinTempRecord = mockk<SkinTemperatureRecord>()
        every { skinTempRecord.startTime } returns now
        every { skinTempRecord.endTime } returns now
        every { skinTempRecord.startZoneOffset } returns null
        every { skinTempRecord.endZoneOffset } returns null
        every { skinTempRecord.baseline } returns null
        every { skinTempRecord.measurementLocation } returns 1
        every { skinTempRecord.deltas } returns listOf()
        every { skinTempRecord.metadata } returns metadata

        val serialized = skinTempRecord.serialize()

        assertEquals(null, serialized["startZoneOffsetSeconds"])
        assertEquals(null, serialized["endZoneOffsetSeconds"])
        assertEquals(null, serialized["baselineCelsius"])
        assertEquals(1, serialized["measurementLocation"])

        @Suppress("UNCHECKED_CAST")
        val serializedMetadata = serialized["metadata"] as Map<String, Any?>
        assertEquals(null, serializedMetadata["device"])
    }

    @Test
    fun `test serialize handles empty deltas list`() {
        val now = Instant.now()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns now
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val skinTempRecord = mockk<SkinTemperatureRecord>()
        every { skinTempRecord.startTime } returns now
        every { skinTempRecord.endTime } returns now
        every { skinTempRecord.startZoneOffset } returns ZoneOffset.UTC
        every { skinTempRecord.endZoneOffset } returns ZoneOffset.UTC
        every { skinTempRecord.baseline } returns Temperature.celsius(36.0)
        every { skinTempRecord.measurementLocation } returns 1
        every { skinTempRecord.deltas } returns listOf()
        every { skinTempRecord.metadata } returns metadata

        val serialized = skinTempRecord.serialize()

        @Suppress("UNCHECKED_CAST")
        val deltas = serialized["deltas"] as List<*>
        assertEquals(0, deltas.size)
    }

    @Test
    fun `test serialize with extreme temperature values`() {
        val now = Instant.now()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns now
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val highBaseline = mockk<Temperature>()
        every { highBaseline.inCelsius } returns 40.0
        every { highBaseline.inFahrenheit } returns 104.0

        val delta = mockk<SkinTemperatureRecord.Delta>()
        val extremeDelta = mockk<TemperatureDelta>()
        every { extremeDelta.inCelsius } returns 5.0
        every { extremeDelta.inFahrenheit } returns 41.0
        every { delta.time } returns now
        every { delta.delta } returns extremeDelta

        val skinTempRecord = mockk<SkinTemperatureRecord>()
        every { skinTempRecord.startTime } returns now
        every { skinTempRecord.endTime } returns now
        every { skinTempRecord.startZoneOffset } returns ZoneOffset.UTC
        every { skinTempRecord.endZoneOffset } returns ZoneOffset.UTC
        every { skinTempRecord.baseline } returns highBaseline
        every { skinTempRecord.measurementLocation } returns 1
        every { skinTempRecord.deltas } returns listOf(delta)
        every { skinTempRecord.metadata } returns metadata

        val serialized = skinTempRecord.serialize()

        assertEquals(highBaseline.inCelsius, serialized["baselineCelsius"])

        @Suppress("UNCHECKED_CAST")
        val deltas = serialized["deltas"] as List<Map<String, Any?>>
        assertEquals(1, deltas.size)

        @Suppress("UNCHECKED_CAST")
        val deltaMap = deltas[0]["delta"] as Map<String, Any?>
        assertEquals(extremeDelta.inCelsius, deltaMap["inCelsius"])
        assertEquals(extremeDelta.inFahrenheit, deltaMap["inFahrenheit"])
    }
}
