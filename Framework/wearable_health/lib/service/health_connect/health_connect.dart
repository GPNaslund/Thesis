import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/constants.dart';
import 'package:wearable_health/model/health_connect/enums/hc_availability.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_connect/health_connect_interface.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';

import '../../model/health_data.dart';

/// Implementation of HealthConnect interface for accessing health data from Android devices.
/// Handles communication with the native Health Connect API through method channels.
class HealthConnectImpl implements HealthConnect {
  /// Channel for communication with native Android Health Connect API.
  MethodChannel methodChannel;

  /// Factory for creating Health Connect data objects from JSON responses.
  HCDataFactory dataFactory;

  /// Utility for safely converting JSON data structures.
  JsonConverter jsonConverter;

  /// Creates a new HealthConnect implementation with required dependencies.
  HealthConnectImpl(this.methodChannel, this.dataFactory, this.jsonConverter);

  /// Queries current permission status for Health Connect metrics.
  /// Returns a list of metrics that are currently permitted.
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

  /// Retrieves health data for specified metrics within the given time range.
  /// Returns a list of typed health data objects (heart rate, skin temperature, etc.).
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

  /// Converts raw JSON response from the platform to typed HealthConnectData objects.
  /// Handles different metric types and creates appropriate data objects.
  List<HealthConnectData> _convertToHealthConnectData(
    Map<String, List<dynamic>> response,
  ) {
    List<HealthConnectData> result = [];

    var rawData = jsonConverter.extractJsonObjectWithListOfJsonObjects(
      response,
      "Error when extracting data for health data creation",
    );

    HealthData healthData = HealthData(rawData);

    healthData.data.forEach((key, value) {
      var healthMetric = HealthConnectHealthMetric.fromString(key);
      if (healthMetric == HealthConnectHealthMetric.heartRate) {
        for (final element in value) {
          var heartRate = dataFactory.createHeartRate(element);
          result.add(heartRate);
        }
      } else if (healthMetric == HealthConnectHealthMetric.skinTemperature) {
        for (final element in value) {
          var skinTemp = dataFactory.createSkinTemperature(element);
          result.add(skinTemp);
        }
      } else if (healthMetric ==
          HealthConnectHealthMetric.heartRateVariability) {
        for (final element in value) {
          var heartRateVariability = dataFactory.createHeartRateVariability(
            element,
          );
          result.add(heartRateVariability);
        }
      } else {
        throw UnimplementedError(
          "[HealthConnect] Failed to convert: $key into a HealthConnect data type",
        );
      }
    });

    return result;
  }

  /// Retrieves the platform version of the Android device.
  @override
  Future<String> getPlatformVersion() async {
    String version = await methodChannel.invokeMethod(
      "$healthConnectPrefix/$platformVersionSuffix",
    );
    return version;
  }

  /// Requests permissions for the specified health metrics.
  /// Returns a list of metrics that were granted permission.
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

  /// Checks if Health Connect is available and accessible on the device.
  /// Returns an availability status indicating if Health Connect can be used.
  @override
  Future<HealthConnectAvailability> checkHealthStoreAvailability() async {
    final result = await methodChannel.invokeMethod(
      "$healthConnectPrefix/$checkDataStoreAvailabilitySuffix",
    );

    if (result == null) {
      throw Exception(
        "[HealthConnect] checkHealthStoreAvailability received null result",
      );
    }

    return HealthConnectAvailability.fromString(result);
  }
}
