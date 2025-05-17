// lib/services/metric_fetches/heart_rate_variability.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';

Future<List<dynamic>> fetchHeartRateVariabilityData({
  required dynamic provider,
  required bool isAndroid,
  required DateTimeRange range,
  required bool convert,
}) async {
  final platformMetric = HealthConnectHealthMetric.heartRateVariability;
  if (!isAndroid) return [];

  if (convert) {
    final data = await provider.getData([platformMetric], range);
    return (data as List)
        .expand((e) => (e as HealthConnectHeartRateVariabilityRmssd)
        .toOpenMHealthHeartRateVariabilityRmssd())
        .toList();
  } else {
    final HealthData raw = await provider.getRawData([platformMetric], range);
    return [raw.data];
  }
}