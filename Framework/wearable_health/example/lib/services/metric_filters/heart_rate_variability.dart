import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';

/// Filters OpenMHealth HRV records by effective time.
List<OpenMHealthHeartRateVariability> filterOpenMHealthHeartRateVariability({
  required List<OpenMHealthHeartRateVariability> entries,
  required DateTimeRange range,
}) {
  final filtered = entries.where((entry) {
    final time = entry.effectiveTimeFrame?.dateTime;
    return time != null &&
        time.isAfter(range.start) &&
        time.isBefore(range.end);
  }).toList();

  filtered.sort((a, b) {
    final t1 = a.effectiveTimeFrame?.dateTime;
    final t2 = b.effectiveTimeFrame?.dateTime;
    if (t1 == null || t2 == null) return 0;
    return t1.compareTo(t2);
  });

  return filtered;
}

/// Filters raw HRV records by time range.
Map<String, List<Map<String, dynamic>>> filterRawHeartRateVariability({
  required List<dynamic> rawEntries,
  required DateTimeRange range,
}) {
  final Map<String, List<Map<String, dynamic>>> filtered = {};

  for (var entry in rawEntries) {
    if (entry is Map<String, dynamic>) {
      for (var permissionKey in entry.keys) {
        final records = entry[permissionKey];
        if (records is List) {
          final List<Map<String, dynamic>> matching = records.where((record) {
            final timeEpochMs = record['timeEpochMs'];
            if (timeEpochMs is int) {
              final time = DateTime.fromMillisecondsSinceEpoch(timeEpochMs);
              return time.isAfter(range.start) && time.isBefore(range.end);
            }
            return false;
          }).cast<Map<String, dynamic>>().toList();

          matching.sort((a, b) {
            final t1 = DateTime.fromMillisecondsSinceEpoch(a['timeEpochMs']);
            final t2 = DateTime.fromMillisecondsSinceEpoch(b['timeEpochMs']);
            return t1.compareTo(t2);
          });

          if (matching.isNotEmpty) {
            filtered[permissionKey] = matching;
          }
        }
      }
    }
  }

  return filtered;
}
