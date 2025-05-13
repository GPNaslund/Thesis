import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory.dart';

class MockJsonConverter implements JsonConverter {
  Map<String, String> stringResponses = {};

  void mockStringValue(String key, String returnValue) {
    stringResponses[key] = returnValue;
  }

  @override
  String extractStringValue(dynamic value, String errMsg) {
    if (value == null) {
      throw FormatException("$errMsg: value is null");
    }

    if (stringResponses.containsKey(value.toString())) {
      return stringResponses[value.toString()]!;
    }

    if (value == 'TestDevice') return 'TestDevice';

    return value.toString();
  }

  @override
  DateTime extractDateTime(dynamic value, String errMsg) {
    if (value == null) {
      throw FormatException("$errMsg: value is null");
    }
    return DateTime.parse('2023-01-01T12:00:00Z');
  }

  @override
  int extractIntValue(dynamic value, String errMsg) {
    if (value == null) {
      throw FormatException("$errMsg: value is null");
    }
    return 1;
  }

  @override
  double extractDoubleValue(dynamic value, String errMsg) {
    if (value == null) {
      throw FormatException("$errMsg: value is null");
    }
    return 37.5;
  }

  @override
  Map<dynamic, dynamic> extractMap(dynamic value, String errMsg) {
    if (value == null) {
      return {};
    }
    return value as Map<dynamic, dynamic>;
  }

  @override
  Map<String, dynamic> extractJsonObject(
    Map<dynamic, dynamic> data,
    String errMsg,
  ) {
    if (data == null) {
      return {};
    }
    return {'source': 'manual'};
  }

  @override
  List<dynamic> extractList(dynamic value, String errMsg) {
    if (value == null) {
      return [];
    }
    return value as List<dynamic>;
  }

  @override
  List<Map<String, dynamic>> extractListOfJsonObjects(
    dynamic value,
    String errMsg,
  ) {
    if (value == null) {
      return [];
    }
    return (value as List).map((e) => {'key': 'value'}).toList();
  }

  @override
  Map<String, List<Map<String, dynamic>>>
  extractJsonObjectWithListOfJsonObjects(dynamic value, String errMsg) {
    if (value == null) {
      return {};
    }
    return {
      'key': [
        {'nested': 'value'},
      ],
    };
  }

  @override
  DateTime extractDateTimeFromEpochMs(dynamic value, String errMsg) {
    if (value == null) {
      throw FormatException("$errMsg: value is null");
    }
    return DateTime.fromMillisecondsSinceEpoch(1609459200000);
  }
}

