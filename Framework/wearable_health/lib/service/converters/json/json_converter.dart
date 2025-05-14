import 'package:wearable_health/service/converters/json/json_converter_interface.dart';

/// Implementation of the JsonConverter interface for safe type extraction and conversion
/// from dynamic JSON data to strongly typed Dart objects.
class JsonConverterImpl implements JsonConverter {
  /// Extracts and validates a Map from dynamic value.
  /// Throws FormatException if value is not a Map.
  @override
  Map<dynamic, dynamic> extractMap(dynamic value, String errMsg) {
    if (value is! Map) {
      throw FormatException(
        "[JsonConverter] expected Map, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

  /// Converts a Map with dynamic keys to a Map with String keys.
  /// Throws FormatException if any key is not a String.
  @override
  Map<String, dynamic> extractJsonObject(
    Map<dynamic, dynamic> data,
    String errMsg,
  ) {
    for (final element in data.entries) {
      if (element.key is! String) {
        throw FormatException("[JsonConverter]: $errMsg");
      }
    }
    return data.cast<String, dynamic>();
  }

  /// Extracts and validates a List from dynamic value.
  /// Throws FormatException if value is not a List.
  @override
  List<dynamic> extractList(dynamic value, String errMsg) {
    if (value is! List) {
      throw FormatException(
        "[JsonConverter] expected list, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

  /// Extracts a List of JSON objects (Map<String, dynamic>) from dynamic value.
  /// Validates both the list structure and that all elements are properly formatted.
  /// Throws FormatException for invalid types.
  @override
  List<Map<String, dynamic>> extractListOfJsonObjects(
    dynamic value,
    String errMsg,
  ) {
    if (value is! List) {
      throw FormatException(
        "[JsonConverter]: expected list, got ${value.runtimeType}: $errMsg",
      );
    }
    final List<Map<String, dynamic>> resultList = [];
    for (final element in value) {
      if (element is! Map) {
        throw FormatException(
          "[JsonConverter] expected each element in list to be a map, got ${element.runtimeType}: $errMsg",
        );
      }
      final Map<String, dynamic> typedMap = {};
      for (final entry in (element).entries) {
        if (entry.key is! String) {
          throw FormatException(
            "[JsonConverter] expected each key in map to be String, got ${entry.key.runtimeType}: $errMsg",
          );
        }
        typedMap[entry.key as String] = entry.value;
      }
      resultList.add(typedMap);
    }
    return resultList;
  }

  /// Extracts a nested structure: a Map with String keys and values as Lists of JSON objects.
  /// Validates all levels of the structure.
  @override
  Map<String, List<Map<String, dynamic>>>
  extractJsonObjectWithListOfJsonObjects(dynamic value, String errMsg) {
    var outerMap = extractMap(value, errMsg);
    Map<String, List<Map<String, dynamic>>> result = {};
    for (final entry in outerMap.entries) {
      var key = extractStringValue(entry.key, errMsg);
      var typedList = extractListOfJsonObjects(entry.value, errMsg);
      result[key] = typedList;
    }
    return result;
  }

  /// Extracts and validates a String value.
  /// Throws FormatException if value is not a String.
  @override
  String extractStringValue(dynamic value, String errMsg) {
    if (value is! String) {
      throw FormatException(
        "[JsonConverter] expected String, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

  /// Extracts and validates an int value.
  /// Throws FormatException if value is not a number or not an int.
  @override
  int extractIntValue(dynamic value, String errMsg) {
    if (value is! num) {
      throw FormatException(
        "[JsonConverter] expected int, got ${value.runtimeType} $errMsg",
      );
    }
    if (value is! int) {
      throw FormatException(
        "[JsonConverter] expected int, got ${value.runtimeType} $errMsg",
      );
    }

    return value;
  }

  /// Extracts and validates a double value.
  /// Throws FormatException if value is not a number or not a double.
  @override
  double extractDoubleValue(dynamic value, String errMsg) {
    if (value is! num) {
      throw FormatException(
        "[JsonConverter] expected double, got ${value.runtimeType}: $errMsg",
      );
    }

    if (value is! double) {
      throw FormatException(
        "[JsonConverter] expected double, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

  /// Parses a String into DateTime.
  /// Throws FormatException if value is not a valid date string.
  @override
  DateTime extractDateTime(dynamic value, String errMsg) {
    if (value is! String) {
      throw FormatException(
        "[JsonConverter] expected string for date time parsing, got ${value.runtimeType}: $errMsg",
      );
    }
    return DateTime.parse(value);
  }

  /// Creates a DateTime from epoch milliseconds.
  /// Throws FormatException if value is not a number.
  @override
  DateTime extractDateTimeFromEpochMs(dynamic value, String errMsg) {
    if (value is! num) {
      throw FormatException(
        "[JsonConverter] expected num for date time parsing, got ${value.runtimeType}: $errMsg",
      );
    }

    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
}
