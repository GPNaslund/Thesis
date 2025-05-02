import 'dart:core';
import '../health_data.dart';

class GetDataResponse {
  final List<HealthData> result;

  GetDataResponse(this.result);

  factory GetDataResponse.fromMap(Map<Object?, Object?> rawData) {
    Map<String, dynamic> serialized;
    try {
      serialized = Map<String, dynamic>.from(rawData);
    } catch (e) {
      throw FormatException("[GetDataResponse] Failed to convert input map to Map<String, dynamic>: $e");
    }

    if (!serialized.containsKey("result")) {
      throw FormatException("[GetDataResponse] Serialized map lacks 'result' key.");
    }

    final dynamic resultValue = serialized["result"];

    if (resultValue is List) {
      List<Map<String, dynamic>> processedList = [];
      for (final rawElement in resultValue) {
        if (rawElement is Map) {
          Map<String, dynamic> elementMap;
          try {
            elementMap = Map<String, dynamic>.from(rawElement);
          } catch (e) {
            print("[GetDataResponse] Warning: Skipping element in 'result' list due to conversion error: $e");
            continue;
          }

          try {
            processedList.add(elementMap);
          } catch (e) {
            print("[GetDataResponse] Warning: Skipping element due to HealthData.fromMap error: $e");
            continue;
          }

        } else {
          print("[GetDataResponse] Warning: Skipping non-Map element in 'result' list: ${rawElement?.runtimeType}");
          continue;
        }
      }
      return GetDataResponse(processedList);

    } else {
      throw FormatException(
          "[GetDataResponse] 'result' must be a List, but found type ${resultValue?.runtimeType}.");
    }
  }
}
