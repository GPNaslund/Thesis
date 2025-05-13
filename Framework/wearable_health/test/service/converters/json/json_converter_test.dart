import "package:test/test.dart";
import "package:wearable_health/service/converters/json/json_converter.dart";

void main() {
  late JsonConverterImpl converter;
  const String testErrMsg = "Test error message";

  setUp(() {
    converter = JsonConverterImpl();
  });

  group('extractMap', () {
    test('should return map when value is a map', () {
      final Map<dynamic, dynamic> testMap = {'key': 'value', 1: 2};
      expect(converter.extractMap(testMap, testErrMsg), equals(testMap));
    });

    test('should return empty map when value is an empty map', () {
      final Map<dynamic, dynamic> testMap = {};
      expect(converter.extractMap(testMap, testErrMsg), equals(testMap));
    });

    test('should throw FormatException when value is not a map', () {
      expect(
        () => converter.extractMap([], testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected Map, got List'),
          ),
        ),
      );
    });

    test('should throw FormatException when value is a String', () {
      expect(
        () => converter.extractMap("not a map", testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected Map, got String'),
          ),
        ),
      );
    });
  });

  group('extractJsonObject', () {
    test(
      'should return Map<String, dynamic> when input has all String keys',
      () {
        final Map<dynamic, dynamic> input = {'key1': 'value1', 'key2': 2};
        final Map<String, dynamic> expected = {'key1': 'value1', 'key2': 2};
        expect(
          converter.extractJsonObject(input, testErrMsg),
          equals(expected),
        );
      },
    );

    test('should return empty Map<String, dynamic> for empty input map', () {
      final Map<dynamic, dynamic> input = {};
      final Map<String, dynamic> expected = {};
      expect(converter.extractJsonObject(input, testErrMsg), equals(expected));
    });

    test('should throw FormatException when a key is not a String', () {
      final Map<dynamic, dynamic> input = {'key1': 'value1', 123: 'value2'};
      expect(
        () => converter.extractJsonObject(input, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains(testErrMsg),
          ),
        ),
      );
    });

    test('should throw FormatException when multiple keys are not Strings', () {
      final Map<dynamic, dynamic> input = {1: 'value1', true: 'value2'};
      expect(
        () => converter.extractJsonObject(input, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains(testErrMsg),
          ),
        ),
      );
    });
  });

  group('extractList', () {
    test('should return list when value is a list', () {
      final List<dynamic> testList = ['item1', 2, true];
      expect(converter.extractList(testList, testErrMsg), equals(testList));
    });

    test('should return empty list when value is an empty list', () {
      final List<dynamic> testList = [];
      expect(converter.extractList(testList, testErrMsg), equals(testList));
    });

    test(
      'should throw FormatException when value is not a list (e.g., Map)',
      () {
        expect(
          () => converter.extractList({}, testErrMsg),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected list, got _Map'),
            ),
          ),
        );
      },
    );

    test('should throw FormatException when value is a String', () {
      expect(
        () => converter.extractList("not a list", testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected list, got String'),
          ),
        ),
      );
    });
  });

  group('extractListOfJsonObjects', () {
    test('should return List<Map<String, dynamic>> for valid input', () {
      final List<dynamic> input = [
        {'key1': 'value1', 'key2': 2},
        {'name': 'test', 'valid': true},
      ];
      final List<Map<String, dynamic>> expected = [
        {'key1': 'value1', 'key2': 2},
        {'name': 'test', 'valid': true},
      ];
      expect(
        converter.extractListOfJsonObjects(input, testErrMsg),
        equals(expected),
      );
    });

    test('should return empty list for empty input list', () {
      final List<dynamic> input = [];
      expect(converter.extractListOfJsonObjects(input, testErrMsg), isEmpty);
    });

    test('should throw FormatException if value is not a list', () {
      expect(
        () => converter.extractListOfJsonObjects({}, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected list, got _Map'),
          ),
        ),
      );
    });

    test('should throw FormatException if list contains a non-map element', () {
      final List<dynamic> input = [
        {'key': 'value'},
        "not a map",
      ];
      expect(
        () => converter.extractListOfJsonObjects(input, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected each element in list to be a map, got String'),
          ),
        ),
      );
    });

    test(
      'should throw FormatException if a map in the list has a non-String key',
      () {
        final List<dynamic> input = [
          {'key1': 'value1'},
          {123: 'wrongKeyType'},
        ];
        expect(
          () => converter.extractListOfJsonObjects(input, testErrMsg),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected each key in map to be String, got int'),
            ),
          ),
        );
      },
    );
  });

  group('extractJsonObjectWithListOfJsonObjects', () {
    test('should return correctly typed map for valid input', () {
      final dynamic input = {
        'list1': [
          {'id': 1, 'value': 'a'},
          {'id': 2, 'value': 'b'},
        ],
        'list2': [
          {'name': 'itemX', 'count': 10},
        ],
      };
      final Map<String, List<Map<String, dynamic>>> expected = {
        'list1': [
          {'id': 1, 'value': 'a'},
          {'id': 2, 'value': 'b'},
        ],
        'list2': [
          {'name': 'itemX', 'count': 10},
        ],
      };
      expect(
        converter.extractJsonObjectWithListOfJsonObjects(input, testErrMsg),
        equals(expected),
      );
    });

    test('should return empty map for empty input map', () {
      final dynamic input = {};
      expect(
        converter.extractJsonObjectWithListOfJsonObjects(input, testErrMsg),
        isEmpty,
      );
    });

    test('should throw FormatException if outer value is not a map', () {
      final dynamic input = [];
      expect(
        () =>
            converter.extractJsonObjectWithListOfJsonObjects(input, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected Map, got List'),
          ),
        ),
      );
    });

    test(
      'should throw FormatException if a key in outer map is not String',
      () {
        final dynamic input = {
          123: [
            {'id': 1},
          ],
        };
        expect(
          () => converter.extractJsonObjectWithListOfJsonObjects(
            input,
            testErrMsg,
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected String, got int'),
            ),
          ),
        );
      },
    );

    test(
      'should throw FormatException if a value in outer map is not a list',
      () {
        final dynamic input = {'list1': "not a list"};
        expect(
          () => converter.extractJsonObjectWithListOfJsonObjects(
            input,
            testErrMsg,
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected list, got String'),
            ),
          ),
        );
      },
    );

    test(
      'should throw FormatException if a list contains maps with non-String keys',
      () {
        final dynamic input = {
          'list1': [
            {1: 'non-string key'},
          ],
        };
        expect(
          () => converter.extractJsonObjectWithListOfJsonObjects(
            input,
            testErrMsg,
          ),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected each key in map to be String, got int'),
            ),
          ),
        );
      },
    );
  });

  group('extractStringValue', () {
    test('should return string when value is a string', () {
      expect(
        converter.extractStringValue("hello", testErrMsg),
        equals("hello"),
      );
    });

    test('should return empty string when value is an empty string', () {
      expect(converter.extractStringValue("", testErrMsg), equals(""));
    });

    test(
      'should throw FormatException when value is not a string (e.g., int)',
      () {
        expect(
          () => converter.extractStringValue(123, testErrMsg),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected String, got int'),
            ),
          ),
        );
      },
    );

    test('should throw FormatException when value is null', () {
      expect(
        () => converter.extractStringValue(null, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected String, got Null'),
          ),
        ),
      );
    });
  });

  group('extractIntValue', () {
    test('should return int when value is an int', () {
      expect(converter.extractIntValue(123, testErrMsg), equals(123));
    });

    test('should return 0 when value is 0', () {
      expect(converter.extractIntValue(0, testErrMsg), equals(0));
    });

    test('should throw FormatException when value is a double', () {
      expect(
        () => converter.extractIntValue(10.0, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected int, got double'),
          ),
        ),
      );
    });

    test('should throw FormatException when value is a String', () {
      expect(
        () => converter.extractIntValue("123", testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected int, got String'),
          ),
        ),
      );
    });
  });

  group('extractDoubleValue', () {
    test('should return double when value is a double', () {
      expect(converter.extractDoubleValue(123.45, testErrMsg), equals(123.45));
    });

    test('should return 0.0 when value is 0.0', () {
      expect(converter.extractDoubleValue(0.0, testErrMsg), equals(0.0));
    });

    test('should throw FormatException when value is an int', () {
      expect(
        () => converter.extractDoubleValue(10, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected double, got int'),
          ),
        ),
      );
    });

    test('should throw FormatException when value is a String', () {
      expect(
        () => converter.extractDoubleValue("123.45", testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected double, got String'),
          ),
        ),
      );
    });
  });

  group('extractDateTime', () {
    test('should return DateTime when value is a valid string', () {
      final String dateString = "2023-10-26T10:00:00Z";
      final DateTime expected = DateTime.utc(2023, 10, 26, 10, 0, 0);
      expect(
        converter.extractDateTime(dateString, testErrMsg),
        equals(expected),
      );
    });

    test('should throw FormatException when value is not a string', () {
      expect(
        () => converter.extractDateTime(12345, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected string for date time parsing, got int'),
          ),
        ),
      );
    });

    test(
      'should throw FormatException when value is an invalid date string',
      () {
        expect(
          () => converter.extractDateTime("not-a-date", testErrMsg),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });

  group('extractDateTimeFromEpochMs', () {
    test(
      'should return DateTime when value is a valid epoch milliseconds int',
      () {
        final int epochMs = 1678886400000;
        final DateTime expected = DateTime.fromMillisecondsSinceEpoch(
          epochMs,
          isUtc: true,
        );
        expect(
          converter
              .extractDateTimeFromEpochMs(epochMs, testErrMsg)
              .millisecondsSinceEpoch,
          equals(expected.millisecondsSinceEpoch),
        );
      },
    );

    test(
      'should return DateTime when value is a valid epoch milliseconds double',
      () {
        final double epochMsDouble = 1678886400000.0;
        final DateTime expected = DateTime.fromMillisecondsSinceEpoch(
          epochMsDouble.toInt(),
          isUtc: true,
        );
        expect(
          converter
              .extractDateTimeFromEpochMs(epochMsDouble, testErrMsg)
              .millisecondsSinceEpoch,
          equals(expected.millisecondsSinceEpoch),
        );
      },
    );

    test(
      'should throw FormatException when value is not a number (e.g. String)',
      () {
        expect(
          () =>
              converter.extractDateTimeFromEpochMs("1678886400000", testErrMsg),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('expected num for date time parsing, got String'),
            ),
          ),
        );
      },
    );

    test('should throw FormatException when value is null', () {
      expect(
        () => converter.extractDateTimeFromEpochMs(null, testErrMsg),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('expected num for date time parsing, got Null'),
          ),
        ),
      );
    });
  });
}
