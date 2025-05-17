import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';

/// Filter OpenMHealth skin temperature entries based on a DateTimeRange.
List<OpenMHealthBodyTemperature> filterOpenMHealthSkinTemperature({
  required List<OpenMHealthBodyTemperature> entries,
  required DateTimeRange range,
}) {
  return entries.where((entry) {
    final time = entry.effectiveTimeFrame.dateTime;
    if (time == null) return false; // 🔐 safe null check

    return time.isAfter(range.start) && time.isBefore(range.end);
  }).toList();
}

List<Map<String, dynamic>> filterRawSkinTemperatureWithTrimmedDeltas({
  required List<dynamic> rawEntries,
  required DateTimeRange range,
}) {
  if (rawEntries.isEmpty) return [];

  final List<Map<String, dynamic>> filtered = [];

  for (var entry in rawEntries) {
    if (entry is Map<String, dynamic>) {
      for (var value in entry.values) {
        if (value is List) {
          for (var record in value) {
            if (record is Map<String, dynamic> && record['deltas'] is List) {
              final deltas = record['deltas'] as List;

              final matchingDeltas = deltas.where((delta) {
                final timeStr = delta['time'];
                final parsedTime = DateTime.tryParse(timeStr ?? '');
                return parsedTime != null &&
                    parsedTime.isAfter(range.start) &&
                    parsedTime.isBefore(range.end);
              }).toList();

              if (matchingDeltas.isNotEmpty) {
                // Clone the original record and replace only the deltas field
                final trimmedRecord = Map<String, dynamic>.from(record);
                trimmedRecord['deltas'] = matchingDeltas;

                filtered.add(trimmedRecord);
              }
            }
          }
        }
      }
    }
  }

  debugPrint('Filtered ${filtered.length} skin temperature records with trimmed deltas');

  return filtered;
}

