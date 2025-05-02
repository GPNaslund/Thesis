import 'dart:core';
import '../health_data.dart';

class GetDataResponse {
  final List<HealthData> result;

  GetDataResponse(this.result);

  factory GetDataResponse.fromMap(Map<Object?, Object?> rawData) {
    List<Map<String, dynamic>> data = _validateArguments(rawData);
    return GetDataResponse(data);
  }

  static List<Map<String, dynamic>> _validateArguments(Map<Object?, Object?> arguments) {
    Map<String, dynamic> serialized;
    try {
      serialized = Map<String, dynamic>.from(arguments);
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
        return processedList;
      } else {
        throw FormatException(
            "[GetDataResponse] 'result' must be a List, but found type ${resultValue?.runtimeType}.");
      }
    } catch (e) {
      throw FormatException("[GetDataResponse] Failed to convert input map to Map<String, dynamic>: $e");
    }
  }
}
