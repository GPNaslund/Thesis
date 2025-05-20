// lib/services/metric_handlers/heart_rate_variability.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import '../metric_filters/heart_rate.dart';

List<String> handleHeartRateData({
  required List<dynamic> data,
  required DateTimeRange range,
  required bool useConverter,
  required void Function(String) onStatusUpdate,
}) {
  List<String> results = [];

  if (useConverter) {
    final filtered = filterOpenMHealthHeartRate(
      entries: data.cast<OpenMHealthHeartRate>(),
      range: range,
    );

    results = filtered.map((entry) {
      return const JsonEncoder.withIndent('  ').convert(entry.toJson());
    }).toList();

    onStatusUpdate('Fetched ${results.length} Open mHealth records');
  } else {
    final filteredMap = filterRawHeartRate(
      rawEntries: data,
      range: range,
    );

    results = [
      const JsonEncoder.withIndent('  ').convert(filteredMap),
    ];

    onStatusUpdate('Fetched ${results.length} raw entry with ${_countAllRecords(filteredMap)} record(s)');
  }

  return results;
}

int _countAllRecords(Map<String, List<Map<String, dynamic>>> map) {
  return map.values.fold(0, (sum, list) => sum + list.length);
}
