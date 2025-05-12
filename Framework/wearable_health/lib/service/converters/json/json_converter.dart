import 'package:wearable_health/service/converters/json/json_converter_interface.dart';

class JsonConverterImpl implements JsonConverter {
  @override
  Map<dynamic, dynamic> extractMap(dynamic value, String errMsg) {
    if (value is! Map) {
      throw FormatException(
        "[JsonConverter] expected Map, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

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

  @override
  List<dynamic> extractList(dynamic value, String errMsg) {
    if (value is! List) {
      throw FormatException(
        "[JsonConverter] expected list, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

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

  @override
  String extractStringValue(dynamic value, String errMsg) {
    if (value is! String) {
      throw FormatException(
        "[JsonConverter] expected String, got ${value.runtimeType}: $errMsg",
      );
    }
    return value;
  }

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

  @override
  DateTime extractDateTime(dynamic value, String errMsg) {
    if (value is! String) {
      throw FormatException(
        "[JsonConverter] expected string for date time parsing, got ${value.runtimeType}: $errMsg",
      );
    }
    return DateTime.parse(value);
  }

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
