import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/constants.dart';
import 'package:wearable_health/model/health_data.dart';
import 'package:wearable_health/model/health_kit/enums/hk_availability.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/health_kit_interface.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

class HealthKitImpl implements HealthKit {
  MethodChannel methodChannel;
  HKDataFactory dataFactory;
  JsonConverter jsonConverter;

  HealthKitImpl(this.methodChannel, this.dataFactory, this.jsonConverter);

  @override
  Future<HealthKitAvailability> checkHealthStoreAvailability() async {
    final result = await methodChannel.invokeMethod(
      "$healthKitPrefix/$checkDataStoreAvailabilitySuffix",
    );

    if (result == null) {
      throw Exception(
        "[HealthKit] checkHealthStoreAvailability received null result",
      );
    }

    return HealthKitAvailability.fromString(result);
  }

  @override
  Future<List<HealthKitData>> getData(
    List<HealthKitHealthMetric> metrics,
    DateTimeRange timeRange,
  ) async {
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
    var errMsg = "Error occured when creating health kit data";
    List<HealthKitData> result = [];
    var healthData = jsonConverter.extractJsonObjectWithListOfJsonObjects(
      response,
      errMsg,
    );
    var healthDataResponse = HealthData(healthData);
    healthDataResponse.data.forEach((key, value) {
      var healthMetric = HealthKitHealthMetric.fromString(key);
      if (healthMetric == HealthKitHealthMetric.heartRate) {
        for (final element in value) {
          var hkHeartRate = dataFactory.createHeartRate(element);
          result.add(hkHeartRate);
        }
      } else if (healthMetric == HealthKitHealthMetric.bodyTemperature) {
        for (final element in value) {
          log(element.toString());
          var hkBodyTemperature = dataFactory.createBodyTemperature(element);
          result.add(hkBodyTemperature);
        }
      } else {
        throw UnimplementedError(
          "[HealthKit] Failed to convert: $key into HealthKitData type",
        );
      }
    });

    return result;
  }

  @override
  Future<String> getPlatformVersion() async {
    String version = await methodChannel.invokeMethod(
      "$healthKitPrefix/$platformVersionSuffix",
    );
    return version;
  }

  @override
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
