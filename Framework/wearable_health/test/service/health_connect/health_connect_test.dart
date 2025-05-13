import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wearable_health/model/health_connect/enums/hc_availability.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_connect/health_connect.dart';

class MockMethodChannel extends Mock implements MethodChannel {
  @override
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    final result =
        super.noSuchMethod(
              Invocation.method(#invokeMethod, [method, arguments]),
            )
            as Future<T?>?;

    return result ?? Future<T?>.value(null);
  }

  @override
  Future<List<T>?> invokeListMethod<T>(String method, [dynamic arguments]) {
    final result =
        super.noSuchMethod(
              Invocation.method(#invokeListMethod, [method, arguments]),
            )
            as Future<List<T>?>?;

    return result ?? Future<List<T>?>.value(<T>[]);
  }

  @override
  Future<Map<K, V>?> invokeMapMethod<K, V>(String method, [dynamic arguments]) {
    final result =
        super.noSuchMethod(
              Invocation.method(#invokeMapMethod, [method, arguments]),
            )
            as Future<Map<K, V>?>?;

    return result ?? Future<Map<K, V>?>.value(<K, V>{});
  }
}

class MockHCDataFactory extends Mock implements HCDataFactory {}

class MockJsonConverter extends Mock implements JsonConverter {}

void main() {
  late HealthConnectImpl healthConnect;
  late MockMethodChannel mockMethodChannel;
  late MockHCDataFactory mockDataFactory;
  late MockJsonConverter mockJsonConverter;

  const String healthConnectPrefix = 'healthConnect';
  const String checkPermissionsSuffix = 'checkPermissions';
  const String getDataSuffix = 'getData';
  const String platformVersionSuffix = 'platformVersion';
  const String requestPermissionsSuffix = 'requestPermissions';
  const String checkDataStoreAvailabilitySuffix = 'dataStoreAvailability';

  setUp(() {
    mockMethodChannel = MockMethodChannel();
    mockDataFactory = MockHCDataFactory();
    mockJsonConverter = MockJsonConverter();

    registerFallbackValue({});

    healthConnect = HealthConnectImpl(
      mockMethodChannel,
      mockDataFactory,
      mockJsonConverter,
    );
  });

  group('checkPermissions', () {
    test('should return list of permitted metrics', () async {
      when(
        () => mockMethodChannel.invokeListMethod<String>(
          '$healthConnectPrefix/$checkPermissionsSuffix',
          any(),
        ),
      ).thenAnswer(
        (_) => Future.value([
          'android.permission.health.READ_HEART_RATE',
          'android.permission.health.READ_SKIN_TEMPERATURE',
        ]),
      );

      final result = await healthConnect.checkPermissions();

      expect(result, hasLength(2));
      expect(result[0], equals(HealthConnectHealthMetric.heartRate));
      expect(result[1], equals(HealthConnectHealthMetric.skinTemperature));
    });

    test('should throw exception when channel returns null', () async {
      when(
        () => mockMethodChannel.invokeListMethod<String>(
          '$healthConnectPrefix/$checkPermissionsSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future.value(null));

      expect(() => healthConnect.checkPermissions(), throwsA(isA<Exception>()));
    });
  });

  group('getData', () {
    test(
      'should return health data for the specified metrics and time range',
      () async {
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 2);
        final timeRange = DateTimeRange(start: startDate, end: endDate);
        final metrics = [
          HealthConnectHealthMetric.heartRate,
          HealthConnectHealthMetric.skinTemperature,
        ];

        final Map<String, List<dynamic>> channelResponse = {
          'android.permission.health.READ_HEART_RATE': [
            {'id': 'heart_rate_1'},
            {'id': 'heart_rate_2'},
          ],
          'android.permission.health.READ_SKIN_TEMPERATURE': [
            {'id': 'skin_temp_1'},
          ],
        };

        final Map<String, List<Map<String, dynamic>>> convertedData = {
          'android.permission.health.READ_HEART_RATE': [
            {'id': 'heart_rate_1'},
            {'id': 'heart_rate_2'},
          ],
          'android.permission.health.READ_SKIN_TEMPERATURE': [
            {'id': 'skin_temp_1'},
          ],
        };

        final heartRate1 = HealthConnectHeartRate(
          startTime: startDate,
          endTime: endDate,
          samples: [],
          metadata: HealthConnectMetadata(
            clientRecordVersion: 1,
            dataOrigin: 'test',
            id: 'heart_rate_1',
            lastModifiedTime: DateTime.now(),
            recordingMethod: 1,
          ),
        );

        final heartRate2 = HealthConnectHeartRate(
          startTime: startDate,
          endTime: endDate,
          samples: [],
          metadata: HealthConnectMetadata(
            clientRecordVersion: 1,
            dataOrigin: 'test',
            id: 'heart_rate_2',
            lastModifiedTime: DateTime.now(),
            recordingMethod: 1,
          ),
        );

        final skinTemp1 = HealthConnectSkinTemperature(
          startTime: startDate,
          endTime: endDate,
          deltas: [],
          measurementLocation: 1,
          metadata: HealthConnectMetadata(
            clientRecordVersion: 1,
            dataOrigin: 'test',
            id: 'skin_temp_1',
            lastModifiedTime: DateTime.now(),
            recordingMethod: 1,
          ),
        );

        when(
          () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
            '$healthConnectPrefix/$getDataSuffix',
            any(),
          ),
        ).thenAnswer((_) => Future.value(channelResponse));

        when(
          () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
            any(),
            any(),
          ),
        ).thenReturn(convertedData);

        var callCount = 0;
        when(() => mockDataFactory.createHeartRate(any())).thenAnswer((_) {
          callCount++;
          return callCount == 1 ? heartRate1 : heartRate2;
        });

        when(
          () => mockDataFactory.createSkinTemperature(any()),
        ).thenReturn(skinTemp1);

        final result = await healthConnect.getData(metrics, timeRange);

        expect(result, hasLength(3));
        expect(result.contains(heartRate1), isTrue);
        expect(result.contains(heartRate2), isTrue);
        expect(result.contains(skinTemp1), isTrue);
      },
    );
  });

  group('getPlatformVersion', () {
    test('should return platform version string', () async {
      when(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$platformVersionSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future<String>.value('Android 12'));

      final result = await healthConnect.getPlatformVersion();

      expect(result, equals('Android 12'));
      verify(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$platformVersionSuffix',
          any(),
        ),
      ).called(1);
    });
  });

