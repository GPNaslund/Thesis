// lib/services/metric_handlers/heart_rate_variability.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import '../metric_filters/heart_rate_variability.dart';

/// Handles HRV data: filtering, sorting, and formatting for display.
List<String> handleHeartRateVariabilityData({
  required List<dynamic> data,
  required DateTimeRange range,
  required bool useConverter,
  required void Function(String) onStatusUpdate,
}) {
  List<String> results = [];

  if (useConverter) {
    final filtered = data
        .cast<OpenMHealthHeartRateVariability>()
        .where((entry) {
      final time = entry.effectiveTimeFrame.dateTime;
      return time != null &&
          time.isAfter(range.start) &&
          time.isBefore(range.end);
    })
        .toList();

    filtered.sort((a, b) {
      final t1 = a.effectiveTimeFrame.dateTime;
      final t2 = b.effectiveTimeFrame.dateTime;
      if (t1 == null || t2 == null) return 0;
      return t1.compareTo(t2);
    });

    results = filtered.map((entry) {
      return const JsonEncoder.withIndent('  ').convert(entry.toJson());
    }).toList();

    onStatusUpdate('Fetched ${results.length} Open mHealth records');
  } else {
    final filteredMap = filterRawHeartRateVariability(
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
  return map.values.fold(0, (total, list) => total + list.length);
}

