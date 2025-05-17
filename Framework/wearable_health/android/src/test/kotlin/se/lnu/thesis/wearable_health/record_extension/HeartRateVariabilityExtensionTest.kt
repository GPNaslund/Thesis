package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateVariabilityRmssdRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.records.metadata.Device
import androidx.health.connect.client.records.metadata.Metadata
import io.mockk.every
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.Instant
import java.time.ZoneOffset

class HeartRateVariabilityExtensionTest {

    @Test
    fun `test HeartRateVariabilityRmssdRecord serialize creates correct map structure`() {
        val time = Instant.parse("2023-01-01T10:00:00Z")
        val zoneOffset = ZoneOffset.ofHours(1)
        val hrv = 50.0

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val device = mockk<Device>()

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns Instant.parse("2023-01-01T10:06:00Z")
        every { metadata.device } returns device
        every { metadata.recordingMethod } returns 1

        val record = mockk<HeartRateVariabilityRmssdRecord>()
        every { record.time } returns time
        every { record.zoneOffset } returns zoneOffset
        every { record.heartRateVariabilityMillis } returns hrv
        every { record.metadata } returns metadata

        val serialized = record.serialize()

        assertEquals(time.toEpochMilli(), serialized["timeEpochMs"])
        assertEquals(zoneOffset.totalSeconds, serialized["zoneOffsetSeconds"])
        assertEquals(hrv, serialized["heartRateVariabilityMillis"])

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

        val record = mockk<HeartRateVariabilityRmssdRecord>()
        every { record.metadata } returns metadata

        val extractedMetadata = record.extractMetadata()

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
        val time = Instant.now()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns time
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val record = mockk<HeartRateVariabilityRmssdRecord>()
        every { record.time } returns time
        every { record.zoneOffset } returns null
        every { record.heartRateVariabilityMillis } returns 45.0
        every { record.metadata } returns metadata

        val serialized = record.serialize()

        assertEquals(null, serialized["zoneOffsetSeconds"])

        @Suppress("UNCHECKED_CAST")
        val serializedMetadata = serialized["metadata"] as Map<String, Any?>
        assertEquals(null, serializedMetadata["device"])
    }

    @Test
    fun `test serialize with minimum required fields`() {
        val time = Instant.now()
        val hrv = 55.0

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns time
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val record = mockk<HeartRateVariabilityRmssdRecord>()
        every { record.time } returns time
        every { record.zoneOffset } returns null
        every { record.heartRateVariabilityMillis } returns hrv
        every { record.metadata } returns metadata

        val serialized = record.serialize()

        assertEquals(time.toEpochMilli(), serialized["timeEpochMs"])
        assertEquals(hrv, serialized["heartRateVariabilityMillis"])

        @Suppress("UNCHECKED_CAST")
        val serializedMetadata = serialized["metadata"] as Map<String, Any?>
        assertEquals(metadata.id, serializedMetadata["id"])
    }

    @Test
    fun `test serialize with extreme HRV values`() {
        val time = Instant.now()
        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns time
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val recordHigh = mockk<HeartRateVariabilityRmssdRecord>()
        every { recordHigh.time } returns time
        every { recordHigh.zoneOffset } returns ZoneOffset.UTC
        every { recordHigh.heartRateVariabilityMillis } returns 200.0
        every { recordHigh.metadata } returns metadata

        val serializedHigh = recordHigh.serialize()
        assertEquals(200.0, serializedHigh["heartRateVariabilityMillis"])

        val recordLow = mockk<HeartRateVariabilityRmssdRecord>()
        every { recordLow.time } returns time
        every { recordLow.zoneOffset } returns ZoneOffset.UTC
        every { recordLow.heartRateVariabilityMillis } returns 1.0
        every { recordLow.metadata } returns metadata

        val serializedLow = recordLow.serialize()
        assertEquals(1.0, serializedLow["heartRateVariabilityMillis"])
    }
}
