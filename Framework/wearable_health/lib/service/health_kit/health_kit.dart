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

/// Implementation of HealthKit interface for accessing health data from iOS devices.
/// Handles communication with the native HealthKit API through method channels.
class HealthKitImpl implements HealthKit {
  /// Channel for communication with native iOS HealthKit API.
  MethodChannel methodChannel;

  /// Factory for creating HealthKit data objects from JSON responses.
  HKDataFactory dataFactory;

  /// Utility for safely converting JSON data structures.
  JsonConverter jsonConverter;

  /// Creates a new HealthKit implementation with required dependencies.
  HealthKitImpl(this.methodChannel, this.dataFactory, this.jsonConverter);

  /// Checks if HealthKit is available and accessible on the device.
  /// Returns an availability status indicating if HealthKit can be used.
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

  /// Retrieves health data for specified metrics within the given time range.
  /// Returns a list of typed health data objects (heart rate, body temperature, etc.).
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

  /// Converts raw JSON response from the platform to typed HealthKitData objects.
  /// Handles different metric types and creates appropriate data objects.
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
      } else if (healthMetric == HealthKitHealthMetric.heartRateVariability) {
        for (final element in value) {
          log(element.toString());
          var hkHeartRateVariability = dataFactory.createHeartRateVariability(element);
          result.add(hkHeartRateVariability);
        }
      } else {
        throw UnimplementedError(
          "[HealthKit] Failed to convert: $key into HealthKitData type",
        );
      }
    });

    return result;
  }

  /// Retrieves the platform version of the iOS device.
  @override
  Future<String> getPlatformVersion() async {
    String version = await methodChannel.invokeMethod(
      "$healthKitPrefix/$platformVersionSuffix",
    );
    return version;
  }

  /// Requests permissions for the specified health metrics.
  /// Returns a boolean indicating if all permissions were granted.
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
