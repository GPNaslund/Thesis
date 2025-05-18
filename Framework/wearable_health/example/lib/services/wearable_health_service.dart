import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import '../constants/metrics.dart';
import '../constants/metrics_mapper.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
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

  Future<bool> redirectToPermissionsSettings() async {
    if (_isAndroid) {
      try {
        return await _provider.redirectToPermissionsSettings();
      } catch (e) {
        debugPrint('⚠️ Failed to redirect to settings: $e');
        return false;
      }
    } else {
      debugPrint('ℹ️ redirectToPermissionsSettings is not supported on iOS.');
      return false;
    }
  }

  Future<dynamic> getFirstRecordRaw(HealthMetric metric) async {
    final now = DateTime.now();
    final range = DateTimeRange(
      start: now.subtract(const Duration(days: 0, hours: 0, minutes: 20)),
      end: now,
    );

    debugPrint('🔍 Fetching first record for metric: $metric');
    debugPrint('📅 Time range: ${range.start} → ${range.end}');

    final data = await getHealthData(metric, range, convert: false);

    debugPrint('📦 Retrieved ${data.length} entries');

    if (data.isEmpty) {
      debugPrint('⚠️ No data found for the given range.');
      return null;
    }

    final first = data.first;
    debugPrint('🧪 First record:\n${const JsonEncoder.withIndent('  ').convert(first)}');

    if (metric == HealthMetric.skinTemperature &&
        first is Map<String, dynamic> &&
        first.containsKey('deltas')) {
      final deltas = first['deltas'];
      if (deltas is List && deltas.isNotEmpty) {
        debugPrint('📏 First delta inside record:\n${const JsonEncoder.withIndent('  ').convert(deltas.first)}');
      } else {
        debugPrint('📭 No deltas found inside first record.');
      }
    }

    return first;
  }

  Future<List<dynamic>> getAllOpenMHealthRecords(HealthMetric metric) async {
    final now = DateTime.now();
    final range = DateTimeRange(
      start: now.subtract(const Duration(minutes: 20)),
      end: now,
    );

    debugPrint('🔍 Fetching OpenMHealth records for metric: $metric');
    debugPrint('📅 Time range: ${range.start} → ${range.end}');

    final data = await getHealthData(metric, range, convert: true);

    debugPrint('📦 Retrieved ${data.length} OpenMHealth entries');

    if (data.isEmpty) {
      debugPrint('⚠️ No OpenMHealth data found for the given range.');
      return [];
    }

    for (int i = 0; i < data.length; i++) {
      try {
        final entry = data[i];
        final jsonString = const JsonEncoder.withIndent('  ').convert(
          entry.toJson(), // Assuming OpenMHealth models implement `.toJson()`
        );
        debugPrint('🧪 Entry [$i]:\n$jsonString');
      } catch (e) {
        debugPrint('⚠️ Failed to serialize entry [$i]: $e');
      }
    }

    return data;
  }

  /*  Future<dynamic> getFirstOpenMHealthRecord(HealthMetric metric) async {
    final now = DateTime.now();
    final range = DateTimeRange(
      start: now.subtract(const Duration(days: 0, hours: 0, minutes: 20)),
      end: now,
    );

    debugPrint('🔍 Fetching first OpenMHealth record for metric: $metric');
    debugPrint('📅 Time range: ${range.start} → ${range.end}');

    final data = await getHealthData(metric, range, convert: true);

    debugPrint('📦 Retrieved ${data.length} OpenMHealth entries');

    if (data.isEmpty) {
      debugPrint('⚠️ No OpenMHealth data found for the given range.');
      return null;
    }

    final first = data.first;

    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(
        first.toJson(), // This assumes all OpenMHealth models implement .toJson()
      );
      debugPrint('🧪 First OpenMHealth record:\n$jsonString');
    } catch (e) {
      debugPrint('⚠️ Failed to serialize first OpenMHealth record: $e');
    }

    return first;
  }
 */


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
