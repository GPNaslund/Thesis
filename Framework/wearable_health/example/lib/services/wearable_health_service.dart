// lib/services/wearable_health_service.dart

import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/provider/provider_type.dart';
import 'package:flutter/foundation.dart';
import '../constants/metrics.dart';
import '../constants/metric_mapper.dart';

class WearableHealthService {
  late final Provider _provider;

  WearableHealthService() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _provider = WearableHealth.getDataProvider(ProviderType.googleHealthConnect);
    } else {
      _provider = WearableHealth.getDataProvider(ProviderType.appleHealthKit);
    }
  }

  Future<String> getPlatformVersion() async {
    try {
      final version = await _provider.getPlatformVersion();
      return version;
    } catch (e) {
      return 'Failed to get platform version';
    }
  }

  Future<bool> hasPermission(HealthMetric metric) async {
    final permission = mapMetricToPermission(metric);
    if (permission == null) {
      return false;
    }

    try {
      return await _provider.hasPermissions(permissions: [permission]);
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPermission(HealthMetric metric) async {
    final permission = mapMetricToPermission(metric);
    if (permission == null) {
      return false;
    }

    try {
      return await _provider.requestPermissions(permissions: [permission]);
    } catch (e) {
      return false;
    }
  }
}