void main() {
  late MockJsonConverter mockJsonConverter;
  late HKDataFactoryImpl dataFactory;

  setUp(() {
    mockJsonConverter = MockJsonConverter();
    dataFactory = HKDataFactoryImpl(mockJsonConverter);

    mockJsonConverter.mockStringValue('test-uuid', 'test-uuid');
    mockJsonConverter.mockStringValue('minimal-uuid', 'minimal-uuid');
    mockJsonConverter.mockStringValue('heart-rate-uuid', 'heart-rate-uuid');
    mockJsonConverter.mockStringValue('TestDevice', 'TestDevice');
    mockJsonConverter.mockStringValue('degC', 'degC');
    mockJsonConverter.mockStringValue('count/min', 'count/min');
    mockJsonConverter.mockStringValue(
      'HKQuantityTypeIdentifierBodyTemperature',
      'HKQuantityTypeIdentifierBodyTemperature',
    );
    mockJsonConverter.mockStringValue(
      'HKQuantityTypeIdentifierHeartRate',
      'HKQuantityTypeIdentifierHeartRate',
    );
  });

  group('HKDataFactoryImpl', () {
    group('createBodyTemperature', () {
      test('should create a valid HKBodyTemperature from complete data', () {
        final testData = {
          'uuid': 'test-uuid',
          'startDate': '2023-01-01T12:00:00Z',
          'endDate': '2023-01-01T12:05:00Z',
          'value': 37.5,
          'unit': 'degC',
          'sampleType': 'HKQuantityTypeIdentifierBodyTemperature',
          'count': 1,
          'metadata': {'source': 'manual'},
          'device': {
            'name': 'TestDevice',
            'manufacturer': 'TestManufacturer',
            'model': 'TestModel',
            'hardwareVersion': '1.0',
            'softwareVersion': '1.0',
          },
          'sourceRevision': {'source': 'TestApp', 'version': '1.0'},
        };

        // Act
        final result = dataFactory.createBodyTemperature(testData);

        // Assert
        expect(result, isA<HKBodyTemperature>());
        expect(result.data.uuid, equals('test-uuid'));
        expect(result.data.quantity.doubleValue, equals(37.5));
        expect(result.data.quantity.unit, equals('degC'));
      });

      test('should create a valid HKBodyTemperature with minimal data', () {
        // Arrange
        final testData = {
          'uuid': 'minimal-uuid',
          'startDate': '2023-01-01T12:00:00Z',
          'endDate': '2023-01-01T12:05:00Z',
          'value': 37.0,
          'unit': 'degC',
          'sampleType': 'HKQuantityTypeIdentifierBodyTemperature',
        };

        // Act
        final result = dataFactory.createBodyTemperature(testData);

        // Assert
        expect(result, isA<HKBodyTemperature>());
        expect(result.data.uuid, equals('minimal-uuid'));
        expect(result.data.count, isNull);
        expect(result.data.metadata, isNull);
        expect(result.data.device, isNull);
        expect(result.data.sourceRevision, isNull);
      });
    });

    group('createHeartRate', () {
      test('should create a valid HKHeartRate from complete data', () {
        // Arrange
        final testData = {
          'uuid': 'heart-rate-uuid',
          'startDate': '2023-01-01T12:00:00Z',
          'endDate': '2023-01-01T12:05:00Z',
          'value': 72.0,
          'unit': 'count/min',
          'sampleType': 'HKQuantityTypeIdentifierHeartRate',
          'count': 1,
          'metadata': {'source': 'watch'},
          'device': {
            'name': 'AppleWatch',
            'manufacturer': 'Apple',
            'model': 'Series 7',
            'hardwareVersion': '1.0',
            'softwareVersion': '8.5',
          },
          'sourceRevision': {'source': 'HealthApp', 'version': '2.0'},
        };

        // Act
        final result = dataFactory.createHeartRate(testData);

        // Assert
        expect(result, isA<HKHeartRate>());
        expect(result.data.uuid, equals('heart-rate-uuid'));
        expect(result.data.quantity.unit, equals('count/min'));
      });
    });

    group('error handling', () {
      test('should propagate errors from JsonConverter', () {
        // Arrange
        final testData = {
          'uuid': null, // This will cause an error in extractStringValue
          'startDate': '2023-01-01T12:00:00Z',
          'endDate': '2023-01-01T12:05:00Z',
          'value': 37.5,
          'unit': 'degC',
          'sampleType': 'HKQuantityTypeIdentifierBodyTemperature',
        };

        // Act & Assert
        expect(
          () => dataFactory.createBodyTemperature(testData),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle null optional fields correctly', () {
        // Arrange
        final testData = {
          'uuid': 'test-uuid',
          'startDate': '2023-01-01T12:00:00Z',
          'endDate': '2023-01-01T12:05:00Z',
          'value': 37.5,
          'unit': 'degC',
          'sampleType': 'HKQuantityTypeIdentifierBodyTemperature',
          'count': null,
          'metadata': null,
          'device': null,
          'sourceRevision': null,
        };

        // Act
        final result = dataFactory.createBodyTemperature(testData);

        // Assert
        expect(result, isA<HKBodyTemperature>());
        expect(result.data.count, isNull);
        expect(result.data.metadata, isNull);
        expect(result.data.device, isNull);
        expect(result.data.sourceRevision, isNull);
      });
    });

    group('_createDevice', () {
      test('should handle partial device data', () {
        // Arrange
        final testData = {
          'uuid': 'test-uuid',
          'startDate': '2023-01-01T12:00:00Z',
          'endDate': '2023-01-01T12:05:00Z',
          'value': 37.5,
          'unit': 'degC',
          'sampleType': 'HKQuantityTypeIdentifierBodyTemperature',
          'device': {'name': 'TestDevice'},
        };

        // Act
        final result = dataFactory.createBodyTemperature(testData);

        // Assert
        expect(result.data.device, isNotNull);
        expect(result.data.device!.manufacturer, isNull);
        expect(result.data.device!.model, isNull);
        expect(result.data.device!.hardwareVersion, isNull);
        expect(result.data.device!.softwareVersion, isNull);
      });
    });
  });
}
