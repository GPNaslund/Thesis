package se.lnu.thesis.wearable_health.record_extension

import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.records.metadata.Device
import androidx.health.connect.client.records.metadata.Metadata
import io.mockk.every
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.Instant
import java.time.ZoneOffset

class HeartRateExtensionTest {
    @Test
    fun `test HeartRateRecord serialize creates correct map structure`() {
        val startTime = Instant.parse("2023-01-01T10:00:00Z")
        val endTime = Instant.parse("2023-01-01T10:05:00Z")
        val startZoneOffset = ZoneOffset.ofHours(1)
        val endZoneOffset = ZoneOffset.ofHours(1)

        val sample1 = mockk<HeartRateRecord.Sample>()
        every { sample1.time } returns Instant.parse("2023-01-01T10:01:00Z")
        every { sample1.beatsPerMinute } returns 70

        val sample2 = mockk<HeartRateRecord.Sample>()
        every { sample2.time } returns Instant.parse("2023-01-01T10:02:30Z")
        every { sample2.beatsPerMinute } returns 75

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

        val heartRateRecord = mockk<HeartRateRecord>()
        every { heartRateRecord.startTime } returns startTime
        every { heartRateRecord.endTime } returns endTime
        every { heartRateRecord.startZoneOffset } returns startZoneOffset
        every { heartRateRecord.endZoneOffset } returns endZoneOffset
        every { heartRateRecord.samples } returns listOf(sample1, sample2)
        every { heartRateRecord.metadata } returns metadata

        val serialized = heartRateRecord.serialize()

        assertEquals(startTime.toEpochMilli(), serialized["startTimeEpochMs"])
        assertEquals(endTime.toEpochMilli(), serialized["endTimeEpochMs"])
        assertEquals(startZoneOffset.totalSeconds, serialized["startZoneOffsetSeconds"])
        assertEquals(endZoneOffset.totalSeconds, serialized["endZoneOffsetSeconds"])

        val samples = serialized["samples"] as List<Map<String, Any?>>
        assertEquals(2, samples.size)
        assertEquals(sample1.time.toString(), samples[0]["time"])
        assertEquals(sample1.beatsPerMinute, samples[0]["beatsPerMinute"])
        assertEquals(sample2.time.toString(), samples[1]["time"])
        assertEquals(sample2.beatsPerMinute, samples[1]["beatsPerMinute"])

        val serializedMetadata = serialized["metadata"] as Map<String, Any?>
        assertEquals(metadata.clientRecordId, serializedMetadata["clientRecordId"])
        assertEquals(metadata.clientRecordVersion, serializedMetadata["clientRecordVersion"])
        assertEquals(metadata.dataOrigin.toString(), serializedMetadata["dataOrigin"])
        assertEquals(metadata.id, serializedMetadata["id"])
        assertEquals(metadata.lastModifiedTime.toString(), serializedMetadata["lastModifiedTime"])
    }

    @Test
    fun `test extractSamples converts all samples correctly`() {
        val sample1 = mockk<HeartRateRecord.Sample>()
        every { sample1.time } returns Instant.parse("2023-01-01T10:01:00Z")
        every { sample1.beatsPerMinute } returns 70

        val sample2 = mockk<HeartRateRecord.Sample>()
        every { sample2.time } returns Instant.parse("2023-01-01T10:02:30Z")
        every { sample2.beatsPerMinute } returns 75

        val sample3 = mockk<HeartRateRecord.Sample>()
        every { sample3.time } returns Instant.parse("2023-01-01T10:03:45Z")
        every { sample3.beatsPerMinute } returns 80

        val samples = listOf(sample1, sample2, sample3)

        val heartRateRecord = mockk<HeartRateRecord>()
        every { heartRateRecord.samples } returns samples

        val extractedSamples = heartRateRecord.extractSamples()

        assertEquals(3, extractedSamples.size)

        for (i in samples.indices) {
            assertEquals(samples[i].time.toString(), extractedSamples[i]["time"])
            assertEquals(samples[i].beatsPerMinute, extractedSamples[i]["beatsPerMinute"])
        }
    }

    @Test
    fun `test extractMetadata converts all metadata fields correctly`() {
        val device = mockk<Device>()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.id } returns "test-id-123"
        every { metadata.clientRecordId } returns "client-record-123"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.lastModifiedTime } returns Instant.parse("2023-01-01T10:06:00Z")
        every { metadata.device } returns device
        every { metadata.recordingMethod } returns 1

        val heartRateRecord = mockk<HeartRateRecord>()
        every { heartRateRecord.metadata } returns metadata

        val extractedMetadata = heartRateRecord.extractMetadata()

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
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1
        every { metadata.id } returns "test-id"
        every { metadata.clientRecordId } returns "client-id"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.lastModifiedTime } returns now

        val heartRateRecord = mockk<HeartRateRecord>()
        every { heartRateRecord.startTime } returns now
        every { heartRateRecord.endTime } returns now
        every { heartRateRecord.startZoneOffset } returns null
        every { heartRateRecord.endZoneOffset } returns null
        every { heartRateRecord.samples } returns listOf()
        every { heartRateRecord.metadata } returns metadata

        val serialized = heartRateRecord.serialize()
        assertEquals(null, serialized["startZoneOffsetSeconds"])
        assertEquals(null, serialized["endZoneOffsetSeconds"])

        val serializedMetadata = serialized["metadata"] as Map<String, Any?>
        assertEquals(null, serializedMetadata["device"])
        assertEquals(1, serializedMetadata["recordingMethod"])
    }

    @Test
    fun `test serialize handles empty samples list`() {
        val now = Instant.now()

        val dataOrigin = mockk<DataOrigin>()
        every { dataOrigin.toString() } returns "test-app"

        val metadata = mockk<Metadata>()
        every { metadata.dataOrigin } returns dataOrigin
        every { metadata.id } returns "test-id"
        every { metadata.clientRecordId } returns "client-id"
        every { metadata.clientRecordVersion } returns 1
        every { metadata.lastModifiedTime } returns now
        every { metadata.device } returns null
        every { metadata.recordingMethod } returns 1

        val heartRateRecord = mockk<HeartRateRecord>()
        every { heartRateRecord.startTime } returns now
        every { heartRateRecord.endTime } returns now
        every { heartRateRecord.startZoneOffset } returns null
        every { heartRateRecord.endZoneOffset } returns null
        every { heartRateRecord.samples } returns listOf()
        every { heartRateRecord.metadata } returns metadata

        val serialized = heartRateRecord.serialize()
        val samples = serialized["samples"] as List<*>
        assertEquals(0, samples.size)
    }
}
