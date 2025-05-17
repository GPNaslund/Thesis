// lib/services/metric_fetches/skin_temperature.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_skin_temperature.dart';

Future<List<dynamic>> fetchSkinTemperatureData({
  required dynamic provider,
  required bool isAndroid,
  required DateTimeRange range,
  required bool convert,
}) async {
  final platformMetric = HealthConnectHealthMetric.skinTemperature;
  if (!isAndroid) return [];

  if (convert) {
    final data = await provider.getData([platformMetric], range);
    return (data as List)
        .expand((e) => (e as HealthConnectSkinTemperature).toOpenMHealthBodyTemperature())
        .toList();
  } else {
    final HealthData raw = await provider.getRawData([platformMetric], range);
    return [raw.data];
  }
}
