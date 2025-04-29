import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/provider/data_converter.dart';
import 'package:wearable_health/provider/enums/datastore_availability.dart';
import 'package:wearable_health/provider/health_data.dart';
import 'package:wearable_health/provider/native/health_data_type.dart';
import 'package:wearable_health/provider/provider.dart';

import 'method_type.dart';

abstract class NativeProvider<T extends HealthDataType> implements Provider {
  final methodChannel = MethodChannel("wearable_health");
  late List<T> dataTypes;

  @override
  Future<DataStoreAvailability> checkDataStoreAvailability() async {
    final result = await methodChannel.invokeMethod<String>(
      MethodType.dataStoreAvailability.value,
    );
    return DataStoreAvailability.fromString(result ?? "unknown");
  }

  @override
  Future<List<HealthData>> getData(
    DateTimeRange timeRange,
    DataConverter? converter,
  ) async {
    List<HealthData> healthDataList = [];
    debugPrint("[getData] Method started.");
    debugPrint(
      "[getData] Calling invokeMethod for interval: ${timeRange.start.toUtc().toIso8601String()} - ${timeRange.end.toUtc().toIso8601String()}",
    );

    try {
      final dynamic rawData = await methodChannel
          .invokeMethod<dynamic>(MethodType.getData.value, {
            'start': timeRange.start.toUtc().toIso8601String(),
            'end': timeRange.end.toUtc().toIso8601String(),
          });

      debugPrint(
        "[getData] Received rawData: Type=${rawData?.runtimeType}, Value=$rawData",
      );

      if (rawData == null) {
        debugPrint("[getData] MethodChannel returned null.");
        return healthDataList;
      }

      debugPrint("[getData] Checking if rawData is a List ('is List')...");
      bool isListCheckResult = rawData is List;
      debugPrint(
        "[GoogleHealthConnect.getData] Result of 'rawData is List': $isListCheckResult",
      );

      if (isListCheckResult) {
        debugPrint("[getData] OK: rawData is a List. Attempting to iterate...");
        List<dynamic> tempList = rawData;
        debugPrint("[getData] Number of elements in list: ${tempList.length}");

        for (final item in tempList) {
          if (item is Map) {
            try {
              final Map<String, String> dataPoint = item.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              );
              healthDataList.add(dataPoint);
            } catch (e, stackTrace) {
              debugPrint(
                "[getData] ERROR: Could not convert Map element: $item. Error: $e\n$stackTrace",
              );
              continue;
            }
          } else {
            debugPrint(
              "[getData] WARNING: Element in list is not a Map: $item (${item.runtimeType})",
            );
          }
        }

        if (converter != null) {
          debugPrint(
            "[getData] Applying converter to ${healthDataList.length} valid data points.",
          );
          try {
            List<HealthData> converted = [];
            for (final dataPoint in healthDataList) {
              converted.add(converter.convertData(dataPoint));
            }
            debugPrint("[getData] Conversion complete.");
            return converted;
          } catch (e, stackTrace) {
            debugPrint(
              "[getData] ERROR: Error during data conversion: $e\n$stackTrace",
            );
            throw Exception("Error applying data converter: $e");
          }
        } else {
          debugPrint(
            "[getData] Returning ${healthDataList.length} processed data points (no converter).",
          );
          return healthDataList;
        }
      } else {
        debugPrint("[getData] ERROR: 'rawData is List' returned false.");
        debugPrint("[getData] rawData.runtimeType is: ${rawData.runtimeType}");
        debugPrint("[getData] rawData.toString() is: ${rawData.toString()}");
        throw Exception(
          "[getData] Unexpected data type received (is List == false): ${rawData.runtimeType}",
        );
      }
    } on PlatformException catch (e, stackTrace) {
      debugPrint(
        "[getData] ERROR: PlatformException: ${e.message}\n${e.details}\n$stackTrace",
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint("[getData] ERROR: Unexpected error: $e\n$stackTrace");
      rethrow;
    }
  }

  @override
  Future<String> getPlatformVersion() async {
    final platformVersion = await methodChannel.invokeMethod<String>(
      MethodType.getPlatformVersion.value,
    );
    return platformVersion ?? "";
  }

  @override
  Future<bool> hasPermissions() async {
    List<String> dataTypeStrings = _dataTypesToStrings(dataTypes);

    final result = await methodChannel.invokeMethod<bool>("hasPermissions", {
      'dataTypes': dataTypeStrings,
    });
    return result ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    List<String> dataTypeStrings = _dataTypesToStrings(dataTypes);

    final result = await methodChannel.invokeMethod<bool>(
      MethodType.requestPermissions.value,
      {'dataTypes': dataTypeStrings},
    );
    return result ?? false;
  }

  List<String> _dataTypesToStrings(List<T> dataTypes) {
    List<String> result = [];

    for (final dataType in dataTypes) {
      result.add(dataType.getDefinition());
    }

    return result;
  }
}
