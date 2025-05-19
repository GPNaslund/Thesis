// lib/services/metric_fetches/skin_temperature.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_skin_temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature.dart';

Future<List<dynamic>> fetchSkinTemperatureData({
  required dynamic provider,
  required bool isAndroid,
  required DateTimeRange range,
  required bool convert,
}) async {
  final platformMetric = HealthConnectHealthMetric.skinTemperature;
  if (!isAndroid) return [];

  if (convert) {
    // this code take the baseline metric from raw, bad code. Fix in if plugin updates
    return await _fetchAndPatchSkinTemperature(provider, platformMetric, range);
  } else {
    final HealthData raw = await provider.getRawData([platformMetric], range);
    return [raw.data];
  }
}

/// BAD CODE: Might fix later if plugin updates
/// This method patches baseline temperature from raw data.
Future<List<dynamic>> _fetchAndPatchSkinTemperature(
    dynamic provider,
    HealthConnectHealthMetric platformMetric,
    DateTimeRange range,
    ) async {
  final data = await provider.getData([platformMetric], range);
  final HealthData raw = await provider.getRawData([platformMetric], range);
  final rawList = raw.data[platformMetric.value];

  if (rawList == null) {
    debugPrint("⚠️ Raw data is null for $platformMetric");
    return [];
  }

  if (rawList.length != data.length) {
    debugPrint("⚠️ Raw and typed data length mismatch!");
  }

  final combined = <HealthConnectSkinTemperature>[];

  for (int i = 0; i < data.length; i++) {
    final typed = data[i] as HealthConnectSkinTemperature;
    final rawEntry = rawList[i] as Map<String, dynamic>;

    if (rawEntry.containsKey('baselineCelsius')) {
      final double celsius = rawEntry['baselineCelsius'];
      final double fahrenheit = (celsius * 9 / 5) + 32;
      typed.baseline = Temperature(celsius, fahrenheit);
    }

    combined.add(typed);
    debugPrint('🧪 patched baseline = ${typed.baseline?.inCelsius}, deltas = ${typed.deltas.length}');
  }

  return combined.expand((e) => e.toOpenMHealthBodyTemperature()).toList();
}
