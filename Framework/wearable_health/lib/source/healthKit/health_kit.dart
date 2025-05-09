import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/constants.dart';
import 'package:wearable_health/dto/health_data_response.dart';
import 'package:wearable_health/source/healthKit/data/dto/hk_heart_rate.dart';
import 'package:wearable_health/source/healthKit/data/health_kit_data.dart';
import 'package:wearable_health/source/healthKit/hk_health_metric.dart';
import 'package:wearable_health/source/health_source_availability.dart';


class HealthKit  {
  final methodChannel = MethodChannel("wearable_health");

  Future<HealthSourceAvailability> checkHealthStoreAvailability() async {
    final result = await methodChannel.invokeMethod(
      "$healthKitPrefix/$checkDataStoreAvailabilitySuffix",
    );

    if (result == null) {
      throw Exception("[HealthKit] checkHealthStoreAvailability received null result");
    }

    return HealthSourceAvailability.fromString(result);
  }

  Future<List<HealthKitData>> getData(List<HealthKitHealthMetric> metrics, DateTimeRange timeRange) async {
    final start = timeRange.start.toUtc().toIso8601String();
    final end = timeRange.end.toUtc().toIso8601String();
    List<String> types = [];
    for (final metric in metrics) {
      types.add(metric.definition);
    }

    Map<String, List<dynamic>>? response = await methodChannel.invokeMapMethod(
      "$healthKitPrefix/$getDataSuffix",
      {"start": start, "end": end, "types": types},
    );

    if (response == null) {
      throw Exception("[HealthKit] getData returned null");
    }

    List<HealthKitData> result = _convertToHealthKitData(response);
    return result;
  }

  List<HealthKitData> _convertToHealthKitData(
      Map<String, List<dynamic>> response,
      ) {
    List<HealthKitData> result = [];
    var healthDataResponse = HealthDataResponse.fromMap(response);
    healthDataResponse.data.forEach((key, value) {
      var healthMetric = HealthKitHealthMetric.fromString(key);
      if (healthMetric == HealthKitHealthMetric.heartRate) {
        for (final element in value) {
          print(element);
          var hkHeartRate = HKHeartRate.fromJson(element);
          result.add(hkHeartRate);
        }
      } else if (healthMetric == HealthKitHealthMetric.bodyTemperature) {
        // Convert to DTO
        for (final element in value) {
          log(element.toString());
        }
        throw UnimplementedError("BodyTemperature not implemented");
      } else {
        throw UnimplementedError("[HealthKit] Failed to convert: $key into HealthKitData type");
      }
    });

    return result;
  }

  Future<String> getPlatformVersion() async {
    String version = await methodChannel.invokeMethod(
      "$healthKitPrefix/$platformVersionSuffix",
    );
    return version;
  }

  Future<bool> requestPermissions(List<HealthKitHealthMetric> metrics) async {
    List<String> definitions = [];
    for (final metric in metrics) {
      definitions.add(metric.definition);
    }

    final bool? response = await methodChannel.invokeMethod(
      "$healthKitPrefix/$requestPermissionsSuffix",
      {"types": definitions},
    );

    if (response == null) {
      throw Exception("[HealthKit] requestPermissions returned null");
    }

    return response;
  }
}