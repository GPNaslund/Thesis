import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/constants.dart';
import 'package:wearable_health/dto/health_data_response.dart';
import 'package:wearable_health/source/healthConnect/data/dto/heart_rate.dart';
import 'package:wearable_health/source/healthConnect/data/dto/skin_temperature.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/health_data_source.dart';
import 'package:wearable_health/source/health_source_availability.dart';

class HealthConnect
    extends HealthDataSource<HealthConnectHealthMetric, HealthConnectData> {
  final methodChannel = MethodChannel("wearable_health");

  @override
  Future<List<HealthConnectHealthMetric>> checkPermissions() async {
    List<String>? response = await methodChannel.invokeListMethod(
      "$healthConnectPrefix/$checkPermissionsSuffix",
    );

    if (response == null) {
      throw Exception("[HealthConnect] checkPermissions returned null");
    }

    List<HealthConnectHealthMetric> result = [];
    for (final element in response) {
      result.add(HealthConnectHealthMetric.fromString(element));
    }

    return result;
  }

  @override
  Future<List<HealthConnectData>> getData(
    List<HealthConnectHealthMetric> metrics,
    DateTimeRange timeRange,
  ) async {
    final start = timeRange.start.toUtc().toIso8601String();
    final end = timeRange.end.toUtc().toIso8601String();
    List<String> types = [];
    for (final metric in metrics) {
      types.add(metric.definition);
    }

    Map<String, List<dynamic>>? response = await methodChannel.invokeMapMethod(
      "$healthConnectPrefix/$getDataSuffix",
      {"start": start, "end": end, "types": types},
    );

    if (response == null) {
      throw Exception("[HealthConnect] getData returned null");
    }

    List<HealthConnectData> result = _convertToHealthConnectData(response);
    return result;
  }

  List<HealthConnectData> _convertToHealthConnectData(
    Map<String, List<dynamic>> response,
  ) {
    List<HealthConnectData> result = [];
    var healthDataResponse = HealthDataResponse.fromMap(response);
    healthDataResponse.data.forEach((key, value) {
      var healthMetric = HealthConnectHealthMetric.fromString(key);
      if (healthMetric == HealthConnectHealthMetric.heartRate) {
        for (final element in value) {
          var heartRate = HealthConnectHeartRate.fromMap(element);
          result.add(heartRate);
        }
      } else if (healthMetric == HealthConnectHealthMetric.skinTemperature) {
        for (final element in value) {
          var skinTemp = HealthConnectSkinTemperature.fromMap(element);
          result.add(skinTemp);
        }
      } else {
        throw UnimplementedError(
          "[HealthConnect] Failed to convert: $key into a HealthConnect data type",
        );
      }
    });

    return result;
  }

  @override
  Future<String> getPlatformVersion() async {
    String version = await methodChannel.invokeMethod(
      "$healthConnectPrefix/$platformVersionSuffix",
    );
    return version;
  }

  @override
  Future<List<HealthConnectHealthMetric>> requestPermissions(
    List<HealthConnectHealthMetric> metrics,
  ) async {
    List<String> definitions = [];
    for (final metric in metrics) {
      definitions.add(metric.definition);
    }

    final List<String>? response = await methodChannel.invokeListMethod(
      "$healthConnectPrefix/$requestPermissionsSuffix",
      {"types": definitions},
    );

    if (response == null) {
      throw Exception("[HealthConnect] requestPermissions returned null");
    }

    List<HealthConnectHealthMetric> result = [];
    for (final element in response) {
      final permitted = HealthConnectHealthMetric.fromString(element);
      result.add(permitted);
    }

    return result;
  }

  @override
  Future<HealthSourceAvailability> checkHealthStoreAvailability() async {
    final result = await methodChannel.invokeMethod(
      "$healthConnectPrefix/$checkDataStoreAvailabilitySuffix",
    );

    if (result == null) {
      throw Exception("[HealthConnect] checkHealthStoreAvailability received null result");
    }

    return HealthSourceAvailability.fromString(result);
  }
}
