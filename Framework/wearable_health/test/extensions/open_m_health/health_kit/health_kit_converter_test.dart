import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_data.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/measurement_location.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_sample_type.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';

void main() {
  group('OpenMHealthConverter for HealthKitData', () {
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      startTime = DateTime(2025, 5, 10, 8, 0);
      endTime = DateTime(2025, 5, 10, 8, 1);
    });

    test('toOpenMHealth should convert HKHeartRate correctly', () {
      final heartRateData = HKHeartRate(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(72.0, doubleValue: 72.0, unit: ""),
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = heartRateData.toOpenMHealth();

      expect(result, isA<List<OpenMHealthSchema>>());
      expect(result.length, equals(1));
      expect(result[0], isA<OpenMHealthHeartRate>());
      expect(result[0].schemaId, equals("omh:heart-rate:2.0"));
      expect((result[0] as OpenMHealthHeartRate).heartRate.value, equals(72.0));
    });

    test('toOpenMHealth should convert HKBodyTemperature correctly', () {
      final bodyTempData = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(37.0, doubleValue: 37.0, unit: ""),
          metadata: {"HKMetadataKeyBodyTemperatureSensorLocation": 6},
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = bodyTempData.toOpenMHealth();
      expect(result, isA<List<OpenMHealthSchema>>());
      expect(result.length, equals(1));
      expect(result[0], isA<OpenMHealthBodyTemperature>());
      expect(result[0].schemaId, equals("omh:body-temperature:4.0"));
      expect(
        (result[0] as OpenMHealthBodyTemperature).bodyTemperature.value,
        equals(37.0),
      );
      expect(
        (result[0] as OpenMHealthBodyTemperature).measurementLocation,
        equals(MeasurementLocation.oral),
      );
    });

    test(
      'toOpenMHealth should throw UnimplementedError for unsupported types',
      () {
        final unsupportedData = UnsupportedHealthKitData();

        expect(
          () => unsupportedData.toOpenMHealth(),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );

    test(
      'toOpenMHealth should return correct error message for unsupported types',
      () {
        final unsupportedData = UnsupportedHealthKitData();

        try {
          unsupportedData.toOpenMHealth();
          fail('Expected an UnimplementedError to be thrown');
        } catch (e) {
          expect(e, isA<UnimplementedError>());
          expect(
            (e as UnimplementedError).message,
            equals(
              'Unimplemented HealthKitData type for OpenMHealth conversion',
            ),
          );
        }
      },
    );

    test('toOpenMHealth passes through results from underlying converters', () {
      final heartRateValue = 85.0;
      final heartRateData = HKHeartRate(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(
            heartRateValue,
            doubleValue: heartRateValue,
            unit: "",
          ),
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = heartRateData.toOpenMHealth();

      expect(result.length, equals(1));
      expect(
        (result[0] as OpenMHealthHeartRate).heartRate.value,
        equals(heartRateValue),
      );
      expect(
        (result[0] as OpenMHealthHeartRate)
            .effectiveTimeFrame
            .timeInterval!
            .startDateTime,
        equals(startTime),
      );
      expect(
        (result[0] as OpenMHealthHeartRate)
            .effectiveTimeFrame
            .timeInterval!
            .endDateTime,
        equals(endTime),
      );
    });

    test('toOpenMHealth preserves schema IDs from specific converters', () {
      final heartRateData = HKHeartRate(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(72.0, doubleValue: 72.0, unit: ""),
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final bodyTempData = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(37.0, doubleValue: 37.0, unit: ""),
          metadata: null,
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final heartRateResult = heartRateData.toOpenMHealth();
      final bodyTempResult = bodyTempData.toOpenMHealth();

      expect(heartRateResult[0].schemaId, equals("omh:heart-rate:2.0"));
      expect(bodyTempResult[0].schemaId, equals("omh:body-temperature:4.0"));
    });
  });
}

class UnsupportedHealthKitData extends HealthKitData {
  @override
  HealthKitHealthMetric get healthMetric => HealthKitHealthMetric.heartRate;
}
