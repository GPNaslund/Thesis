// NEW FILE: lib/services/metric_filters/heart_rate.dart

import 'package:flutter/material.dart';

List<dynamic> filterHeartRateEntries(List<dynamic> data, DateTimeRange range) {
  return data.where((entry) {
    try {
      final timestamp = DateTime.parse(entry['effective_time_frame']['date_time']);
      return timestamp.isAfter(range.start) && timestamp.isBefore(range.end);
    } catch (_) {
      return false;
    }
  }).toList();
}