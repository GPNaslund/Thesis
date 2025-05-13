import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import '../constants/metrics.dart';
import '../constants/metrics_mapper.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_data.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_data.dart';


class WearableHealthService {
  late final dynamic _provider;
  final bool _isAndroid = Platform.isAndroid;

  WearableHealthService() {
    _provider = _isAndroid
        ? WearableHealth().getGoogleHealthConnect()
        : WearableHealth().getAppleHealthKit();
  }

  Future<String> getPlatformVersion() async {
    try {
      return await _provider.getPlatformVersion();
    } catch (e) {
      return 'Failed to get platform version';
    }
  }

  Future<void> requestPermissions(List<HealthMetric> metrics) async {
    final platformMetrics = metrics
        .map((m) => mapMetricToPlatformMetric(m, isAndroid: _isAndroid))
        .where((m) => m != null)
        .toList();

    if (_isAndroid) {
      await _provider.requestPermissions(
        platformMetrics.cast<HealthConnectHealthMetric>(),
      );
    } else {
      await _provider.requestPermissions(
        platformMetrics.cast<HealthKitHealthMetric>(),
      );
    }
  }

  Future<List<dynamic>> getHealthData(
      HealthMetric metric,
      DateTimeRange range, {
        bool convert = false,
      }) async {
    final platformMetric = mapMetricToPlatformMetric(metric, isAndroid: _isAndroid);
    if (platformMetric == null) return [];

    final data = _isAndroid
        ? await _provider.getData(
        [platformMetric as HealthConnectHealthMetric], range)
        : await _provider.getData(
        [platformMetric as HealthKitHealthMetric], range);

    if (convert) {
      return (_isAndroid
          ? (data as List<dynamic>).expand((entry) => (entry as HealthConnectData).toOpenMHealth())
          : (data as List<dynamic>).expand((entry) => (entry as HealthKitData).toOpenMHealth())
      ).toList();
    }

    return data;
  }
}
