import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_sample_type.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';

void main() {
  group('OpenMHealthHeartRateConverter for HKHeartRate', () {
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      startTime = DateTime(2025, 5, 10, 8, 0);
      endTime = DateTime(2025, 5, 10, 8, 1);
    });

    test('toOpenMHealthHeartRate should convert HKHeartRate correctly', () {
      final hkHeartRate = HKHeartRate(
        HKQuantitySample(
          uuid: "",
          sampleType: HKSampleType(identifier: ""),
          count: 0,
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(72.0, doubleValue: 72.0, unit: ""),
        ),
      );

      final result = hkHeartRate.toOpenMHealthHeartRate();

      expect(result.length, equals(1));
      expect(result[0], isA<OpenMHealthHeartRate>());
    });

    test('toOpenMHealthHeartRate should map heart rate value correctly', () {
      final heartRateValue = 75.0;
      final hkHeartRate = HKHeartRate(
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

      final result = hkHeartRate.toOpenMHealthHeartRate();

      expect(result[0].heartRate.value, equals(heartRateValue));
      expect(result[0].heartRate.unit, equals("beatsPerMinute"));
    });

    test('toOpenMHealthHeartRate should set correct time frame', () {
      final hkHeartRate = HKHeartRate(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(72.0, doubleValue: 72.0, unit: ""),
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkHeartRate.toOpenMHealthHeartRate();

      expect(
        result[0].effectiveTimeFrame.timeInterval!.startDateTime,
        equals(startTime),
      );
      expect(
        result[0].effectiveTimeFrame.timeInterval!.endDateTime,
        equals(endTime),
      );
    });

    test('Converted object should have correct schema ID', () {
      final hkHeartRate = HKHeartRate(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(72.0, doubleValue: 72.0, unit: ""),
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkHeartRate.toOpenMHealthHeartRate();

      expect(result[0].schemaId, equals("omh:heart-rate:2.0"));
    });

    test('toOpenMHealthHeartRate should handle extreme values', () {
      final testValues = [0.0, 250.0];

      for (final value in testValues) {
        final hkHeartRate = HKHeartRate(
          HKQuantitySample(
            startDate: startTime,
            endDate: endTime,
            quantity: HKQuantity(value, doubleValue: value, unit: ""),
            uuid: '',
            sampleType: HKSampleType(identifier: ""),
            count: null,
          ),
        );

        final result = hkHeartRate.toOpenMHealthHeartRate();

        expect(result[0].heartRate.value, equals(value));
      }
    });

    test('toJSON() returns correct format from converted objects', () {
      final hkHeartRate = HKHeartRate(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(72.0, doubleValue: 72.0, unit: ""),
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkHeartRate.toOpenMHealthHeartRate();
      final jsonResult = result[0].toJson();

      expect(jsonResult, isA<Map<String, dynamic>>());
      expect(jsonResult["heart_rate"], isNotNull);
      expect(jsonResult["time_frame"], isNotNull);
      expect(jsonResult["heart_rate"]["value"], equals(72.0));
      expect(jsonResult["heart_rate"]["unit"], equals("beatsPerMinute"));
    });

    test('toOpenMHealthHeartRate should handle decimal heart rate values', () {
      // Arrange
      final heartRateValue = 72.5; // Decimal value
      final hkHeartRate = HKHeartRate(
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

      final result = hkHeartRate.toOpenMHealthHeartRate();

      expect(result[0].heartRate.value, equals(heartRateValue));
    });
  });
}