  group('requestPermissions', () {
    test('should return list of granted permissions', () async {
      final metrics = [
        HealthConnectHealthMetric.heartRate,
        HealthConnectHealthMetric.skinTemperature,
      ];

      when(
        () => mockMethodChannel.invokeListMethod<String>(
          '$healthConnectPrefix/$requestPermissionsSuffix',
          any(),
        ),
      ).thenAnswer(
        (_) => Future.value(['android.permission.health.READ_HEART_RATE']),
      );

      final result = await healthConnect.requestPermissions(metrics);

      expect(result, hasLength(1));
      expect(result[0], equals(HealthConnectHealthMetric.heartRate));
      verify(
        () => mockMethodChannel.invokeListMethod<String>(
          '$healthConnectPrefix/$requestPermissionsSuffix',
          any(),
        ),
      ).called(1);
    });

    test('should throw exception when channel returns null', () async {
      final metrics = [HealthConnectHealthMetric.heartRate];

      when(
        () => mockMethodChannel.invokeListMethod<String>(
          '$healthConnectPrefix/$requestPermissionsSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future.value(null));

      expect(
        () => healthConnect.requestPermissions(metrics),
        throwsA(isA<Exception>()),
      );
    });

    test('should send correct permissions to method channel', () async {
      final metrics = [
        HealthConnectHealthMetric.heartRate,
        HealthConnectHealthMetric.skinTemperature,
      ];

      Map<String, dynamic>? capturedArguments;

      when(
        () => mockMethodChannel.invokeListMethod<String>(
          '$healthConnectPrefix/$requestPermissionsSuffix',
          any(),
        ),
      ).thenAnswer((invocation) {
        capturedArguments =
            invocation.positionalArguments[1] as Map<String, dynamic>?;
        return Future.value(['android.permission.health.READ_HEART_RATE']);
      });

      await healthConnect.requestPermissions(metrics);

      expect(capturedArguments, isNotNull);
      expect(capturedArguments!['types'], isA<List<String>>());
      expect(
        capturedArguments!['types'],
        containsAll([
          'android.permission.health.READ_HEART_RATE',
          'android.permission.health.READ_SKIN_TEMPERATURE',
        ]),
      );
    });
  });

  group('checkHealthStoreAvailability', () {
    test('should return available status', () async {
      when(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$checkDataStoreAvailabilitySuffix',
          any(),
        ),
      ).thenAnswer((_) => Future<String>.value('available'));

      final result = await healthConnect.checkHealthStoreAvailability();

      expect(result, equals(HealthConnectAvailability.available));
      verify(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$checkDataStoreAvailabilitySuffix',
          any(),
        ),
      ).called(1);
    });

    test('should return unavailable status', () async {
      when(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$checkDataStoreAvailabilitySuffix',
          any(),
        ),
      ).thenAnswer((_) => Future<String>.value('unavailable'));

      final result = await healthConnect.checkHealthStoreAvailability();

      expect(result, equals(HealthConnectAvailability.unavailable));
    });

    test('should return needsUpdate status', () async {
      when(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$checkDataStoreAvailabilitySuffix',
          any(),
        ),
      ).thenAnswer((_) => Future<String>.value('needsUpdate'));

      final result = await healthConnect.checkHealthStoreAvailability();

      expect(result, equals(HealthConnectAvailability.needsUpdate));
    });

