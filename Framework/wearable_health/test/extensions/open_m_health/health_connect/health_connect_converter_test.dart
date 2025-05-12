import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_data.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_record_sample.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature_delta.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature_delta.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';

void main() {
  group('OpenMHealthConverter', () {
    late DateTime startTime;
    late DateTime endTime;
    late HealthConnectMetadata metadata;

    setUp(() {
      startTime = DateTime(2025, 5, 10, 8, 0);
      endTime = DateTime(2025, 5, 10, 9, 0);
      metadata = HealthConnectMetadata(
        clientRecordVersion: null,
        dataOrigin: '',
        id: '',
        lastModifiedTime: endTime,
        recordingMethod: 1,
      );
    });

    test('toOpenMHealth should convert HealthConnectHeartRate correctly', () {
      // Arrange
      final heartRateData = HealthConnectHeartRate(
        startTime: startTime,
        endTime: endTime,
        startZoneOffset: 0,
        endZoneOffset: 0,
        samples: [
          HeartRateRecordSample(startTime, 72),
          HeartRateRecordSample(startTime, 75),
        ],
        metadata: metadata,
      );

      final result = heartRateData.toOpenMHealth();

      // Assert
      expect(result, isA<List<OpenMHealthSchema>>());
      expect(result.length, equals(2));
      expect(result[0], isA<OpenMHealthHeartRate>());
      expect(result[0].schemaId, equals("omh:heart-rate:2.0"));
    });

    test(
      'toOpenMHealth should convert HealthConnectSkinTemperature correctly',
      () {
        final skinTempData = HealthConnectSkinTemperature(
          baseline: Temperature(36.5, 36.5),
          deltas: [
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 10)),
              TemperatureDelta(0.1, 0.1),
            ),
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 20)),
              TemperatureDelta(0.2, 0.2),
            ),
          ],
          startTime: startTime,
          endTime: endTime,
          measurementLocation: 3,
          metadata: metadata,
        );

        final result = skinTempData.toOpenMHealth();

        expect(result, isA<List<OpenMHealthSchema>>());
        expect(result.length, equals(2));
        expect(result[0], isA<OpenMHealthBodyTemperature>());
        expect(result[0].schemaId, equals("omh:body-temperature:4.0"));
      },
    );

    test(
      'toOpenMHealth should throw UnimplementedError for unsupported types',
      () {
        final unsupportedData = UnsupportedHealthData();

        expect(
          () => unsupportedData.toOpenMHealth(),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );

    test('toOpenMHealth returns empty list when data is empty', () {
      final emptyHeartRateData = HealthConnectHeartRate(
        startTime: startTime,
        endTime: endTime,
        samples: [],
        metadata: metadata,
      );

      final result = emptyHeartRateData.toOpenMHealth();

      expect(result, isA<List<OpenMHealthSchema>>());
      expect(result, isEmpty);
    });

    test(
      'toOpenMHealth passes through all items from underlying converters',
      () {
        final multipleHeartRateData = HealthConnectHeartRate(
          startTime: startTime,
          endTime: endTime,
          samples: [
            HeartRateRecordSample(startTime, 60),
            HeartRateRecordSample(startTime, 65),
            HeartRateRecordSample(startTime, 70),
          ],
          metadata: metadata,
        );

        final result = multipleHeartRateData.toOpenMHealth();

        expect(result.length, equals(3));

        for (int i = 0; i < result.length; i++) {
          expect(result[i], isA<OpenMHealthHeartRate>());
          expect(
            (result[i] as OpenMHealthHeartRate).heartRate.value,
            equals(multipleHeartRateData.samples[i].beatsPerMinute),
          );
        }
      },
    );
  });
}

class UnsupportedHealthData extends HealthConnectData {
  @override
  HealthConnectHealthMetric get metric => HealthConnectHealthMetric.heartRate;
}
