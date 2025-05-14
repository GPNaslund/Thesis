import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory.dart';

@GenerateMocks([JsonConverter])
import 'hc_data_factory_test.mocks.dart';

void main() {
  group('HCDataFactoryImpl', () {
    late HCDataFactoryImpl factory;
    late MockJsonConverter mockConverter;

    setUp(() {
      mockConverter = MockJsonConverter();
      factory = HCDataFactoryImpl(mockConverter);
    });

    group('createHeartRate', () {
      test('should create a HealthConnectHeartRate object from valid data', () {
        final DateTime startTime = DateTime(2025, 5, 10, 8, 0);
        final DateTime endTime = DateTime(2025, 5, 10, 9, 0);
        final DateTime sampleTime = DateTime(2025, 5, 10, 8, 30);
        final DateTime lastModifiedTime = DateTime(2025, 5, 10, 10, 0);

        final Map<String, dynamic> inputData = {
          "startTimeEpochMs": 1731009600000,
          "endTimeEpochMs": 1731013200000,
          "startZoneOffset": 0,
          "endZoneOffset": 0,
          "samples": [
            {"time": "2025-05-10T08:30:00", "beatsPerMinute": 72},
          ],
          "metadata": {
            "clientRecordId": "record123",
            "clientRecordVersion": 1,
            "dataOrigin": "device123",
            "device": "smartwatch",
            "id": "id123",
            "lastModifiedTime": "2025-05-10T10:00:00",
            "recordingMethod": 1,
          },
        };

        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["startTimeEpochMs"],
            any,
          ),
        ).thenReturn(startTime);
        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["endTimeEpochMs"],
            any,
          ),
        ).thenReturn(endTime);
        when(
          mockConverter.extractIntValue(inputData["startZoneOffset"], any),
        ).thenReturn(0);
        when(
          mockConverter.extractIntValue(inputData["endZoneOffset"], any),
        ).thenReturn(0);

        when(
          mockConverter.extractList(inputData["samples"], any),
        ).thenReturn(inputData["samples"]);
        when(
          mockConverter.extractJsonObject(inputData["samples"][0], any),
        ).thenReturn(inputData["samples"][0]);
        when(
          mockConverter.extractDateTime(inputData["samples"][0]["time"], any),
        ).thenReturn(sampleTime);
        when(
          mockConverter.extractIntValue(
            inputData["samples"][0]["beatsPerMinute"],
            any,
          ),
        ).thenReturn(72);

        when(
          mockConverter.extractJsonObject(inputData["metadata"], any),
        ).thenReturn(inputData["metadata"]);
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["clientRecordId"],
            any,
          ),
        ).thenReturn("record123");
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["clientRecordVersion"],
            any,
          ),
        ).thenReturn(1);
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["dataOrigin"],
            any,
          ),
        ).thenReturn("device123");
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["device"],
            any,
          ),
        ).thenReturn("smartwatch");
        when(
          mockConverter.extractStringValue(inputData["metadata"]["id"], any),
        ).thenReturn("id123");
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["lastModifiedTime"],
            any,
          ),
        ).thenReturn("2025-05-10T10:00:00");
        when(
          mockConverter.extractDateTime("2025-05-10T10:00:00", any),
        ).thenReturn(lastModifiedTime);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["recordingMethod"],
            any,
          ),
        ).thenReturn(1);

        final result = factory.createHeartRate(inputData);

        expect(result, isA<HealthConnectHeartRate>());
        expect(result.startTime, equals(startTime));
        expect(result.endTime, equals(endTime));
        expect(result.startZoneOffset, equals(0));
        expect(result.endZoneOffset, equals(0));
        expect(result.samples.length, equals(1));
        expect(result.samples[0].time, equals(sampleTime));
        expect(result.samples[0].beatsPerMinute, equals(72));
        expect(result.metadata.clientRecordId, equals("record123"));
        expect(result.metadata.clientRecordVersion, equals(1));
        expect(result.metadata.dataOrigin, equals("device123"));
        expect(result.metadata.device, equals("smartwatch"));
        expect(result.metadata.id, equals("id123"));
        expect(result.metadata.lastModifiedTime, equals(lastModifiedTime));
        expect(result.metadata.recordingMethod, equals(1));
      });

      test('should handle null optional fields in heart rate data', () {
        final DateTime startTime = DateTime(2025, 5, 10, 8, 0);
        final DateTime endTime = DateTime(2025, 5, 10, 9, 0);
        final DateTime sampleTime = DateTime(2025, 5, 10, 8, 30);
        final DateTime lastModifiedTime = DateTime(2025, 5, 10, 10, 0);

        final Map<String, dynamic> inputData = {
          "startTimeEpochMs": 1731009600000,
          "endTimeEpochMs": 1731013200000,
          "startZoneOffset": null,
          "endZoneOffset": null,
          "samples": [
            {"time": "2025-05-10T08:30:00", "beatsPerMinute": 72},
          ],
          "metadata": {
            "clientRecordId": null,
            "clientRecordVersion": null,
            "dataOrigin": "device123",
            "device": null,
            "id": "id123",
            "lastModifiedTime": "2025-05-10T10:00:00",
            "recordingMethod": 1,
          },
        };

        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["startTimeEpochMs"],
            any,
          ),
        ).thenReturn(startTime);
        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["endTimeEpochMs"],
            any,
          ),
        ).thenReturn(endTime);

        when(
          mockConverter.extractList(inputData["samples"], any),
        ).thenReturn(inputData["samples"]);
        when(
          mockConverter.extractJsonObject(inputData["samples"][0], any),
        ).thenReturn(inputData["samples"][0]);
        when(
          mockConverter.extractDateTime(inputData["samples"][0]["time"], any),
        ).thenReturn(sampleTime);
        when(
          mockConverter.extractIntValue(
            inputData["samples"][0]["beatsPerMinute"],
            any,
          ),
        ).thenReturn(72);

        when(
          mockConverter.extractJsonObject(inputData["metadata"], any),
        ).thenReturn(inputData["metadata"]);
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["dataOrigin"],
            any,
          ),
        ).thenReturn("device123");
        when(
          mockConverter.extractStringValue(inputData["metadata"]["id"], any),
        ).thenReturn("id123");
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["lastModifiedTime"],
            any,
          ),
        ).thenReturn("2025-05-10T10:00:00");
        when(
          mockConverter.extractDateTime("2025-05-10T10:00:00", any),
        ).thenReturn(lastModifiedTime);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["recordingMethod"],
            any,
          ),
        ).thenReturn(1);

        final result = factory.createHeartRate(inputData);

        expect(result, isA<HealthConnectHeartRate>());
        expect(result.startZoneOffset, isNull);
        expect(result.endZoneOffset, isNull);
        expect(result.metadata.clientRecordId, isNull);
        expect(result.metadata.clientRecordVersion, isNull);
        expect(result.metadata.device, isNull);
      });

      test('should handle multiple samples in heart rate data', () {
        final DateTime startTime = DateTime(2025, 5, 10, 8, 0);
        final DateTime endTime = DateTime(2025, 5, 10, 9, 0);
        final DateTime sampleTime1 = DateTime(2025, 5, 10, 8, 15);
        final DateTime sampleTime2 = DateTime(2025, 5, 10, 8, 30);
        final DateTime sampleTime3 = DateTime(2025, 5, 10, 8, 45);
        final DateTime lastModifiedTime = DateTime(2025, 5, 10, 10, 0);

        final Map<String, dynamic> inputData = {
          "startTimeEpochMs": 1731009600000,
          "endTimeEpochMs": 1731013200000,
          "samples": [
            {"time": "2025-05-10T08:15:00", "beatsPerMinute": 70},
            {"time": "2025-05-10T08:30:00", "beatsPerMinute": 72},
            {"time": "2025-05-10T08:45:00", "beatsPerMinute": 74},
          ],
          "metadata": {
            "dataOrigin": "device123",
            "id": "id123",
            "lastModifiedTime": "2025-05-10T10:00:00",
            "recordingMethod": 1,
            "clientRecordVersion": 1,
          },
        };

        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["startTimeEpochMs"],
            any,
          ),
        ).thenReturn(startTime);
        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["endTimeEpochMs"],
            any,
          ),
        ).thenReturn(endTime);

        when(
          mockConverter.extractList(inputData["samples"], any),
        ).thenReturn(inputData["samples"]);

        when(
          mockConverter.extractJsonObject(inputData["samples"][0], any),
        ).thenReturn(inputData["samples"][0]);
        when(
          mockConverter.extractDateTime(inputData["samples"][0]["time"], any),
        ).thenReturn(sampleTime1);
        when(
          mockConverter.extractIntValue(
            inputData["samples"][0]["beatsPerMinute"],
            any,
          ),
        ).thenReturn(70);

        when(
          mockConverter.extractJsonObject(inputData["samples"][1], any),
        ).thenReturn(inputData["samples"][1]);
        when(
          mockConverter.extractDateTime(inputData["samples"][1]["time"], any),
        ).thenReturn(sampleTime2);
        when(
          mockConverter.extractIntValue(
            inputData["samples"][1]["beatsPerMinute"],
            any,
          ),
        ).thenReturn(72);

        when(
          mockConverter.extractJsonObject(inputData["samples"][2], any),
        ).thenReturn(inputData["samples"][2]);
        when(
          mockConverter.extractDateTime(inputData["samples"][2]["time"], any),
        ).thenReturn(sampleTime3);
        when(
          mockConverter.extractIntValue(
            inputData["samples"][2]["beatsPerMinute"],
            any,
          ),
        ).thenReturn(74);

        when(
          mockConverter.extractJsonObject(inputData["metadata"], any),
        ).thenReturn(inputData["metadata"]);
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["dataOrigin"],
            any,
          ),
        ).thenReturn("device123");
        when(
          mockConverter.extractStringValue(inputData["metadata"]["id"], any),
        ).thenReturn("id123");
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["lastModifiedTime"],
            any,
          ),
        ).thenReturn("2025-05-10T10:00:00");
        when(
          mockConverter.extractDateTime("2025-05-10T10:00:00", any),
        ).thenReturn(lastModifiedTime);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["recordingMethod"],
            any,
          ),
        ).thenReturn(1);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["clientRecordVersion"],
            any,
          ),
        ).thenReturn(1);

        final result = factory.createHeartRate(inputData);

        expect(result, isA<HealthConnectHeartRate>());
        expect(result.samples.length, equals(3));
        expect(result.samples[0].time, equals(sampleTime1));
        expect(result.samples[0].beatsPerMinute, equals(70));
        expect(result.samples[1].time, equals(sampleTime2));
        expect(result.samples[1].beatsPerMinute, equals(72));
        expect(result.samples[2].time, equals(sampleTime3));
        expect(result.samples[2].beatsPerMinute, equals(74));
      });
    });

    group('createSkinTemperature', () {
      test(
        'should create a HealthConnectSkinTemperature object from valid data',
        () {
          final DateTime startTime = DateTime(2025, 5, 10, 8, 0);
          final DateTime endTime = DateTime(2025, 5, 10, 9, 0);
          final DateTime deltaTime = DateTime(2025, 5, 10, 8, 30);
          final DateTime lastModifiedTime = DateTime(2025, 5, 10, 10, 0);

          final Map<String, dynamic> inputData = {
            "startTimeEpochMs": 1731009600000,
            "endTimeEpochMs": 1731013200000,
            "startZoneOffsetSeconds": 0,
            "endZoneOffsetSeconds": 0,
            "deltas": [
              {
                "time": "2025-05-10T08:30:00",
                "delta": {"inCelsius": 0.2, "inFahrenheit": 0.36},
              },
            ],
            "baseline": {"inCelsius": 36.5, "inFahrenheit": 97.7},
            "measurementLocation": 3,
            "metadata": {
              "clientRecordId": "record123",
              "clientRecordVersion": 1,
              "dataOrigin": "device123",
              "device": "smartwatch",
              "id": "id123",
              "lastModifiedTime": "2025-05-10T10:00:00",
              "recordingMethod": 1,
            },
          };

          when(
            mockConverter.extractDateTimeFromEpochMs(
              inputData["startTimeEpochMs"],
              any,
            ),
          ).thenReturn(startTime);
          when(
            mockConverter.extractDateTimeFromEpochMs(
              inputData["endTimeEpochMs"],
              any,
            ),
          ).thenReturn(endTime);
          when(
            mockConverter.extractIntValue(
              inputData["startZoneOffsetSeconds"],
              any,
            ),
          ).thenReturn(0);
          when(
            mockConverter.extractIntValue(
              inputData["endZoneOffsetSeconds"],
              any,
            ),
          ).thenReturn(0);

          when(
            mockConverter.extractList(inputData["deltas"], any),
          ).thenReturn(inputData["deltas"]);
          when(
            mockConverter.extractJsonObject(inputData["deltas"][0], any),
          ).thenReturn(inputData["deltas"][0]);
          when(
            mockConverter.extractDateTime(inputData["deltas"][0]["time"], any),
          ).thenReturn(deltaTime);
          when(
            mockConverter.extractJsonObject(
              inputData["deltas"][0]["delta"],
              any,
            ),
          ).thenReturn(inputData["deltas"][0]["delta"]);
          when(
            mockConverter.extractDoubleValue(
              inputData["deltas"][0]["delta"]["inCelsius"],
              any,
            ),
          ).thenReturn(0.2);
          when(
            mockConverter.extractDoubleValue(
              inputData["deltas"][0]["delta"]["inFahrenheit"],
              any,
            ),
          ).thenReturn(0.36);

          when(
            mockConverter.extractJsonObject(inputData["baseline"], any),
          ).thenReturn(inputData["baseline"]);
          when(
            mockConverter.extractDoubleValue(
              inputData["baseline"]["inCelsius"],
              any,
            ),
          ).thenReturn(36.5);
          when(
            mockConverter.extractDoubleValue(
              inputData["baseline"]["inFahrenheit"],
              any,
            ),
          ).thenReturn(97.7);

          when(
            mockConverter.extractIntValue(
              inputData["measurementLocation"],
              any,
            ),
          ).thenReturn(3);

          when(
            mockConverter.extractJsonObject(inputData["metadata"], any),
          ).thenReturn(inputData["metadata"]);
          when(
            mockConverter.extractStringValue(
              inputData["metadata"]["clientRecordId"],
              any,
            ),
          ).thenReturn("record123");
          when(
            mockConverter.extractIntValue(
              inputData["metadata"]["clientRecordVersion"],
              any,
            ),
          ).thenReturn(1);
          when(
            mockConverter.extractStringValue(
              inputData["metadata"]["dataOrigin"],
              any,
            ),
          ).thenReturn("device123");
          when(
            mockConverter.extractStringValue(
              inputData["metadata"]["device"],
              any,
            ),
          ).thenReturn("smartwatch");
          when(
            mockConverter.extractStringValue(inputData["metadata"]["id"], any),
          ).thenReturn("id123");
          when(
            mockConverter.extractStringValue(
              inputData["metadata"]["lastModifiedTime"],
              any,
            ),
          ).thenReturn("2025-05-10T10:00:00");
          when(
            mockConverter.extractDateTime("2025-05-10T10:00:00", any),
          ).thenReturn(lastModifiedTime);
          when(
            mockConverter.extractIntValue(
              inputData["metadata"]["recordingMethod"],
              any,
            ),
          ).thenReturn(1);

          final result = factory.createSkinTemperature(inputData);

          expect(result, isA<HealthConnectSkinTemperature>());
          expect(result.startTime, equals(startTime));
          expect(result.endTime, equals(endTime));
          expect(result.startZoneOffset, equals(0));
          expect(result.endZoneOffset, equals(0));
          expect(result.measurementLocation, equals(3));

          expect(result.baseline, isNotNull);
          expect(result.baseline!.inCelsius, equals(36.5));
          expect(result.baseline!.inFahrenheit, equals(97.7));

          expect(result.deltas.length, equals(1));
          expect(result.deltas[0].time, equals(deltaTime));
          expect(result.deltas[0].delta.inCelsius, equals(0.2));
          expect(result.deltas[0].delta.inFahrenheit, equals(0.36));

          expect(result.metadata.clientRecordId, equals("record123"));
          expect(result.metadata.clientRecordVersion, equals(1));
          expect(result.metadata.dataOrigin, equals("device123"));
          expect(result.metadata.device, equals("smartwatch"));
          expect(result.metadata.id, equals("id123"));
          expect(result.metadata.lastModifiedTime, equals(lastModifiedTime));
          expect(result.metadata.recordingMethod, equals(1));
        },
      );

      test('should handle null baseline in skin temperature data', () {
        final DateTime startTime = DateTime(2025, 5, 10, 8, 0);
        final DateTime endTime = DateTime(2025, 5, 10, 9, 0);
        final DateTime deltaTime = DateTime(2025, 5, 10, 8, 30);
        final DateTime lastModifiedTime = DateTime(2025, 5, 10, 10, 0);

        final Map<String, dynamic> inputData = {
          "startTimeEpochMs": 1731009600000,
          "endTimeEpochMs": 1731013200000,
          "deltas": [
            {
              "time": "2025-05-10T08:30:00",
              "delta": {"inCelsius": 0.2, "inFahrenheit": 0.36},
            },
          ],
          "baseline": null,
          "measurementLocation": 3,
          "metadata": {
            "dataOrigin": "device123",
            "id": "id123",
            "lastModifiedTime": "2025-05-10T10:00:00",
            "recordingMethod": 1,
            "clientRecordVersion": 1,
          },
        };

        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["startTimeEpochMs"],
            any,
          ),
        ).thenReturn(startTime);
        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["endTimeEpochMs"],
            any,
          ),
        ).thenReturn(endTime);

        when(
          mockConverter.extractList(inputData["deltas"], any),
        ).thenReturn(inputData["deltas"]);
        when(
          mockConverter.extractJsonObject(inputData["deltas"][0], any),
        ).thenReturn(inputData["deltas"][0]);
        when(
          mockConverter.extractDateTime(inputData["deltas"][0]["time"], any),
        ).thenReturn(deltaTime);
        when(
          mockConverter.extractJsonObject(inputData["deltas"][0]["delta"], any),
        ).thenReturn(inputData["deltas"][0]["delta"]);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][0]["delta"]["inCelsius"],
            any,
          ),
        ).thenReturn(0.2);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][0]["delta"]["inFahrenheit"],
            any,
          ),
        ).thenReturn(0.36);

        when(
          mockConverter.extractIntValue(inputData["measurementLocation"], any),
        ).thenReturn(3);

        when(
          mockConverter.extractJsonObject(inputData["metadata"], any),
        ).thenReturn(inputData["metadata"]);
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["dataOrigin"],
            any,
          ),
        ).thenReturn("device123");
        when(
          mockConverter.extractStringValue(inputData["metadata"]["id"], any),
        ).thenReturn("id123");
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["lastModifiedTime"],
            any,
          ),
        ).thenReturn("2025-05-10T10:00:00");
        when(
          mockConverter.extractDateTime("2025-05-10T10:00:00", any),
        ).thenReturn(lastModifiedTime);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["recordingMethod"],
            any,
          ),
        ).thenReturn(1);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["clientRecordVersion"],
            any,
          ),
        ).thenReturn(1);

        final result = factory.createSkinTemperature(inputData);

        expect(result, isA<HealthConnectSkinTemperature>());
        expect(result.baseline, isNull);
        expect(result.deltas.length, equals(1));
      });

      test('should handle multiple deltas in skin temperature data', () {
        final DateTime startTime = DateTime(2025, 5, 10, 8, 0);
        final DateTime endTime = DateTime(2025, 5, 10, 9, 0);
        final DateTime deltaTime1 = DateTime(2025, 5, 10, 8, 15);
        final DateTime deltaTime2 = DateTime(2025, 5, 10, 8, 30);
        final DateTime deltaTime3 = DateTime(2025, 5, 10, 8, 45);
        final DateTime lastModifiedTime = DateTime(2025, 5, 10, 10, 0);

        final Map<String, dynamic> inputData = {
          "startTimeEpochMs": 1731009600000,
          "endTimeEpochMs": 1731013200000,
          "deltas": [
            {
              "time": "2025-05-10T08:15:00",
              "delta": {"inCelsius": 0.1, "inFahrenheit": 0.18},
            },
            {
              "time": "2025-05-10T08:30:00",
              "delta": {"inCelsius": 0.2, "inFahrenheit": 0.36},
            },
            {
              "time": "2025-05-10T08:45:00",
              "delta": {"inCelsius": 0.3, "inFahrenheit": 0.54},
            },
          ],
          "baseline": {"inCelsius": 36.5, "inFahrenheit": 97.7},
          "measurementLocation": 3,
          "metadata": {
            "dataOrigin": "device123",
            "id": "id123",
            "lastModifiedTime": "2025-05-10T10:00:00",
            "recordingMethod": 1,
            "clientRecordVersion": 1,
          },
        };

        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["startTimeEpochMs"],
            any,
          ),
        ).thenReturn(startTime);
        when(
          mockConverter.extractDateTimeFromEpochMs(
            inputData["endTimeEpochMs"],
            any,
          ),
        ).thenReturn(endTime);

        when(
          mockConverter.extractList(inputData["deltas"], any),
        ).thenReturn(inputData["deltas"]);

        when(
          mockConverter.extractJsonObject(inputData["deltas"][0], any),
        ).thenReturn(inputData["deltas"][0]);
        when(
          mockConverter.extractDateTime(inputData["deltas"][0]["time"], any),
        ).thenReturn(deltaTime1);
        when(
          mockConverter.extractJsonObject(inputData["deltas"][0]["delta"], any),
        ).thenReturn(inputData["deltas"][0]["delta"]);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][0]["delta"]["inCelsius"],
            any,
          ),
        ).thenReturn(0.1);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][0]["delta"]["inFahrenheit"],
            any,
          ),
        ).thenReturn(0.18);

        when(
          mockConverter.extractJsonObject(inputData["deltas"][1], any),
        ).thenReturn(inputData["deltas"][1]);
        when(
          mockConverter.extractDateTime(inputData["deltas"][1]["time"], any),
        ).thenReturn(deltaTime2);
        when(
          mockConverter.extractJsonObject(inputData["deltas"][1]["delta"], any),
        ).thenReturn(inputData["deltas"][1]["delta"]);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][1]["delta"]["inCelsius"],
            any,
          ),
        ).thenReturn(0.2);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][1]["delta"]["inFahrenheit"],
            any,
          ),
        ).thenReturn(0.36);

        when(
          mockConverter.extractJsonObject(inputData["deltas"][2], any),
        ).thenReturn(inputData["deltas"][2]);
        when(
          mockConverter.extractDateTime(inputData["deltas"][2]["time"], any),
        ).thenReturn(deltaTime3);
        when(
          mockConverter.extractJsonObject(inputData["deltas"][2]["delta"], any),
        ).thenReturn(inputData["deltas"][2]["delta"]);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][2]["delta"]["inCelsius"],
            any,
          ),
        ).thenReturn(0.3);
        when(
          mockConverter.extractDoubleValue(
            inputData["deltas"][2]["delta"]["inFahrenheit"],
            any,
          ),
        ).thenReturn(0.54);

        when(
          mockConverter.extractJsonObject(inputData["baseline"], any),
        ).thenReturn(inputData["baseline"]);
        when(
          mockConverter.extractDoubleValue(
            inputData["baseline"]["inCelsius"],
            any,
          ),
        ).thenReturn(36.5);
        when(
          mockConverter.extractDoubleValue(
            inputData["baseline"]["inFahrenheit"],
            any,
          ),
        ).thenReturn(97.7);

        when(
          mockConverter.extractIntValue(inputData["measurementLocation"], any),
        ).thenReturn(3);

        when(
          mockConverter.extractJsonObject(inputData["metadata"], any),
        ).thenReturn(inputData["metadata"]);
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["dataOrigin"],
            any,
          ),
        ).thenReturn("device123");
        when(
          mockConverter.extractStringValue(inputData["metadata"]["id"], any),
        ).thenReturn("id123");
        when(
          mockConverter.extractStringValue(
            inputData["metadata"]["lastModifiedTime"],
            any,
          ),
        ).thenReturn("2025-05-10T10:00:00");
        when(
          mockConverter.extractDateTime("2025-05-10T10:00:00", any),
        ).thenReturn(lastModifiedTime);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["recordingMethod"],
            any,
          ),
        ).thenReturn(1);
        when(
          mockConverter.extractIntValue(
            inputData["metadata"]["clientRecordVersion"],
            any,
          ),
        ).thenReturn(1);

        final result = factory.createSkinTemperature(inputData);

        expect(result, isA<HealthConnectSkinTemperature>());
        expect(result.deltas.length, equals(3));

        expect(result.deltas[0].time, equals(deltaTime1));
        expect(result.deltas[0].delta.inCelsius, equals(0.1));
        expect(result.deltas[0].delta.inFahrenheit, equals(0.18));

        expect(result.deltas[1].time, equals(deltaTime2));
        expect(result.deltas[1].delta.inCelsius, equals(0.2));
        expect(result.deltas[1].delta.inFahrenheit, equals(0.36));

        expect(result.deltas[2].time, equals(deltaTime3));
        expect(result.deltas[2].delta.inCelsius, equals(0.3));
        expect(result.deltas[2].delta.inFahrenheit, equals(0.54));
      });
    });
  });
}
