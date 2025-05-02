// lib/constants/metric_mapper.dart

import 'dart:io';
import 'metrics.dart';

String getMetricLabel(HealthMetric metric) {
  switch (metric) {
    case HealthMetric.heartRate:
      return 'Heart Rate';
    case HealthMetric.skinTemperature:
      return 'Skin Temperature';
  }
}

String? mapMetricToPermission(HealthMetric metric) {
  if (Platform.isAndroid) {
    switch (metric) {
      case HealthMetric.heartRate:
        return 'android.permission.health.READ_HEART_RATE';
      case HealthMetric.skinTemperature:
        return 'android.permission.health.READ_SKIN_TEMPERATURE';
    }
  } else {
    switch (metric) {
      case HealthMetric.heartRate:
        return 'HKQuantityTypeIdentifierHeartRate';
      case HealthMetric.skinTemperature:
        return 'HKQuantityTypeIdentifierBodyTemperature';
    }
  }
  return null;
}
