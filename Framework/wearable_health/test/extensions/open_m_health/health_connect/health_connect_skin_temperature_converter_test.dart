import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_skin_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/descriptive_statistic.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/measurement_location.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature_delta.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature_delta.dart';

void main() {
  group('OpenMHealthBodyTemperatureConverter', () {
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

    test('toOpenMHealthBodyTemperature should convert all deltas', () {
      // Arrange
      final skinTemp = HealthConnectSkinTemperature(
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
          SkinTemperatureDelta(
            startTime.add(Duration(minutes: 30)),
            TemperatureDelta(-0.1, -0.1),
          ),
        ],
        startTime: startTime,
        endTime: endTime,
        measurementLocation: 3,
        metadata: metadata,
      );

      final result = skinTemp.toOpenMHealthBodyTemperature();

      expect(result.length, equals(3));
    });

    test(
      'toOpenMHealthBodyTemperature should correctly calculate temperatures with baseline',
      () {
        // Arrange
        final baseline = Temperature(36.5, 36.5);
        final skinTemp = HealthConnectSkinTemperature(
          baseline: baseline,
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
          measurementLocation: 1,
          metadata: metadata,
        );

        final result = skinTemp.toOpenMHealthBodyTemperature();

        expect(result[0].bodyTemperature.value, equals(36.6));
        expect(result[1].bodyTemperature.value, equals(36.7));
        expect(result[0].bodyTemperature.unit, equals(TemperatureUnit.C));
      },
    );

    test(
      'toOpenMHealthBodyTemperature should correctly calculate temperatures without baseline, using previous values',
      () {
        final skinTemp = HealthConnectSkinTemperature(
          baseline: null,
          deltas: [
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 10)),
              TemperatureDelta(36.5, 36.5),
            ),
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 20)),
              TemperatureDelta(0.2, 0.2),
            ),
          ],
          startTime: startTime,
          endTime: endTime,
          measurementLocation: 2,
          metadata: metadata,
        );

        final result = skinTemp.toOpenMHealthBodyTemperature();

        expect(result[0].bodyTemperature.value, equals(36.5));
        expect(result[1].bodyTemperature.value, equals(36.7));
      },
    );

    test('toOpenMHealthBodyTemperature should handle empty deltas list', () {
      final skinTemp = HealthConnectSkinTemperature(
        baseline: Temperature(36.5, 36.5),
        deltas: [],
        startTime: startTime,
        endTime: endTime,
        measurementLocation: 3,
        metadata: metadata,
      );

      final result = skinTemp.toOpenMHealthBodyTemperature();

      expect(result, isEmpty);
    });

    test(
      'toOpenMHealthBodyTemperature should map measurementLocation correctly',
      () {
        final locations = [
          [1, MeasurementLocation.finger],
          [2, MeasurementLocation.toe],
          [3, MeasurementLocation.wrist],
          [0, null],
          [99, null],
        ];

        for (final locationPair in locations) {
          final skinTemp = HealthConnectSkinTemperature(
            baseline: Temperature(36.5, 36.5),
            deltas: [
              SkinTemperatureDelta(
                startTime.add(Duration(minutes: 10)),
                TemperatureDelta(0.1, 0.1),
              ),
            ],
            startTime: startTime,
            endTime: endTime,
            measurementLocation: locationPair[0] as int,
            metadata: metadata,
          );

          final result = skinTemp.toOpenMHealthBodyTemperature();

          expect(result[0].measurementLocation, equals(locationPair[1]));
        }
      },
    );

    test('toOpenMHealthBodyTemperature should set correct time frame', () {
      final timePoint1 = startTime.add(Duration(minutes: 15));
      final timePoint2 = startTime.add(Duration(minutes: 30));

      final skinTemp = HealthConnectSkinTemperature(
        baseline: Temperature(36.5, 36.5),
        deltas: [
          SkinTemperatureDelta(timePoint1, TemperatureDelta(0.1, 0.1)),
          SkinTemperatureDelta(timePoint2, TemperatureDelta(0.2, 0.2)),
        ],
        startTime: startTime,
        endTime: endTime,
        measurementLocation: 3,
        metadata: metadata,
      );

      final result = skinTemp.toOpenMHealthBodyTemperature();

      expect(result[0].effectiveTimeFrame.dateTime, equals(timePoint1));
      expect(result[1].effectiveTimeFrame.dateTime, equals(timePoint2));
    });

    test(
      'toOpenMHealthBodyTemperature should set descriptive statistic to count',
      () {
        final skinTemp = HealthConnectSkinTemperature(
          baseline: Temperature(36.5, 36.5),
          deltas: [
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 10)),
              TemperatureDelta(0.1, 0.1),
            ),
          ],
          startTime: startTime,
          endTime: endTime,
          measurementLocation: 3,
          metadata: metadata,
        );

        final result = skinTemp.toOpenMHealthBodyTemperature();

        expect(
          result[0].descriptiveStatistic,
          equals(DescriptiveStatistic.count),
        );
      },
    );

    test('Converted objects should have correct schema ID', () {
      final skinTemp = HealthConnectSkinTemperature(
        baseline: Temperature(36.5, 36.5),
        deltas: [
          SkinTemperatureDelta(
            startTime.add(Duration(minutes: 10)),
            TemperatureDelta(0.1, 0.1),
          ),
        ],
        startTime: startTime,
        endTime: endTime,
        measurementLocation: 3,
        metadata: metadata,
      );

      final result = skinTemp.toOpenMHealthBodyTemperature();

      expect(result[0].schemaId, equals("omh:body-temperature:4.0"));
    });

    test('toJSON() returns correct format from converted objects', () {
      final skinTemp = HealthConnectSkinTemperature(
        baseline: Temperature(36.5, 36.5),
        deltas: [
          SkinTemperatureDelta(
            startTime.add(Duration(minutes: 10)),
            TemperatureDelta(0.1, 0.1),
          ),
        ],
        startTime: startTime,
        endTime: endTime,
        measurementLocation: 3,
        metadata: metadata,
      );

      final result = skinTemp.toOpenMHealthBodyTemperature();
      final jsonResult = result[0].toJson();

      expect(jsonResult, isA<Map<String, dynamic>>());
      expect(jsonResult["body_temperature"], isNotNull);
      expect(jsonResult["effective_time_frame"], isNotNull);
      expect(jsonResult["descriptive_statistic"], isNotNull);
      expect(jsonResult["measurement_location"], isNotNull);
      expect(jsonResult.containsKey("temporal_relationship_to_sleep"), isFalse);
    });

    test(
      'toOpenMHealthBodyTemperature should handle negative deltas correctly',
      () {
        // rrange
        final skinTemp = HealthConnectSkinTemperature(
          baseline: Temperature(36.5, 36.5),
          deltas: [
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 10)),
              TemperatureDelta(-0.5, -0.5),
            ),
            SkinTemperatureDelta(
              startTime.add(Duration(minutes: 20)),
              TemperatureDelta(-0.2, -0.2),
            ),
          ],
          startTime: startTime,
          endTime: endTime,
          measurementLocation: 3,
          metadata: metadata,
        );

        final result = skinTemp.toOpenMHealthBodyTemperature();

        expect(result[0].bodyTemperature.value, equals(36.0)); // 36.5 - 0.5
        expect(result[1].bodyTemperature.value, equals(36.3)); // 36.5 - 0.2
      },
    );
  });
}
