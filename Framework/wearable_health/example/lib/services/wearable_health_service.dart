// lib/services/wearable_health_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import '../constants/metrics.dart';
import '../constants/metrics_mapper.dart';
import 'package:wearable_health/model/health_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_skin_temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';

/// Service for interacting with the wearable health plugin
class WearableHealthService {
  /// Holds the correct provider depending on platform (Google or Apple)
  late final dynamic _provider;
  /// Boolean flag to determine if platform is Android
  final bool _isAndroid = Platform.isAndroid;

  /// Constructor that initializes the provider based on platform
  WearableHealthService() {
    _provider = _isAndroid
    /// android
        ? WearableHealth().getGoogleHealthConnect()
    ///ios
        : WearableHealth().getAppleHealthKit();
  }

  /// Returns the platform version string
  Future<String> getPlatformVersion() async {
    try {
      return await _provider.getPlatformVersion();
    } catch (e) {
      return 'Failed to get platform version';
    }
  }

  /// Requests permissions for a list of HealthMetric items
  Future<void> requestPermissions(List<HealthMetric> metrics) async {
    /// Convert each app metric to the correct platform-specific enum
    final platformMetrics = metrics
        .map((m) => mapMetricToPlatformMetric(m, isAndroid: _isAndroid))
        .where((m) => m != null)
        .toList();

    /// Cast and request permissions based on platform
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

  /// Fetches health data for a given metric and time range
  Future<List<dynamic>> getHealthData(
      HealthMetric metric,
      DateTimeRange range, {
        bool convert = false,
      }) async {
    /// Map the generic metric to its platform-specific version
    final platformMetric =
    mapMetricToPlatformMetric(metric, isAndroid: _isAndroid);
    if (platformMetric == null) return [];

    /// Handle Android (Health Connect) case
    if (_isAndroid) {
      if (convert) {
        /// Fetch and convert data to OpenMHealth format
        final data = await _provider.getData(
          [platformMetric as HealthConnectHealthMetric],
          range,
        );

        /// Convert each entry based on its runtime type
        return (data as List).expand((entry) {
          if (entry is HealthConnectHeartRate) {
            return entry.toOpenMHealthHeartRate();
          } else if (entry is HealthConnectSkinTemperature) {
            return entry.toOpenMHealthBodyTemperature();
          } else if (entry is HealthConnectHeartRateVariabilityRmssd) {
            return entry.toOpenMHealthHeartRateVariabilityRmssd();
          } else {
            return [];
          }
        }).toList();
      } else {
        /// Else fetch raw data from Health Connect
        final HealthData raw = await _provider.getRawData(
          [platformMetric as HealthConnectHealthMetric],
          range,
        );
        /// Returns raw data list
        return [raw.data];
      }
    } else {
      /// Handle iOS (HealthKit) case
      final data = await _provider.getData(
        [platformMetric as HealthKitHealthMetric],
        range,
      );
      /// Return data as OpenMHealth format or raw
      return convert
          ? (data as List).expand((entry) => entry.toOpenMHealth()).toList()
          : data;
    }
  }

}
