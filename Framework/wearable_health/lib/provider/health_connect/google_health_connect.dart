import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/provider/data_converter.dart';
import 'package:wearable_health/provider/enums/datastore_availability.dart';
import 'package:wearable_health/provider/health_connect/data/health_connect_data_type.dart';
import 'package:wearable_health/provider/health_connect/enums/method_type.dart';
import 'package:wearable_health/provider/health_data.dart';
import 'package:wearable_health/provider/provider.dart';

class GoogleHealthConnect implements Provider {
  final methodChannel = MethodChannel("wearable_health");
  List<HealthConnectDataType> dataTypes;

  GoogleHealthConnect(this.dataTypes);

  @override
  Future<String> getPlatformVersion() async {
    final platformVersion = await methodChannel.invokeMethod<String>(
      MethodType.getPlatformVersion.value,
    );
    return platformVersion ?? "";
  }

  @override
  Future<bool> requestPermissions() async {
    List<String> dataTypeStrings = _dataTypesToStrings(dataTypes);

    final result = await methodChannel.invokeMethod<bool>(
      MethodType.requestPermissions.value,
      {'permissions': dataTypeStrings},
    );
    return result ?? false;
  }

  @override
  Future<bool> hasPermissions() async {
    List<String> dataTypeStrings = _dataTypesToStrings(dataTypes);

    final result = await methodChannel.invokeMethod<bool>("hasPermissions", {
      'permissions': dataTypeStrings,
    });
    return result ?? false;
  }

  @override
  Future<DataStoreAvailability> checkDataStoreAvailability() async {
    final result = await methodChannel.invokeMethod<String>(
      MethodType.dataStoreAvailability.value,
    );
    return DataStoreAvailability.fromString(result ?? "unkown");
  }

  @override
  Future<List<HealthData>> getData(
    DateTimeRange range,
    DataConverter? converter,
  ) async {
    final allData = await methodChannel.invokeMethod<List<Map<String, String>>>(
      MethodType.getData.value,
      {'start': range.start.toString(), 'end': range.end.toString()},
    );

    if (converter != null) {
      List<Map<String, String>> converted = [];
      for (final rawDataPoint in allData!) {
        converted.add(converter.convertData(rawDataPoint));
      }
      return converted;
    }

    return allData ?? <HealthData>[];
  }

  List<String> _dataTypesToStrings(List<HealthConnectDataType> dataTypes) {
    List<String> result = [];

    for (final dataType in dataTypes) {
      result.add(dataType.toString());
    }

    return result;
  }
}
