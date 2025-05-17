import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import '../constants/metrics.dart';
import '../constants/metrics_mapper.dart';
import 'package:wearable_health/model/health_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'metric_filters/heart_rate.dart';
import 'metric_filters/heart_rate_variability.dart';
import 'metric_filters/skin_temperature.dart';

// Import modular metric-specific handlers
import 'metric_fetches/heart_rate.dart';
import 'metric_fetches/heart_rate_variability.dart';
import 'metric_fetches/skin_temperature.dart';

/// Central service for interacting with the wearable_health plugin
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
    } catch (_) {
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
    switch (metric) {
      case HealthMetric.heartRate:
        return await fetchHeartRateData(
          provider: _provider,
          isAndroid: _isAndroid,
          range: range,
          convert: convert,
        );
      case HealthMetric.heartRateVariability:
        return await fetchHeartRateVariabilityData(
          provider: _provider,
          isAndroid: _isAndroid,
          range: range,
          convert: convert,
        );
      case HealthMetric.skinTemperature:
        return await fetchSkinTemperatureData(
          provider: _provider,
          isAndroid: _isAndroid,
          range: range,
          convert: convert,
        );
      default:
        return [];
    }
  }
}
