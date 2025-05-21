import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/descriptive_statistic.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/measurement_location.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_sample_type.dart';

void main() {
  group('OpenMHealthBodyTemperatureConverter for HKBodyTemperature', () {
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      startTime = DateTime(2025, 5, 10, 8, 0);
      endTime = DateTime(2025, 5, 10, 8, 1);
    });

    test(
      'toOpenMHealthBodyTemperature should convert HKBodyTemperature correctly',
      () {
        final hkBodyTemp = HKBodyTemperature(
          HKQuantitySample(
            startDate: startTime,
            endDate: endTime,
            quantity: HKQuantity(value: 37.0, unit: ""),
            metadata: null,
            uuid: '',
            sampleType: HKSampleType(identifier: ""),
            count: null,
          ),
        );

        final result = hkBodyTemp.toOpenMHealthBodyTemperature();

        expect(result.length, equals(1));
        expect(result[0], isA<OpenMHealthBodyTemperature>());
      },
    );

    test(
      'toOpenMHealthBodyTemperature should map temperature value correctly',
      () {
        final tempValue = 37.5;
        final hkBodyTemp = HKBodyTemperature(
          HKQuantitySample(
            startDate: startTime,
            endDate: endTime,
            quantity: HKQuantity(value: tempValue, unit: ''),
            metadata: null,
            uuid: '',
            sampleType: HKSampleType(identifier: ""),
            count: null,
          ),
        );

        final result = hkBodyTemp.toOpenMHealthBodyTemperature();

        expect(result[0].bodyTemperature.value, equals(tempValue));
        expect(result[0].bodyTemperature.unit, equals(TemperatureUnit.C));
      },
    );

    test('toOpenMHealthBodyTemperature should set correct time frame', () {
      final hkBodyTemp = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(value: 37.0, unit: ''),
          metadata: null,
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkBodyTemp.toOpenMHealthBodyTemperature();

      expect(result[0].effectiveTimeFrame.dateTime, equals(startTime));
    });

    test(
      'toOpenMHealthBodyTemperature should set descriptive statistic to count',
      () {
        final hkBodyTemp = HKBodyTemperature(
          HKQuantitySample(
            startDate: startTime,
            endDate: endTime,
            quantity: HKQuantity(value: 37.0, unit: ''),
            metadata: null,
            uuid: '',
            sampleType: HKSampleType(identifier: ""),
            count: null,
          ),
        );

        final result = hkBodyTemp.toOpenMHealthBodyTemperature();

        expect(
          result[0].descriptiveStatistic,
          equals(DescriptiveStatistic.count),
        );
      },
    );

    test('Converted object should have correct schema ID', () {
      final hkBodyTemp = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(value: 37.0, unit: ""),
          metadata: null,
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkBodyTemp.toOpenMHealthBodyTemperature();

      expect(result[0].schemaId, equals("omh:body-temperature:4.0"));
    });

    test(
      'toOpenMHealthBodyTemperature should map all measurement locations correctly',
      () {
        final locations = [
          [0, null],
          [1, MeasurementLocation.axillary],
          [2, null],
          [3, MeasurementLocation.tympanic],
          [4, MeasurementLocation.finger],
          [5, null],
          [6, MeasurementLocation.oral],
          [7, MeasurementLocation.rectal],
          [8, MeasurementLocation.toe],
          [9, MeasurementLocation.tympanic],
          [10, MeasurementLocation.temporalArtery],
          [11, MeasurementLocation.forehead],
          [99, null],
        ];

        for (final location in locations) {
          final hkBodyTemp = HKBodyTemperature(
            HKQuantitySample(
              startDate: startTime,
              endDate: endTime,
              quantity: HKQuantity(value: 37.0, unit: ''),
              metadata: {
                "HKMetadataKeyBodyTemperatureSensorLocation": location[0],
              },
              uuid: '',
              sampleType: HKSampleType(identifier: ""),
              count: null,
            ),
          );

          final result = hkBodyTemp.toOpenMHealthBodyTemperature();

          expect(
            result[0].measurementLocation,
            equals(location[1]),
            reason: "Failed for location code: ${location[0]}",
          );
        }
      },
    );

    test('toOpenMHealthBodyTemperature should handle missing metadata', () {
      final hkBodyTemp = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(value: 37.0, unit: ''),
          metadata: null,
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkBodyTemp.toOpenMHealthBodyTemperature();

      expect(result[0].measurementLocation, isNull);
    });

    test(
      'toOpenMHealthBodyTemperature should handle metadata without location',
      () {
        final hkBodyTemp = HKBodyTemperature(
          HKQuantitySample(
            startDate: startTime,
            endDate: endTime,
            quantity: HKQuantity(value: 37.0, unit: ''),
            metadata: {"SomeOtherKey": "SomeValue"},
            uuid: '',
            sampleType: HKSampleType(identifier: ""),
            count: null,
          ),
        );

        final result = hkBodyTemp.toOpenMHealthBodyTemperature();

        expect(result[0].measurementLocation, isNull);
      },
    );

    test(
      'toOpenMHealthBodyTemperature should handle non-numeric location value',
      () {
        final hkBodyTemp = HKBodyTemperature(
          HKQuantitySample(
            startDate: startTime,
            endDate: endTime,
            quantity: HKQuantity(value: 37.0, unit: ""),
            metadata: {
              "HKMetadataKeyBodyTemperatureSensorLocation": "invalidValue",
            },
            uuid: '',
            sampleType: HKSampleType(identifier: ""),
            count: null,
          ),
        );

        final result = hkBodyTemp.toOpenMHealthBodyTemperature();

        expect(result[0].measurementLocation, isNull);
      },
    );

    test('toJSON() returns correct format from converted objects', () {
      final hkBodyTemp = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(value: 37.0, unit: ""),
          metadata: {
            "HKMetadataKeyBodyTemperatureSensorLocation": 6, // Oral
          },
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkBodyTemp.toOpenMHealthBodyTemperature();
      final jsonResult = result[0].toJson();

      expect(jsonResult, isA<Map<String, dynamic>>());
      expect(jsonResult["body_temperature"], isNotNull);
      expect(jsonResult["effective_time_frame"], isNotNull);
      expect(jsonResult["descriptive_statistic"], isNotNull);
      expect(jsonResult["measurement_location"], isNotNull);
      expect(jsonResult["body_temperature"]["value"], equals(37.0));
      expect(
        jsonResult["measurement_location"],
        equals({"measurement-location": "oral"}),
      );
    });

    test('toJSON() should not include null measurement location', () {
      final hkBodyTemp = HKBodyTemperature(
        HKQuantitySample(
          startDate: startTime,
          endDate: endTime,
          quantity: HKQuantity(value: 37.0, unit: ""),
          metadata: null,
          uuid: '',
          sampleType: HKSampleType(identifier: ""),
          count: null,
        ),
      );

      final result = hkBodyTemp.toOpenMHealthBodyTemperature();
      final jsonResult = result[0].toJson();

      expect(jsonResult.containsKey("measurement_location"), isFalse);
    });

    test(
      'toOpenMHealthBodyTemperature should handle extreme temperature values',
      () {
        final testValues = [35.0, 42.0];

        for (final value in testValues) {
          final hkBodyTemp = HKBodyTemperature(
            HKQuantitySample(
              startDate: startTime,
              endDate: endTime,
              quantity: HKQuantity(value: value, unit: ""),
              metadata: null,
              uuid: '',
              sampleType: HKSampleType(identifier: ""),
              count: null,
            ),
          );

          final result = hkBodyTemp.toOpenMHealthBodyTemperature();

          expect(result[0].bodyTemperature.value, equals(value));
        }
      },
    );
  });
}
