// lib/services/metric_filters/skin_temperature.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';

/// Filter OpenMHealth skin temperature entries based on a DateTimeRange.
List<OpenMHealthBodyTemperature> filterOpenMHealthSkinTemperature({
  required List<OpenMHealthBodyTemperature> entries,
  required DateTimeRange range,
}) {
  final filtered = entries.where((entry) {
    final time = entry.effectiveTimeFrame.dateTime;
    if (time == null) return false;
    return time.isAfter(range.start) && time.isBefore(range.end);
  }).toList();

  filtered.sort((a, b) {
    final t1 = a.effectiveTimeFrame.dateTime;
    final t2 = b.effectiveTimeFrame.dateTime;
    if (t1 == null || t2 == null) return 0;
    return t1.compareTo(t2);
  });

  return filtered;
}

Map<String, List<Map<String, dynamic>>> filterRawSkinTemperature({
  required List<dynamic> rawEntries,
  required DateTimeRange range,
}) {
  if (rawEntries.isEmpty) return {};

  final Map<String, List<Map<String, dynamic>>> filtered = {};

  for (var entry in rawEntries) {
    if (entry is Map<String, dynamic>) {
      for (var permissionKey in entry.keys) {
        final records = entry[permissionKey];
        if (records is List) {
          final List<Map<String, dynamic>> trimmed = [];

          for (var record in records) {
            if (record is Map<String, dynamic> && record['deltas'] is List) {
              final deltas = record['deltas'] as List;

              final matchingDeltas = deltas.where((delta) {
                final timeStr = delta['time'];
                final parsedTime = DateTime.tryParse(timeStr ?? '');
                return parsedTime != null &&
                    parsedTime.isAfter(range.start) &&
                    parsedTime.isBefore(range.end);
              }).toList();

              /// Sort deltas by time
              matchingDeltas.sort((a, b) {
                final t1 = DateTime.tryParse(a['time'] ?? '');
                final t2 = DateTime.tryParse(b['time'] ?? '');
                if (t1 == null || t2 == null) return 0;
                return t1.compareTo(t2);
              });

              if (matchingDeltas.isNotEmpty) {
                final trimmedRecord = Map<String, dynamic>.from(record);
                trimmedRecord['deltas'] = matchingDeltas;
                trimmed.add(trimmedRecord);
              }
            }
          }

          /// Sort records by first delta time
          trimmed.sort((a, b) {
            final t1 = DateTime.tryParse((a['deltas']?[0]?['time']) ?? '');
            final t2 = DateTime.tryParse((b['deltas']?[0]?['time']) ?? '');
            if (t1 == null || t2 == null) return 0;
            return t1.compareTo(t2);
          });

          if (trimmed.isNotEmpty) {
            filtered[permissionKey] = trimmed;
          }
        }
      }
    }
  }

  debugPrint('✅ Filtered and sorted records under ${filtered.length} permission keys');
  return filtered;
}

