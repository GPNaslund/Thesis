import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:wearable_health/model/health_kit/enums/hk_availability.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/health_kit.dart';

@GenerateMocks([MethodChannel, HKDataFactory, JsonConverter])
import 'health_kit_test.mocks.dart';

void main() {
  late MockMethodChannel methodChannel;
  late MockHKDataFactory dataFactory;
  late MockJsonConverter jsonConverter;
  late HealthKitImpl healthKit;

  const String healthKitPrefix = 'healthKit';
  const String dataStoreAvailabilitySuffix = 'dataStoreAvailability';
  const String getDataSuffix = 'getData';
  const String platformVersionSuffix = 'platformVersion';
  const String requestPermissionsSuffix = 'requestPermissions';

  setUp(() {
    methodChannel = MockMethodChannel();
    dataFactory = MockHKDataFactory();
    jsonConverter = MockJsonConverter();
    healthKit = HealthKitImpl(methodChannel, dataFactory, jsonConverter);
  });

  group('checkHealthStoreAvailability', () {
    test('returns HealthKitAvailability when successful', () async {
      when(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$dataStoreAvailabilitySuffix',
        ),
      ).thenAnswer((_) async => 'available');

      final result = await healthKit.checkHealthStoreAvailability();

      expect(result, equals(HealthKitAvailability.available));
      verify(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$dataStoreAvailabilitySuffix',
        ),
      ).called(1);
    });

    test('throws exception when result is null', () async {
      when(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$dataStoreAvailabilitySuffix',
        ),
      ).thenAnswer((_) async => null);

      expect(
            () => healthKit.checkHealthStoreAvailability(),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains(
              '[HealthKit] checkHealthStoreAvailability received null result',
            ),
          ),
        ),
      );
    });
  });

  group('getData', () {
    final now = DateTime.now();
    final timeRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
    final metrics = [
      HealthKitHealthMetric.heartRate,
      HealthKitHealthMetric.bodyTemperature,
    ];
    final types = metrics.map((m) => m.definition).toList();
    final requestMap = {
      'start': timeRange.start.toUtc().toIso8601String(),
      'end': timeRange.end.toUtc().toIso8601String(),
      'types': types,
    };

    test('returns list of HealthKitData when successful', () async {
      final responseMap = {
        "HKQuantityTypeIdentifierHeartRate": [
          {'value': 75, 'timestamp': '2023-01-01T12:00:00.000Z'},
        ],
        "HKQuantityTypeIdentifierBodyTemperature": [
          {'value': 37.0, 'timestamp': '2023-01-01T12:00:00.000Z'},
        ],
      };

      when(
        methodChannel.invokeMapMethod(
          '$healthKitPrefix/$getDataSuffix',
          requestMap,
        ),
      ).thenAnswer((_) async => responseMap);

      final extractedData = {
        "HKQuantityTypeIdentifierHeartRate": [
          {'value': 75, 'timestamp': '2023-01-01T12:00:00.000Z'},
        ],
        "HKQuantityTypeIdentifierBodyTemperature": [
          {'value': 37.0, 'timestamp': '2023-01-01T12:00:00.000Z'},
        ],
      };
      when(
        jsonConverter.extractJsonObjectWithListOfJsonObjects(responseMap, any),
      ).thenReturn(extractedData);

      final mockHeartRate = MockHKHeartRate();
      final mockBodyTemp = MockHKBodyTemperature();

      when(
        dataFactory.createHeartRate(any),
      ).thenReturn(mockHeartRate as HKHeartRate);
      when(
        dataFactory.createBodyTemperature(any),
      ).thenReturn(mockBodyTemp as HKBodyTemperature);

      final result = await healthKit.getData(metrics, timeRange);

      expect(result, hasLength(2));
      expect(result, contains(mockHeartRate));
      expect(result, contains(mockBodyTemp));
      verify(
        methodChannel.invokeMapMethod(
          '$healthKitPrefix/$getDataSuffix',
          requestMap,
        ),
      ).called(1);
    });

    test('throws exception when response is null', () async {
      when(
        methodChannel.invokeMapMethod(
          '$healthKitPrefix/$getDataSuffix',
          requestMap,
        ),
      ).thenAnswer((_) async => null);

      expect(
            () => healthKit.getData(metrics, timeRange),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('[HealthKit] getData returned null'),
          ),
        ),
      );
    });

    test(
      'throws UnimplementedError for unsupported health metric type',
          () async {
        final responseMap = {
          'unsupportedMetric': [
            {'value': 75, 'timestamp': '2023-01-01T12:00:00.000Z'},
          ],
        };

        when(
          methodChannel.invokeMapMethod(
            '$healthKitPrefix/$getDataSuffix',
            requestMap,
          ),
        ).thenAnswer((_) async => responseMap);

        when(
          jsonConverter.extractJsonObjectWithListOfJsonObjects(
            responseMap,
            any,
          ),
        ).thenReturn({
          'unsupportedMetric': [{}],
        });

        expect(
              () => healthKit.getData(metrics, timeRange),
          throwsA(
            isA<UnimplementedError>().having(
                  (e) => e.toString(),
              'message',
              contains(
                '[HealthKitHealthMetric] Received unknown metric string: unsupportedMetric',
              ),
            ),
          ),
        );
      },
    );
  });

  group('getRawData', () {
  final now = DateTime.now();
  final timeRange = DateTimeRange(
    start: now.subtract(const Duration(days: 7)),
    end: now,
  );
  final metrics = [
    HealthKitHealthMetric.heartRate,
    HealthKitHealthMetric.bodyTemperature,
  ];
  final types = metrics.map((m) => m.definition).toList();
  final requestMap = {
    'start': timeRange.start.toUtc().toIso8601String(),
    'end': timeRange.end.toUtc().toIso8601String(),
    'types': types,
  };

  test('returns HealthData when successful', () async {
    final responseMap = {
      "HKQuantityTypeIdentifierHeartRate": [
        {'value': 75, 'timestamp': '2023-01-01T12:00:00.000Z'},
      ],
      "HKQuantityTypeIdentifierBodyTemperature": [
        {'value': 37.0, 'timestamp': '2023-01-01T12:00:00.000Z'},
      ],
    };

    when(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        requestMap,
      ),
    ).thenAnswer((_) async => responseMap);

    final convertedData = {
      "HKQuantityTypeIdentifierHeartRate": [
        {'value': 75, 'timestamp': '2023-01-01T12:00:00.000Z'},
      ],
      "HKQuantityTypeIdentifierBodyTemperature": [
        {'value': 37.0, 'timestamp': '2023-01-01T12:00:00.000Z'},
      ],
    };

    when(
      jsonConverter.extractJsonObjectWithListOfJsonObjects(responseMap, any),
    ).thenReturn(convertedData);

    final mockHealthData = MockHealthKitData();
    when(
      dataFactory.createHealthData(convertedData),
    ).thenReturn(mockHealthData);

    final result = await healthKit.getRawData(metrics, timeRange);

    expect(result, equals(mockHealthData));
    verify(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        requestMap,
      ),
    ).called(1);
    verify(
      jsonConverter.extractJsonObjectWithListOfJsonObjects(responseMap, any),
    ).called(1);
    verify(
      dataFactory.createHealthData(convertedData),
    ).called(1);
  });

  test('should correctly format date ranges and metrics in request', () async {
    final startDate = DateTime(2025, 1, 1);
    final endDate = DateTime(2025, 1, 2);
    final customTimeRange = DateTimeRange(start: startDate, end: endDate);
    final customMetrics = [
      HealthKitHealthMetric.heartRate,
      HealthKitHealthMetric.bodyTemperature,
    ];

    final expectedRequestMap = {
      'start': startDate.toUtc().toIso8601String(),
      'end': endDate.toUtc().toIso8601String(),
      'types': customMetrics.map((m) => m.definition).toList(),
    };

    final responseMap = {
      "HKQuantityTypeIdentifierHeartRate": [],
      "HKQuantityTypeIdentifierBodyTemperature": [],
    };

    when(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        expectedRequestMap,
      ),
    ).thenAnswer((_) async => responseMap);

    when(
      jsonConverter.extractJsonObjectWithListOfJsonObjects(responseMap, any),
    ).thenReturn({
      "HKQuantityTypeIdentifierHeartRate": [],
      "HKQuantityTypeIdentifierBodyTemperature": [],
    });

    final mockHealthData = MockHealthKitData();
    when(
      dataFactory.createHealthData(any),
    ).thenReturn(mockHealthData);

    await healthKit.getRawData(customMetrics, customTimeRange);

    verify(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        expectedRequestMap,
      ),
    ).called(1);
  });

  test('throws exception when response is null', () async {
    when(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        requestMap,
      ),
    ).thenAnswer((_) async => null);

    expect(
      () => healthKit.getRawData(metrics, timeRange),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('[HealthKit] getRawData returned null'),
        ),
      ),
    );
  });

  test('should handle empty data sets', () async {
    final emptyResponseMap = {
      "HKQuantityTypeIdentifierHeartRate": [],
      "HKQuantityTypeIdentifierBodyTemperature": [],
    };

    when(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        requestMap,
      ),
    ).thenAnswer((_) async => emptyResponseMap);

    final emptyConvertedData = {
      "HKQuantityTypeIdentifierHeartRate": [],
      "HKQuantityTypeIdentifierBodyTemperature": [],
    };

    when(
      jsonConverter.extractJsonObjectWithListOfJsonObjects(emptyResponseMap, any),
    ).thenReturn(emptyConvertedData);

    final mockEmptyHealthData = MockHealthKitData();
    when(
      dataFactory.createHealthData(emptyConvertedData),
    ).thenReturn(mockEmptyHealthData);

    final result = await healthKit.getRawData(metrics, timeRange);

    expect(result, equals(mockEmptyHealthData));
    verify(
      methodChannel.invokeMapMethod(
        '$healthKitPrefix/$getDataSuffix',
        requestMap,
      ),
    ).called(1);
  });
});

  group('getPlatformVersion', () {
    test('returns platform version when successful', () async {
      const expectedVersion = '12.0';
      when(
        methodChannel.invokeMethod('$healthKitPrefix/$platformVersionSuffix'),
      ).thenAnswer((_) async => expectedVersion);

      final result = await healthKit.getPlatformVersion();

      expect(result, equals(expectedVersion));
      verify(
        methodChannel.invokeMethod('$healthKitPrefix/$platformVersionSuffix'),
      ).called(1);
    });
  });

  group('requestPermissions', () {
    final metrics = [
      HealthKitHealthMetric.heartRate,
      HealthKitHealthMetric.bodyTemperature,
    ];
    final definitions = metrics.map((m) => m.definition).toList();
    final requestMap = {'types': definitions};

    test('returns true when permissions are granted', () async {
      when(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$requestPermissionsSuffix',
          requestMap,
        ),
      ).thenAnswer((_) async => true);

      final result = await healthKit.requestPermissions(metrics);

      expect(result, isTrue);
      verify(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$requestPermissionsSuffix',
          requestMap,
        ),
      ).called(1);
    });

    test('returns false when permissions are denied', () async {
      when(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$requestPermissionsSuffix',
          requestMap,
        ),
      ).thenAnswer((_) async => false);

      final result = await healthKit.requestPermissions(metrics);

      expect(result, isFalse);
    });

    test('throws exception when result is null', () async {
      when(
        methodChannel.invokeMethod(
          '$healthKitPrefix/$requestPermissionsSuffix',
          requestMap,
        ),
      ).thenAnswer((_) async => null);

      expect(
            () => healthKit.requestPermissions(metrics),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('[HealthKit] requestPermissions returned null'),
          ),
        ),
      );
    });
  });
}

class MockHKHeartRate extends Mock implements HKHeartRate {}

class MockHKBodyTemperature extends Mock implements HKBodyTemperature {}

class MockHealthKitData extends Mock implements HealthKitData {}
