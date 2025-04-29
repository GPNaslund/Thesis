// lib/constants/metric_mapper.dart

import 'dart:io';
import 'metrics.dart';

String? mapMetricToPermission(HealthMetric metric) {
  if (Platform.isAndroid) {
    switch (metric) {
      case HealthMetric.heartRate:
        return 'android.permission.health.READ_HEART_RATE';
    }
  } else {
    switch (metric) {
      case HealthMetric.heartRate:
        return 'HKQuantityTypeIdentifierHeartRate';
    }
  }
}
