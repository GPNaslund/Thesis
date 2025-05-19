// lib/services/metric_filters/heart_rate_variability.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';

/// Filters OpenMHealth heart rate entries by their time interval start.
List<OpenMHealthHeartRate> filterOpenMHealthHeartRate({
  required List<OpenMHealthHeartRate> entries,
  required DateTimeRange range,
}) {
  final filtered = entries.where((entry) {
    final start = entry.effectiveTimeFrame.timeInterval?.startDateTime;
    return start != null &&
        start.isAfter(range.start) &&
        start.isBefore(range.end);
  }).toList();

  filtered.sort((a, b) {
    final t1 = a.effectiveTimeFrame.timeInterval?.startDateTime;
    final t2 = b.effectiveTimeFrame.timeInterval?.startDateTime;
    if (t1 == null || t2 == null) return 0;
    return t1.compareTo(t2);
  });

  return filtered;
}

/// Filters raw heart rate records by filtering individual samples
/// within each record that fall in the given range.
Map<String, List<Map<String, dynamic>>> filterRawHeartRate({
  required List<dynamic> rawEntries,
  required DateTimeRange range,
}) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};

  for (var entry in rawEntries) {
    if (entry is Map<String, dynamic>) {
      for (var permissionKey in entry.keys) {
        final records = entry[permissionKey];
        if (records is List) {
          final List<Map<String, dynamic>> matchingRecords = [];

          for (var record in records) {
            if (record is Map<String, dynamic>) {
              final samples = record['samples'];
              if (samples is List) {
                final filteredSamples = samples.where((sample) {
                  final timeStr = sample['time'];
                  final parsed = DateTime.tryParse(timeStr ?? '');
                  return parsed != null &&
                      parsed.isAfter(range.start) &&
                      parsed.isBefore(range.end);
                }).toList();

                // Only include the record if it has at least one valid sample
                if (filteredSamples.isNotEmpty) {
                  // Replace the samples list with the filtered one
                  final newRecord = Map<String, dynamic>.from(record);
                  newRecord['samples'] = filteredSamples;

                  // Sort samples by time
                  newRecord['samples'].sort((a, b) {
                    final aTime = DateTime.tryParse(a['time'] ?? '');
                    final bTime = DateTime.tryParse(b['time'] ?? '');
                    if (aTime == null || bTime == null) return 0;
                    return aTime.compareTo(bTime);
                  });

                  matchingRecords.add(newRecord);
                }
              }
            }
          }

          // Sort matching records by first sample time
          matchingRecords.sort((a, b) {
            final aTime = DateTime.tryParse(a['samples']?[0]?['time'] ?? '');
            final bTime = DateTime.tryParse(b['samples']?[0]?['time'] ?? '');
            if (aTime == null || bTime == null) return 0;
            return aTime.compareTo(bTime);
          });

          if (matchingRecords.isNotEmpty) {
            filtered[permissionKey] = matchingRecords;
          }
        }
      }
    }
  }

  return filtered;
}
