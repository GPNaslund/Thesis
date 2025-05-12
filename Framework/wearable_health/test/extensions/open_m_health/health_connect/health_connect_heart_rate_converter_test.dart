import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_record_sample.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';

void main() {
  group('OpenMHealthHeartRateConverter', () {
    late HealthConnectHeartRate sampleHeartRateData;
    late HealthConnectMetadata sampleMetadata;
    late DateTime sampleDatetime;

    setUp(() {
      sampleDatetime = DateTime.now();
      final startTime = sampleDatetime.subtract(const Duration(minutes: 30));
      final endTime = sampleDatetime;
      sampleMetadata = HealthConnectMetadata(
        dataOrigin: "",
        id: "",
        lastModifiedTime: sampleDatetime,
        recordingMethod: 1,
        clientRecordVersion: 1,
      );

      sampleHeartRateData = HealthConnectHeartRate(
        startTime: startTime,
        endTime: endTime,
        startZoneOffset: 0,
        endZoneOffset: 0,
        samples: [
          HeartRateRecordSample(sampleDatetime, 72),
          HeartRateRecordSample(sampleDatetime, 75),
          HeartRateRecordSample(sampleDatetime, 78),
        ],
        metadata: sampleMetadata,
      );
    });

    test('toOpenMHealthHeartRate should convert all samples', () {
      final result = sampleHeartRateData.toOpenMHealthHeartRate();

      expect(result.length, equals(3));
    });

    test('toOpenMHealthHeartRate should correctly map heart rate values', () {
      final result = sampleHeartRateData.toOpenMHealthHeartRate();

      expect(result[0].heartRate.value, equals(72));
      expect(result[1].heartRate.value, equals(75));
      expect(result[2].heartRate.value, equals(78));

      for (final item in result) {
        expect(item.heartRate.unit, equals("beatsPerMinute"));
      }
    });

    test(
      'toOpenMHealthHeartRate should set correct time frame for all items',
      () {
        final result = sampleHeartRateData.toOpenMHealthHeartRate();

        for (final item in result) {
          expect(
            item.effectiveTimeFrame.timeInterval!.startDateTime,
            equals(sampleHeartRateData.startTime),
          );
          expect(
            item.effectiveTimeFrame.timeInterval!.endDateTime,
            equals(sampleHeartRateData.endTime),
          );
        }
      },
    );

    test(
      'toOpenMHealthHeartRate should return empty list for empty samples',
      () {
        final emptyData = HealthConnectHeartRate(
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          samples: [],
          metadata: sampleMetadata,
        );

        final result = emptyData.toOpenMHealthHeartRate();

        expect(result, isEmpty);
      },
    );

    test('toOpenMHealthHeartRate should handle extreme values', () {
      final extremeData = HealthConnectHeartRate(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        samples: [
          HeartRateRecordSample(sampleDatetime, 0),
          HeartRateRecordSample(sampleDatetime, 250),
        ],
        metadata: sampleMetadata,
      );

      final result = extremeData.toOpenMHealthHeartRate();

      expect(result.length, equals(2));
      expect(result[0].heartRate.value, equals(0));
      expect(result[1].heartRate.value, equals(250));
    });

    test('Converted objects should have correct schema ID', () {
      final result = sampleHeartRateData.toOpenMHealthHeartRate();

      for (final item in result) {
        expect(item.schemaId, equals("omh:heart-rate:2.0"));
      }
    });

    test('toJSON() returns correct format from converted objects', () {
      final result = sampleHeartRateData.toOpenMHealthHeartRate();
      final jsonResult = result[0].toJson();

      expect(jsonResult, isA<Map<String, dynamic>>());
      expect(jsonResult["heart_rate"], isNotNull);
      expect(jsonResult["time_frame"], isNotNull);
      expect(jsonResult.containsKey("descriptive_statistic"), isFalse);
      expect(
        jsonResult.containsKey("temporal_relationship_to_physical_activity"),
        isFalse,
      );
      expect(jsonResult.containsKey("temporal_relationship_to_sleep"), isFalse);
    });
  });
}
