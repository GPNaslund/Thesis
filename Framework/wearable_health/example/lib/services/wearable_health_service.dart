// lib/services/wearable_health_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearable_health/provider/health_data.dart';
import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/provider/dto/get_data_request.dart';
import 'package:wearable_health/provider/dto/request_permissions_request.dart';
import 'package:wearable_health/provider/enums/health_data_type.dart';
import '../constants/metrics.dart';
import '../constants/metric_mapper.dart';

typedef PermissionResult = ({bool allGranted, List<HealthMetric> grantedMetrics});

typedef HealthDataMap = Map<String, String>;

class WearableHealthService {
  late final Provider _provider;

  WearableHealthService() {
    _provider = Platform.isAndroid
        ? WearableHealth.getGoogleHealthConnect()
        : WearableHealth.getAppleHealthKit();
  }

  Future<String> getPlatformVersion() async {
    try {
      return await _provider.getPlatformVersion();
    } catch (e) {
      return 'Failed to get platform version';
    }
  }

  Future<PermissionResult> requestPermissions(List<HealthMetric> metrics) async {
    final types = metrics
        .map(mapMetricToHealthDataType)
        .whereType<HealthDataType>()
        .toList();

    final request = RequestPermissionsRequest(types);
    final result = await _provider.requestPermissions(request);

    final grantedMetrics = metrics.where((m) =>
        result.permissions.contains(mapMetricToHealthDataType(m))
    ).toList();

    final allGranted = grantedMetrics.length == metrics.length;
    return (allGranted: allGranted, grantedMetrics: grantedMetrics);
  }

  Future<List<HealthData>> getHealthData(
      HealthMetric metric,
      DateTimeRange range,
      {bool convert = false}
      ) async {
    final type = mapMetricToHealthDataType(metric);
    if (type == null) return [];

    final request = GetDataRequest(
      range,
      [type],
      converter: null,
    );

    try {
      final response = await _provider.getData(request);
      return response.result;
    } catch (e) {
      return [];
    }
  }
}
