import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/constants.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/health_data_source.dart';
import 'package:wearable_health/source/health_source_availability.dart';

class HealthConnect
    extends HealthDataSource<HealthConnectHealthMetric, HealthConnectData> {
  final methodChannel = MethodChannel(methodChannelName);

  @override
  Future<List<HealthConnectHealthMetric>> checkPermissions(
    List<HealthConnectHealthMetric> metrics,
  ) async {
    List<String> types = [];
    for (final element in metrics) {
      types.add(element.definition);
    }

    List<String> response = await methodChannel.invokeMethod(
      "$healthConnectPrefix/$checkPermissionsSuffix",
      {"types": types},
    );

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

    Map<String, dynamic>? response = await methodChannel.invokeMapMethod(
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
    Map<String, dynamic> response,
  ) {
    List<HealthConnectData> result = [];
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
      definitions.add(metric.value);
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
      throw Exception("[checkDataStoreAvailability] received null result");
    }

    return HealthSourceAvailability.fromString(result);
  }
}