    test('should throw exception when channel returns null', () async {
      when(
        () => mockMethodChannel.invokeMethod<String>(
          '$healthConnectPrefix/$checkDataStoreAvailabilitySuffix',
          any(),
        ),
      ).thenAnswer((_) => Future<String?>.value(null));

      await expectLater(
        () => healthConnect.checkHealthStoreAvailability(),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'should throw UnimplementedError for unknown availability status',
      () async {
        when(
          () => mockMethodChannel.invokeMethod<String>(
            '$healthConnectPrefix/$checkDataStoreAvailabilitySuffix',
            any(),
          ),
        ).thenAnswer((_) => Future<String>.value('unknown_status'));

        await expectLater(
          () => healthConnect.checkHealthStoreAvailability(),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });

  group('getData edge cases', () {
    test('should handle empty data sets', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 2);
      final timeRange = DateTimeRange(start: startDate, end: endDate);
      final metrics = [HealthConnectHealthMetric.heartRate];

      final Map<String, List<dynamic>> emptyChannelResponse = {
        'android.permission.health.READ_HEART_RATE': [],
      };

      final Map<String, List<Map<String, dynamic>>> emptyConvertedData = {
        'android.permission.health.READ_HEART_RATE': [],
      };

      when(
        () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
          '$healthConnectPrefix/$getDataSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future.value(emptyChannelResponse));

      when(
        () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
          any(),
          any(),
        ),
      ).thenReturn(emptyConvertedData);

      final result = await healthConnect.getData(metrics, timeRange);

      expect(result, isEmpty);
    });

    test('should correctly format date ranges in getData', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 2);
      final timeRange = DateTimeRange(start: startDate, end: endDate);
      final metrics = [HealthConnectHealthMetric.heartRate];

      Map<String, dynamic>? capturedArguments;

      when(
        () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
          '$healthConnectPrefix/$getDataSuffix',
          any(),
        ),
      ).thenAnswer((invocation) {
        capturedArguments =
            invocation.positionalArguments[1] as Map<String, dynamic>?;
        return Future.value({'android.permission.health.READ_HEART_RATE': []});
      });

      when(
        () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
          any(),
          any(),
        ),
      ).thenReturn({'android.permission.health.READ_HEART_RATE': []});

      await healthConnect.getData(metrics, timeRange);

      expect(capturedArguments, isNotNull);
      expect(
        capturedArguments!['start'],
        equals(startDate.toUtc().toIso8601String()),
      );
      expect(
        capturedArguments!['end'],
        equals(endDate.toUtc().toIso8601String()),
      );
      expect(
        capturedArguments!['types'],
        equals(['android.permission.health.READ_HEART_RATE']),
      );
    });

    test('should correctly handle multiple metrics in getData', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 2);
      final timeRange = DateTimeRange(start: startDate, end: endDate);
      final metrics = [
        HealthConnectHealthMetric.heartRate,
        HealthConnectHealthMetric.skinTemperature,
      ];

      Map<String, dynamic>? capturedArguments;

      when(
        () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
          '$healthConnectPrefix/$getDataSuffix',
          any(),
        ),
      ).thenAnswer((invocation) {
        capturedArguments =
            invocation.positionalArguments[1] as Map<String, dynamic>?;
        return Future.value({
          'android.permission.health.READ_HEART_RATE': [],
          'android.permission.health.READ_SKIN_TEMPERATURE': [],
        });
      });

      when(
        () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
          any(),
          any(),
        ),
      ).thenReturn({
        'android.permission.health.READ_HEART_RATE': [],
        'android.permission.health.READ_SKIN_TEMPERATURE': [],
      });

      await healthConnect.getData(metrics, timeRange);

      expect(capturedArguments, isNotNull);
      expect(
        capturedArguments!['types'],
        contains('android.permission.health.READ_HEART_RATE'),
      );
      expect(
        capturedArguments!['types'],
        contains('android.permission.health.READ_SKIN_TEMPERATURE'),
      );
      expect(capturedArguments!['types'].length, equals(2));
    });
  });

  group('_convertToHealthConnectData', () {
    test('should convert heart rate data correctly', () async {
      final Map<String, List<dynamic>> response = {
        'android.permission.health.READ_HEART_RATE': [
          {'id': 'heart_rate_1'},
        ],
      };

      final Map<String, List<Map<String, dynamic>>> convertedData = {
        'android.permission.health.READ_HEART_RATE': [
          {'id': 'heart_rate_1'},
        ],
      };

      final mockHeartRate = HealthConnectHeartRate(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        samples: [],
        metadata: HealthConnectMetadata(
          clientRecordVersion: 1,
          dataOrigin: 'test',
          id: 'heart_rate_1',
          lastModifiedTime: DateTime.now(),
          recordingMethod: 1,
        ),
      );

      when(
        () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
          response,
          any(),
        ),
      ).thenReturn(convertedData);

      when(
        () => mockDataFactory.createHeartRate(any()),
      ).thenReturn(mockHeartRate);

      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 2);
      final timeRange = DateTimeRange(start: startDate, end: endDate);
      final metrics = [HealthConnectHealthMetric.heartRate];

      when(
        () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
          '$healthConnectPrefix/$getDataSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future.value(response));

      final result = await healthConnect.getData(metrics, timeRange);

      expect(result, hasLength(1));
      expect(result[0], equals(mockHeartRate));

      verify(
        () => mockDataFactory.createHeartRate(
          convertedData['android.permission.health.READ_HEART_RATE']![0],
        ),
      ).called(1);
    });

    test('should convert skin temperature data correctly', () async {
      final Map<String, List<dynamic>> response = {
        'android.permission.health.READ_SKIN_TEMPERATURE': [
          {'id': 'skin_temp_1'},
        ],
      };

      final Map<String, List<Map<String, dynamic>>> convertedData = {
        'android.permission.health.READ_SKIN_TEMPERATURE': [
          {'id': 'skin_temp_1'},
        ],
      };

      final mockSkinTemp = HealthConnectSkinTemperature(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        deltas: [],
        measurementLocation: 1,
        metadata: HealthConnectMetadata(
          clientRecordVersion: 1,
          dataOrigin: 'test',
          id: 'skin_temp_1',
          lastModifiedTime: DateTime.now(),
          recordingMethod: 1,
        ),
      );

      when(
        () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
          response,
          any(),
        ),
      ).thenReturn(convertedData);

      when(
        () => mockDataFactory.createSkinTemperature(any()),
      ).thenReturn(mockSkinTemp);

      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 2);
      final timeRange = DateTimeRange(start: startDate, end: endDate);
      final metrics = [HealthConnectHealthMetric.skinTemperature];

      when(
        () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
          '$healthConnectPrefix/$getDataSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future.value(response));

      final result = await healthConnect.getData(metrics, timeRange);

      expect(result, hasLength(1));
      expect(result[0], equals(mockSkinTemp));

      verify(
        () => mockDataFactory.createSkinTemperature(
          convertedData['android.permission.health.READ_SKIN_TEMPERATURE']![0],
        ),
      ).called(1);
    });

    test('should throw UnimplementedError for unknown health metric', () async {
      final Map<String, List<dynamic>> response = {
        'android.permission.health.READ_UNKNOWN_METRIC': [
          {'id': 'unknown_1'},
        ],
      };

      final Map<String, List<Map<String, dynamic>>> convertedData = {
        'android.permission.health.READ_UNKNOWN_METRIC': [
          {'id': 'unknown_1'},
        ],
      };

      when(
        () => mockJsonConverter.extractJsonObjectWithListOfJsonObjects(
          response,
          any(),
        ),
      ).thenReturn(convertedData);

      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 2);
      final timeRange = DateTimeRange(start: startDate, end: endDate);
      final metrics = [HealthConnectHealthMetric.heartRate];

      when(
        () => mockMethodChannel.invokeMapMethod<String, List<dynamic>>(
          '$healthConnectPrefix/$getDataSuffix',
          any(),
        ),
      ).thenAnswer((_) => Future.value(response));

      expect(
        () => healthConnect.getData(metrics, timeRange),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
