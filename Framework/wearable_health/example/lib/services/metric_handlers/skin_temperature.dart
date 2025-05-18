// lib/services/metric_handlers/skin_temperature.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import '../metric_filters/skin_temperature.dart';

/// Handles skin temperature data: filtering, sorting, and formatting that is used for displaying data
List<String> handleSkinTemperatureData({
  required List<dynamic> data,
  required DateTimeRange range,
  required bool useConverter,
  required void Function(String) onStatusUpdate,
}) {
  List<String> results = [];

  if (useConverter) {
    // OpenMHealth formatted filtering and sorting
    final filtered = filterOpenMHealthSkinTemperature(
      entries: data.cast<OpenMHealthBodyTemperature>(),
      range: range,
    );

    results = filtered.map((entry) {
      final json = entry.toJson();

      // Optional: override timestamp string to show local time
      final dt = entry.effectiveTimeFrame.dateTime;
      if (dt != null) {
        json['effective_time_frame']['date_time'] = dt.toLocal().toIso8601String();
      }

      return const JsonEncoder.withIndent('  ').convert(json);
    }).toList();

    onStatusUpdate('Fetched ${filtered.length} entries');
  } else {
    // Raw record filtering and sorting
    final filteredMap = filterRawSkinTemperature(
      rawEntries: data,
      range: range,
    );

    results = [
      const JsonEncoder.withIndent('  ').convert(filteredMap),
    ];

    onStatusUpdate('Fetched ${_countAllRecords(filteredMap)} record(s)');
  }

  return results;
}

int _countAllRecords(Map<String, List<Map<String, dynamic>>> map) {
  return map.values.fold(0, (total, list) => total + list.length);
}
