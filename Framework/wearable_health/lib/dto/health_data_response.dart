import 'dart:developer';

class HealthDataResponse {
  final Map<String, List<Map<String, dynamic>>> data;

  HealthDataResponse(this.data);

  factory HealthDataResponse.fromMap(Map<String, dynamic> rawOuterMap) {
    log("Received rawOuterMap: $rawOuterMap");
    final Map<String, List<Map<String, dynamic>>> processedData = {};

    for (final entry in rawOuterMap.entries) {
      final String key = entry.key;
      final dynamic rawValueInOuterMap = entry.value;

      if (rawValueInOuterMap is List) {
        final List<Map<String, dynamic>> typedList = [];
        for (final rawItemInList in rawValueInOuterMap) {
          if (rawItemInList is Map) {
            try {
              typedList.add(Map<String, dynamic>.from(rawItemInList));
            } catch (e) {
              throw FormatException(
                "Invalid inner map structure for key '$key'. All keys in inner maps must be Strings.",
              );
            }
          } else {
            throw FormatException(
              "Invalid item type in list for key '$key'. Expected a Map, got ${rawItemInList?.runtimeType}.",
            );
          }
        }
        processedData[key] = typedList;
      } else {
        throw FormatException(
          "Invalid value type for key '$key'. Expected a List, got ${rawValueInOuterMap?.runtimeType}.",
        );
      }
    }
    return HealthDataResponse(processedData);
  }

  List<Map<String, dynamic>>? getDataFor(String key) {
    return data[key];
  }
}
